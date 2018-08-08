{%- from 'hadoop/settings.sls' import hadoop with context %}
{%- from 'hadoop/livy/settings.sls' import livy with context %}
{%- from 'hadoop/user_macro.sls' import hadoop_user with context %}
{%- from 'hadoop/keystore_macro.sls' import keystore with context %}
{%- from 'hadoop/keystore_macro.sls' import keystore with context %}

include:
  - hadoop.systemd
  
{%- set username = 'livy' %}
{%- set uid = hadoop.users[username] %}

{{ hadoop_user(username, uid, ssh=False) }}

livy-directory:
  file.directory:
    - name: {{ livy.install_dir }}
    - user: {{ username }}

livy-conf-directory:
  file.directory:
    - name: /etc/livy
    - user: {{ username }}

livy-directory-symlink:
  file.symlink:
    - target: {{ livy.install_dir }}
    - name: {{ livy.dir }}

download-livy-archive:
  cmd.run:
    - name: wget {{ livy.download_mirror }}/{{ livy.version }}-incubating/livy-{{ livy.version }}-{{ livy.release }}.zip
    - cwd: {{ livy.install_dir }}
    - user: {{ username }}
    - unless: test -f {{ livy.install_dir }}/bin/livy-server

{% set archive_dir = livy.install_dir + '/livy-' + livy.version + '-' + livy.release %}
{% set archive = archive_dir + '.zip' %}

check-livy-archive:
  module.run:
    - name: file.check_hash
    - path: {{ archive }}
    - file_hash: {{ livy.hash }}
    - onchanges:
      - cmd: download-livy-archive    
    - require_in:
      - archive: unpack-livy-archive   


unpack-livy-archive:
  archive.extracted:
    - name: {{ livy.install_dir }}
    - source: file://{{ archive }}
    - archive_format: zip
    - user: {{ username }}
    - group: hadoop
    - onchanges:
      - cmd: download-livy-archive

cleanup-livy-directory:
  cmd.run:
    - name: mv {{ archive_dir }}/* {{ livy.install_dir }}; rm -rf {{ archive_dir }}*
    - onchanges:
      - archive: unpack-livy-archive

livy-symlink:
  file.symlink:
    - target: {{ livy.install_dir}}
    - name: {{livy.dir}}

livy-conf-symlink:
  file.symlink:
    - target: {{ livy.install_dir}}/conf
    - name: /etc/livy/conf

livy-logs-directory:
  file.directory:
    - name: {{ livy.install_dir }}/logs
    - user: {{ username }}

livy-logs-symlink:
  file.symlink:
    - target: {{ livy.install_dir}}/logs
    - name: /var/log/livy

/etc/livy/conf/livy.conf:
  file.managed:
    - source: salt://hadoop/conf/livy/livy.conf
    - user: {{username}}
    - group: {{username}}
    - mode: '644'
    - template: jinja
    - context:
      username: {{ username }}
      keystore_pass: {{ hadoop.keystore_pass }}

/etc/livy/conf/livy-env.sh:
  file.managed:
    - source: salt://hadoop/conf/livy/livy-env.sh
    - user: {{username}}
    - group: {{username}}
    - mode: '755'
    - template: jinja

/etc/default/livy.env:
  file.managed:
    - source: salt://hadoop/conf/livy/livy.env
    - user: {{username}}
    - group: {{username}}
    - mode: '755'
    - template: jinja

{{ livy.install_dir}}/upload_jars.sh:
  file.managed:
    - source: salt://hadoop/conf/livy/upload_jars.sh
    - user: {{username}}
    - group: {{username}}
    - mode: '755'
    - template: jinja

/etc/livy/conf/spark-blacklist.conf:
  file.managed:
    - source: salt://hadoop/conf/livy/spark-blacklist.conf
    - user: {{username}}
    - group: {{username}}
    - mode: '644'
    - template: jinja

{% if livy.jmx_export %}
/etc/livy/conf/jmx.yaml:
  file.managed:
    - source: salt://hadoop/conf/livy/jmx.yaml
    - user: {{username}}
    - group: {{username}}
    - mode: '755'
    - template: jinja
{% endif %}

{% if hadoop.secure_mode %}

{{ keystore(username, ssl_conf=False)}}

/etc/krb5/livy.keytab:
  file.managed:
    - source: salt://kerberos/files/{{username}}-{{ grains['fqdn'] }}.keytab
    - user: {{ username }}
    - group: {{ username }}
    - mode: '0400'

/etc/krb5/spnego.livy.keytab:
  file.managed:
    - source: salt://kerberos/files/spnego-{{ grains['fqdn'] }}.keytab
    - user: {{ username }}
    - group: {{ username }}
    - mode: '0400'
{% endif %}

/etc/systemd/system/livy.service:
  file.managed:
    - source: salt://hadoop/files/livy.init.systemd
    - user: root
    - group: root
    - mode: '644'
    - template: jinja
    - context:
      dir: {{ livy.dir }}
      username: {{ username }}
    - watch_in:
      - cmd: systemd-reload

livy-service:
  service.running:
    - enable: True
    - name: livy.service
    - watch:
      - file: /etc/livy/conf/livy.conf

