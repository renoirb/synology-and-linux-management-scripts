# Running inlined python from a shell script

See source
https://gist.github.com/renoirb/361e4e2817341db4be03b8f667338d47#file-mixing_bash_python-sh

```sh
ENDPOINT=https://api.enlightns.com
NAME=example.enlightns.info

set -e

command -v http >/dev/null 2>&1 || { echo >&2 "HTTPie Python CLI is required for this script to work. Aborting."; exit 1; }
command -v python >/dev/null 2>&1 || { echo >&2 "Python is required for this script to work. Aborting."; exit 1; }

if [[ -z ${EMAIL} ]]; then
  (>&2 echo "Missing EMAIL shell environment variable"; exit 1)
fi



function extract_data_from_json() {
    PYTHON_WHAT=$1 PYTHON_INPUT=$2 python - <<END
import sys, json, os;
selector = os.environ['PYTHON_WHAT']
json_data = json.loads(os.environ['PYTHON_INPUT'])
print(json_data[selector])
END
}



if [[ -z ${ENLIGHTNS_AUTHORIZATION_TOKEN} ]]; then

  if [[ -z ${ENLIGHTNS_PASSWORD} ]]; then
    read -p "EnlightNS account password for ${EMAIL}? " ENLIGHTNS_PASSWORD
  fi

  AUTH_REQUEST_CREDS="{\"email\": \"${EMAIL}\", \"password\": \"${ENLIGHTNS_PASSWORD}\"}"

## See enlightns docs
## http://enlightns-docs.readthedocs.io/en/latest/
##
## Get Authentication token
##
## echo '{"email": "self@example.org", "password": "foobar"}' |  http --verbose POST https://api.enlightns.com/api-token-auth/ Content-Type:application/json
##
## Expected outcome
##
## {"token": "JWT 0000.REDACTED.REDACTED-AGAIN"}
##

AUTH_REQUEST_TOKEN=$(echo $AUTH_REQUEST_CREDS|http -b POST ${ENDPOINT}/api-token-auth/ Content-Type:application/json)
TOKEN=$(extract_data_from_json "token" "${AUTH_REQUEST_TOKEN}")

(cat <<- STATUS
---------------------------------------------------------------
Authentication to ${ENDPOINT} successful
subsequent requests will be made with the following HTTP header
    Authorization: ${TOKEN}
To prefent re-authenticating, use ENLIGHTNS_AUTHORIZATION_TOKEN
shell environment variable.
---------------------------------------------------------------
STATUS
)
ENLIGHTNS_AUTHORIZATION_TOKEN=$TOKEN
fi

## UNFINISHED here.
http --verbose GET ${ENDPOINT}/user/record/ Content-Type:application/json "Authorization: ${ENLIGHTNS_AUTHORIZATION_TOKEN}"

##
## Output would look like
##
#HTTP/1.1 200 OK
#Allow: GET, HEAD, OPTIONS
#Connection: keep-alive
#Content-Language: en
#Content-Type: application/json
#Date: Thu, 27 Apr 2017 17:36:21 GMT
#Server: nginx
#Transfer-Encoding: chunked
#Vary: Accept, Accept-Language, Cookie
#X-Frame-Options: DENY
#
#[
#    {
#        "active": true,
#        "auth": null,
#        "content": "0.0.0.0",
#        "id": 11,
#        "is_free": false,
#        "name": "example.enlightns.info",
#        "owner": "self@example.org",
#        "ttl": 300,
#        "type": "A"
#    }
#]
```
