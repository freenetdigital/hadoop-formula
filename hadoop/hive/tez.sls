/usr/lib/tez:
  file.directory:
    - user: hive

/etc/tez/conf/tez-site.xml:
  file.managed:
    - makedirs: True
    - user: hive
    - contents: |
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <?xml-stylesheet type="text/xsl" href="configuration.xsl"?><!--
         Licensed to the Apache Software Foundation (ASF) under one or more
         contributor license agreements.  See the NOTICE file distributed with
         this work for additional information regarding copyright ownership.
         The ASF licenses this file to You under the Apache License, Version 2.0
         (the "License"); you may not use this file except in compliance with
         the License.  You may obtain a copy of the License at

             http://www.apache.org/licenses/LICENSE-2.0

         Unless required by applicable law or agreed to in writing, software
         distributed under the License is distributed on an "AS IS" BASIS,
         WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
         See the License for the specific language governing permissions and
         limitations under the License.
      --><configuration>
        <property>
          <name>tez.lib.uris</name>
          <value>/apps/apache-tez-0.9.0-bin.tar.gz</value>
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
