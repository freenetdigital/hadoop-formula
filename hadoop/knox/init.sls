{%- from 'hadoop/settings.sls' import hadoop with context %}
{%- from 'hadoop/knox/settings.sls' import knox with context %}
{%- from 'hadoop/user_macro.sls' import hadoop_user with context %}
#{%- from 'hadoop/hdfs_mkdir_macro.sls' import hdfs_mkdir with context %}
include:
  - hadoop.systemd
  
{%- set username = 'knox' %}
{%- set uid = hadoop.users[username] %}

{{ hadoop_user(username, uid) }}

knox-directory:
  file.directory:
    - name: {{ knox.install_dir }}
    - user: {{ username }}

knox-conf-directory:
  file.directory:
    - name: /etc/knox
    - user: {{ username }}

knox-directory-symlink:
  file.symlink:
    - target: {{ knox.install_dir }}
    - name: {{ knox.dir }}

download-knox-archive:
  cmd.run:
    - name: wget {{ knox.download_mirror }}/{{ knox.version }}/knox-{{ knox.version }}.zip
    - cwd: {{ knox.install_dir }}
    - user: {{ username }}
    - unless: test -f {{ knox.install_dir }}/bin/gateway.sh

{% set archive_dir = knox.install_dir + '/knox-' + knox.version %}
{% set archive = archive_dir + '.zip' %}

check-knox-archive:
  module.run:
    - name: file.check_hash
    - path: {{ archive }}
    - file_hash: {{ knox.hash }}
    - onchanges:
      - cmd: download-knox-archive     
    - require_in:
      - archive: unpack-knox-archive   

unpack-knox-archive:
  archive.extracted:
    - name: {{ knox.install_dir }}
    - source: file://{{ archive }}
    - archive_format: zip
    - user: {{ username }}
    - group: {{ username }}
    - onchanges:
      - cmd: download-knox-archive


cleanup-knox-directory:
  cmd.run:
    - name: mv {{ archive_dir }}/* {{ knox.install_dir }}; rm -rf {{ archive_dir }}*
    - onchanges:
      - archive: unpack-knox-archive

knox-conf-symlink:
  file.symlink:
    - target: {{ knox.install_dir }}/conf
    - name: {{ knox.conf_dir }}

{% if grains['init'] == 'systemd' %}
/etc/systemd/system/knox.service:
  file.managed:
    - source: salt://hadoop/files/knox.init.systemd
    - user: root
    - group: root
    - mode: '644'
    - template: jinja
    - context:
      dir: {{ knox.dir }}
    - watch_in:
      - cmd: systemd-reload

{% endif %}

{% if knox.jmx_export %}
#TODO
{% endif %} 

knox-service:
  service.running:
    - enable: True
    - name: knox.service

