{% from 'hadoop/settings.sls' import hadoop with context %}
{% set version = salt['pillar.get']('hive:tez:version', '0.9.0') %}

tez-directory-symlink:
  file.symlink:
    - target: /usr/lib/apache-tez-{{ version }}-bin
    - name: /usr/lib/tez

/etc/hive/conf/tez-site.xml:
  file.managed:
    - makedirs: True
    - user: hive
    - template: jinja
    - source: salt://hadoop/conf/hive/tez-site.xml

install-tez:
  cmd.run:
    - cwd: /usr/lib
    - name: wget http://apache.lauf-forum.at/tez/{{ version }}/apache-tez-{{ version }}-bin.tar.gz; tar xvf apache-tez-{{ version }}-bin.tar.gz 
    - unless: ls /usr/lib/apache-tez-{{ version }}-bin/conf/tez-default-template.xml

{% if not hadoop.secure_mode %}
copy-to-hdfs:
  cmd.run:
    - user: hdfs
    - name: hdfs dfs -put /usr/lib/apache-tez-{{ version }}-bin/share/tez.tar.gz /apps/tez/
    - unless: hdfs dfs -ls /apps/tez/tez.tar.gz

chown-as-hive:
  cmd.run:
    - user: hdfs
    - name: hdfs dfs -chown -R hive /apps/tez
{% endif %}
