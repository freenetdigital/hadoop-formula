{%- from "hadoop/settings.sls" import hadoop with context %}
{%- from "hadoop/yarn/settings.sls" import yarn with context %}
{%- from "hadoop/mapred/settings.sls" import mapred with context %}
{%- from "hadoop/user_macro.sls" import hadoop_user with context %}
{%- from 'hadoop/hdfs_mkdir_macro.sls' import hdfs_mkdir with context %}
{%- from 'hadoop/keystore_macro.sls' import keystore with context %}

include:
  - hadoop.systemd

{%- if hadoop.major_version|string() == '2' %}

{% set username = 'yarn' %}
{% set yarn_home_directory = '/user/' + username %}
{% set uid = hadoop.users[username] %}
{{ hadoop_user(username, uid) }}

{% if yarn.is_resourcemanager or yarn.is_nodemanager %}

{% for disk in yarn.local_disks %}
{{ disk }}/yarn:
  file.directory:
    - user: root
    - group: root
    - makedirs: True
{{ disk }}/yarn/local:
  file.directory:
    - user: yarn
    - group: hadoop
    - require:
      - file: {{ disk }}/yarn
{% endfor %}

{{ yarn.first_local_disk }}/yarn/logs:
  file.directory:
    - user: yarn
    - group: hadoop
    - require:
      - file: {{ yarn.first_local_disk }}/yarn

{{ hadoop.alt_config }}/container-executor.cfg:
  file.managed:
    - unless: test ! -f {{hadoop.alt_home}}/bin/container-executor
    - source: salt://hadoop/conf/yarn/container-executor.cfg
    - mode: 400 
    - user: root
    - group: hadoop
    - template: jinja
    - context:
      local_disks:
{%- for disk in yarn.local_disks %}
        - {{ disk }}/yarn/local
{%- endfor %}
      local_log_disk: {{ yarn.first_local_disk }}/yarn/log
      banned_users_list: {{ yarn.banned_users|join(',') }}

# restore the special permissions of the linux container executor
fix-executor-ownership:
  file.managed:
    - mode: 06050
    - user: root
    - group: hadoop
    - onlyif: test -f {{hadoop.alt_home}}/bin/container-executor
    - name: {{hadoop.alt_home}}/bin/container-executor

#duplicate fix, if chmod is invoked before chown, the permissions get messed up
fix-executor-permissions:
  file.managed:
    - mode: 06050
    - user: root
    - group: hadoop
    - onlyif: test -f {{hadoop.alt_home}}/bin/container-executor
    - name: {{hadoop.alt_home}}/bin/container-executor

#{{ hadoop.alt_config }}/yarn-site.xml:
#  file.managed:
#    - source: salt://hadoop/conf/yarn/yarn-site.xml
#    - mode: 644
#    - user: root
#    - template: jinja

{{ hadoop.alt_config }}/capacity-scheduler.xml:
  file.managed:
    - source: salt://hadoop/conf/yarn/capacity-scheduler.xml
    - mode: 644
    - user: root
    - template: jinja

{%- endif %}

{% if hadoop.secure_mode %}
/etc/krb5/yarn.keytab:
  file.managed:
    - source: salt://kerberos/files/{{username}}-{{ grains['fqdn'] }}.keytab
    - user: {{ username }}
    - group: {{ username }}
    - mode: '400'
{{ keystore(username)}}
{% endif %}

{% if yarn.is_resourcemanager %}

{% if hadoop.secure_mode %}
/etc/krb5/wap.keytab:
  file.managed:
    - source: salt://kerberos/files/wap-{{ grains['fqdn'] }}.keytab
    - user: {{ username }}
    - group: {{ username }}
    - mode: '400'
{% endif %}

# add mr-history directories for Hadoop 2
{%- set yarn_site = yarn.config_yarn_site %}
{%- set rald = yarn_site.get('yarn.nodemanager.remote-app-log-dir', '/app-logs') %}

