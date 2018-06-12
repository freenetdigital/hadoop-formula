{%- if jmx_export %}
export HIVE_SERVER2_HADOOP_OPTS="$HIVE_SERVER2_HADOOP_OPTS -javaagent:/var/lib/prometheus_jmx_javaagent/jmx_prometheus_javaagent-0.10.jar=27011:/etc/hive/conf/jmx_hive.yaml"
export HIVE_METASTORE_HADOOP_OPTS="$HIVE_METASTORE_HADOOP_OPTS -javaagent:/var/lib/prometheus_jmx_javaagent/jmx_prometheus_javaagent-0.10.jar=27012:/etc/hive/conf/jmx_metastore.yaml"
{% endif %} 
