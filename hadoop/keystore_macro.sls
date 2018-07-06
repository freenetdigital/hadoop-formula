{%- from 'hadoop/settings.sls' import hadoop with context %}

{% macro keystore(username) -%}
import-cert:
  cmd.run:
    - name: export RANDFILE=/root/.rnd; openssl pkcs12 -export -in {{ hadoop.cert_pub_path}}/{{ hadoop.cert_name }} -inkey {{ hadoop.cert_priv_path }}/{{ hadoop.cert_name }}.key -out /home/{{username}}/.keystore.p12 -password pass:{{ hadoop.keystore_pass }}
    - creates: /home/{{username}}/.keystore.p12

create-jvm-keystore:
  cmd.run:
    - name: {{ salt['pillar.get']('java_home', '/usr/lib/java')}}/bin/keytool -importkeystore -srckeystore /home/{{username}}/.keystore.p12 -destkeystore /home/{{username}}/.keystore -srcstoretype pkcs12 -deststorepass {{ hadoop.keystore_pass }} -srcstorepass {{ hadoop.keystore_pass }}
    - creates: /home/{{username}}/.keystore

set-cert-alias:
  cmd.run:
    - name: {{ salt['pillar.get']('java_home', '/usr/lib/java')}}/bin/keytool -changealias -alias '1' -destalias '{{ grains['fqdn'] }}' -keystore /home/{{username}}/.keystore -storepass {{ hadoop.keystore_pass }}
    - onchanges:
      - cmd: create-jvm-keystore

/home/{{username}}/.keystore:
  file.managed:
    - user: {{ username }}
    - group: {{ username }}
    - mode: "400"
    - replace: False

/home/{{username}}/.keystore.p12:
  file.managed:
    - user: {{ username }}
    - group: {{ username }}
    - mode: "400"
    - replace: False

{{ hadoop.alt_conf }}/ssl-server.xml:
  file.managed:
    - source: salt://hadoop/conf/ssl-server.xml
    - user: {{ username }}
    - group: {{ username }}
    - mode: "400"
    - context:
      username={{username}}
      keystore_pass={{keystore_pass}}

{{ hadoop.alt_conf }}/ssl-client.xml:
  file.managed:
    - source: salt://hadoop/conf/ssl-client.xml
    - user: {{ username }}
    - group: {{ username }}
    - mode: "400"
    - context:
      username: {{username}}
      keystore_pass: {{keystore_pass}}

{%- endmacro %}
