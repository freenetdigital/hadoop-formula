{%- set p  = salt['pillar.get']('ranger', {}) %}
{%- set pc = p.get('config', {}) %}
{%- set g  = salt['grains.get']('ranger', {}) %}
{%- set gc = g.get('config', {}) %}

{%- set base_install_dir   = g.get('base_install_dir', p.get('base_install_dir', '/usr/lib')) %}
{%- set admin_dir          = g.get('admin_dir',        p.get('admin_dir', base_install_dir+'/ranger-admin')) %}
{%- set conf_dir           = g.get('conf_dir',         p.get('conf_dir', '/etc/ranger-admin/conf')) %}

{%- set version            = g.get('version',        p.get('version', '1.0.0')) %}
{%- set jmx_export         = gc.get('jmx_export',   pc.get('jmx_export', false)) %}


{%- set ranger = {} %}
{%- do ranger.update({ 'version'                  : version,
                     'hash'                       : hash,
                     'conf_dir'                   : conf_dir,
                     'admin_dir'                  : admin_dir,
                     'admin_install_dir'          : base_install_dir + '/ranger-admin-' + version,
                     'jmx_export'                 : jmx_export,
                   }) %}