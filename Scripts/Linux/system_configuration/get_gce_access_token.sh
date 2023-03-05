#!/bin/bash

# Get access token for accessing Google APIs
# This will first attempt to fetch the token via ADC, and if ADC are not specified, from VM instance metadata
# Returns either a token, or "" if failed

get_gce_access_token () {

    if [ -z "${GOOGLE_APPLICATION_CREDENTIALS}" ]; then

        # No ADC have been specified; let's attempt to get access token from VM metadata

        local METADATA
        METADATA="http://metadata.google.internal/computeMetadata/v1"

        # Fetch access token for google APIs
        local ACCESS_TOKEN
        ACCESS_TOKEN=$({ curl --silent -H 'Metadata-Flavor: Google' "${METADATA}/instance/service-accounts/default/token" || return ; } | { cut -d '"' -f 4 || return ; }) || return
        #Typical response format from curl call:
        #   {
        #     "name": "projects/<id>/secrets/<name>/versions/1",
        #     "payload": {
        #       "data": "<base64 encoded string>"
        #     }
        #   }

        echo -n "${ACCESS_TOKEN}"
    else
        # Construct JWT from ADC
        # Reference: https://gist.github.com/ryu1kn/c76aed0af8728f659730d9c26c9ee0ed

        local ADC_PRIVATE_KEY
        ADC_PRIVATE_KEY=$(cat "${GOOGLE_APPLICATION_CREDENTIALS}" | jq -r ".private_key") || return

        local ACCESS_TOKEN_HEADER
        ACCESS_TOKEN_HEADER='{"alg":"RS256","typ":"JWT"}'

        local ACCESS_TOKEN_HEADER_BASE64URL
        ACCESS_TOKEN_HEADER_BASE64URL=$({ echo -n "${ACCESS_TOKEN_HEADER}" || return ; } | { base64 -w0 || return ; } | { tr '/+' '_-' || return ; } | { tr -d '=' || return ; }) || return

        local ACCESS_TOKEN_ISSUER
        ACCESS_TOKEN_ISSUER=$(cat "${GOOGLE_APPLICATION_CREDENTIALS}" | jq -r ".client_email") || return

        local ACCESS_TOKEN_SCOPE
        ACCESS_TOKEN_SCOPE="https://www.googleapis.com/auth/cloud-platform"

        local ACCESS_TOKEN_START_DATE
        ACCESS_TOKEN_START_DATE=$(date +%s)

        local ACCESS_TOKEN_DURATION
        ACCESS_TOKEN_DURATION=3600

        local ACCESS_TOKEN_END_DATE
        ACCESS_TOKEN_END_DATE=$(("${ACCESS_TOKEN_START_DATE}" + "${ACCESS_TOKEN_DURATION}"))

        local ACCESS_TOKEN_CLAIM
        ACCESS_TOKEN_CLAIM=$(echo "
            {
                \"iss\": \"${ACCESS_TOKEN_ISSUER}\",
                \"scope\": \"${ACCESS_TOKEN_SCOPE}\",
                \"aud\": \"https://www.googleapis.com/oauth2/v4/token\",
                \"exp\": \""${ACCESS_TOKEN_END_DATE}"\",
                \"iat\": \""${ACCESS_TOKEN_START_DATE}"\"
            }
            " | jq -c .) || return

        local ACCESS_TOKEN_CLAIM_BASE64URL
        ACCESS_TOKEN_CLAIM_BASE64URL=$({ echo -n "${ACCESS_TOKEN_CLAIM}" || return ; } | { base64 -w0 || return ; } | { tr '/+' '_-' || return ; } | { tr -d '=' || return ; }) || return

        local ACCESS_TOKEN_HEADER_AND_CLAIM_BASE64URL
        ACCESS_TOKEN_HEADER_AND_CLAIM_BASE64URL="${ACCESS_TOKEN_HEADER_BASE64URL}.${ACCESS_TOKEN_CLAIM_BASE64URL}"

        local ACCESS_TOKEN_SIGNATURE_BASE64URL
        ACCESS_TOKEN_SIGNATURE_BASE64URL=$({ openssl dgst -sha256 -sign <(echo -n "${ADC_PRIVATE_KEY}") <(echo -n "${ACCESS_TOKEN_HEADER_AND_CLAIM_BASE64URL}") || return ; } | { base64 -w0 || return ; } | { tr '/+' '_-' || return ; } | { tr -d '=' || return ; }) || return

        local ACCESS_TOKEN_REQUEST_BASE64URL
        ACCESS_TOKEN_REQUEST_BASE64URL="${ACCESS_TOKEN_HEADER_AND_CLAIM_BASE64URL}.${ACCESS_TOKEN_SIGNATURE_BASE64URL}"

#        echo "Access Token Header (base64url): ${ACCESS_TOKEN_HEADER_BASE64URL}"
#        echo "Access Token Claim (base64url): ${ACCESS_TOKEN_CLAIM_BASE64URL}"
#        echo "Access Token Header and Claim (base64url): ${ACCESS_TOKEN_HEADER_AND_CLAIM_BASE64URL}"
#        echo "Access Token Signature (base64url): ${ACCESS_TOKEN_SIGNATURE_BASE64URL}"
#        echo "Access Token Request (base64url): ${ACCESS_TOKEN_REQUEST}"

        # Request an Access Token with provided issuer ID
        local ACCESS_TOKEN
        ACCESS_TOKEN=$({ curl -s -X POST "https://www.googleapis.com/oauth2/v4/token" \
            --data-urlencode 'grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer' \
            --data-urlencode "assertion=${ACCESS_TOKEN_REQUEST_BASE64URL}" || return ; } \
            | { jq -r ".access_token" || return ; }) \
        || return

        echo -n "${ACCESS_TOKEN}"
    fi
}
