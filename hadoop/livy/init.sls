{%- from 'hadoop/settings.sls' import hadoop with context %}
{%- from 'hadoop/livy/settings.sls' import livy with context %}
{%- from 'hadoop/user_macro.sls' import hadoop_user with context %}
{%- from 'hadoop/keystore_macro.sls' import keystore with context %}

include:
  - hadoop.systemd
  
{%- set username = 'livy' %}
{%- set uid = hadoop.users[username] %}

{{ hadoop_user(username, uid, ssh=False) }}

{% if livy.download_mirror %}
download-livy-archive:
  cmd.run:
    - name: wget {{ livy.download_mirror }}/{{ livy.version }}/livy-{{ livy.version }}.tgz
    - cwd: {{ livy.download_dir }}
    - user: {{ username }}
    - unless: test -f {{ livy.download_dir }}/livy-{{livy.version}}/VERSION

unpack-livy-archive:
  archive.extracted:
    - name: {{ livy.download_dir }}
    - source: file://{{ livy.download_dir }}/livy-{{ livy.version}}.tgz
    - archive_format: tar
    - user: {{ username }}
    - group: {{ username }}
    - onchanges:
      - cmd: download-livy-archive
{% else %}
copy-livy-archive:
  archive.extracted:
    - name: {{ livy.download_dir }}
    - source: salt://livy/files/livy-{{ livy.version}}.tgz
    - archive_format: tar
    - clean: true
    - user: {{ username }}
    - group: {{ username }}
    - unless: test -f {{livy.download_dir }}/livy-{{ livy.version }}/VERSION
{% endif %} 


install-build-dependencies:
  pkg.installed:
    - pkgs:
      - python2.7-dev 
      - make 
      - libkrb5-dev 
      - libxml2-dev 
      - libffi-dev 
      - libxslt-dev 
      - libsqlite3-dev 
      - libssl-dev 
      - libldap2-dev 
      - libkrb5-dev 
      - libmysqlclient-dev 
      - libsasl2-dev 
      - libsasl2-modules-gssapi-mit 
      - libsqlite3-dev 
      - libxml2-dev 
      - libxslt-dev 
      - libffi-dev 
      - libgmp3-dev 
      - libz-dev 
      - python-pip

livy-make-install:
  cmd.run:
    - name: 'bash -c "PREFIX={{livy.install_dir}} make install"'
    - cwd: {{ livy.download_dir}}/livy-{{ livy.version }}
    - unless: test -f {{livy.install_dir}}/livy/build/env/bin/livy

livy-symlink:
  file.symlink:
    - target: {{ livy.install_dir}}/livy
    - name: {{livy.dir}}

livy-conf-dir:
  file.directory:
    - name: /etc/livy
    - user: {{username}}

livy-log-dir:
  file.directory:
    - name: {{ livy.install_dir }}/livy/logs
    - user: {{username}}
    - group: {{username}}

livy-log-audit-dir:
  file.directory:
    - name: {{ livy.install_dir }}/livy/logs/audit_logs
    - user: {{username}}
    - group: {{username}}
    - mode: '700'

livy-log-symlink:
  file.symlink:
    - target: {{ livy.install_dir}}/livy/logs
    - name: /var/log/livy


livy-conf-symlink:
  file.symlink:
    - target: {{ livy.install_dir}}/livy/desktop/conf
    - name: {{ livy.conf_dir}}

livy-create-hive-conf:
  file.directory:
    - name: /etc/hive/conf
    - makedirs: true

hive-site.xml-for-livy:
  file.managed:
    - name: /etc/hive/conf/hive-site.xml
    - template: jinja
    - source: salt://hadoop/conf/hive/hive-site.xml

{{ livy.conf_dir}}/livy.ini:
  file.managed:
    - source: salt://hadoop/conf/livy/livy.ini
    - user: {{ username }}
    - group: {{ username }}
    - mode: '600'
    - template: jinja
    - context:
      username: {{username}}

{% if hadoop.secure_mode %}
/etc/krb5/livy.keytab:
  file.managed:
    - source: salt://kerberos/files/{{username}}-{{ grains['fqdn'] }}.keytab
    - user: {{ username }}
    - group: {{ username }}
    - mode: '0400'

/home/{{username}}/ssl:
  file.directory:
    - user: {{ username}}
    - group: {{ username}}

/home/{{username}}/ssl/{{hadoop.cert_name}}:
  file.copy:
    - source: {{ hadoop.cert_pub_path}}/{{hadoop.cert_name}}
    - user: {{ username }}
    - mode: '400'
/home/{{username}}/ssl/{{hadoop.cert_name}}.key:
  file.copy:
    - source: {{ hadoop.cert_priv_path}}/{{hadoop.cert_name}}.key
    - user: {{ username }}
    - mode: '400'
{% endif %}

{{ livy.sqlite_path}}:
  file.managed:
    - user: {{ username }}
    - group: {{ username }}
    - replace: False
    - create: False

/etc/systemd/system/livy.service:
  file.managed:
    - source: salt://hadoop/files/livy.init.systemd
    - user: root
    - group: root
    - mode: '644'
    - template: jinja
    - context:
      dir: {{ livy.dir }}
    - watch_in:
      - cmd: systemd-reload

livy-service:
  service.running:
    - enable: True
    - name: livy.service
    - watch:
      - file: {{ livy.conf_dir}}/livy.ini
