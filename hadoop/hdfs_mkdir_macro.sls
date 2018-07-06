{% from 'hadoop/settings.sls' import hadoop with context %}
{% macro hdfs_mkdir(name, user, group, mode, cmd) -%}
{%- set localname = name | replace('/', '-') %}
{% if not hadoop.secure_mode %}
make{{ localname }}-dir:
  cmd.run:
    - user: hdfs
    - name: {{ cmd }} -mkdir -p {{ name }}
    - unless: {{ cmd }} -test -d {{ name }}

chown{{ localname }}-dir:
  cmd.run:
    - user: hdfs
{%- if group %}
    - name: {{ cmd }} -chown {{ user }}:{{ group }} {{ name }}
    - unless: 'bash -c "[ \"$({{ cmd }} -stat ''%u%g'' {{ name }} )\" == \"{{ user }}{{group}}\" ]"'
        
{%- else %}
    - name: {{ cmd }} -chown {{ user }} {{ name }}
    - unless: 'bash -c "[ \"$({{ cmd }} -stat ''%u'' {{ name }} )\" == \"{{ user }}\" ]"'
{%- endif %}

#this ugly 'unless' clause parses the output of ls, transforms the permission string like 
#'drwxr-x---' into octal, in order to compare it. The option to show octal permission via 
#'hdfs dfs stat' is only introduced in 3.0.0 but missing in 2.8.4
chmod{{ localname }}-dir:
  cmd.run:
    - user: hdfs
    - name: {{ cmd }} -chmod {{ mode }} {{ name }}
    {% if mode|string() == "1777" %}
    - unless: '/usr/bin/test "$({{ cmd }} -ls -d {{ name }} | tr -s '' '' | cut -d'' '' -f1)" == "drwxrwxrwt"'
    {% else %} 
    - unless: '/usr/bin/test "$({{ cmd }} -ls -d {{ name }} | awk ''{k=0;for(i=0;i<=8;i++) {if (substr($1,i+2,1)~/[s]/) k += ((substr($1,i+2,1)~/[s]/)*2^9);else k+=((substr($1,i+2,1)~/[rwx]/)*2^(8-i));}if (k)printf("%0o",k);}'')" == "{{ mode }}"'
    {% endif %}
{% endif %}
{%- endmacro %}
