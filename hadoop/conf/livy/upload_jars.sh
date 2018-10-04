#!/bin/bash

# run as livy: 'sudo -u livy upload_jars.sh'

# read env parameters
set -o allexport
source /etc/default/livy.env
source /etc/default/hadoop-systemd
set +o allexport

LIVY_HOME=/usr/lib/livy
#init kerberos auth
kinit -k -t /etc/krb5/livy.keytab livy/{{ grains['fqdn']}}@{{grains['cluster_id'] | upper }}

# create dirs if missing
hdfs dfs -mkdir /apps/livy/
hdfs dfs -mkdir /apps/livy/rsc-jars
hdfs dfs -mkdir /apps/livy/repl_2.10-jars
hdfs dfs -mkdir /apps/livy/repl_2.11-jars
hdfs dfs -mkdir /apps/spark

# upload rsc-jars
for rsc in $LIVY_HOME/rsc-jars/*.jar; do
        name=${rsc##*/}
        hdfs dfs -rm /apps/livy/rsc-jars/$name
        hdfs dfs -put $rsc /apps/livy/rsc-jars/
done

# upload repl jars
for repl210 in $LIVY_HOME/repl_2.10-jars/*.jar; do
        name=${repl210##*/}
        hdfs dfs -rm /apps/livy/repl_2.10-jars/$name
        hdfs dfs -put $repl210 /apps/livy/repl_2.10-jars/
done
for repl211 in $LIVY_HOME/repl_2.11-jars/*.jar; do
        name=${repl211##*/}
        hdfs dfs -rm /apps/livy/repl_2.11-jars/$name
        hdfs dfs -put $repl211 /apps/livy/repl_2.11-jars/
done

# upload spark
${JAVA_HOME}/bin/jar cv0f /home/livy/spark-libs.jar -C ${SPARK_HOME}/jars/ .
hdfs dfs -rm /apps/spark/spark-libs.jar
hdfs dfs -put /home/livy/spark-libs.jar /apps/spark/

hdfs dfs -rm /apps/spark/sparkr.zip
hdfs dfs -put ${SPARK_HOME}/R/lib/sparkr.zip /apps/spark/

hdfs dfs -rm /apps/spark/pyspark.zip
hdfs dfs -rm /apps/spark/py4j-0.10.7-src.zip
hdfs dfs -put ${SPARK_HOME}/python/lib/pyspark.zip /apps/spark/
hdfs dfs -put ${SPARK_HOME}/python/lib/py4j-0.10.7-src.zip /apps/spark/
