{%- from 'hadoop/settings.sls' import hadoop with context %}
{%- from 'hadoop/knox/settings.sls' import knox with context %}
{%- from 'hadoop/ranger/settings.sls' import ranger with context %}

{%- set username = 'knox' %}
{%- set uid = hadoop.users[username] %}

{% if knox.ranger_plugin %}

unpack-ranger-knox-plugin-archive:
  archive.extracted:
    - name: {{ knox.install_dir}}/ranger_knox_plugin
    - source: salt://ranger/ranger-{{ ranger.version }}/ranger-{{ ranger.version }}-knox-plugin.zip
    - archive_format: zip
    - clean: true
    - user: {{ username }}
    - group: {{ username }}
    - unless: test -f {{ knox.install_dir }}/ranger_knox_plugin/enable-knox-plugin.sh

move-knox-plugin-files:
  cmd.run:
    - name: mv {{ knox.install_dir}}/ranger_knox_plugin/ranger-{{ ranger.version }}-knox-plugin/* {{ knox.install_dir}}/ranger_knox_plugin/; rm -rf {{ knox.install_dir}}/ranger_knox_plugin/ranger-{{ ranger.version }}-knox-plugin
    - onchanges:
      - archive: unpack-ranger-knox-plugin-archive


#{{ knox.install_dir }}/ranger_knox_plugin/install.properties:
#  file.managed:
#    - source: salt://hadoop/conf/knox/ranger.install.properties
#    - user: {{ username }}
#    - group: {{ username }}
#    - mode: '644'
#    - template: jinja
#
#provision-ranger-knox-plugin:
#  cmd.run:
#    - name: bash -c './enable-knox-plugin.sh'
#    - cwd: {{ knox.install_dir }}/ranger_knox_plugin
#    - env:
#      - JAVA_HOME: '/usr/lib/java'
#    - onchanges:
#      - file: {{ knox.install_dir }}/ranger_knox_plugin/install.properties
#
#knox-service:
#  service.running:
#    - enable: True
#    - name: hadoop-resourcemanager
#    - watch:
#      - cmd: provision-ranger-knox-plugin
{% endif %}
