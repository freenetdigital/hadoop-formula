{% set db = "hive" %}
{% set user = "hive" %}
{% set pass = "hive" %}
{% set schema_file = "/usr/lib/hive/scripts/metastore/upgrade/mysql/hive-schema-2.3.0.mysql.sql" %}
  
{% set cpp =  salt['pillar.get']('hive:mysql:pass', 'default') %}
{% set cpu =  salt['pillar.get']('hive:mysql:user', 'default') %}

{{ user }}-user-creation:
  mysql_user.present:
    - name: {{ user }}
    - host: localhost
    - password: {{ pass }}
    - connection_pass: {{ cpp }}
    - connection_user: {{ cpu }}

{{ db }}-db-creation:
  mysql_database.present:
    - name: {{ db }}
    - connection_pass: {{ cpp }}
    - connection_user: {{ cpu }}

grant-{{user}}-{{ db }}:
  mysql_grants.present:
    - grant: all privileges
    - database: {{ db }}.*
    - user: {{ user }}
    - connection_pass: {{ cpp }}
    - connection_user: {{ cpu }}

load-hive-schema:
  mysql_query.run_file:
    - database: {{ db }}
    - query_file: {{ schema_file }}
    - connection_pass: {{ cpp }}
    - connection_user: {{ cpu }}

#TODO add mysql connector
# wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.45.tar.gz
# tar -xvf mysql-connector-java-5.1.45.tar.gz 
# cp mysql-connector-java-5.1.45/mysql-connector-java-5.1.45-bin.jar /usr/lib/hive/lib/

download-and-copy-mysql-connector:
  cmd.run:
    - cwd: /usr/lib
    - name: wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.45.tar.gz; tar -xvf mysql-connector-java-5.1.45.tar.gz; cp mysql-connector-java-5.1.45/mysql-connector-java-5.1.45-bin.jar /usr/lib/hive/lib/
    - user: hive
    - unless: ls /usr/lib/hive/lib/mysql-connector-java-5.1.45-bin.jar


#TODO setup ssl truststore
#https://community.hortonworks.com/articles/72475/connect-hiveserver2-to-mysql-metastore-over-ssl-1.html

#TODO
# create /root/.my.cnf with 0600
# [mysql]
# user=uuuu
# password=aaaa
