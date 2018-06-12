{%- from 'hadoop/settings.sls' import hadoop with context %}
{%- from 'hadoop/hive/settings.sls' import hive with context %}
{%- from 'hadoop/user_macro.sls' import hadoop_user with context %}
{%- from 'hadoop/hdfs_mkdir_macro.sls' import hdfs_mkdir with context %}
include:
  - hadoop.systemd
  
{%- set username = 'hive' %}
{%- set uid = hadoop.users[username] %}

{{ hadoop_user(username, uid) }}

hive-directory:
  file.directory:
    - name: {{ hive.install_dir }}
    - user: {{ username }}

hive-conf-directory:
  file.directory:
    - name: /etc/hive
    - user: {{ username }}

hive-directory-symlink:
  file.symlink:
    - target: {{ hive.install_dir }}
    - name: {{ hive.dir }}

download-hive-archive:
  cmd.run:
    - name: wget {{ hive.download_mirror }}/hive-{{ hive.version }}/apache-hive-{{ hive.version }}-bin.tar.gz
    - cwd: {{ hive.install_dir }}
    - user: {{ username }}
    - unless: test -f {{ hive.install_dir }}/bin/hive

{% set archive_dir = hive.install_dir + '/apache-hive-' + hive.version + '-bin' %}
{% set archive = archive_dir + '.tar.gz' %}

check-jdk-archive:
  module.run:
    - name: file.check_hash
    - path: {{ archive }}
    - file_hash: {{ hive.hash }}
    - onchanges:
      - cmd: download-hive-archive     
    - require_in:
      - archive: unpack-hive-archive   

unpack-hive-archive:
  archive.extracted:
    - name: {{ hive.install_dir }}
    - source: file://{{ archive }}
    - archive_format: tar
    - user: {{ username }}
    - group: {{ username }}
    - onchanges:
      - cmd: download-hive-archive


cleanup-hive-directory:
  cmd.run:
    - name: mv {{ archive_dir }}/* {{ hive.install_dir }}; rm -rf {{ archive_dir }}*
    - onchanges:
      - archive: unpack-hive-archive

hive-conf-symlink:
  file.symlink:
    - target: {{ hive.install_dir }}/conf
    - name: {{ hive.conf_dir }}

hive-site.xml:
  file.managed:
    - name: {{ hive.install_dir }}/conf/hive-site.xml
    - template: jinja
    - source: salt://hadoop/conf/hive/hive-site.xml
    - user: {{ username }}
    - watch_in:
      - service: hive-hiveserver2

hive-log-directory:
  file.directory:
    - name: {{ hive.hive_log_dir }}
    - user: {{ username }}

hive-log4j2.properties:
  file.managed:
    - name: {{ hive.install_dir }}/conf/hive-log4j2.properties
    - template: jinja
    - source: salt://hadoop/conf/hive/hive-log4j2.properties
    - user: {{ username }}
    - watch_in:
      - service: hive-hiveserver2

{{ hdfs_mkdir('/tmp', 'hdfs', 'hadoop', 1777, hadoop.dfs_cmd) }}
{{ hdfs_mkdir('/apps', 'hdfs', 'hadoop', 1777, hadoop.dfs_cmd) }}
{{ hdfs_mkdir('/tmp/scratch', 'hive', 'hadoop', 1777, hadoop.dfs_cmd) }}

{% if grains['init'] == 'systemd' %}
/etc/systemd/system/hive-hiveserver2.service:
  file.managed:
    - source: salt://hadoop/files/hive.init.systemd
    - user: root
    - group: root
    - mode: '644'
    - template: jinja
    - context:
      svc: hiveserver2
    - watch_in:
      - cmd: systemd-reload

/etc/systemd/system/hive-metastore.service:
  file.managed:
    - source: salt://hadoop/files/hive.init.systemd
    - user: root
    - group: root
    - mode: '644'
    - template: jinja
    - context:
      svc: metastore
    - watch_in:
      - cmd: systemd-reload
{% endif %}

{% if hive.jmx_export %}
{{ hive.conf_dir }}/hive-env.sh:
  file.managed:
    - source: salt://hadoop/conf/hive/hive-env.sh
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - context:
      jmx_export: {{ hive.jmx_export }}

{{ hive.conf_dir }}/jmx_hive.yaml:
  file.managed:
    - source: salt://hadoop/conf/hive/jmx_hive.yaml
    - template: jinja
    - mode: 644
    - user: root
    - group: root
{% endif %} 

hive-metastore:
  service.running:
    - enable: True

hive-hiveserver2:
  service.running:
    - enable: True
