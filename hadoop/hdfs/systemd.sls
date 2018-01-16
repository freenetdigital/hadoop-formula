{% if grains['init'] == 'systemd' %}
systemd-reload:
  cmd.wait:
    - name: systemctl daemon-reload 
{% endif %}
