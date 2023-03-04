{#
## Be your own Certification Authority.
##
## Create a self-signed TLS CA certicate
##
## @TODO Migrate
##

##
## Be your own Certification Authority.
##
## Create a self-signed TLS CA certicate
##
## Originally written: 2016-04-29
## See: https://gist.github.com/renoirb/de501adc1164e9fec47b257d6ee2a2ff
## File: openssl.sls
##
## Renoir Boulanger <contribs@renoirboulanger.com>
##
#}

{%- set parent_hostname = salt['pillar.get']('local:parent_hostname', 'localhost.local') -%}
{%- set CAtop = './ca' -%}
{%- set CA_SECRET = salt['pillar.get']('local:ca_secret', 'Fooo') -%}

{%- set fqdn = 'noc.' ~  parent_hostname -%}
{%- set SUBJ_EMAIL = 'team-devops@example.org' %}

## We cannot set SUBJ_OU, SUBJ_O with spaces here
## because newca.sh and newcert.sh would break.
{%- set SUBJ_O = 'ExampleOrg' -%}
{%- set SUBJ_OU = 'ExampleDept' %}


Install OpenSSL:
  pkg.installed:
    - name: openssl


Backup /etc/ssl/openssl.cnf:
  cmd.run:
    - name: cp /etc/ssl/openssl.cnf /etc/ssl/openssl.cnf.orig
    - creates: /etc/ssl/openssl.cnf.orig


Rewrite /etc/ssl/openssl.cnf:
  file.managed:
    - name: /etc/ssl/openssl.cnf
    - source: salt://openssl/files/openssl.cnf.jinja
    - template: jinja
    - context:
        CATOP: {{ CAtop }}
        SUBJ_CN: {{ fqdn }}
        SUBJ_EMAIL: {{ SUBJ_EMAIL }}
        SUBJ_O: {{ SUBJ_O }}
        SUBJ_OU: {{ SUBJ_OU }}


# Follow conventions from /etc/ssl/openssl.conf
# we can change those later if we don't like the mention
# demoCA in the paths.
Ensure OpenSSL CA exists:
  cmd.script:
    - cwd: /etc/ssl
    - unless: test -f {{ CAtop }}/private/ca.key
    - source: salt://openssl/scripts/newca.sh
    ### If you want to see more in the output
    #- SHOW_DETAILS: "1"
    #- SHOW_COMMANDS: "1"
    - env:
      - KEY_SECRET: {{ CA_SECRET }}
      - CATOP: {{ CAtop }}
      - SUBJ_CN: {{ fqdn }}
      - SUBJ_EMAIL: {{ SUBJ_EMAIL }}
      - SUBJ_O: {{ SUBJ_O }}
      - SUBJ_OU: {{ SUBJ_OU }}


Ensure file ownership are applied:
  cmd.wait:
    - cwd: /etc/ssl
    - template: jinja
    - watch:
      - cmd: Ensure OpenSSL CA exists
    - name: |
        chmod -R 700 {{ CAtop }}/private && \
        chmod 400 {{ CAtop }}/private/ca.key

