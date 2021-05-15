#!/bin/bash

if [ $# -eq 1 ]; then

	# if `docker run` only has one arguments, we assume user is running alternate command like `bash` to inspect the image
	exec "$@"

else

	# if java home is defined, use it
	JAVA_BIN="java"
	if [ "$JAVA_HOME" ]; then
		JAVA_BIN="$JAVA_HOME/bin/java"
	fi

	exec $JAVA_BIN $JAVA_OPTS -jar /usr/share/jenkins/swarm-client.jar "$@"

fi
