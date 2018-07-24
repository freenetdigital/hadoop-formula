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
    - name: wget {{ hue.download_mirror }}/{{ hue.version }}/hue-{{ hue.version }}.tgz
    - cwd: {{ hue.download_dir }}
    - user: {{ username }}
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

hue-conf-symlink:
  file.symlink:
    - target: {{ hue.install_dir}}/hue/desktop/conf
    - name: {{ hue.conf_dir}}

{{ hue.conf_dir}}/hue.ini:
  file.managed:
    - source: salt://hadoop/conf/hue/hue.ini
    - user: {{ username }}
    - group: {{ username }}
    - mode: '600'
    - template: jinja

/etc/krb5/hue.keytab:
  file.managed:
    - source: salt://kerberos/files/{{username}}-{{ grains['fqdn'] }}.keytab
    - user: {{ username }}
    - group: {{ username }}
    - mode: '0400'
