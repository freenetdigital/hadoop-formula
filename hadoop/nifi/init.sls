{%- from 'hadoop/settings.sls' import hadoop with context %}
{%- from 'hadoop/nifi/settings.sls' import nifi with context %}
{%- from 'hadoop/user_macro.sls' import hadoop_user with context %}
{%- from 'hadoop/keystore_macro.sls' import keystore with context %}

include:
  - hadoop.systemd
  
{%- set username = 'nifi' %}
{%- set uid = hadoop.users[username] %}

{{ hadoop_user(username, uid, ssh=False) }}

nifi-directory:
  file.directory:
    - name: {{ nifi.install_dir }}
    - user: {{ username }}
nifi-data-directory:
  file.directory:
    - name: {{ nifi.data_dir }}
    - user: {{ username }}

nifi-tk-directory:
  file.directory:
    - name: {{ nifi.toolkit_install_dir }}
    - user: {{ username }}

nifi-conf-directory:
  file.directory:
    - name: /etc/nifi
    - user: {{ username }}

nifi-directory-symlink:
  file.symlink:
    - target: {{ nifi.install_dir }}
    - name: {{ nifi.dir }}

download-nifi-archive:
  cmd.run:
    - name: wget {{ nifi.download_mirror }}/{{ nifi.version }}/nifi-{{ nifi.version }}-bin.zip
    - cwd: {{ nifi.install_dir }}
    - user: {{ username }}
    - unless: test -f {{ nifi.install_dir }}/bin/nifi.sh

download-nifi-toolkit-archive:
  cmd.run:
    - name: wget {{ nifi.download_mirror }}/{{ nifi.version }}/nifi-toolkit-{{ nifi.version }}-bin.zip
    - cwd: {{ nifi.toolkit_install_dir }}
    - user: {{ username }}
    - unless: test -f {{ nifi.toolkit_install_dir }}/bin/tls-toolkit.sh

{% set archive_dir = nifi.install_dir + '/nifi-' + nifi.version %}
{% set archive = archive_dir + '-bin.zip' %}
{% set tk_archive_dir = nifi.toolkit_install_dir + '/nifi-toolkit-' + nifi.version %}
{% set tk_archive = tk_archive_dir + '-bin.zip' %}

check-nifi-archive:
  module.run:
    - name: file.check_hash
    - path: {{ archive }}
    - file_hash: {{ nifi.hash }}
    - onchanges:
      - cmd: download-nifi-archive    
    - require_in:
      - archive: unpack-nifi-archive   

check-tk-nifi-archive:
  module.run:
    - name: file.check_hash
    - path: {{ tk_archive }}
    - file_hash: {{ nifi.toolkit_hash }}
    - onchanges:
      - cmd: download-nifi-toolkit-archive    
    - require_in:
      - archive: unpack-tk-nifi-archive   


unpack-nifi-archive:
  archive.extracted:
    - name: {{ nifi.install_dir }}
    - source: file://{{ archive }}
    - archive_format: zip
    - user: {{ username }}
    - group: hadoop
    - onchanges:
      - cmd: download-nifi-archive

unpack-tk-nifi-archive:
  archive.extracted:
    - name: {{ nifi.toolkit_install_dir }}
    - source: file://{{ tk_archive }}
    - archive_format: zip
    - user: {{ username }}
    - group: hadoop
    - onchanges:
      - cmd: download-nifi-toolkit-archive

