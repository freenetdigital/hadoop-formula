{%- set p  = salt['pillar.get']('knox', {}) %}
{%- set pc = p.get('config', {}) %}
{%- set g  = salt['grains.get']('knox', {}) %}
{%- set gc = g.get('config', {}) %}

{%- set base_install_dir   = gc.get('base_install_dir', pc.get('base_install_dir', '/usr/lib')) %}
{%- set dir                = gc.get('dir', pc.get('dir', base_install_dir+'/knox')) %}
{%- set conf_dir           = gc.get('conf_dir', pc.get('conf_dir', '/etc/knox/conf')) %}
{%- set version            = gc.get('version', pc.get('version', '1.0.0')) %}
{%- set hash               = gc.get('hash', pc.get('hash', 'md5=5d91894740b490b82a378892e4e4e08e')) %}
{%- set download_mirror    = gc.get('download_mirror', pc.get('download_mirror', 'http://apache.lauf-forum.at/knox')) %}

{%- set jmx_export         = pc.get('jmx_export', false) %}

{%- set knox = {} %}
{%- do knox.update({ 'version'                  : version,
                     'hash'                     : hash,
                     'conf_dir'                 : conf_dir,
                     'dir'                      : dir,
                     'install_dir'              : base_install_dir + '/knox-' + version,
                     'download_mirror'          : download_mirror,
                     'jmx_export'               : jmx_export,
                   }) %}
