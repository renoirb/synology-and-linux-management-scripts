#!/usr/bin/env bash

##
## Be your own Certification Authority.
##
## Create a self-signed TLS CA certicate
##
## Originally written: 2016-04-29
## See: https://gist.github.com/renoirb/de501adc1164e9fec47b257d6ee2a2ff
## File: newca.sh
##
## Renoir Boulanger <contribs@renoirboulanger.com>
##

##
## Related:
## - https://www.openssl.org/docs/manmaster/apps/openssl.html#PASS-PHRASE-ARGUMENTS
## - http://stackoverflow.com/questions/34440463/openssl-subject-does-not-start-with-in-os-x-application
## - https://www.openssl.org/docs/manmaster/apps/genrsa.html
## - https://www.openssl.org/docs/manmaster/apps/req.html
## - https://www.openssl.org/docs/manmaster/apps/ca.html
## - https://jamielinux.com/docs/openssl-certificate-authority/create-the-root-pair.html
##
## Credit: Some notes are taken directly from jamielinux.com
##
##
## Acting as a certificate authority (CA) means dealing with cryptographic pairs of
## private keys and public certificates. The very first cryptographic pair we’ll create
## is the root pair. This consists of the root key (cakey.pem) and root certificate
## (cacert.pem). This pair forms the identity of your CA.
##
## Typically, the root CA does not sign server or client certificates directly.
## The root CA is only ever used to create one or more intermediate CAs,
## which are trusted by the root CA to sign certificates on their behalf.
## This is best practice. It allows the root key to be kept offline
## and unused as much as possible, as any compromise of the root key is disastrous.
##


set -e


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
  # export is required here because we
  # will use openssl -passin/-passout options
  # and this needs to be exported
  export KEY_SECRET="thisisnotsecret"
fi



SUBJ_LINE=$(echo "/C=US/ST=NY/L=New-York/O=${SUBJ_O}/OU=${SUBJ_OU}/CN=${SUBJ_CN}/emailAddress=${SUBJ_EMAIL}" | sed 's/\s/+/g')

if [[ ${SHOW_DETAILS} == "1" ]]; then
  echo ${SUBJ_LINE}
fi



declare -A paths
paths['key']="${CATOP}/private/ca.key"
paths['insecure_key']="${CATOP}/private/ca.insecure.key"
paths['req']="${CATOP}/req/ca.csr"
paths['cert']="${CATOP}/certs/ca.pem"
paths['serial']="${CATOP}/serial"

declare -A human_explanation
human_explanation['key']="Certificate private key, passphrase is ${KEY_SECRET}"
human_explanation['insecure_key']="Certificate private key, not passphrase protected"
human_explanation['req']="Certificate request. Might not be useful when we use self-signed"
human_explanation['cert']="Certificate"
human_explanation['serial']=""

# Add to this array what gotten created
declare -a created



mkdir -p ${CATOP}/certs

chmod 700 ${CATOP}/certs

mkdir -p ${CATOP}/newcerts

chmod 700 ${CATOP}/newcerts

mkdir -p ${CATOP}/crl

mkdir -p ${CATOP}/req

mkdir -p ${CATOP}/private

touch ${CATOP}/index.txt



GENRSA="\
openssl genrsa -aes256 \
               -passout env:KEY_SECRET \
               -out ${paths['key']} 4096"

if [[ ${SHOW_COMMANDS} == "1" ]]; then
  echo ${GENRSA}
fi

if [[ ! -f ${paths['key']} ]]; then
  ${GENRSA} && \
  created=(${created[@]} 'key')
fi



MAKE_INSECURE_KEY="openssl rsa -passin env:KEY_SECRET -in ${paths['key']} -out ${paths['insecure_key']}"
if [[ ${SHOW_COMMANDS} == "1" ]]; then
  echo ${MAKE_INSECURE_KEY}
fi

if [[ ! -f ${paths['insecure_key']} ]]; then
  ${MAKE_INSECURE_KEY} && \
  created=(${created[@]} 'insecure_key')
fi



REQUEST="\
openssl req -new -sha256 \
            -passin env:KEY_SECRET \
            -key ${paths['key']} \
            -out ${paths['req']} \
            -subj ${SUBJ_LINE}"

if [[ ${SHOW_COMMANDS} == "1" ]]; then
  echo ${REQUEST}
fi

if [[ ! -f ${paths['req']} ]]; then
  ${REQUEST} && \
  created=(${created[@]} 'req')
fi



REVIEW_REQUEST="openssl req -noout -text -in ${paths['req']}"

if [[ ${SHOW_COMMANDS} == "1" ]]; then
  echo ${REVIEW_REQUEST}
fi

if [[ ! -f ${paths['req']}.txt ]]; then
  ${REVIEW_REQUEST} > ${paths['req']}.txt
fi



## Contrary to what [1] shows, instead of using "req", we will be
## using "ca". But the outcome is the same, except that the Issuer
## (or subject) is using our identity.
## [1]: https://jamielinux.com/docs/openssl-certificate-authority/create-the-root-pair.html
CREATE_CA="\
openssl ca  -create_serial -batch -selfsign \
            -passin env:KEY_SECRET \
            -out ${paths['cert']} \
            -extensions v3_ca \
            -keyfile ${paths['key']} \
            -infiles ${paths['req']}"

if [[ ${SHOW_COMMANDS} == "1" ]]; then
  echo ${CREATE_CA}
fi

if [[ ! -f ${paths['cert']} ]]; then
  ${CREATE_CA} && \
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
