{%- set p  = salt['pillar.get']('nifi', {}) %}
{%- set pc = p.get('config', {}) %}
{%- set g  = salt['grains.get']('nifi', {}) %}
{%- set gc = g.get('config', {}) %}

{%- set base_install_dir   = g.get('base_install_dir', p.get('base_install_dir', '/usr/lib')) %}
{%- set dir                = g.get('dir', p.get('dir', base_install_dir+'/nifi')) %}
{%- set reg_dir            = g.get('reg_dir', p.get('reg_dir', base_install_dir+'/nifi-registry')) %}

{%- set hash               = g.get('hash', p.get('hash', 'sha512=79da5387e00b2a4f8e5ce37c8f4ac685aa97e18c90185aa1f150ac7725f04ebbe4be05ad04fcdac76ef42fcdf6a3a7f681b3dc27050bc8fade83d3b52cf827a4')) %}
{%- set reg_hash           = g.get('reg_hash', p.get('reg_hash', 'sha512=fd2898bf60dc90293f265a28f03dc78c672755fd807061d87ceb84d8f9ea81a4bfdac7c31d41e2b843cdf5e927e5e398fb4408193791eb4578a856d70bffec4f')) %}
{%- set toolkit_hash       = g.get('toolkit_hash', p.get('toolkit_hash', 'sha512=3db1ca9be2b1e573b6661c6b32d31ed512115b560252e39f7911e3c137df70b82d70932dd3d8b5680a828738df19dc10524544a4e2dac04abbe1cc7c4686cad8')) %}
{%- set download_mirror    = g.get('download_mirror', p.get('download_mirror', 'http://ftp.halifax.rwth-aachen.de/apache/nifi')) %}
{%- set reg_download_mirror= g.get('reg_download_mirror', p.get('reg_download_mirror', 'http://ftp.halifax.rwth-aachen.de/apache/nifi')) %}
{%- set version            = g.get('version',        p.get('version', '1.7.1')) %}
{%- set reg_version        = g.get('reg_version',    p.get('reg_version', '0.3.0')) %}

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
                     'reg_version'              : reg_version,
                     'hash'                     : hash,
                     'reg_hash'                 : reg_hash,
                     'toolkit_hash'             : toolkit_hash,
                     'dir'                      : dir,
                     'reg_dir'                  : reg_dir,
                     'install_dir'              : base_install_dir + '/nifi-' + version,
                     'reg_install_dir'          : base_install_dir + '/nifi-registry-' + version,
                     'toolkit_install_dir'      : base_install_dir + '/nifi-toolkit-' + version,
                     'download_mirror'          : download_mirror,
                     'reg_download_mirror'      : reg_download_mirror,
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
