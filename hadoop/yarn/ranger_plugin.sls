{%- from 'hadoop/settings.sls' import hadoop with context %}
{%- from 'hadoop/yarn/settings.sls' import yarn with context %}
{%- from 'hadoop/ranger/settings.sls' import ranger with context %}

{%- set username = 'yarn' %}
{%- set uid = hadoop.users[username] %}

{% if yarn.ranger_plugin and yarn.is_resourcemanager %}

unpack-ranger-plugin-archive:
  archive.extracted:
    - name: {{ hadoop.alt_home}}/ranger_yarn_plugin
    - source: salt://ranger/ranger-{{ ranger.version }}/ranger-{{ ranger.version }}-yarn-plugin.zip
    - archive_format: zip
    - clean: true
    - user: {{ username }}
    - group: {{ username }}
    - unless: test -f {{ hadoop.alt_home }}/ranger_yarn_plugin/enable-yarn-plugin.sh

move-plugin-files:
  cmd.run:
    - name: mv {{ hadoop.alt_home}}/ranger_yarn_plugin/ranger-{{ ranger.version }}-yarn-plugin/* {{ hadoop.alt_home}}/ranger_yarn_plugin/; rm -rf {{ hadoop.alt_home}}/ranger_yarn_plugin/ranger-{{ ranger.version }}-yarn-plugin
    - onchanges:
      - archive: unpack-ranger-plugin-archive


#{{ hadoop.alt_home }}/ranger_yarn_plugin/install.properties:
#  file.managed:
#    - source: salt://hadoop/conf/yarn/ranger.install.properties
#    - user: {{ username }}
#    - group: {{ username }}
#    - mode: '644'
#    - template: jinja
#
#provision-ranger-yarn-plugin:
#  cmd.run:
#    - name: bash -c './enable-yarn-plugin.sh'
#    - cwd: {{ hadoop.alt_home }}/ranger_yarn_plugin
#    - env:
#      - JAVA_HOME: '/usr/lib/java'
#    - onchanges:
#      - file: {{ hadoop.alt_home }}/ranger_yarn_plugin/install.properties
#
##{{ hadoop.alt_config}}/ranger-hdfs-security.xml:
##  file.managed:
##    - source: salt://hadoop/conf/hdfs/ranger-hdfs-security.xml
##    - user: {{ username }}
##    - group: {{ username }}
##    - mode: '644'
##    - template: jinja
#
#yarn-service:
#  service.running:
#    - enable: True
#    - name: hadoop-resourcemanager
#    - watch:
#      - cmd: provision-ranger-yarn-plugin
#{% endif %}
