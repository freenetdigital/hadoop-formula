{%- from 'hadoop/settings.sls'        import hadoop      with context %}
{%- from 'hadoop/ranger/settings.sls' import ranger      with context %}
{%- from 'hadoop/solr/settings.sls'   import solr        with context %}
{%- from 'hadoop/user_macro.sls'      import hadoop_user with context %}

include:
  - hadoop.systemd
  
{%- set username = 'ranger' %}
{%- set uid = hadoop.users[username] %}

{{ hadoop_user(username, uid, ssh=False) }}

ranger-directory:
  file.directory:
    - name: {{ ranger.admin_install_dir }}
    - user: {{ username }}

ranger-directory-symlink:
  file.symlink:
    - target: {{ ranger.admin_install_dir }}
    - name: {{ ranger.admin_dir }}

unpack-ranger-admin-archive:
  archive.extracted:
    - name: {{ ranger.admin_install_dir }}
    - source: salt://ranger/ranger-{{ ranger.version }}/ranger-{{ ranger.version }}-admin.zip
    - archive_format: zip
    - clean: true
    - user: {{ username }}
    - group: {{ username }}
    - unless: test -f {{ ranger.admin_install_dir }}/bin/service_start.py

move-files:
  cmd.run:
    - name: mv {{ ranger.admin_install_dir}}/ranger-{{ ranger.version }}-admin/* {{ranger.admin_install_dir}}; rm -rf {{ ranger.admin_install_dir}}/ranger-{{ ranger.version }}-admin
    - onchanges:
      - archive: unpack-ranger-admin-archive

enforce-mode:
  file.directory:
    - name: {{ ranger.admin_install_dir }}
    - user: {{ username }}
    - group: {{ username }}
    - dir_mode: 755
    - recurse:
      - user
      - group
      - mode
    - onchanges:
      - archive: unpack-ranger-admin-archive

mysql-connector-deps:
  pkg.installed:
    - pkgs: 
      - libmysql-java
      - bc

