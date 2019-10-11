{% set p  = salt['pillar.get']('hadoop', {}) %}
{% set pc = p.get('config', {}) %}
{% set g  = salt['grains.get']('hadoop', {}) %}
{% set gc = g.get('config', {}) %}

{%- set versions = {} %}
{%- set default_dist_id = 'apache-2.8.4' %}
{%- set dist_id = g.get('version', p.get('version', default_dist_id)) %}

{%- set default_versions = {   
                     'apache-2.8.4' : { 'version'       : '2.8.4',
                                        'version_name'  : 'hadoop-2.8.4',
                                        'source_url'    : g.get('source_url', p.get('source_url', 'https://archive.apache.org/dist/hadoop/core/hadoop-2.8.4/hadoop-2.8.4.tar.gz')),
                                        'source_hash'   : g.get('source_hash', p.get('source_hash', 'b30b409bb69185003b3babd1504ba224')),
                                        'major_version' : '2',
                                      },  
                     'apache-3.1.1' : { 'version'       : '3.1.1',
                                        'version_name'  : 'hadoop-3.1.1',
                                        'source_url'    : g.get('source_url', p.get('source_url', 'http://ftp.halifax.rwth-aachen.de/apache/hadoop/common/hadoop-3.1.1/hadoop-3.1.1.tar.gz')),
                                        'source_hash'   : g.get('source_hash', p.get('source_hash', '0b6ab06b59ae75f433de387783f19011')),
                                        'major_version' : '3',
                                      },  
                   }%}

{%- set versions         = p.get('versions', default_versions) %}
{%- set version_info     = versions.get(dist_id, versions['apache-2.8.0']) %}
{%- set alt_home         = salt['pillar.get']('hadoop:prefix', '/usr/lib/hadoop') %}
{%- set real_home        = '/usr/lib/' + version_info['version_name'] %}
{%- set alt_config       = gc.get('directory', pc.get('directory', '/etc/hadoop/conf')) %}
{%- set real_config      = alt_config + '-' + version_info['version'] %}
{%- set real_config_dist = alt_config + '.dist' %}
{%- set default_log_root = '/var/log/hadoop' %}
{%- set log_root         = gc.get('log_root', pc.get('log_root', default_log_root)) %}
{%- set initscript       = 'hadoop.init' %}
{%- set initscript_systemd  = 'hadoop.init.systemd' %}
{%- set targeting_method = g.get('targeting_method', p.get('targeting_method', 'grain')) %}
{%- set jmx_export = pc.get('jmx_export', false) %}

{%- set dfs_cmd = alt_home + '/bin/hdfs dfs' %}
{%- set dfsadmin_cmd = alt_home + '/bin/hdfs dfsadmin' %}

{%- set java_home        = salt['grains.get']('java_home', salt['pillar.get']('java_home', '/usr/lib/java')) %}
{%- set config_core_site = gc.get('core-site', pc.get('core-site', {})) %}
{%- set secure_mode      = gc.get('secure_mode', pc.get('secure_mode', False)) %}
{%- set ldap_user_to_unix= gc.get('ldap_user_to_unix', pc.get('ldap_user_to_unix', False)) %}
{%- set cert_name        = gc.get('cert_name', pc.get('cert_name', '')) %}
{%- set cert_priv_path   = gc.get('cert_priv_path', pc.get('cert_priv_path', '/etc/ssl/private')) %}
{%- set cert_pub_path    = gc.get('cert_pub_path', pc.get('cert_pub_path', '/etc/ssl/certs')) %}
{%- set keystore_pass    = gc.get('keystore_pass', pc.get('keystore_pass', False)) %}
{%- set additional_jars  = gc.get('additional_jars', pc.get('additional_jars', [])) %}
{%- set gcp_auth_file    = gc.get('gcp_auth_file', pc.get('gcp_auth_file', '')) %}

{%- set users = { 'hadoop' : 6000,
                  'hdfs'   : 6001,
                  'mapred' : 6002,
                  'yarn'   : 6003,
                  'hive'   : 6004,
                  'knox'   : 6005,
                  'ranger' : 6006,
                  'solr'   : 6007,
                  'hue'    : 6008,
                  'spark'  : 6009,
                  'livy'   : 6010,
                  'nifi'   : 6011,
                  'hive-metastore'   : 6012,
                } %}

{%- set hadoop = {} %}
{%- do hadoop.update( {   'dist_id'          : dist_id,
                          'cdhmr1'           : version_info.get('cdhmr1', False),
                          'version'          : version_info['version'],
                          'version_name'     : version_info['version_name'],
                          'source_url'       : version_info['source_url'],
                          'source_hash'      : version_info['source_hash'],
                          'major_version'    : version_info['major_version']|string(),
                          'alt_home'         : alt_home,
                          'real_home'        : real_home,
                          'alt_config'       : alt_config,
                          'real_config'      : real_config,
                          'real_config_dist' : real_config_dist,
                          'initscript'       : initscript,
                          'initscript_systemd'       : initscript_systemd,
                          'dfs_cmd'          : dfs_cmd,
                          'dfsadmin_cmd'     : dfsadmin_cmd,
                          'java_home'        : java_home,
                          'log_root'         : log_root,
                          'default_log_root' : default_log_root,
                          'config_core_site' : config_core_site,
                          'targeting_method' : targeting_method,
                          'users'            : users,
                          'jmx_export'       : jmx_export,
                          'secure_mode'      : secure_mode,
                          'keystore_pass'    : keystore_pass,
                          'cert_name'        : cert_name,
                          'cert_priv_path'   : cert_priv_path,
                          'cert_pub_path'    : cert_pub_path,
                          'ldap_user_to_unix': ldap_user_to_unix,
			  'additional_jars'  : additional_jars,
			  'gcp_auth_file'    : gcp_auth_file,
                      }) %}
