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

#solr-conf-directory:
#  file.directory:
#    - name: {{ solr.conf_dir }}
#    - user: {{ username }}

solr-data-directory:
  file.directory:
    - name: {{ solr.data_dir }}
    - user: {{ username }}

solr-home-directory:
  file.directory:
    - name: {{ solr.home_dir }}
    - user: {{ username }}

solr-logs-directory:
  file.directory:
    - name: {{ solr.log_dir }}
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
    - unless: test -f {{ solr.install_dir }}/bin/solr

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

{% if grains['init'] == 'systemd' %}
/etc/systemd/system/solr.service:
  file.managed:
    - source: salt://hadoop/files/solr.init.systemd
    - user: root
    - group: root
    - mode: '644'
    - template: jinja
    - watch_in:
      - cmd: systemd-reload

{% if solr.jmx_export %}
/etc/systemd/system/solr-exporter.service:
  file.managed:
    - source: salt://hadoop/files/solr-exporter.init.systemd
    - user: root
    - group: root
    - mode: '644'
    - template: jinja
    - watch_in:
      - cmd: systemd-reload
{% endif %}
{% endif %}

/etc/default/solr.in.sh:
  file.managed:
    - source: salt://hadoop/conf/solr/solr.in.sh
    - user: root
    - group: {{ username }}
    - mode: '640'
    - template: jinja
    - watch_in:
      - cmd: systemd-reload

{{ solr.home_dir }}/solr.xml:
  file.managed:
    - source: salt://hadoop/conf/solr/solr.xml
    - user: {{ username }}
    - group: {{ username }}
    - mode: '640'
    - template: jinja

solr-service:
  service.running:
    - enable: True
    - name: solr.service
