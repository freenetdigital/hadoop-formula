{%- set p  = salt['pillar.get']('hive', {}) %}
{%- set pc = p.get('config', {}) %}
{%- set g  = salt['grains.get']('hive', {}) %}
{%- set gc = g.get('config', {}) %}

{%- set base_install_dir   = gc.get('base_install_dir', pc.get('base_install_dir', '/usr/lib')) %}
{%- set dir                = gc.get('dir', pc.get('dir', base_install_dir+'/hive')) %}
{%- set conf_dir           = gc.get('conf_dir', pc.get('conf_dir', '/etc/hive/conf')) %}
{%- set version            = gc.get('version', pc.get('version', '2.3.2')) %}
{%- set hash               = gc.get('hash', pc.get('hash', 'md5=8f3abedb3fba28769afcea1445c64231')) %}
{%- set download_mirror    = gc.get('download_mirror', pc.get('download_mirror', 'http://apache.lauf-forum.at/hive')) %}

{%- set metastore_backend  = pc.get('metastore_backend', 'mysql') %}

{%- set admin_username     = pc.get('admin_username', 'root') %}
{%- set admin_password     = pc.get('admin_password', 'root') %}

{%- set metastore_db       = pc.get('metastore_db', 'hive') %}
{%- set metastore_user     = pc.get('metastore_user', 'hive') %}
{%- set metastore_pass     = pc.get('metastore_pass', 'hive') %}

{% mver = version.split('.') %}

{%- set metastore_schema_version     = pc.get('metastore_schema_version', mver[0] + '.' + mver[1] + '.0' ) %}
{%- set metastore_schema_file        = pc.get('metastore_schema_file', dir + '/scripts/metastore/upgrade/' + metastore_backend +'/hive-schema-' + metastore_schema_version + '.' + metastore_backend + '.sql') %}

{%- set hive = {} %}
{%- do hive.update({ 'version'                  : version,
                     'hash'                     : hash,
                     'conf_dir'                 : conf_dir,
                     'install_dir'              : base_install_dir + '/hive-' + version,
                     'dir'                      : base_install_dir + '/hive',
                     'download_mirror'          : download_mirror,
                     'metastore_backend'        : metastore_backend,
                     'admin_username'           : admin_username ,
                     'admin_password'           : admin_password ,
                     'metastore_db'             : metastore_db ,
                     'metastore_user'           : metastore_user ,
                     'metastore_pass'           : metastore_pass ,
                     'metastore_schema_version' : metastore_schema_version ,
                     'metastore_schema_file'    : metastore_schema_file ,
                   }) %}
