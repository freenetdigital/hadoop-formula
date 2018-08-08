{%- set p  = salt['pillar.get']('spark', {}) %}
{%- set pc = p.get('config', {}) %}
{%- set g  = salt['grains.get']('spark', {}) %}
{%- set gc = g.get('config', {}) %}

{%- set base_install_dir   = g.get('base_install_dir', p.get('base_install_dir', '/usr/lib')) %}
{%- set dir                = g.get('dir', p.get('dir', base_install_dir+'/spark')) %}

{%- set hash               = g.get('hash', p.get('hash', 'sha1=1fbd29356181d936be70eaf5331a38dc0c3c4667')) %}
{%- set download_mirror    = g.get('download_mirror', p.get('download_mirror', 'http://apache.lauf-forum.at/spark')) %}
{%- set release            = g.get('release', p.get('release', 'bin-without-hadoop')) %}

{%- set version            = g.get('version',        p.get('version', '2.3.1')) %}

{%- set jmx_export         = gc.get('jmx_export', pc.get('jmx_export', false)) %}
{%- set additional_jars    = gc.get('additional_jars', pc.get('additional_jars', [])) %}
{%- set yarn_archive       = gc.get('yarn_archive', pc.get('yarn_archive', '')) %}


{%- set spark = {} %}
{%- do spark.update({ 'version'                 : version,
                     'hash'                     : hash,
                     'release'                  : release,
                     'dir'                      : dir,
                     'install_dir'              : base_install_dir + '/spark-' + version + '-' + release,
                     'download_mirror'          : download_mirror,
                     'jmx_export'               : jmx_export,
                     'additional_jars'          : additional_jars,
                     'yarn_archive'             : yarn_archive,
                   }) %}
