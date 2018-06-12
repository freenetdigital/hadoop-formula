{%- from 'hadoop/hive/settings.sls' import hive with context %}
{%- from 'hadoop/settings.sls' import hadoop with context %}

{% set db = hive.metastore_db %}
{% set user = hive.metastore_user %}
{% set pass = hive.metastore_pass %}
{% set schema_file = hive.metastore_schema_file %}

{% set conn = "mysql-connector-java-5.1.45" %}
{% set conn_tar = conn + ".tar.gz" %}

#{{ user }}-user-creation:
#  mysql_user.present:
#    - name: {{ user }}
#    - host: localhost
#    - password: {{ pass }}
#    - connection_pass: {{ hive.admin_password }}
#    - connection_user: {{ hive.admin_username }}
#
#{{ db }}-db-creation:
#  mysql_database.present:
#    - name: {{ db }}
#    - connection_pass: {{ hive.admin_password }}
#    - connection_user: {{ hive.admin_username }}
#
#grant-{{user}}-{{ db }}:
#  mysql_grants.present:
#    - grant: all privileges
#    - database: {{ db }}.*
#    - user: {{ user }}
#    - connection_pass: {{ hive.admin_password }}
#    - connection_user: {{ hive.admin_username }}
#
#load-schema-from-{{ schema_file }}:
#  cmd.run:
#    - name: mysql -u {{ hive.admin_username }} -hlocalhost {{ db }} < {{ schema_file }}
#    - unless: mysql -D hive -e "select SCHEMA_VERSION from VERSION;" -s -N
#
download-and-copy-mysql-connector:
  cmd.run:
    - cwd: {{ hive.dir }}
    - name: wget https://dev.mysql.com/get/Downloads/Connector-J/{{ conn_tar }}; tar -xvf {{ conn_tar }}; cp {{ conn }}/{{ conn }}-bin.jar {{ hive.dir }}/lib/; rm -rf {{ conn }}*
    - unless: ls /usr/lib/hive/lib/mysql-connector-java-5.1.45-bin.jar

init-schema:
  cmd.run:
    - name: bash -c "export HADOOP_LIBEXEC_DIR={{ hadoop.alt_home }}/libexec; {{ hive.install_dir}}/bin/schematool -dbType mysql -initSchema"
    - unless: bash -c "export HADOOP_LIBEXEC_DIR={{ hadoop.alt_home }}/libexec; {{ hive.install_dir}}/bin/schematool -dbType mysql -validate"

##TODO setup ssl truststore
##https://community.hortonworks.com/articles/72475/connect-hiveserver2-to-mysql-metastore-over-ssl-1.html
#
##TODO
## create /root/.my.cnf with 0600
## [mysql]
## user=uuuu
## password=aaaa
