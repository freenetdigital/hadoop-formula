# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This hs2 start script implements proposed patch: https://issues.apache.org/jira/browse/HIVE-12582
# in order to include hs2 specific jvm/hadoop env parameters, f.e. jmx exporter
# It is neccessary as of hive 2.3.3

THISSERVICE=hiveserver2
export SERVICE_LIST="${SERVICE_LIST}${THISSERVICE} "

hiveserver2() {
  echo "$(timestamp): Starting HiveServer2"
  CLASS=org.apache.hive.service.server.HiveServer2
  if $cygwin; then
    HIVE_LIB=`cygpath -w "$HIVE_LIB"`
  fi
  JAR=${HIVE_LIB}/hive-service-[0-9].*.jar

  export HADOOP_CLIENT_OPTS=" -Dproc_hiveserver2 $HADOOP_CLIENT_OPTS "
  export HADOOP_OPTS="$HIVE_SERVER2_HADOOP_OPTS $HADOOP_OPTS"
  exec $HADOOP jar $JAR $CLASS $HIVE_OPTS "$@"
}

hiveserver2_help() {
  hiveserver2 -H
}

timestamp()
{
 date +"%Y-%m-%d %T"
}

