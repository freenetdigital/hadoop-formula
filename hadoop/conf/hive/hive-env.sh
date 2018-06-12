{%- if jmx_export %}
export HADOOP_CLIENT_OPTS="$HADOOP_CLIENT_OPTS -javaagent:/var/lib/prometheus_jmx_javaagent/jmx_prometheus_javaagent-0.10.jar=27011:/etc/hive/conf/jmx_hive.yaml"
{% endif %} 