{{ hdfs_mkdir(mapred.history_dir, username, username, 755, hadoop.dfs_cmd) }}
{{ hdfs_mkdir(mapred.history_intermediate_done_dir, username, username, 1777, hadoop.dfs_cmd) }}
{{ hdfs_mkdir(mapred.history_done_dir, username, username, 1777, hadoop.dfs_cmd) }}
{{ hdfs_mkdir(yarn_home_directory, username, username, 700, hadoop.dfs_cmd) }}
{{ hdfs_mkdir(rald, username, 'hadoop', 1777, hadoop.dfs_cmd) }}

/etc/init.d/hadoop-historyserver:
  file.managed:
    - source: salt://hadoop/files/{{ hadoop.initscript }}
    - user: root
    - group: root
    - mode: '755'
    - template: jinja
    - context:
      hadoop_svc: historyserver
      hadoop_user: hdfs
      hadoop_major: {{ hadoop.major_version }}
      hadoop_home: {{ hadoop.alt_home }}

{% if grains['init'] == 'systemd' %}
systemd-hadoop-historyserver:
  file.managed:
    - name: /etc/systemd/system/hadoop-historyserver.service
    - source: salt://hadoop/files/{{ hadoop.initscript_systemd }}
    - user: root
    - group: root
    - mode: '644'
    - template: jinja
    - context:
      hadoop_svc: historyserver
      hadoop_user: hdfs
      hadoop_major: {{ hadoop.major_version }}
      hadoop_home: {{ hadoop.alt_home }}
    - watch_in:
      - cmd: systemd-reload
{% endif %}

hadoop-historyserver:
  service.running:
    - enable: True

/etc/init.d/hadoop-resourcemanager:
  file.managed:
    - source: salt://hadoop/files/{{ hadoop.initscript }}
    - user: root
    - group: root
    - mode: '755'
    - template: jinja
    - context:
      hadoop_svc: resourcemanager
      hadoop_user: yarn
      hadoop_major: {{ hadoop.major_version }}
      hadoop_home: {{ hadoop.alt_home }}

{% if grains['init'] == 'systemd' %}
systemd-hadoop-resourcemanager:
  file.managed:
    - name: /etc/systemd/system/hadoop-resourcemanager.service
    - source: salt://hadoop/files/{{ hadoop.initscript_systemd }}
    - user: root
    - group: root
    - mode: '644'
    - template: jinja
    - context:
      hadoop_svc: resourcemanager
      hadoop_user: yarn
      hadoop_major: {{ hadoop.major_version }}
      hadoop_home: {{ hadoop.alt_home }}
    - watch_in:
      - cmd: systemd-reload
{% endif %}

hadoop-resourcemanager:
  service.running:
    - enable: True
{% endif %}

{% if yarn.is_nodemanager %}

/etc/init.d/hadoop-nodemanager:
  file.managed:
    - source: salt://hadoop/files/{{ hadoop.initscript }}
    - user: root
    - group: root
    - mode: '755'
    - template: jinja
    - context:
      hadoop_svc: nodemanager
      hadoop_user: yarn
      hadoop_major: {{ hadoop.major_version }}
      hadoop_home: {{ hadoop.alt_home }}

{% if grains['init'] == 'systemd' %}
systemd-hadoop-nodemanager:
  file.managed:
    - name: /etc/systemd/system/hadoop-nodemanager.service
    - source: salt://hadoop/files/{{ hadoop.initscript_systemd }}
    - user: root
    - group: root
    - mode: '644'
    - template: jinja
    - context:
      hadoop_svc: nodemanager
      hadoop_user: yarn
      hadoop_major: {{ hadoop.major_version }}
      hadoop_home: {{ hadoop.alt_home }}
    - watch_in:
      - cmd: systemd-reload
{% endif %}

hadoop-nodemanager:
  service.running:
    - enable: True
{% endif %}
{%- endif %}

