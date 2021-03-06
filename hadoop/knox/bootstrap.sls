{%- from 'hadoop/settings.sls' import hadoop with context %}
{%- from 'hadoop/knox/settings.sls' import knox with context %}
  
{%- set username = 'knox' %}
{%- set uid = hadoop.users[username] %}


knox-data-security:
  file.directory:
    - name: {{ knox.install_dir }}/data/security
    - user: {{ username }}
    - group: {{ username }}

knox-data-security-keystores:
  file.directory:
    - name: {{ knox.install_dir }}/data/security/keystores
    - user: {{ username }}
    - group: {{ username }}

{% if knox.cert_name %}
import-cert:
  cmd.run:
    - name: export RANDFILE=/root/.rnd; openssl pkcs12 -export -in {{ knox.cert_pub_path}}/{{ knox.cert_name }} -inkey {{ knox.cert_priv_path }}/{{ knox.cert_name }}.key -out {{ knox.install_dir }}/data/security/keystores/knox.p12 -password pass:{{ knox.master_pass }}
    - creates: {{ knox.install_dir }}/data/security/keystores/knox.p12

create-jvm-keystore:
  cmd.run:
    - name: {{ salt['pillar.get']('java_home', '/usr/lib/java')}}/bin/keytool -importkeystore -srckeystore {{ knox.install_dir }}/data/security/keystores/knox.p12 -destkeystore {{ knox.install_dir }}/data/security/keystores/gateway.jks -srcstoretype pkcs12 -deststorepass {{ knox.master_pass }} -srcstorepass {{ knox.master_pass }}
    - creates: {{ knox.install_dir }}/data/security/keystores/gateway.jks

set-cert-alias: 
  cmd.run:
    - name: {{ salt['pillar.get']('java_home', '/usr/lib/java')}}/bin/keytool -changealias -alias '1' -destalias 'gateway-identity' -keystore {{ knox.install_dir }}/data/security/keystores/gateway.jks -storepass {{ knox.master_pass }}
    - onchanges:
      - cmd: create-jvm-keystore

{{ knox.install_dir }}/data/security/keystores/gateway.jks:
  file.managed:
    - replace: False
    - user: {{ username }}
    - group: {{ username }}

#create-gateway-passphrase-for-cert:
#  cmd.run:
#    - name: {{ knox.install_dir }}/bin/knoxcli.sh create-alias gateway-identity-passphrase --value {{ knox.master_pass }}

{% else %}

only-localcert:
  test.show_notification:
    - name: No certificate was configured 
    - text: "No certificate was configured using knox.cert_name, local demo cert will be used by knox on startup, See: http://knox.apache.org/books/knox-1-0-0/user-guide.html#Keystores"

{% endif %}

{% if knox.master_enc %}
{{ knox.install_dir}}/data/security/master:
  file.managed:
    - user: {{ username }}
    - group: {{ username }}
    - mode: 600
    - contents_pillar: knox:master_enc 
    - allow_empty: False
{% else %}
{% if not salt['file.file_exists'](knox.install_dir + '/data/security/master') %} 
need-manual-master-secret:
  test.show_notification:
    - name: No master secrete was defined.
    - text: "No master secrete was defined. Use 'knoxcli.sh create-master' to create one. Use this value for the var: knox.master_enc "
{% endif %} 
{% endif %} 
