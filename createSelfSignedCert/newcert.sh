#!/usr/bin/env bash

##
## Be your own Certification Authority.
##
## Create a self-signed TLS Server certicate
##
## Originally written: 2016-04-29
## See: https://gist.github.com/renoirb/de501adc1164e9fec47b257d6ee2a2ff
## File: newcert.sh
##
## Renoir Boulanger <contribs@renoirboulanger.com>
##


set -e


##
## Related
## - https://www.openssl.org/docs/manmaster/apps/req.html
## - http://httpd.apache.org/docs/2.0/ssl/ssl_faq.html#verify
##
## This is heavily following conventions from /usr/lib/ssl/misc/CA.sh
##
## # CSR
## When documentation refers to a CSR, here they are refered as Request.
## They are stored in /etc/ssl/CA/*req.pem.
## If we wanted to have them signed by a comercial Certificate Authority ("CA"),
## that's what we would send them.
## Otherwise we don't really need them if we are signing them ourselves.
##


## Add optional shell options
for i in "$@"
do
case $i in
    --show-details)
    SHOW_DETAILS=1
    shift # past argument with no value
    ;;
    --show-commands)
    SHOW_COMMANDS=1
    shift # past argument with no value
    ;;
    *)
    # unknown option
    ;;
esac
done


if [[ -z "${SLUG}" ]]; then
  SLUG="foo"
fi

if [[ -z "${CATOP}" ]]; then
  CATOP="./ca"
fi

if [[ -z "${SUBJ_CN}" ]]; then
  # Only domain names
  SUBJ_CN="noc.sandbox.example.org"
fi

if [[ -z "${SUBJ_EMAIL}" ]]; then
  # Only valid email
  SUBJ_EMAIL="root@${SUBJ_CN}"
fi

if [[ -z "${SUBJ_OU}" ]]; then
  # Please no spaces!
  SUBJ_OU="ExampleDept"
fi

if [[ -z "${SUBJ_O}" ]]; then
  # Please no spaces!
  SUBJ_O="ExampleOrg"
fi

if [[ -z "${KEY_SECRET}" ]]; then
  export KEY_SECRET="thisisnotsecret"
fi


SUBJ_LINE=$(echo "/C=US/ST=NY/L=New-York/O=${SUBJ_O}/OU=${SUBJ_OU}/CN=${SUBJ_CN}/emailAddress=${SUBJ_EMAIL}" | sed 's/\s/+/g')

if [[ ${SHOW_DETAILS} == "1" ]]; then
  echo ${SUBJ_LINE}
fi



##
## Create SSL certificate alternate names
## See:
##  - http://apetec.com/support/GenerateSAN-CSR.htm
##  - http://security.stackexchange.com/questions/74345/provide-subjectaltname-to-openssl-directly-on-command-line#91556
SUBJ_SAN="\n\n[ SAN ]\nsubjectAltName=DNS:${SLUG}.example.org,DNS:www.${SUBJ_CN}\n"
TMP_CONFIG="$(mktemp)"
cat /etc/ssl/openssl.cnf > ${TMP_CONFIG}
printf "${SUBJ_SAN}" >> ${TMP_CONFIG}



declare -A paths
paths['key']="${CATOP}/private/${SLUG}.key"
paths['insecure_key']="${CATOP}/private/${SLUG}.insecure.key"
paths['req']="${CATOP}/req/${SLUG}.csr"
paths['cert']="${CATOP}/certs/${SLUG}.pem"



declare -A human_explanation
human_explanation['key']="Certificate private key for ${SLUG}, passphrase is ${KEY_SECRET}"
human_explanation['insecure_key']="Certificate private key for ${SLUG}, not passphrase protected"
human_explanation['req']="Certificate request for ${SLUG}, as ${SUBJ_CN}. Might not be useful when we use self-signed"
human_explanation['cert']="Certificate for ${SLUG}, as ${SUBJ_CN}."



# Add to this array what gotten created
declare -a created



## This generates two things. A CSR (...req.pem),
## and a Private key (...key.pem). All in one command.
REQUEST="\
openssl req -new \
            -passout env:KEY_SECRET
            -keyout ${paths['key']} \
            -out ${paths['req']} \
            -subj ${SUBJ_LINE} \
            -reqexts SAN \
            -config ${TMP_CONFIG}"

if [[ ${SHOW_DETAILS} == "1" ]]; then
  echo "${REQUEST}"
fi

if [[ ! -f ${paths['req']} ]]; then
  (${REQUEST}) && \
  created=(${created[@]} 'req' 'key')
fi



MAKE_INSECURE_KEY="openssl rsa -passin env:KEY_SECRET -in ${paths['key']} -out ${paths['insecure_key']}"
if [[ ${SHOW_COMMANDS} == "1" ]]; then
  echo ${MAKE_INSECURE_KEY}
fi

if [[ ! -f ${paths['insecure_key']} ]]; then
  ${MAKE_INSECURE_KEY} && \
  created=(${created[@]} 'insecure_key')
fi



##
## We won't write a text file with the key details.
##
## To review the key, you can do it like this:
## Note: You'll need to remember password $KEY_SECRET
##
##       openssl rsa -noout -text -in /path/to/fookey.pem
##



REVIEW_REQUEST="openssl req -noout -text -in ${paths['req']}"

if [[ ${SHOW_COMMANDS} == "1" ]]; then
  echo ${REVIEW_REQUEST}
fi

if [[ ! -f ${paths['req']}.txt ]]; then
  ${REVIEW_REQUEST} > ${paths['req']}.txt
fi



CERTIFICATE="\
openssl x509 -req \
             -passin env:KEY_SECRET \
             -extensions SAN \
             -extfile ${TMP_CONFIG} \
             -in ${paths['req']} \
             -signkey ${paths['key']} \
             -out ${paths['cert']}"

if [[ ${SHOW_DETAILS} == "1" ]]; then
  echo ${CERTIFICATE}
fi

if [[ ! -f ${paths['cert']} ]]; then
  ${CERTIFICATE} && \
  created=(${created[@]} 'cert')
fi



REVIEW_CERT="openssl x509 -noout -text -in ${paths['cert']}"

if [[ ${SHOW_COMMANDS} == "1" ]]; then
  echo ${REVIEW_CERT}
fi

if [[ ! -f ${paths['cert']}.txt ]]; then
  ${REVIEW_CERT} > ${paths['cert']}.txt
fi



if [[ ${SHOW_COMMANDS} == "1" ]]; then
  if [[ ${#created[@]} -gt 0 ]]; then
    echo "New files created:"
    for k in ${created[@]}; do
      echo "  - ${paths[${k}]}: ${human_explanation[${k}]}"
    done
  else
    echo 'No files created'
  fi
fi



rm ${TMP_CONFIG}
