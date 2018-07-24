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

hue-conf-directory:
  file.directory:
    - name: /etc/hue
    - user: {{ username }}

hue-directory-symlink:
  file.symlink:
    - target: {{ hue.install_dir }}
    - name: {{ hue.dir }}

{% if hue.download_mirror %}
download-hue-archive:
  cmd.run:
    - name: wget {{ hue.download_mirror }}/{{ hue.version }}/hue-{{ hue.version }}.tgz
    - cwd: {{ hue.install_dir }}
    - user: {{ username }}
    - unless: test -f {{ hue.install_dir }}/bin/gateway.sh
{% else %}
copy-hue-archive:
  archive.extracted:
    - name: {{ hue.install_dir }}
    - source: salt://hue/files/hue-{{ hue.version}}.tgz
    - archive_format: tar
    - clean: true
    - user: {{ username }}
    - group: {{ username }}
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

#hue-conf-symlink:
#  file.symlink:
#    - target: {{ hue.install_dir }}/conf
#    - name: {{ hue.conf_dir }}
#
#{% if grains['init'] == 'systemd' %}
#/etc/systemd/system/hue.service:
#  file.managed:
#    - source: salt://hadoop/files/hue.init.systemd
#    - user: root
#    - group: root
#    - mode: '644'
#    - template: jinja
#    - context:
#      dir: {{ hue.dir }}
#    - watch_in:
#      - cmd: systemd-reload
#
#{% endif %}
#
#{{ hue.conf_dir}}/gateway-site.xml:
#  file.managed:
#    - source: salt://hadoop/conf/hue/gateway-site.xml
#    - user: {{ username }}
#    - group: {{ username }}
#    - mode: '644'
#    - template: jinja
#    - watch_in:
#      - cmd: systemd-reload
#
#{{ hue.conf_dir}}/topologies/manager.xml:
#  file.managed:
#    - source: salt://hadoop/conf/hue/manager.xml
#    - user: {{ username }}
#    - group: {{ username }}
#    - mode: '600'
#    - template: jinja
#
#{{ hue.conf_dir}}/topologies/{{ grains['cluster_id'] }}.xml:
#  file.managed:
#    - source: salt://hadoop/conf/hue/cluster.xml
#    - user: {{ username }}
#    - group: {{ username }}
#    - mode: '600'
#    - template: jinja
#
#{{ hue.conf_dir}}/topologies/{{ grains['cluster_id'] }}-ranger.xml:
#  file.managed:
#    - source: salt://hadoop/conf/hue/ranger.xml
#    - user: {{ username }}
#    - group: {{ username }}
#    - mode: '600'
#    - template: jinja
#
#{% if hadoop.secure_mode %}
#{{ hue.conf_dir}}/krb5JAASLogin.conf:
#  file.managed:
#    - source: salt://hadoop/conf/hue/krb5JAASLogin.conf
#    - user: {{ username }}
#    - group: {{ username }}
#    - mode: '644'
#    - template: jinja
#
#/etc/krb5/hue.keytab:
#  file.managed:
#    - source: salt://kerberos/files/{{username}}-{{ grains['fqdn'] }}.keytab
#    - user: {{ username }}
#    - group: {{ username }}
#    - mode: '0400'
#
#{{ keystore('hue', ssl_conf=False) }}
#{% endif %}
#
#{% if hue.jmx_export %}
#{{ hue.conf_dir}}/jmx.yaml:
#  file.managed:
#    - source: salt://hadoop/conf/hue/jmx.yaml
#    - user: {{ username }}
#    - group: {{ username }}
#    - mode: '600'
#    - template: jinja
#
#{{ hue.install_dir}}/bin/gateway.sh:
#  file.replace:
#    - pattern: "^APP_MEM_OPTS.*"
#    - repl: 'APP_MEM_OPTS=" -javaagent:/var/lib/prometheus_jmx_javaagent/jmx_prometheus_javaagent-0.10.jar=27014:{{hue.conf_dir}}/jmx.yaml"'
#{% endif %} 
#
#hue-service:
#  service.running:
#    - enable: True
#    - name: hue.service
#
