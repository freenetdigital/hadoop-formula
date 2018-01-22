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

{{ hdfs_mkdir('/tmp', 'hdfs', 'hadoop', 1777, hadoop.dfs_cmd) }}
{{ hdfs_mkdir('/apps', 'hdfs', 'hadoop', 1777, hadoop.dfs_cmd) }}
{{ hdfs_mkdir('/tmp/scratch', 'hive', 'hadoop', 1777, hadoop.dfs_cmd) }}

install-tez:
  cmd.run:
    - name: wget http://mirror.funkfreundelandshut.de/apache/tez/0.9.0/apache-tez-0.9.0-bin.tar.gz && 
    - user: hdfs

{% if grains['init'] == 'systemd' %}
hadoop-hive2:
  file.managed:
    - name: /etc/systemd/system/hadoop-hive2.service
    - source: salt://hadoop/files/hive.init.systemd
    - user: root
    - group: root
    - mode: '644'
    - template: jinja
    - watch_in:
      - cmd: systemd-reload
{% endif %}

