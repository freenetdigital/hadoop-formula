{%- from 'hadoop/settings.sls' import hadoop with context %}
{%- from 'hadoop/ranger/settings.sls' import ranger with context %}
{%- from 'hadoop/user_macro.sls' import hadoop_user with context %}

include:
  - hadoop.systemd
  
{%- set username = 'ranger' %}
{%- set uid = hadoop.users[username] %}

{{ hadoop_user(username, uid, ssh=False) }}

ranger-directory:
  file.directory:
    - name: {{ ranger.install_dir }}
    - user: {{ username }}

ranger-directory-symlink:
  file.symlink:
    - target: {{ ranger.install_dir }}
    - name: {{ ranger.dir }}

{% set archive_dir = ranger.install_dir + '/ranger-' + ranger.version %}
{% set archive_admin = archive_dir + '-admin.zip' %}
copy-ranger-archive:
  file.managed:
    - source: salt://ranger/ranger-{{ ranger.version }}/ranger-{{ ranger.version }}-admin.zip
    - name: {{ archive_admin }}
    - user: {{ username }}
    - unless: test -f {{ ranger.install_dir }}/bin/service_start.py

unpack-ranger-archive:
  archive.extracted:
    - name: {{ ranger.install_dir }}
    - source: file://{{ archive_admin }}
    - archive_format: zip
    - user: {{ username }}
    - group: {{ username }}
    - onchanges:
      - cmd: copy-ranger-archive


cleanup-ranger-directory:
  cmd.run:
    - name: mv {{ archive_dir }}/* {{ ranger.install_dir }}; rm -rf {{ archive_dir }}*
    - onchanges:
      - archive: unpack-ranger-archive

