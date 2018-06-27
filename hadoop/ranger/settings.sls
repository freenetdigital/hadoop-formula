{%- set p  = salt['pillar.get']('ranger', {}) %}
{%- set pc = p.get('config', {}) %}
{%- set g  = salt['grains.get']('ranger', {}) %}
{%- set gc = g.get('config', {}) %}

{%- set base_install_dir   = g.get('base_install_dir', p.get('base_install_dir', '/usr/lib')) %}
{%- set data_dir           = g.get('data_dir',         p.get('data_dir', '/var/ranger'))%}
{%- set dir                = g.get('dir',              p.get('dir', base_install_dir+'/ranger')) %}
{%- set conf_dir           = g.get('conf_dir',         p.get('conf_dir', '/etc/ranger/conf')) %}

{%- set version            = g.get('version',        p.get('version', '1.0.0')) %}
{%- set jmx_export         = gc.get('jmx_export',   pc.get('jmx_export', false)) %}


{%- set ranger = {} %}
{%- do ranger.update({ 'version'                  : version,
                     'hash'                     : hash,
                     'conf_dir'                 : conf_dir,
                     'dir'                      : dir,
                     'install_dir'              : base_install_dir + '/ranger-' + version,
                     'jmx_export'               : jmx_export,
                   }) %}
