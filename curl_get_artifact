#!/usr/bin/env bash

##
## This script was created to help me fetch an artifact on a GitLab instance.
##
## Originally written: 2017
## See: https://gist.github.com/renoirb/361e4e2817341db4be03b8f667338d47#file-get_artifacts-sh
## Time Spent: ~
##
## Renoir Boulanger <contribs@renoirboulanger.com>
##

#set -xue
set -ue


################################################################################
# MUST HAVE Arguments and their name. Everything stops if one here is missing.

argEndpointBaseUrl="${1:?Missing first argument}"


################################################################################
# Functions. That could be distributed and re-used.

must_command_exist()
{
    command -v "${1}" >/dev/null 2>&1 || { echo >&2 "Command ${1} must exist."; exit 1; }
}

# https://stackoverflow.com/questions/11362250/in-bash-how-do-i-test-if-a-variable-is-defined-in-u-mode#answer-19874099
is_var_defined()
{
    if [ $# -ne 1 ]
    then
        echo "Expected exactly one argument: variable name as string, e.g., 'my_var'"
        exit 1
    fi
    # Tricky.  Since Bash option 'set -u' may be enabled, we cannot directly test if a variable
    # is defined with this construct: [ ! -z "$var" ].  Instead, we must use default value
    # substitution with this construct: [ ! -z "${var:-}" ].  Normally, a default value follows the
    # operator ':-', but here we leave it blank for empty (null) string.  Finally, we need to
    # substitute the text from $1 as 'var'.  This is not allowed directly in Bash with this
    # construct: [ ! -z "${$1:-}" ].  We need to use indirection with eval operator.
    # Example: $1="var"
    # Expansion for eval operator: "[ ! -z \${$1:-} ]" -> "[ ! -z \${var:-} ]"
    # Code  execute: [ ! -z ${var:-} ]
    eval "[ ! -z \${$1:-} ]"
    return $?  # Pedantic.
}

must_var_defined()
{
    is_var_defined "$1" || { echo >&2 "Variable ${1} is not defined and must exist."; exit 1; }
}


################################################################################
# Sanity checks before executing anything else.

must_command_exist jq
must_command_exist curl

must_var_defined PRIVATE_TOKEN


################################################################################
# Parametrized HTTP API URLs.

TOKEN=$PRIVATE_TOKEN


################################################################################
# https://gitlab.msu.edu/help/user/project/pipelines/job_artifacts.md
# https://docs.gitlab.com/ee/api/jobs.html

## e.g. curl -sSL -v 'https://gitlab.example.org:5443/Foo/bar/-/jobs/artifacts/branchName/raw/dist/dist.zip?job=Release' -H "PRIVATE-TOKEN: $PRIVATE_TOKEN"
#BRANCHNAME=branchName
#DIRNAME=dist
#FILE=dist.zip
#JOBNAME=Release
#endpoint="/-/jobs/artifacts/${BRANCHNAME}/raw/${DIRNAME}/${FILE}?job=${JOBNAME}"

## IN PROGRESS

# https://docs.gitlab.com/ee/api/jobs.html#list-project-jobs
## e.g. curl -sSL -v --H "PRIVATE-TOKEN: 111" 'https://gitlab.example.com/api/v4/projects/1/jobs?scope[]=pending&scope[]=running'
endpoint="/api/v4/projects/373/jobs?scope[]=success"

# https://gitlab.example.org:5443/Foo/bar/-/jobs/artifacts/branchName/browse?job=Release
# https://gitlab.example.org:5443/Foo/bar/-/jobs/11377/artifacts/browse

## e.g. /builds/artifacts/master/browse?job=coverage
#endpoint="/builds/artifacts/${BRANCHNAME}/browse?job=${JOBNAME}"




URL=${argEndpointBaseUrl}
URL+=${endpoint}
echo $URL

curl -gsSL -v "${URL}" -H "PRIVATE-TOKEN: $TOKEN"
