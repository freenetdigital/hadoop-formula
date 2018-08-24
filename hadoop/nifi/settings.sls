{%- set p  = salt['pillar.get']('nifi', {}) %}
{%- set pc = p.get('config', {}) %}
{%- set g  = salt['grains.get']('nifi', {}) %}
{%- set gc = g.get('config', {}) %}

{%- set base_install_dir   = g.get('base_install_dir', p.get('base_install_dir', '/usr/lib')) %}
{%- set dir                = g.get('dir', p.get('dir', base_install_dir+'/nifi')) %}

{%- set hash               = g.get('hash', p.get('hash', 'sha1=3027ac4daa09a9f6185fc501a5b137d1c4b8aad4')) %}
{%- set toolkit_hash       = g.get('toolkit_hash', p.get('toolkit_hash', 'sha1=2e1e290824d83a1700f72b2999a2ec836ed544d0')) %}
{%- set download_mirror    = g.get('download_mirror', p.get('download_mirror', 'https://archive.apache.org/dist/nifi')) %}
{%- set version            = g.get('version',        p.get('version', '1.4.0')) %}

{%- set jmx_export                = gc.get('jmx_export', pc.get('jmx_export', false)) %}
{%- set provenance_implementation = gc.get('provenance_implementation', pc.get('provenance_implementation', 'org.apache.nifi.provenance.PersistentProvenanceRepository')) %}
{%- set knoxsso                   = gc.get('knoxsso', pc.get('knoxsso', false)) %}
{%- set knox_audience             = gc.get('knox_audience', pc.get('knox_audience', '')) %}
{%- set min_mem                   = gc.get('min_mem', pc.get('min_mem', '512m')) %}
{%- set max_mem                   = gc.get('max_mem', pc.get('max_mem', '512m')) %}
{%- set ranger_auth               = gc.get('ranger_auth', pc.get('ranger_auth', false)) %}
{%- set data_dir                  = gc.get('data_dir', pc.get('data_dir', dir)) %}
{%- set additional_jars           = gc.get('additional_jars', pc.get('additional_jars', [])) %}


{%- set nifi = {} %}
{%- do nifi.update({ 'version'                  : version,
                     'hash'                     : hash,
                     'toolkit_hash'             : toolkit_hash,
                     'dir'                      : dir,
                     'install_dir'              : base_install_dir + '/nifi-' + version,
                     'toolkit_install_dir'      : base_install_dir + '/nifi-toolkit-' + version,
                     'download_mirror'          : download_mirror,
                     'jmx_export'               : jmx_export,
                     'provenance_implementation': provenance_implementation,
                     'knoxsso'                  : knoxsso,
                     'knox_audience'            : knox_audience,
                     'min_mem'                  : min_mem,
                     'max_mem'                  : max_mem,
                     'ranger_auth'              : ranger_auth,
                     'data_dir'                 : data_dir,
                     'additional_jars'          : additional_jars,
                   }) %}
