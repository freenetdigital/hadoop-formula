{%- from 'hadoop/settings.sls' import hadoop with context %}
{%- from 'hadoop/mapred/settings.sls' import mapred with context %}
{%- from 'hadoop/user_macro.sls' import hadoop_user with context %}
{%- from 'hadoop/hdfs_mkdir_macro.sls' import hdfs_mkdir with context %}

{% set username = 'mapred' %}
{% set uid = hadoop.users[username] %}
{{ hadoop_user(username, uid) }}


###########################
# TODO: needs rework and evaluation
###########################


## skip all except user creation if there is no targeting match
#{% if mapred.is_tasktracker or mapred.is_jobtracker %}
#
#{% for disk in mapred.local_disks %}
#{{ disk }}/mapred:
#  file.directory:
#    - user: {{ username }}
#    - group: hadoop
#    - mode: 775
#    - makedirs: True
#{% endfor %}
#
#{{ hadoop['alt_config'] }}/mapred-site.xml:
#  file.managed:
#    - source: salt://hadoop/conf/mapred/mapred-site.xml
#    - template: jinja
#    - mode: 644
#
#{{ hadoop['alt_config'] }}/taskcontroller.cfg:
#  file.managed:
#    - source: salt://hadoop/conf/mapred/taskcontroller.cfg
#    - template: jinja
#    - mode: 644
#
#{% if hadoop.secure_mode %}
#/etc/krb5/mapred.keytab:
#  file.managed:
#    - source: salt://kerberos/files/{{grains['cluster_id']}}/{{username}}-{{ grains['fqdn'] }}.keytab
#    - user: {{ username }}
#    - group: {{ username }}
#    - mode: '400'
#{% endif %}
#{%- endif %}
## create the /tmp directory
#
#{% if mapred.is_jobtracker %}
## hadoop 1 apparently cannot set the sticky bit
#{%- if hadoop.major_version != '1' %}
#{{ hdfs_mkdir('/tmp', 'hdfs', None, 1777, hadoop.dfs_cmd) }}
#{%- else %}
#{{ hdfs_mkdir('/tmp', 'hdfs', None, 777, hadoop.dfs_cmd) }}
#{%- endif %}
#{% endif %}
#
#
#systemd-reload-mapred:
#  cmd.wait:
#    - name: systemctl daemon-reload 
