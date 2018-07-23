{%- from 'hadoop/settings.sls' import hadoop with context %}
{%- from 'hadoop/ranger/settings.sls' import ranger with context %}

{% if hadoop.ldap_user_to_unix %}
libnss-ldapd:
  pkg.installed

/etc/nslcd.conf:
  file.managed:
    - source: salt://hadoop/conf/nslcd.conf
    - template: jinja
    - mode: 400
    - user: root
    - group: root

/etc/nsswitch.conf:
  file.managed:
    - source: salt://hadoop/files/nsswitch.conf
    - template: jinja
    - mode: 400
    - user: root
    - group: root

nslcd:
  service.running:
    - enable: True
    - watch_any: 
      - file: /etc/nslcd.conf
      - file: /etc/nsswitch.conf
nscd:
  service.running:
    - enable: True
    - watch_any: 
      - file: /etc/nslcd.conf
      - file: /etc/nsswitch.conf

{% endif %} 
