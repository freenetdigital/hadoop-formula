{%- set p  = salt['pillar.get']('livy', {}) %}
{%- set pc = p.get('config', {}) %}
{%- set g  = salt['grains.get']('livy', {}) %}
{%- set gc = g.get('config', {}) %}

{%- set base_install_dir   = g.get('base_install_dir', p.get('base_install_dir', '/usr/lib')) %}
{%- set dir                = g.get('dir', p.get('dir', base_install_dir+'/livy')) %}

{%- set hash               = g.get('hash', p.get('hash', 'sha1=4f0f46280eb6ca77ec76091979970622668baf32')) %}
{%- set download_mirror    = g.get('download_mirror', p.get('download_mirror', 'http://apache.lauf-forum.at/incubator/livy')) %}
{%- set release            = g.get('release', p.get('release', 'incubating-bin')) %}

{%- set version            = g.get('version',        p.get('version', '0.5.0')) %}

{%- set jmx_export            = gc.get('jmx_export', pc.get('jmx_export', false)) %}
{%- set rsc_jars              = gc.get('rsc_jars',   pc.get('rsc_jars', '')) %}
{%- set repl_jars             = gc.get('repl_jars',  pc.get('repl_jars', '')) %}
{%- set pyspark               = gc.get('pyspark',  pc.get('pyspark', '')) %}
{%- set sparkr                = gc.get('sparkr',  pc.get('sparkr', '')) %}


{%- set livy = {} %}
{%- do livy.update({ 'version'                 : version,
                     'hash'                     : hash,
                     'release'                  : release,
                     'dir'                      : dir,
                     'install_dir'              : base_install_dir + '/livy-' + version + '-' + release,
                     'download_mirror'          : download_mirror,
                     'jmx_export'               : jmx_export,
                     'rsc_jars'                 : rsc_jars,
                     'repl_jars'                : repl_jars,
                     'pyspark'                  : pyspark,
                     'sparkr'                   : sparkr,
                   }) %}
