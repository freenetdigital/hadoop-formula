{%- from 'hadoop/nifi/settings.sls' import nifi   with context -%}
{%- from 'hadoop/settings.sls'      import hadoop with context -%}
#!/bin/sh
#
#    Licensed to the Apache Software Foundation (ASF) under one or more
#    contributor license agreements.  See the NOTICE file distributed with
#    this work for additional information regarding copyright ownership.
#    The ASF licenses this file to You under the Apache License, Version 2.0
#    (the "License"); you may not use this file except in compliance with
#    the License.  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#

export JAVA_HOME={{ hadoop.java_home }}
export NIFI_REGISTRY_HOME="{{ nifi.reg_dir}}"
export NIFI_REGISTRY_PID_DIR="/var/run/nifi-registry"
export NIFI_REGISTRY_LOG_DIR="/var/log/nifi-registry"

