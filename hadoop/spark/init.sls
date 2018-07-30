{%- from 'hadoop/settings.sls' import hadoop with context %}
{%- from 'hadoop/spark/settings.sls' import spark with context %}
{%- from 'hadoop/user_macro.sls' import hadoop_user with context %}

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
    - name: {{ spark.conf_dir}}
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
    - unless: test -f {{ spark.install_dir }}/spark-{{spark.version}}/VERSION

{% set archive_dir = spark.install_dir + '/spark-' + spark.version %}
{% set archive = archive_dir + '-' + spark.release + '.tgz' %}

check-solr-archive:
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
    - source: file://{{ spark.install_dir }}/spark-{{ spark.version}}-{{spark.release}}.tgz
    - archive_format: tar
    - user: {{ username }}
    - group: {{ username }}
    - onchanges:
      - cmd: download-spark-archive

spark-symlink:
  file.symlink:
    - target: {{ spark.install_dir}}/spark
    - name: {{spark.dir}}


