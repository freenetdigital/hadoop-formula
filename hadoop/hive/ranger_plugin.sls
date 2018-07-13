{%- from 'hadoop/settings.sls' import hadoop with context %}
{%- from 'hadoop/hive/settings.sls' import hive with context %}
{%- from 'hadoop/ranger/settings.sls' import ranger with context %}

{%- set username = 'hive' %}
{%- set uid = hadoop.users[username] %}

{% if hive.ranger_plugin %}

unpack-ranger-hive-plugin-archive:
  archive.extracted:
    - name: {{ hadoop.alt_home}}/ranger_hive_plugin
    - source: salt://ranger/ranger-{{ ranger.version }}/ranger-{{ ranger.version }}-hive-plugin.zip
    - archive_format: zip
    - clean: true
    - user: {{ username }}
    - group: {{ username }}
    - unless: test -f {{ hadoop.alt_home }}/ranger_hive_plugin/enable-hive-plugin.sh

move-hive-plugin-files:
  cmd.run:
    - name: mv {{ hadoop.alt_home}}/ranger_hive_plugin/ranger-{{ ranger.version }}-hive-plugin/* {{ hadoop.alt_home}}/ranger_hive_plugin/; rm -rf {{ hadoop.alt_home}}/ranger_hive_plugin/ranger-{{ ranger.version }}-hive-plugin
    - onchanges:
      - archive: unpack-ranger-hive-plugin-archive


#{{ hadoop.alt_home }}/ranger_hive_plugin/install.properties:
#  file.managed:
#    - source: salt://hadoop/conf/hive/ranger.install.properties
#    - user: {{ username }}
#    - group: {{ username }}
#    - mode: '600'
#    - template: jinja
#
#provision-ranger-hive-plugin:
#  cmd.run:
#    - name: bash -c './enable-hive-plugin.sh'
#    - cwd: {{ hadoop.alt_home }}/ranger_hive_plugin
#    - env:
#      - JAVA_HOME: '/usr/lib/java'
#    - onchanges:
#      - file: {{ hadoop.alt_home }}/ranger_hive_plugin/install.properties
#
#hive-service:
#  service.running:
#    - enable: True
#    - name: hadoop-resourcemanager
#    - watch:
#      - cmd: provision-ranger-hive-plugin
{% endif %}
