#!/bin/bash

# Some plugins do not lock the versions of their dependencies, but set them to 'latest'.
# In order to enable repeatability of building the Dockerfile, we want to manually lock all plugin
#  versions we use. This script accomplishes that.

JENKINS_IMAGE=`head -n 1 Dockerfile | sed 's/FROM //'`

HOST_WORKDIR=`realpath .`

# Run jenkins-plugin-cli and retrieve a full list of plugins including dependencies
#
# Note that we do not specify `--latest false` when invoking jenkins-plugin-cli.
# This is because the '--latest false' logic will not update dependencies:
#  if there first is a dependency a -> b (v1.2) -> c (v1.1),
#  and later on a dependency d -> b (v1.3) -> c (v1.2),
#  then the `--latest false` output will record c at v1.1 (and ignore that there is a v1.2 dependency)
#  and therefore the flattened output will be inconsistent.
#
# To work around this, we expect that plugins.txt contents have been bumped recently,
#  and freeze all plugin versions at what is currently latest.

docker run --rm --name jenkins --volume $HOST_WORKDIR:/workdir:ro $JENKINS_IMAGE jenkins-plugin-cli --plugin-file /workdir/plugins.txt --list >list_stdout.txt 2>list_stderr.txt
LIST_EXITCODE=$?
LIST_STDOUT=`cat list_stdout.txt`
LIST_STDERR=`cat list_stderr.txt`
rm list_stdout.txt list_stderr.txt

if [[ $LIST_EXITCODE -ne 0 ]]; then

  # Something went wrong when resolving depedencies; print error messages

  echo "$LIST_STDERR"
  exit 1

else

  # Success; stdout will contain a list of all plugins including dependencies on the following format:
  #
  # ...
  # Resulting plugin list:
  # durable-task 1.35
  # git 4.4.5
  # ...
  # Done
  #
  # so transform that into:
  #
  # durable-task:1.35
  # git-4.4.5
  # ...

  PLUGINS_WITH_DEPENDENCIES=`echo "$LIST_STDOUT" | sed -n '1,/Resulting plugin list:/d;/Done/q;s/ /:/g;p'`

  # Write plugin list including dependencies to text file

  echo "$PLUGINS_WITH_DEPENDENCIES" > plugins-with-dependencies.txt

  echo "Done"
  exit 0

fi

