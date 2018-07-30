{%- from 'hadoop/settings.sls' import hadoop with context %}
{%- from 'hadoop/livy/settings.sls' import livy with context %}
{%- from 'hadoop/user_macro.sls' import hadoop_user with context %}

# this state does currently only deploy livy libs and config to be used by apache livy
# with this configuration, only livy on yarn mode is supported

include:
  - hadoop.systemd
  
{%- set username = 'livy' %}
{%- set uid = hadoop.users[username] %}

{{ hadoop_user(username, uid, ssh=False) }}

livy-directory:
  file.directory:
    - name: {{ livy.install_dir }}
    - user: {{ username }}

livy-conf-directory:
  file.directory:
    - name: /etc/livy
    - user: {{ username }}

livy-directory-symlink:
  file.symlink:
    - target: {{ livy.install_dir }}
    - name: {{ livy.dir }}

download-livy-archive:
  cmd.run:
    - name: wget {{ livy.download_mirror }}/{{ livy.version }}-incubating/livy-{{ livy.version }}-{{ livy.release }}.zip
    - cwd: {{ livy.install_dir }}
    - user: {{ username }}
    - unless: test -f {{ livy.install_dir }}/livy-{{livy.version}}-{{livy.release}}/bin/livy-server

{% set archive_dir = livy.install_dir + '/livy-' + livy.version + '-' + livy.release %}
{% set archive = archive_dir + '.zip' %}

check-livy-archive:
  module.run:
    - name: file.check_hash
    - path: {{ archive }}
    - file_hash: {{ livy.hash }}
    - onchanges:
      - cmd: download-livy-archive    
    - require_in:
      - archive: unpack-livy-archive   


unpack-livy-archive:
  archive.extracted:
    - name: {{ livy.install_dir }}
    - source: file://{{ archive }}
    - archive_format: zip
    - user: {{ username }}
    - group: hadoop
    - onchanges:
      - cmd: download-livy-archive

cleanup-livy-directory:
  cmd.run:
    - name: mv {{ archive_dir }}/* {{ livy.install_dir }}; rm -rf {{ archive_dir }}*
    - onchanges:
      - archive: unpack-livy-archive

livy-symlink:
  file.symlink:
    - target: {{ livy.install_dir}}
    - name: {{livy.dir}}

livy-conf-symlink:
  file.symlink:
    - target: {{ livy.install_dir}}/conf
    - name: /etc/livy/conf

