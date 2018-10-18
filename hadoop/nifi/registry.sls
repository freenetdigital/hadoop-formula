{%- from 'hadoop/settings.sls' import hadoop with context %}
{%- from 'hadoop/nifi/settings.sls' import nifi with context %}
{%- from 'hadoop/user_macro.sls' import hadoop_user with context %}
{%- from 'hadoop/keystore_macro.sls' import keystore with context %}

include:
  - hadoop.systemd
  
{%- set username = 'nifi' %}
{%- set uid = hadoop.users[username] %}

{{ hadoop_user(username, uid, ssh=False) }}

nifi-reg-directory:
  file.directory:
    - name: {{ nifi.reg_install_dir }}
    - user: {{ username }}

nifi-reg-data-directory:
  file.directory:
    - name: {{ nifi.data_dir }}
    - user: {{ username }}

nifi-conf-directory:
  file.directory:
    - name: /etc/nifi-registry
    - user: {{ username }}

nifi-reg-directory-symlink:
  file.symlink:
    - target: {{ nifi.reg_install_dir }}
    - name: {{ nifi.reg_dir }}

download-nifi-reg-archive:
  cmd.run:
    - name: wget {{ nifi.reg_download_mirror }}/nifi-registry/nifi-registry-{{ nifi.reg_version }}/nifi-registry-{{ nifi.reg_version }}-bin.zip
    - cwd: {{ nifi.reg_install_dir }}
    - user: {{ username }}
    - unless: test -f {{ nifi.reg_install_dir }}/bin/nifi-registry.sh

{% set reg_archive_dir = nifi.reg_install_dir + '/nifi-registry-' + nifi.reg_version %}
{% set reg_archive = reg_archive_dir + '-bin.zip' %}

check-nifi-reg-archive:
  module.run:
    - name: file.check_hash
    - path: {{ reg_archive }}
    - file_hash: {{ nifi.reg_hash }}
    - onchanges:
      - cmd: download-nifi-reg-archive    
    - require_in:
      - archive: unpack-nifi-reg-archive   

unpack-nifi-reg-archive:
  archive.extracted:
    - name: {{ nifi.reg_install_dir }}
    - source: file://{{ reg_archive }}
    - archive_format: zip
    - user: {{ username }}
    - group: hadoop
    - onchanges:
      - cmd: download-nifi-reg-archive

