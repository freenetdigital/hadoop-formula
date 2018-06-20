{%- set p  = salt['pillar.get']('knox', {}) %}
{%- set pc = p.get('config', {}) %}
{%- set g  = salt['grains.get']('knox', {}) %}
{%- set gc = g.get('config', {}) %}

{%- set base_install_dir   = g.get('base_install_dir', p.get('base_install_dir', '/usr/lib')) %}
{%- set dir                = g.get('dir', p.get('dir', base_install_dir+'/knox')) %}
{%- set conf_dir           = g.get('conf_dir', p.get('conf_dir', '/etc/knox/conf')) %}
{%- set hash               = g.get('hash', p.get('hash', 'md5=5d91894740b490b82a378892e4e4e08e')) %}
{%- set download_mirror    = g.get('download_mirror', p.get('download_mirror', 'http://apache.lauf-forum.at/knox')) %}

{%- set version            = g.get('version',        p.get('version', '1.0.0')) %}
{%- set master_pass        = g.get('master_pass',    p.get('master_pass', '')) %}
{%- set master_enc         = g.get('master_enc',     p.get('master_enc', '')) %}
{%- set cert_name          = g.get('cert_name',      p.get('cert_name', '')) %}
{%- set cert_pub_path      = g.get('cert_pub_path',  p.get('cert_pub_path', '/etc/ssl/certs')) %}
{%- set cert_priv_path     = g.get('cert_priv_path', p.get('cert_priv_path', '/etc/ssl/private')) %}

{%- set jmx_export         = pc.get('jmx_export', false) %}

{%- set knox = {} %}
{%- do knox.update({ 'version'                  : version,
                     'hash'                     : hash,
                     'conf_dir'                 : conf_dir,
                     'dir'                      : dir,
                     'install_dir'              : base_install_dir + '/knox-' + version,
                     'download_mirror'          : download_mirror,
                     'jmx_export'               : jmx_export,
                     'master_pass'              : master_pass,
                     'master_enc'               : master_enc, 
                     'cert_name'                : cert_name, 
                     'cert_pub_path'            : cert_pub_path, 
                     'cert_priv_path'           : cert_priv_path, 
                   }) %}
