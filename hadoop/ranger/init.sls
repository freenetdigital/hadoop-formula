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

{{ ranger.admin_install_dir }}/install.properties:
  file.managed:
    - source: salt://hadoop/conf/ranger/admin.install.properties
    - user: {{ username }}
    - group: {{ username }}
    - mode: '600'
    - template: jinja

ranger-usersync-directory:
  file.directory:
    - name: {{ ranger.usync_install_dir }}
    - user: {{ username }}

ranger-usersync-directory-symlink:
  file.symlink:
    - target: {{ ranger.usync_install_dir }}
    - name: {{ ranger.usync_dir }}

unpack-ranger-usersync-archive:
  archive.extracted:
    - name: {{ ranger.usync_install_dir }}
    - source: salt://ranger/ranger-{{ ranger.version }}/ranger-{{ ranger.version }}-usersync.zip
    - archive_format: zip
    - clean: true
    - user: {{ username }}
    - group: {{ username }}
    - unless: test -f {{ ranger.usync_install_dir }}/ranger-usersync

move-usersync-files:
  cmd.run:
    - name: mv {{ ranger.usync_install_dir}}/ranger-{{ ranger.version }}-usersync/* {{ranger.usync_install_dir}}; rm -rf {{ ranger.usync_install_dir}}/ranger-{{ ranger.version }}-usersync
    - onchanges:
      - archive: unpack-ranger-usersync-archive

usersync-enforce-mode:
  file.directory:
    - name: {{ ranger.usync_install_dir }}
    - user: {{ username }}
    - group: {{ username }}
    - dir_mode: 755
    - recurse:
      - user
      - group
      - mode
    - onchanges:
      - archive: unpack-ranger-usersync-archive

{{ ranger.usync_install_dir }}/install.properties:
  file.managed:
    - source: salt://hadoop/conf/ranger/usersync.install.properties
    - user: {{ username }}
    - group: {{ username }}
    - mode: '600'
    - template: jinja

{% if grains['init'] == 'systemd' %}
/etc/systemd/system/ranger-admin.service:
  file.managed:
    - source: salt://hadoop/files/ranger-admin.init.systemd
    - user: root
    - group: root
    - mode: '644'
    - template: jinja
    - watch_in:
      - cmd: systemd-reload

/etc/systemd/system/ranger-usersync.service:
  file.managed:
    - source: salt://hadoop/files/ranger-usersync.init.systemd
    - user: root
    - group: root
    - mode: '644'
    - template: jinja
    - watch_in:
      - cmd: systemd-reload
{% endif %}

provision-ranger-admin:
  cmd.run:
    - name: bash -c './setup.sh; /etc/init.d/ranger-admin stop; rm /etc/init.d/ranger-admin'
    - cwd: {{ ranger.admin_install_dir }}
    - onchanges: 
      - file: {{ ranger.admin_install_dir }}/install.properties

provision-ranger-usync:
  cmd.run:
    - name: bash -c './setup.sh; /etc/init.d/ranger-usersync stop; rm /etc/init.d/ranger-usersync'
    - cwd: {{ ranger.usync_install_dir }}
    - onchanges: 
      - file: {{ ranger.usync_install_dir }}/install.properties

ranger-agent:
  service.running:
    - enable: True
    - watch:
      - cmd: provision-ranger-admin

ranger-usersync:
  service.running:
    - enable: True
    - watch:
      - cmd: provision-ranger-usync

