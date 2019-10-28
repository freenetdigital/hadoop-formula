{%- from 'hadoop/settings.sls' import hadoop with context %}
{%- from 'hadoop/hue/settings.sls' import hue with context %}
{%- from 'hadoop/user_macro.sls' import hadoop_user with context %}
{%- from 'hadoop/keystore_macro.sls' import keystore with context %}

include:
  - hadoop.systemd

{%- set username = 'hue' %}
{%- set uid = hadoop.users[username] %}

{{ hadoop_user(username, uid, ssh=False) }}

{% if hue.download_mirror %}
download-hue-archive:
  cmd.run:
    - name: wget {{ hue.download_mirror }}/hue-{{ hue.version }}.tgz
    - cwd: {{ hue.download_dir }}
    - unless: test -f {{ hue.download_dir }}/hue-{{hue.version}}/VERSION

unpack-hue-archive:
  archive.extracted:
    - name: {{ hue.download_dir }}
    - source: file://{{ hue.download_dir }}/hue-{{ hue.version}}.tgz
    - archive_format: tar
    - user: {{ username }}
    - group: {{ username }}
    - onchanges:
      - cmd: download-hue-archive
{% else %}
copy-hue-archive:
  archive.extracted:
    - name: {{ hue.download_dir }}
    - source: salt://hue/files/hue-{{ hue.version}}.tgz
    - archive_format: tar
    - clean: true
    - user: {{ username }}
    - group: {{ username }}
    - unless: test -f {{hue.download_dir }}/hue-{{ hue.version }}/VERSION
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

hue-make-install:
  cmd.run:
    - name: 'bash -c "PREFIX={{hue.install_dir}} make install"'
    - cwd: {{ hue.download_dir}}/hue-{{ hue.version }}
    - unless: test -f {{hue.install_dir}}/hue/build/env/bin/hue

hue-symlink:
  file.symlink:
    - target: {{ hue.install_dir}}/hue
    - name: {{hue.dir}}

hue-conf-dir:
  file.directory:
    - name: /etc/hue
    - user: {{username}}

hue-log-dir:
  file.directory:
    - name: {{ hue.install_dir }}/hue/logs
    - user: {{username}}
    - group: {{username}}

hue-log-audit-dir:
  file.directory:
    - name: {{ hue.install_dir }}/hue/logs/audit_logs
    - user: {{username}}
    - group: {{username}}
    - mode: '700'

hue-log-symlink:
  file.symlink:
    - target: {{ hue.install_dir}}/hue/logs
    - name: /var/log/hue


hue-conf-symlink:
  file.symlink:
    - target: {{ hue.install_dir}}/hue/desktop/conf
    - name: {{ hue.conf_dir}}

hue-create-hive-conf:
  file.directory:
    - name: /etc/hive/conf
    - makedirs: true

hive-site.xml-for-hue:
  file.managed:
    - name: /etc/hive/conf/hive-site.xml
    - template: jinja
    - source: salt://hadoop/conf/hive/hive-site.xml.external

{{ hue.conf_dir}}/hue.ini:
  file.managed:
    - source: salt://hadoop/conf/hue/hue.ini
    - user: {{ username }}
    - group: {{ username }}
    - mode: '600'
    - template: jinja
    - context:
      username: {{username}}

{% if hadoop.secure_mode %}
/etc/krb5/hue.keytab:
  file.managed:
    - source: salt://kerberos/files/{{grains['cluster_id']}}/{{username}}-{{ grains['fqdn'] }}.keytab
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

{{ hue.sqlite_path}}:
  file.managed:
    - user: {{ username }}
    - group: {{ username }}
    - replace: False
    - create: False

/etc/systemd/system/hue.service:
  file.managed:
    - source: salt://hadoop/files/hue.init.systemd
    - user: root
    - group: root
    - mode: '644'
    - template: jinja
    - context:
      dir: {{ hue.dir }}
    - watch_in:
      - cmd: systemd-reload

hue-service:
  service.running:
    - enable: True
    - name: hue.service
    - watch:
      - file: {{ hue.conf_dir}}/hue.ini
