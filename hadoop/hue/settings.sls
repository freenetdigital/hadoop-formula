{%- set p  = salt['pillar.get']('hue', {}) %}
{%- set pc = p.get('config', {}) %}
{%- set g  = salt['grains.get']('hue', {}) %}
{%- set gc = g.get('config', {}) %}

{%- set base_install_dir   = g.get('base_install_dir', p.get('base_install_dir', '/usr/lib')) %}
{%- set download_dir       = g.get('download_dir', p.get('download_dir', '/opt')) %}
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
{%- set sqlite_path           = gc.get('sqlite_path', pc.get('sqlite_path', dir + '/desktop/desktop.db')) %}
{%- set ldap_username_pattern = gc.get('ldap_username_pattern', pc.get('ldap_username_pattern','')) %}
{%- set ldap_user_filter      = gc.get('ldap_user_filter', pc.get('ldap_user_filter','')) %}
{%- set database_type         = gc.get('database_type', pc.get('database_type', 'sqlite')) %}
{%- set database_name         = gc.get('database_name', pc.get('database_name', 'huedb')) %}
{%- set database_password     = gc.get('database_password', pc.get('database_password', '')) %}


{%- set hue = {} %}
{%- do hue.update({ 'version'                  : version,
                     'hash'                     : hash,
                     'conf_dir'                 : conf_dir,
                     'dir'                      : dir,
                     'install_dir'              : base_install_dir + '/hue-' + version,
                     'download_dir'             : download_dir,
                     'download_mirror'          : download_mirror,
                     'jmx_export'               : jmx_export,
                     'sqlite_path'              : sqlite_path,
                     'cert_name'                : cert_name, 
                     'cert_pub_path'            : cert_pub_path, 
                     'cert_priv_path'           : cert_priv_path, 
                     'ldap_username_pattern'    : ldap_username_pattern,
                     'ldap_user_filter'         : ldap_user_filter,
                     'database_type'            : database_type,
                     'database_name'            : database_name,
                     'database_password'        : database_password,
                   }) %}
