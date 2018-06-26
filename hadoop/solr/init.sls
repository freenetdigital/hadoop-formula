{%- from 'hadoop/settings.sls' import hadoop with context %}
{%- from 'hadoop/solr/settings.sls' import solr with context %}
{%- from 'hadoop/user_macro.sls' import hadoop_user with context %}

include:
  - hadoop.systemd
  
{%- set username = 'solr' %}
{%- set uid = hadoop.users[username] %}

{{ hadoop_user(username, uid, ssh=False) }}

solr-directory:
  file.directory:
    - name: {{ solr.install_dir }}
    - user: {{ username }}

solr-conf-directory:
  file.directory:
    - name: /etc/solr
    - user: {{ username }}

solr-directory-symlink:
  file.symlink:
    - target: {{ solr.install_dir }}
    - name: {{ solr.dir }}

download-solr-archive:
  cmd.run:
    - name: wget {{ solr.download_mirror }}/{{ solr.version }}/solr-{{ solr.version }}.zip
    - cwd: {{ solr.install_dir }}
    - user: {{ username }}
    - unless: test -f {{ solr.install_dir }}/bin/gateway.sh

{% set archive_dir = solr.install_dir + '/solr-' + solr.version %}
{% set archive = archive_dir + '.zip' %}

check-solr-archive:
  module.run:
    - name: file.check_hash
    - path: {{ archive }}
    - file_hash: {{ solr.hash }}
    - onchanges:
      - cmd: download-solr-archive     
    - require_in:
      - archive: unpack-solr-archive   

unpack-solr-archive:
  archive.extracted:
    - name: {{ solr.install_dir }}
    - source: file://{{ archive }}
    - archive_format: zip
    - user: {{ username }}
    - group: {{ username }}
    - onchanges:
      - cmd: download-solr-archive


cleanup-solr-directory:
  cmd.run:
    - name: mv {{ archive_dir }}/* {{ solr.install_dir }}; rm -rf {{ archive_dir }}*
    - onchanges:
      - archive: unpack-solr-archive

solr-conf-symlink:
  file.symlink:
    - target: {{ solr.install_dir }}/conf
    - name: {{ solr.conf_dir }}

#{% if grains['init'] == 'systemd' %}
#/etc/systemd/system/solr.service:
#  file.managed:
#    - source: salt://hadoop/files/solr.init.systemd
#    - user: root
#    - group: root
#    - mode: '644'
#    - template: jinja
#    - context:
#      dir: {{ solr.dir }}
#    - watch_in:
#      - cmd: systemd-reload
#
#{% endif %}
#
#{{ solr.conf_dir}}/gateway-site.xml:
#  file.managed:
#    - source: salt://hadoop/conf/solr/gateway-site.xml
#    - user: {{ username }}
#    - group: {{ username }}
#    - mode: '644'
#    - template: jinja
#    - watch_in:
#      - cmd: systemd-reload
#
#{{ solr.conf_dir}}/topologies/manager.xml:
#  file.managed:
#    - source: salt://hadoop/conf/solr/manager.xml
#    - user: {{ username }}
#    - group: {{ username }}
#    - mode: '600'
#    - template: jinja
#
#{{ solr.conf_dir}}/topologies/{{ grains['cluster_id'] }}.xml:
#  file.managed:
#    - source: salt://hadoop/conf/solr/cluster.xml
#    - user: {{ username }}
#    - group: {{ username }}
#    - mode: '600'
#    - template: jinja
#
#{% if solr.jmx_export %}
#{{ solr.conf_dir}}/jmx.yaml:
#  file.managed:
#    - source: salt://hadoop/conf/solr/jmx.yaml
#    - user: {{ username }}
#    - group: {{ username }}
#    - mode: '600'
#    - template: jinja
#
#{{ solr.install_dir}}/bin/gateway.sh:
#  file.replace:
#    - pattern: "^APP_MEM_OPTS.*"
#    - repl: 'APP_MEM_OPTS=" -javaagent:/var/lib/prometheus_jmx_javaagent/jmx_prometheus_javaagent-0.10.jar=27014:{{solr.conf_dir}}/jmx.yaml"'
#{% endif %} 
#
#solr-service:
#  service.running:
#    - enable: True
#    - name: solr.service
#
