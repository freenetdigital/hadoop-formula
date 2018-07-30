{%- set p  = salt['pillar.get']('spark', {}) %}
{%- set pc = p.get('config', {}) %}
{%- set g  = salt['grains.get']('spark', {}) %}
{%- set gc = g.get('config', {}) %}

{%- set base_install_dir   = g.get('base_install_dir', p.get('base_install_dir', '/usr/lib')) %}
{%- set dir                = g.get('dir', p.get('dir', base_install_dir+'/spark')) %}
{%- set conf_dir           = g.get('conf_dir', p.get('conf_dir', '/etc/spark/conf')) %}

{%- set hash               = g.get('hash', p.get('hash', 'sha1=45dcb8055444f73b8a84c2276ddd1e857ce4a191')) %}
{%- set download_mirror    = g.get('download_mirror', p.get('download_mirror', 'http://apache.lauf-forum.at/spark')) %}

{%- set version            = g.get('version',        p.get('version', '2.3.1')) %}

{%- set jmx_export            = gc.get('jmx_export', pc.get('jmx_export', false)) %}


{%- set spark = {} %}
{%- do spark.update({ 'version'                  : version,
                     'hash'                     : hash,
                     'conf_dir'                 : conf_dir,
                     'dir'                      : dir,
                     'install_dir'              : base_install_dir + '/spark-' + version,
                     'download_dir'             : download_dir,
                     'download_mirror'          : download_mirror,
                     'jmx_export'               : jmx_export,
                   }) %}
