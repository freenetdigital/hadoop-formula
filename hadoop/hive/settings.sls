{%- set p  = salt['pillar.get']('hive', {}) %}
{%- set pc = p.get('config', {}) %}
{%- set g  = salt['grains.get']('hive', {}) %}
{%- set gc = g.get('config', {}) %}

{%- set base_install_dir = gc.get('base_install_dir', pc.get('base_install_dir', '/var/lib')) %}
{%- set dir              = gc.get('dir', pc.get('dir', base_install_dir+'/hive')) %}
{%- set version          = gc.get('version', pc.get('version', '2.3.2')) %}
{%- set hash             = gc.get('hash', pc.get('hash', 'md5=8f3abedb3fba28769afcea1445c64231')) %}
{%- set download_mirror  = gc.get('download_mirror', pc.get('download_mirror', 'http://apache.lauf-forum.at/hive')) %}

{%- set hive = {} %}
{%- do hive.update({ 'version'            : version,
                     'hash'               : hash,
                     'install_dir'        : base_install_dir + '/hive-' + version,
                     'dir'                : base_install_dir + '/hive',
                     'download_mirror'    : download_mirror,
                   }) %}
