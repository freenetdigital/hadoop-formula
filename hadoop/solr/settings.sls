{%- set p  = salt['pillar.get']('solr', {}) %}
{%- set pc = p.get('config', {}) %}
{%- set g  = salt['grains.get']('solr', {}) %}
{%- set gc = g.get('config', {}) %}

{%- set base_install_dir   = g.get('base_install_dir', p.get('base_install_dir', '/usr/lib')) %}
{%- set data_dir           = g.get('data_dir',         p.get('data_dir', '/var/solr'))%}
{%- set dir                = g.get('dir',              p.get('dir', base_install_dir+'/solr')) %}
{%- set conf_dir           = g.get('conf_dir',         p.get('conf_dir', '/etc/solr/conf')) %}
{%- set hash               = g.get('hash',             p.get('hash', 'sha1=551fa068b2ae464bafd47f668408f392eb8dec9c')) %}
{%- set download_mirror    = g.get('download_mirror', p.get('download_mirror', 'http://apache.lauf-forum.at/lucene/solr')) %}

{%- set version            = g.get('version',        p.get('version', '7.3.1')) %}
{%- set jmx_export         = gc.get('jmx_export',   pc.get('jmx_export', false)) %}
{%- set data_dir           = gc.get('data_dir',     pc.get('data_dir', '/var/solr/')) %}


{%- set solr = {} %}
{%- do solr.update({ 'version'                  : version,
                     'hash'                     : hash,
                     'conf_dir'                 : conf_dir,
                     'dir'                      : dir,
                     'install_dir'              : base_install_dir + '/solr-' + version,
                     'download_mirror'          : download_mirror,
                     'jmx_export'               : jmx_export,
                     'data_dir'                 : data_dir,
                     'home_dir'                 : data_dir + '/data',
                   }) %}
