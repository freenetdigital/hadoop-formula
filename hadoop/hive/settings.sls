{%- set p  = salt['pillar.get']('hive', {}) %}
{%- set pc = p.get('config', {}) %}
{%- set g  = salt['grains.get']('hive', {}) %}
{%- set gc = g.get('config', {}) %}

{%- install_dir      = gc.get('install_dir', pc.get('install_dir', '/var/lib/')) %}
{%- version          = gc.get('version', pc.get('version', '2.3.2')) %}
{%- hash             = gc.get('hash', pc.get('hash', 'md5=8f3abedb3fba28769afcea1445c64231')) %}
{%- download_mirror  = gc.get('download_mirror', pc.get('download_mirror', 'http://apache.lauf-forum.at/hive')) %}

{%- set hive = {} %}
{%- do hive.update({ 'version'            : version,
                     'hash'               : hash,
                     'install_dir'        : install_dir,
                     'download_mirror'    : download_mirror,
                   }) %}