cleanup-nifi-reg-directory:
  cmd.run:
    - name: mv {{ reg_archive_dir }}/* {{ nifi.reg_install_dir }}; rm -rf {{ reg_archive_dir }}*
    - onchanges:
      - archive: unpack-nifi-reg-archive

nifi-reg-symlink:
  file.symlink:
    - target: {{ nifi.reg_install_dir}}
    - name: {{nifi.reg_dir}}

nifi-reg-conf-symlink:
  file.symlink:
    - target: {{ nifi.reg_install_dir}}/conf
    - name: /etc/nifi-registry/conf

nifi-reg-logs-directory:
  file.directory:
    - name: /var/log/nifi-registry
    - user: {{ username }}

/etc/nifi-registry/conf/nifi-registry.properties:
  file.managed:
    - source: salt://hadoop/conf/nifi/nifi-registry.properties
    - user: {{username}}
    - group: {{username}}
    - mode: '644'
    - template: jinja
    - context:
      username: {{ username }}
      keystore_pass: {{ hadoop.keystore_pass }}

{{nifi.reg_install_dir}}/bin/nifi-env.sh:
  file.managed:
    - source: salt://hadoop/conf/nifi/nifi-env.sh
    - user: {{username}}
    - group: {{username}}
    - mode: '755'
    - template: jinja

#/etc/nifi/conf/authorizers.xml:
#  file.managed:
#    {%- if nifi.ranger_auth %}
#    - source: salt://hadoop/conf/nifi/authorizers-ranger.xml
#    {%- else %}
#    - source: salt://hadoop/conf/nifi/authorizers-default.xml
#    {%- endif %}
#    - user: {{username}}
#    - group: {{username}}
#    - mode: '644'
#    - template: jinja
#
/etc/nifi-registry/conf/bootstrap.conf:
  file.managed:
    - source: salt://hadoop/conf/nifi/bootstrap-registry.conf
    - user: {{username}}
    - group: {{username}}
    - mode: '644'
    - template: jinja
    - context:
      username: {{ username }}

/etc/nifi-registry/conf/providers.xml:
  file.managed:
    - source: salt://hadoop/conf/nifi/providers.xml
    - user: {{username}}
    - group: {{username}}
    - mode: '644'
    - template: jinja
    - context:
      username: {{ username }}
#
#{% for nar in nifi.additional_jars %}
#{{nifi.install_dir}}/lib/{{nar}}:
#  file.managed:
#    - source: salt://nifi/files/{{nar}}
#    - user: {{ username }}
#    - group: hadoop
#{% endfor %}
#
#{% if nifi.jmx_export %}
#/etc/nifi/conf/jmx.yaml:
#  file.managed:
#    - source: salt://hadoop/conf/nifi/jmx.yaml
#    - user: {{username}}
#    - group: {{username}}
#    - mode: '755'
#    - template: jinja
#{% endif %}
#
{% if hadoop.secure_mode %}

{{ keystore(username, ssl_conf=False)}}

#/etc/krb5/nifi.keytab:
#  file.managed:
#    - source: salt://kerberos/files/{{grains['cluster_id']}}/{{username}}-{{ grains['fqdn'] }}.keytab
#    - user: {{ username }}
#    - group: {{ username }}
#    - mode: '0400'
{% endif %}
#
#{% if nifi.ranger_auth %}
#download-nifi-ranger-plugin:
#  cmd.run:
#    - name: wget http://central.maven.org/maven2/org/apache/nifi/nifi-ranger-nar/{{ nifi.version}}/nifi-ranger-nar-{{nifi.version}}.nar
#    - cwd: /tmp/
#    - user: {{ username }}
#    - unless: test -f {{ nifi.install_dir }}/lib/nifi-ranger-nar-{{nifi.version}}.nar
#
#check-nifi-ranger-plugin:
#  module.run:
#    - name: file.check_hash
#    - path: /tmp/nifi-ranger-nar-{{nifi.version}}.nar
#    - file_hash: "sha1=69f88069bb6a87e73590ccfbcb8f4b0853dcadaa"
#    - onchanges:
#      - cmd: download-nifi-ranger-plugin    
#    - require_in:
#      - archive: move-nifi-ranger-plugin   
#
#move-nifi-ranger-plugin:
#  file.copy:
#    - name: {{ nifi.install_dir }}/lib/nifi-ranger-nar-{{nifi.version}}.nar
#    - source: /tmp/nifi-ranger-nar-{{nifi.version}}.nar
#    - user: {{ username }}
#    - group: hadoop
#    - unless: test -f {{ nifi.install_dir }}/lib/nifi-ranger-nar-{{nifi.version}}.nar
#
#/etc/ranger/nifi-{{ grains['cluster_id']}}/policycache:
#  file.directory:
#    - user: {{ username }}
#    - group: {{ username }}
#    - makedirs: true
#
#/var/log/nifi-{{ grains['cluster_id']}}/audit/solr/spool:
#  file.directory:
#    - user: {{ username }}
#    - group: {{ username }}
#    - makedirs: true
#
#/etc/nifi/conf/ranger-nifi-audit.xml:
#  file.managed:
#    - source: salt://hadoop/conf/nifi/ranger-nifi-audit.xml
#    - user: {{username}}
#    - group: {{username}}
#    - mode: '400'
#    - template: jinja
#
#/etc/nifi/conf/ranger-nifi-security.xml:
#  file.managed:
#    - source: salt://hadoop/conf/nifi/ranger-nifi-security.xml
#    - user: {{username}}
#    - group: {{username}}
#    - mode: '400'
#    - template: jinja
#
#{% if hadoop.secure_mode %}
#
#/etc/nifi/conf/ranger-policymgr-ssl.xml:
#  file.managed:
#    - source: salt://hadoop/conf/nifi/ranger-policymgr-ssl.xml
#    - user: {{username}}
#    - group: {{username}}
#    - mode: '400'
#    - template: jinja
#{% endif %}
#
#create-hadoop-ssl-credential-store:
#  cmd.run:
#    - name: bash -c "hadoop credential create sslkeystore -value {{ hadoop.keystore_pass}} -provider localjceks://file/home/{{username}}/credentials.jceks && hadoop credential create ssltruststore -value changeit -provider localjceks://file/home/{{username}}/credentials.jceks"
#    - user: {{ username }}
#    - unless: test -f /home/{{username}}/credentials.jceks
#
#{% endif %}

/etc/systemd/system/nifi-registry.service:
  file.managed:
    - source: salt://hadoop/files/nifi-registry.init.systemd
    - user: root
    - group: root
    - mode: '644'
    - template: jinja
    - context:
      reg_dir: {{ nifi.reg_dir }}
      username: {{ username }}
    - watch_in:
      - cmd: systemd-reload

nifi-registry-service:
  service.running:
    - enable: True
    - name: nifi-registry.service
    - watch:
      - file: /etc/nifi-registry/conf/nifi-registry.properties

