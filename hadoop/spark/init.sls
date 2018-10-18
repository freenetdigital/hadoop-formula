{%- from 'hadoop/settings.sls' import hadoop with context %}
{%- from 'hadoop/spark/settings.sls' import spark with context %}
{%- from 'hadoop/user_macro.sls' import hadoop_user with context %}
{%- set hive_target = 'G@role:hive and G@clustername:' + grains['cluster_id'] -%}
{%- set hive_grains = salt['mine.get'](hive_target, 'grains.item','compound') -%}

# this state does currently only deploy spark libs and config to be used by apache livy
# with this configuration, only spark on yarn mode is supported

include:
  - hadoop.systemd
  
{%- set username = 'spark' %}
{%- set uid = hadoop.users[username] %}

{{ hadoop_user(username, uid, ssh=False) }}

spark-directory:
  file.directory:
    - name: {{ spark.install_dir }}
    - user: {{ username }}

spark-conf-directory:
  file.directory:
    - name: /etc/spark
    - user: {{ username }}

spark-directory-symlink:
  file.symlink:
    - target: {{ spark.install_dir }}
    - name: {{ spark.dir }}

download-spark-archive:
  cmd.run:
    - name: wget {{ spark.download_mirror }}/spark-{{ spark.version }}/spark-{{ spark.version }}-{{ spark.release }}.tgz
    - cwd: {{ spark.install_dir }}
    - user: {{ username }}
    - unless: test -f {{ spark.install_dir }}/bin/spark-submit

{% set archive_dir = spark.install_dir + '/spark-' + spark.version + '-' + spark.release %}
{% set archive = archive_dir + '.tgz' %}

check-spark-archive:
  module.run:
    - name: file.check_hash
    - path: {{ archive }}
    - file_hash: {{ spark.hash }}
    - onchanges:
      - cmd: download-spark-archive    
    - require_in:
      - archive: unpack-spark-archive   


unpack-spark-archive:
  archive.extracted:
    - name: {{ spark.install_dir }}
    - source: file://{{ archive }}
    - archive_format: tar
    - user: {{ username }}
    - group: hadoop
    - onchanges:
      - cmd: download-spark-archive

cleanup-spark-directory:
  cmd.run:
    - name: mv {{ archive_dir }}/* {{ spark.install_dir }}; rm -rf {{ archive_dir }}*
    - onchanges:
      - archive: unpack-spark-archive

spark-symlink:
  file.symlink:
    - target: {{ spark.install_dir}}
    - name: {{spark.dir}}

spark-conf-symlink:
  file.symlink:
    - target: {{ spark.install_dir}}/conf
    - name: /etc/spark/conf

{%- if hive_grains.keys()|length > 0 %}
spark-create-hive-conf-dir:
  file.directory:
    - name: /etc/hive/conf
    - makedirs: true

hive-site.xml-for-spark:
  file.managed:
    - name: /etc/hive/conf/hive-site.xml
    - template: jinja
    - source: salt://hadoop/conf/hive/hive-site.xml.external

hive-site.xml-for-spark2:
  file.managed:
    - name: /etc/hadoop/conf/hive-site.xml
    - template: jinja
    - source: salt://hadoop/conf/hive/hive-site.xml.external
{% endif %}

/etc/spark/conf/spark-defaults.conf:
  file.managed:
    - template: jinja
    - source: salt://hadoop/conf/spark/spark-defaults.conf
    - user: {{ username }}
    - group: hadoop

{% for jar in spark.additional_jars %}
{{spark.install_dir}}/jars/{{jar}}:
  file.managed:
    - source: salt://spark/files/{{jar}}
    - user: {{ username }}
    - group: hadoop
{% endfor %}