cleanup-nifi-directory:
  cmd.run:
    - name: mv {{ archive_dir }}/* {{ nifi.install_dir }}; rm -rf {{ archive_dir }}*
    - onchanges:
      - archive: unpack-nifi-archive

cleanup-nifi-toolkit-directory:
  cmd.run:
    - name: mv {{ tk_archive_dir }}/* {{ nifi.toolkit_install_dir }}; rm -rf {{ tk_archive_dir }}*
    - onchanges:
      - archive: unpack-tk-nifi-archive

nifi-symlink:
  file.symlink:
    - target: {{ nifi.install_dir}}
    - name: {{nifi.dir}}

nifi-conf-symlink:
  file.symlink:
    - target: {{ nifi.install_dir}}/conf
    - name: /etc/nifi/conf

nifi-logs-directory:
  file.directory:
    - name: /var/log/nifi
    - user: {{ username }}

/etc/nifi/conf/nifi.properties:
  file.managed:
    - source: salt://hadoop/conf/nifi/nifi.properties
    - user: {{username}}
    - group: {{username}}
    - mode: '644'
    - template: jinja
    - context:
      username: {{ username }}
      keystore_pass: {{ hadoop.keystore_pass }}

{{nifi.install_dir}}/bin/nifi-env.sh:
  file.managed:
    - source: salt://hadoop/conf/nifi/nifi-env.sh
    - user: {{username}}
    - group: {{username}}
    - mode: '755'
    - template: jinja

/etc/nifi/conf/authorizers.xml:
  file.managed:
    {%- if nifi.ranger_auth %}
    - source: salt://hadoop/conf/nifi/authorizers-ranger.xml
    {%- else %}
    - source: salt://hadoop/conf/nifi/authorizers-default.xml
    {%- endif %}
    - user: {{username}}
    - group: {{username}}
    - mode: '644'
    - template: jinja

/etc/nifi/conf/bootstrap.conf:
  file.managed:
    - source: salt://hadoop/conf/nifi/bootstrap.conf
    - user: {{username}}
    - group: {{username}}
    - mode: '644'
    - template: jinja
    - context:
      username: {{ username }}

{% for nar in nifi.additional_jars %}
{{nifi.install_dir}}/lib/{{nar}}:
  file.managed:
    - source: salt://nifi/files/{{nar}}
    - user: {{ username }}
    - group: hadoop
{% endfor %}

{% if nifi.jmx_export %}
/etc/nifi/conf/jmx.yaml:
  file.managed:
    - source: salt://hadoop/conf/nifi/jmx.yaml
    - user: {{username}}
    - group: {{username}}
    - mode: '755'
    - template: jinja
{% endif %}

{% if hadoop.secure_mode %}

{{ keystore(username, ssl_conf=False)}}

/etc/krb5/nifi.keytab:
  file.managed:
    - source: salt://kerberos/files/{{grains['cluster_id']}}/{{username}}-{{ grains['fqdn'] }}.keytab
    - user: {{ username }}
    - group: {{ username }}
    - mode: '0400'
/etc/krb5/nifi-nohost.keytab:
  file.managed:
    - source: salt://kerberos/files/{{grains['cluster_id']}}/{{username}}-nohost.keytab
    - user: {{ username }}
    - group: {{ username }}
    - mode: '0400'
{% endif %}

{% if nifi.ranger_auth %}
download-nifi-ranger-plugin:
  cmd.run:
    - name: wget http://central.maven.org/maven2/org/apache/nifi/nifi-ranger-nar/{{ nifi.version}}/nifi-ranger-nar-{{nifi.version}}.nar
    - cwd: /tmp/
    - user: {{ username }}
    - unless: test -f {{ nifi.install_dir }}/lib/nifi-ranger-nar-{{nifi.version}}.nar

check-nifi-ranger-plugin:
  module.run:
    - name: file.check_hash
    - path: /tmp/nifi-ranger-nar-{{nifi.version}}.nar
    - file_hash: "sha1=69f88069bb6a87e73590ccfbcb8f4b0853dcadaa"
    - onchanges:
      - cmd: download-nifi-ranger-plugin    
    - require_in:
      - archive: move-nifi-ranger-plugin   

move-nifi-ranger-plugin:
  file.copy:
    - name: {{ nifi.install_dir }}/lib/nifi-ranger-nar-{{nifi.version}}.nar
    - source: /tmp/nifi-ranger-nar-{{nifi.version}}.nar
    - user: {{ username }}
    - group: hadoop
    - unless: test -f {{ nifi.install_dir }}/lib/nifi-ranger-nar-{{nifi.version}}.nar

/etc/ranger/nifi-{{ grains['cluster_id']}}/policycache:
  file.directory:
    - user: {{ username }}
    - group: {{ username }}
    - makedirs: true

/var/log/nifi-{{ grains['cluster_id']}}/audit/solr/spool:
  file.directory:
    - user: {{ username }}
    - group: {{ username }}
    - makedirs: true

/etc/nifi/conf/ranger-nifi-audit.xml:
  file.managed:
    - source: salt://hadoop/conf/nifi/ranger-nifi-audit.xml
    - user: {{username}}
    - group: {{username}}
    - mode: '400'
    - template: jinja

/etc/nifi/conf/ranger-nifi-security.xml:
  file.managed:
    - source: salt://hadoop/conf/nifi/ranger-nifi-security.xml
    - user: {{username}}
    - group: {{username}}
    - mode: '400'
    - template: jinja

{% if hadoop.secure_mode %}

/etc/nifi/conf/ranger-policymgr-ssl.xml:
  file.managed:
    - source: salt://hadoop/conf/nifi/ranger-policymgr-ssl.xml
    - user: {{username}}
    - group: {{username}}
    - mode: '400'
    - template: jinja
{% endif %}

create-hadoop-ssl-credential-store:
  cmd.run:
    - name: bash -c "hadoop credential create sslkeystore -value {{ hadoop.keystore_pass}} -provider localjceks://file/home/{{username}}/credentials.jceks && hadoop credential create ssltruststore -value changeit -provider localjceks://file/home/{{username}}/credentials.jceks"
    - user: {{ username }}
    - unless: test -f /home/{{username}}/credentials.jceks

{% endif %}
/etc/systemd/system/nifi.service:
  file.managed:
    - source: salt://hadoop/files/nifi.init.systemd
    - user: root
    - group: root
    - mode: '644'
    - template: jinja
    - context:
      dir: {{ nifi.dir }}
      username: {{ username }}
    - watch_in:
      - cmd: systemd-reload

nifi-service:
  service.running:
    - enable: True
    - name: nifi.service
    - watch:
      - file: /etc/nifi/conf/nifi.properties

