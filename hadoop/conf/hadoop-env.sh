export JAVA_HOME={{ java_home }}
export HADOOP_PREFIX={{ hadoop_home }}
export HADOOP_CONF_DIR={{ hadoop_config }}
export PATH=$HADOOP_PREFIX/bin:$HADOOP_PREFIX/sbin:${JAVA_HOME}/bin:$PATH

export HADOOP_HEAPSIZE=1024
export JMX_OPTS=" -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote -Djava.rmi.server.hostname=127.0.0.1"
{%- if jmx_export %}
export JMX_HDFS_NN=" -javaagent:/var/lib/prometheus_jmx_javaagent/jmx_prometheus_javaagent-0.10.jar=27001:{{ hadoop_config }}/jmx_hdfs_nn.yaml"
export JMX_HDFS_DN=" -javaagent:/var/lib/prometheus_jmx_javaagent/jmx_prometheus_javaagent-0.10.jar=27003:{{ hadoop_config }}/jmx_hdfs_dn.yaml"

export HADOOP_NAMENODE_OPTS="$JMX_OPTS -Dcom.sun.management.jmxremote.port=26001 $JMX_HDFS_NN"
export HADOOP_DATANODE_OPTS="$JMX_OPTS -Dcom.sun.management.jmxremote.port=26003 $JMX_HDFS_DN"
export HADOOP_ZKFC_OPTS=" -javaagent:/var/lib/prometheus_jmx_javaagent/jmx_prometheus_javaagent-0.10.jar=27008:{{ hadoop_config }}/jmx_hdfs_zkfc.yaml"
export HADOOP_JOURNALNODE_OPTS=" -javaagent:/var/lib/prometheus_jmx_javaagent/jmx_prometheus_javaagent-0.10.jar=27007:{{ hadoop_config }}/jmx_hdfs_jn.yaml"
{% else %}
export HADOOP_NAMENODE_OPTS="$JMX_OPTS -Dcom.sun.management.jmxremote.port=26001 $HADOOP_NAMENODE_OPTS"
export HADOOP_DATANODE_OPTS="$JMX_OPTS -Dcom.sun.management.jmxremote.port=26003 $HADOOP_DATANODE_OPTS"
{% endif %} 
export HADOOP_SECONDARYNAMENODE_OPTS="$JMX_OPTS -Dcom.sun.management.jmxremote.port=26002 $HADOOP_SECONDARYNAMENODE_OPTS"
export HADOOP_BALANCER_OPTS="$JMX_OPTS -Dcom.sun.management.jmxremote.port=26004 $HADOOP_BALANCER_OPTS"
export HADOOP_JOBTRACKER_OPTS="$JMX_OPTS -Dcom.sun.management.jmxremote.port=26005 $HADOOP_JOBTRACKER_OPTS"
export HADOOP_TASKTRACKER_OPTS="$JMX_OPTS -Dcom.sun.management.jmxremote.port=26006 $HADOOP_TASKTRACKER_OPTS"

export HADOOP_USER=hadoop
export HDFS_USER=hdfs
export MAPRED_USER=mapred
export YARN_USER=yarn

{%- set logs = '/var/log/hadoop' %}
{%- set pids = '/var/run/hadoop' %}

export HADOOP_LOG_DIR={{ logs }}
export HDFS_LOG_DIR={{ logs }}
export MAPRED_LOG_DIR={{ logs }}
export HADOOP_MAPRED_LOG_DIR={{ logs }}
export YARN_LOG_DIR={{ logs }}

export HADOOP_PID_DIR={{ pids }}
export HDFS_PID_DIR={{ pids }}
export MAPRED_PID_DIR={{ pids }}
export HADOOP_MAPRED_PID_DIR={{ pids }}
export YARN_PID_DIR={{ pids }}
