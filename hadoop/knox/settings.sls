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
{%- set config_gateway_site = gc.get('gateway-site', pc.get('gateway-site', {})) %}

{%- set jmx_export            = gc.get('jmx_export', pc.get('jmx_export', false)) %}
{%- set ldap_host             = gc.get('ldap_host', pc.get('ldap_host','')) %}
{%- set ldap_port             = gc.get('ldap_host', pc.get('ldap_port','')) %}
{%- set ldap_searchbase       = gc.get('ldap_searchbase', pc.get('ldap_searchbase','')) %}
{%- set ldap_group_searchbase = gc.get('ldap_group_searchbase', pc.get('ldap_group_searchbase','')) %}
{%- set ldap_user             = gc.get('ldap_user', pc.get('ldap_user','')) %}
{%- set ldap_pass             = gc.get('ldap_pass', pc.get('ldap_pass','')) %}
{%- set manager_topology      = gc.get('manager_topology', pc.get('manager_topology',{})) %}
{%- set cluster_topology      = gc.get('cluster_topology', pc.get('cluster_topology',{})) %}
{%- set gateway_port          = gc.get('gateway_port', pc.get('gateway_port', '8443')) %}
{%- set gateway_path          = gc.get('gateway_path', pc.get('gateway_path','gateway')) %}
{%- set ranger_plugin         = gc.get('ranger_plugin', pc.get('ranger_plugin', False)) %}
{%- set token_ttl             = gc.get('token_ttl', pc.get('token_ttl', 36000000)) %}


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
                     'config_gateway_site'      : config_gateway_site,
                     'jmx_export'               : jmx_export,
                     'ldap_host'                : ldap_host,
                     'ldap_port'                : ldap_port,
                     'ldap_searchbase'          : ldap_searchbase,
                     'ldap_group_searchbase'    : ldap_group_searchbase,
                     'ldap_user'                : ldap_user,
                     'ldap_pass'                : ldap_pass,
                     'manager_topology'         : manager_topology,
                     'cluster_topology'         : cluster_topology,
                     'gateway_port'             : gateway_port,
                     'gateway_path'             : gateway_path,
                     'ranger_plugin'            : ranger_plugin,
		     'token_ttl'		: token_ttl,
                   }) %}
