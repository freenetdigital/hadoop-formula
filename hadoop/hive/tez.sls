/usr/lib/tez:
  file.directory:
    - user: hive

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
          <value>/apps/tez/apache-tez-0.9.0-bin.tar.gz</value>
        </property>
        <property>
          <name>tez.use.cluster.hadoop-libs</name>
          <value>false</value>
        </property>
      </configuration>

install-tez:
  cmd.run:
    - cwd: /usr/lib
    - name: wget http://mirror.funkfreundelandshut.de/apache/tez/0.9.0/apache-tez-0.9.0-bin.tar.gz; tar xvf apache-tez-0.9.0-bin.tar.gz; mv apache-tez-0.9.0-bin/* /usr/lib/tez
    - unless: ls /usr/lib/tez/conf/tez-default-template.xml

copy-to-hdfs:
  cmd.run:
    - name: hadoop fs -copyFromLocal /usr/lib/apache-tez-0.9.0-bin.tar.gz /apps/
    - unless: hadoop fs -ls /apps/apache-tez-0.9.0-bin.tar.gz
