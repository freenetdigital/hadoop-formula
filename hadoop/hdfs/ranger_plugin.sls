{%- from 'hadoop/settings.sls' import hadoop with context %}
{%- from 'hadoop/hdfs/settings.sls' import hdfs with context %}
{%- from 'hadoop/ranger/settings.sls' import ranger with context %}

{%- set username = 'hdfs' %}
{%- set uid = hadoop.users[username] %}

{% if hdfs.ranger_plugin and hdfs.is_namenode %}

unpack-ranger-plugin-archive:
  archive.extracted:
    - name: {{ hadoop.alt_home}}/ranger_plugin
    - source: salt://ranger/ranger-{{ ranger.version }}/ranger-{{ ranger.version }}-hdfs-plugin.zip
    - archive_format: zip
    - clean: true
    - user: {{ username }}
    - group: {{ username }}
    - unless: test -f {{ hadoop.alt_home }}/ranger_plugin/enable-hdfs-plugin.sh

move-plugin-files:
  cmd.run:
    - name: mv {{ hadoop.alt_home}}/ranger_plugin/ranger-{{ ranger.version }}-hdfs-plugin/* {{ hadoop.alt_home}}/ranger_plugin/; rm -rf {{ hadoop.alt_home}}/ranger_plugin/ranger-{{ ranger.version }}-hdfs-plugin
    - onchanges:
      - archive: unpack-ranger-plugin-archive


{{ hadoop.alt_home }}/ranger_plugin/install.properties:
  file.managed:
    - source: salt://hadoop/conf/hdfs/ranger.install.properties
    - user: {{ username }}
    - group: {{ username }}
    - mode: '644'
    - template: jinja

provision-ranger-hdfs-plugin:
  cmd.run:
    - name: bash -c './enable-hdfs-plugin.sh'
    - cwd: {{ hadoop.alt_home }}/ranger_plugin
    - env:
      - JAVA_HOME: '/usr/lib/java'
    - onchanges:
      - file: {{ hadoop.alt_home }}/ranger_plugin/install.properties

{{ hadoop.alt_config}}/ranger-hdfs-security.xml:
  file.managed:
    - source: salt://hadoop/conf/hdfs/ranger-hdfs-security.xml
    - user: {{ username }}
    - group: {{ username }}
    - mode: '644'
    - template: jinja

hdfs-service:
  service.running:
    - enable: True
    - name: hadoop-namenode
    - watch:
      - cmd: provision-ranger-hdfs-plugin
{% endif %}
