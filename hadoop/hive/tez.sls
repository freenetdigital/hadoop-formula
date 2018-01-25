{% set version = salt['pillar.get']('hive:tez:version', '0.9.0') %}

tez-directory-symlink:
  file.symlink:
    - target: /usr/lib/tez-{{ version }}-bin
    - name: /usr/lib/tez

/etc/hive/conf/tez-site.xml:
  file.managed:
    - makedirs: True
    - user: hive
    - contents: |
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
      <configuration>
        <property>
          <name>tez.lib.uris</name>
          <value>/apps/tez/apache-tez-{{ version }}-bin/share/tez.tar.gz</value>
        </property>
        <property>
          <name>tez.use.cluster.hadoop-libs</name>
          <value>false</value>
        </property>
      </configuration>

install-tez:
  cmd.run:
    - cwd: /usr/lib
    - name: wget http://mirror.funkfreundelandshut.de/apache/tez/{{ version }}/apache-tez-{{ version }}-bin.tar.gz; tar xvf apache-tez-{{ version }}-bin.tar.gz 
    - unless: ls /usr/lib/tez-{{ version }}-bin/conf/tez-default-template.xml

copy-to-hdfs:
  cmd.run:
    - user: hdfs
    - name: hadoop fs -copyFromLocal /usr/lib/tez-{{ version }}-bin /apps/tez/
    - unless: hadoop fs -ls /apps/tez/apache-tez-{{ version }}-bin/share/tez.tar.gz

chown-as-hive:
  cmd.run:
    - user: hdfs
    - name: hadoop fs -chown -R hive /apps/tez
