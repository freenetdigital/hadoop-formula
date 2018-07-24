{%- from 'hadoop/settings.sls' import hadoop with context %}
{%- from 'hadoop/hue/settings.sls' import hue with context %}
{%- from 'hadoop/user_macro.sls' import hadoop_user with context %}
{%- from 'hadoop/keystore_macro.sls' import keystore with context %}

include:
  - hadoop.systemd
  
{%- set username = 'hue' %}
{%- set uid = hadoop.users[username] %}

{{ hadoop_user(username, uid, ssh=False) }}

hue-directory:
  file.directory:
    - name: {{ hue.install_dir }}
    - user: {{ username }}


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
