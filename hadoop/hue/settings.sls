{%- set p  = salt['pillar.get']('hue', {}) %}
{%- set pc = p.get('config', {}) %}
{%- set g  = salt['grains.get']('hue', {}) %}
{%- set gc = g.get('config', {}) %}

{%- set base_install_dir   = g.get('base_install_dir', p.get('base_install_dir', '/usr/lib')) %}
{%- set dir                = g.get('dir', p.get('dir', base_install_dir+'/hue')) %}
{%- set conf_dir           = g.get('conf_dir', p.get('conf_dir', '/etc/hue/conf')) %}

#hue is hosted on dropbox without reliable deeplinks, use archive on salt-master if available, searches for 'hue-<version>.tgz' 
{%- set hash               = g.get('hash', p.get('hash', 'sha1=45dcb8055444f73b8a84c2276ddd1e857ce4a191')) %}
{%- set download_mirror    = g.get('download_mirror', p.get('download_mirror', '')) %}

{%- set version            = g.get('version',        p.get('version', '4.2.0')) %}
{%- set cert_name          = g.get('cert_name',      p.get('cert_name', '')) %}
{%- set cert_pub_path      = g.get('cert_pub_path',  p.get('cert_pub_path', '/etc/ssl/certs')) %}
{%- set cert_priv_path     = g.get('cert_priv_path', p.get('cert_priv_path', '/etc/ssl/private')) %}

{%- set jmx_export            = gc.get('jmx_export', pc.get('jmx_export', false)) %}
{%- set ldap_host             = gc.get('ldap_host', pc.get('ldap_host','')) %}
{%- set ldap_port             = gc.get('ldap_host', pc.get('ldap_port','')) %}
{%- set ldap_searchbase       = gc.get('ldap_searchbase', pc.get('ldap_searchbase','')) %}
{%- set ldap_group_searchbase = gc.get('ldap_group_searchbase', pc.get('ldap_group_searchbase','')) %}
{%- set ldap_user             = gc.get('ldap_user', pc.get('ldap_user','')) %}
{%- set ldap_pass             = gc.get('ldap_pass', pc.get('ldap_pass','')) %}


{%- set hue = {} %}
{%- do hue.update({ 'version'                  : version,
                     'hash'                     : hash,
                     'conf_dir'                 : conf_dir,
                     'dir'                      : dir,
                     'install_dir'              : base_install_dir + '/hue-' + version,
                     'download_mirror'          : download_mirror,
                     'jmx_export'               : jmx_export,
                     'cert_name'                : cert_name, 
                     'cert_pub_path'            : cert_pub_path, 
                     'cert_priv_path'           : cert_priv_path, 
                     'ldap_host'                : ldap_host,
                     'ldap_port'                : ldap_port,
                     'ldap_searchbase'          : ldap_searchbase,
                     'ldap_group_searchbase'    : ldap_group_searchbase,
                     'ldap_user'                : ldap_user,
                     'ldap_pass'                : ldap_pass,
                   }) %}
