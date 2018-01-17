{%- from 'hadoop/settings.sls' import hadoop with context %}
{%- from 'hive/settings.sls' import hive with context %}
{%- from 'hadoop/user_macro.sls' import hadoop_user with context %}
include:
  - hadoop.systemd
  
{%- set username = 'hive' %}
{%- set uid = hadoop.users[username] %}

{{ hadoop_user(username, uid) }}

hive-directory:
  file.directory:
    - name: {{ hive.install_dir }}/hive-{{ hive.version }}
    - owner: {{ username }}
  file.symlink:
    - name: {{ hive.install_dir }}/hive-{{ hive.version }}
    - target: {{ hive.install_dir }}

download-hive-archive:
  cmd.run:
    - name: wget {{ hive.download_mirror }}/hive-{{ hive.version }}/apache-hive-{{ hive.version }}-bin.tar.gz
    - cwd: {{ hive.install_dir }}
    - user: {{ username }}
    - unless: ls {{ hive.install_dir }} | grep "hive-{{ hive.version }}"

check-jdk-archive:
  module.run:
    - name: file.check_hash
    - path: {{ hive.install_dir }}/apache-hive-{{ hive.version }}-bin.tar.gz
    - file_hash: {{ hive.hash }}
    - onchanges:
      - cmd: download-hive-archive     
    - require_in:
      - archive: unpack-hive-archive   

unpack-hive-archive:
  archive.extracted:
    - name: {{ hive.install_dir }}/hive-{{ hive.version }}
    - source: file://{{ hive.install_dir }}/apache-hive-{{ hive.version }}-bin.tar.gz
    - archive_format: tar
    - user: {{ username }}
    - group: {{ username }}
    - if_missing: hive
    - onchanges:
      - cmd: download-hive-archive



