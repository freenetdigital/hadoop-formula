{%- set p  = salt['pillar.get']('ranger', {}) %}
{%- set pc = p.get('config', {}) %}
{%- set g  = salt['grains.get']('ranger', {}) %}
{%- set gc = g.get('config', {}) %}

{%- set base_install_dir   = g.get('base_install_dir', p.get('base_install_dir', '/usr/lib')) %}
{%- set admin_dir          = g.get('admin_dir',        p.get('admin_dir', base_install_dir+'/ranger-admin')) %}
{%- set usync_dir          = g.get('usync_dir',        p.get('usync_dir', base_install_dir+'/ranger-usersync')) %}
{%- set conf_dir           = g.get('conf_dir',         p.get('conf_dir', '/etc/ranger-admin/conf')) %}

{%- set version               = g.get('version',                 p.get('version',     '1.0.0')) %}
{%- set jmx_export            = gc.get('jmx_export',            pc.get('jmx_export',   False)) %}
{%- set db_root_pass          = gc.get('db_root_pass',          pc.get('db_root_pass', '')) %}
{%- set db_host               = gc.get('db_host',               pc.get('db_host', 'localhost')) %}
{%- set db_port               = gc.get('db_port',               pc.get('db_port', '3306')) %}
{%- set ranger_pass           = gc.get('ranger_pass',           pc.get('ranger_pass', '')) %}
{%- set ui_useraccess         = gc.get('ui_useraccess',         pc.get('ui_useraccess', False)) %}
{%- set ldap_host             = gc.get('ldap_host',             pc.get('ldap_host','')) %}
{%- set ldap_port             = gc.get('ldap_host',             pc.get('ldap_port','')) %}
{%- set ldap_searchbase       = gc.get('ldap_searchbase',       pc.get('ldap_searchbase','')) %}
{%- set ldap_group_searchbase = gc.get('ldap_group_searchbase', pc.get('ldap_group_searchbase','')) %}
{%- set ldap_user             = gc.get('ldap_user',             pc.get('ldap_user','')) %}
{%- set ldap_pass             = gc.get('ldap_pass',             pc.get('ldap_pass','')) %}
{%- set ldap_ad_domain        = gc.get('ldap_ad_domain',        pc.get('ldap_ad_domain','')) %}
{%- set ldap_scrape_userfilter = gc.get('ldap_scrape_userfilter',pc.get('ldap_scrape_userfilter','')) %}
{%- set ldap_ad_usersearchfilter = gc.get('ldap_ad_usersearchfilter',pc.get('ldap_ad_usersearchfilter','')) %}



{%- set ranger = {} %}
{%- do ranger.update({ 'version'                    : version,
                       'hash'                       : hash,
                       'conf_dir'                   : conf_dir,
                       'admin_dir'                  : admin_dir,
                       'admin_install_dir'          : base_install_dir + '/ranger-admin-' + version,
                       'usync_dir'                  : usync_dir,
                       'usync_install_dir'          : base_install_dir + '/ranger-usersync-' + version,
                       'jmx_export'                 : jmx_export,
                       'db_root_pass'               : db_root_pass,
                       'db_host'                    : db_host,
                       'db_port'                    : db_port,
                       'ranger_pass'                : ranger_pass,
                       'ui_useraccess'              : ui_useraccess,
                       'ldap_host'                  : ldap_host,
                       'ldap_port'                  : ldap_port,
                       'ldap_searchbase'            : ldap_searchbase,
                       'ldap_group_searchbase'      : ldap_group_searchbase,
                       'ldap_user'                  : ldap_user,
                       'ldap_pass'                  : ldap_pass,
                       'ldap_ad_domain'             : ldap_ad_domain,
                       'ldap_scrape_userfilter'     : ldap_scrape_userfilter,
                       'ldap_ad_usersearchfilter'   : ldap_ad_usersearchfilter,

                   }) %}
