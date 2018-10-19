{%- from 'hadoop/settings.sls' import hadoop with context %}
{%- from 'hadoop/nifi/settings.sls' import nifi with context %}
{%- from 'hadoop/user_macro.sls' import hadoop_user with context %}
{%- from 'hadoop/keystore_macro.sls' import keystore with context %}

include:
  - hadoop.systemd
  
{%- set username = 'nifi' %}
{%- set uid = hadoop.users[username] %}

{{ hadoop_user(username, uid, ssh=False) }}

nifi-reg-directory:
  file.directory:
    - name: {{ nifi.reg_install_dir }}
    - user: {{ username }}

nifi-reg-data-directory:
  file.directory:
    - name: {{ nifi.data_dir }}
    - user: {{ username }}

nifi-conf-directory:
  file.directory:
    - name: /etc/nifi-registry
    - user: {{ username }}

nifi-reg-directory-symlink:
  file.symlink:
    - target: {{ nifi.reg_install_dir }}
    - name: {{ nifi.reg_dir }}

download-nifi-reg-archive:
  cmd.run:
    - name: wget {{ nifi.reg_download_mirror }}/nifi-registry/nifi-registry-{{ nifi.reg_version }}/nifi-registry-{{ nifi.reg_version }}-bin.zip
    - cwd: {{ nifi.reg_install_dir }}
    - user: {{ username }}
    - unless: test -f {{ nifi.reg_install_dir }}/bin/nifi-registry.sh

{% set reg_archive_dir = nifi.reg_install_dir + '/nifi-registry-' + nifi.reg_version %}
{% set reg_archive = reg_archive_dir + '-bin.zip' %}

check-nifi-reg-archive:
  module.run:
    - name: file.check_hash
    - path: {{ reg_archive }}
    - file_hash: {{ nifi.reg_hash }}
    - onchanges:
      - cmd: download-nifi-reg-archive    
    - require_in:
      - archive: unpack-nifi-reg-archive   

unpack-nifi-reg-archive:
  archive.extracted:
    - name: {{ nifi.reg_install_dir }}
    - source: file://{{ reg_archive }}
    - archive_format: zip
    - user: {{ username }}
    - group: hadoop
    - onchanges:
      - cmd: download-nifi-reg-archive

cleanup-nifi-reg-directory:
  cmd.run:
    - name: mv {{ reg_archive_dir }}/* {{ nifi.reg_install_dir }}; rm -rf {{ reg_archive_dir }}*
    - onchanges:
      - archive: unpack-nifi-reg-archive

nifi-reg-symlink:
  file.symlink:
    - target: {{ nifi.reg_install_dir}}
    - name: {{nifi.reg_dir}}

nifi-reg-conf-symlink:
  file.symlink:
    - target: {{ nifi.reg_install_dir}}/conf
    - name: /etc/nifi-registry/conf

nifi-reg-logs-directory:
  file.directory:
    - name: /var/log/nifi-registry
    - user: {{ username }}

nifi-reg-log-symlink:
  file.symlink:
    - target: /var/log/nifi-registry
    - name: {{ nifi.reg_install_dir}}/logs

/etc/nifi-registry/conf/nifi-registry.properties:
  file.managed:
    - source: salt://hadoop/conf/nifi/nifi-registry.properties
    - user: {{username}}
    - group: {{username}}
    - mode: '644'
    - template: jinja
    - context:
      username: {{ username }}
      keystore_pass: {{ hadoop.keystore_pass }}

{{nifi.reg_install_dir}}/bin/nifi-registry-env.sh:
  file.managed:
    - source: salt://hadoop/conf/nifi/nifi-registry-env.sh
    - user: {{username}}
    - group: {{username}}
    - mode: '755'
    - template: jinja

/etc/nifi-registry/conf/authorizers.xml:
  file.managed:
    - source: salt://hadoop/conf/nifi/authorizers-registry.xml
    - user: {{username}}
    - group: {{username}}
    - mode: '644'
    - template: jinja

/etc/nifi-registry/conf/bootstrap.conf:
  file.managed:
    - source: salt://hadoop/conf/nifi/bootstrap-registry.conf
    - user: {{username}}
    - group: {{username}}
    - mode: '644'
    - template: jinja
    - context:
      username: {{ username }}

/etc/nifi-registry/conf/providers.xml:
  file.managed:
    - source: salt://hadoop/conf/nifi/providers.xml
    - user: {{username}}
    - group: {{username}}
    - mode: '644'
    - template: jinja
    - context:
      username: {{ username }}

/etc/nifi-registry/conf/identity-providers.xml:
  file.managed:
    - source: salt://hadoop/conf/nifi/identity-providers.xml
    - user: {{username}}
    - group: {{username}}
    - mode: '644'
    - template: jinja

{% if nifi.jmx_export %}
/etc/nifi-registry/conf/jmx.yaml:
  file.managed:
    - source: salt://hadoop/conf/nifi/jmx.yaml
    - user: {{username}}
    - group: {{username}}
    - mode: '755'
    - template: jinja
{% endif %}


{% if hadoop.secure_mode %}
{{ keystore(username, ssl_conf=False)}}
{% endif %}

/etc/systemd/system/nifi-registry.service:
  file.managed:
    - source: salt://hadoop/files/nifi-registry.init.systemd
    - user: root
    - group: root
    - mode: '644'
    - template: jinja
    - context:
      reg_dir: {{ nifi.reg_dir }}
      username: {{ username }}
    - watch_in:
      - cmd: systemd-reload

nifi-registry-service:
  service.running:
    - enable: True
    - name: nifi-registry.service
    - watch:
      - file: /etc/nifi-registry/conf/nifi-registry.properties

