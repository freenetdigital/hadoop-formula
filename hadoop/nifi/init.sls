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
    - name: wget {{ nifi.download_mirror }}/{{ nifi.version }}/nifi-{{ nifi.version }}.zip
    - cwd: {{ nifi.install_dir }}
    - user: {{ username }}

download-nifi-toolkit-archive:
  cmd.run:
    - name: wget {{ nifi.download_mirror }}/{{ nifi.version }}/nifi-toolkit-{{ nifi.version }}.zip
    - cwd: {{ nifi.toolkit_install_dir }}
    - user: {{ username }}
    #- unless: test -f {{ nifi.install_dir }}/bin/nifi-server

{% set archive_dir = nifi.install_dir + '/nifi-' + nifi.version %}
{% set archive = archive_dir + '.zip' %}
{% set tk_archive_dir = nifi.toolkit_install_dir + '/nifi-toolkit-' + nifi.version %}
{% set tk_archive = tk_archive_dir + '.zip' %}

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

cleanup-nifi-directory:
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
    - name: {{ nifi.install_dir }}/logs
    - user: {{ username }}

nifi-logs-symlink:
  file.symlink:
    - target: {{ nifi.install_dir}}/logs
    - name: /var/log/nifi

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

#/etc/nifi/conf/nifi-env.sh:
#  file.managed:
#    - source: salt://hadoop/conf/nifi/nifi-env.sh
#    - user: {{username}}
#    - group: {{username}}
#    - mode: '755'
#    - template: jinja
#
#/etc/default/nifi.env:
#  file.managed:
#    - source: salt://hadoop/conf/nifi/nifi.env
#    - user: {{username}}
#    - group: {{username}}
#    - mode: '755'
#    - template: jinja
#
#{{ nifi.install_dir}}/upload_jars.sh:
#  file.managed:
#    - source: salt://hadoop/conf/nifi/upload_jars.sh
#    - user: {{username}}
#    - group: {{username}}
#    - mode: '755'
#    - template: jinja
#
#/etc/nifi/conf/spark-blacklist.conf:
#  file.managed:
#    - source: salt://hadoop/conf/nifi/spark-blacklist.conf
#    - user: {{username}}
#    - group: {{username}}
#    - mode: '644'
#    - template: jinja
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

{% if hadoop.secure_mode %}

{{ keystore(username, ssl_conf=False)}}

/etc/krb5/nifi.keytab:
  file.managed:
    - source: salt://kerberos/files/{{username}}-{{ grains['fqdn'] }}.keytab
    - user: {{ username }}
    - group: {{ username }}
    - mode: '0400'
{% endif %}

#/etc/systemd/system/nifi.service:
#  file.managed:
#    - source: salt://hadoop/files/nifi.init.systemd
#    - user: root
#    - group: root
#    - mode: '644'
#    - template: jinja
#    - context:
#      dir: {{ nifi.dir }}
#      username: {{ username }}
#    - watch_in:
#      - cmd: systemd-reload
#
#nifi-service:
#  service.running:
#    - enable: True
#    - name: nifi.service
#    - watch:
#      - file: /etc/nifi/conf/nifi.conf
#
