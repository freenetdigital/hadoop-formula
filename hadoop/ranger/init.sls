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

unpack-ranger-admin-archive:
  archive.extracted:
    - name: {{ ranger.install_dir }}
    - source: salt://ranger/ranger-{{ ranger.version }}/ranger-{{ ranger.version }}-admin.zip
    - archive_format: zip
    - clean: true
    - user: {{ username }}
    - group: {{ username }}
    - unless: test -f {{ ranger.install_dir }}/bin/service_start.py

move-files:
  cmd.run:
    - name: mv {{ ranger.install_dir}}/ranger-{{ ranger.version }}-admin/* {{ranger.install_dir}}; rm -rf {{ ranger.install_dir}}/ranger-{{ ranger.version }}-admin

enforce-mode:
  file.directory:
    - name: {{ ranger.install_dir }}
    - user: {{ username }}
    - group: {{ username }}
    - dir_mode: 755
    - recurse:
      - user
      - group
      - mode


