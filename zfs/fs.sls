{% set zfs = salt.pillar.get('zfs') %}

{% for zfs_dataset in zfs.get('fs', ()) %}
{% set outer_loop = loop %}
zfs_dataset_{{ loop.index0 }}:
  {% if zfs_dataset.present|default(True) %}
  zfs.filesystem_present:
    - name: {{ zfs_dataset.dataset }}
    {%- if zfs_dataset.get('properties') %}
    - properties:
        {{ zfs_dataset.properties|yaml }}
    {%- endif %}
    {%- if loop.index0 > 0 %}
    - require:
      - zfs: zfs_dataset_{{ loop.index0 - 1 }}
    {%- endif %}
  {% else %}
  zfs.filesystem_absent:
    - name: {{ zfs_dataset.dataset }}
  {% endif %}

# Permissions

{% for permission in zfs_dataset.get('permissions', ()) %}

{% if permission.startswith('unallow') or permission.startswith('allow') %}

zfs_dataset_{{ outer_loop.index0 }}_permission_{{ loop.index0 }}:
  cmd.run:
    - name: zfs {{ permission }} {{ zfs_dataset.dataset }}
    - runas: root
    - shell: /bin/sh
    {%- if loop.index0 > 0 %}
    - require:
      - zfs: zfs_dataset_{{ outer_loop.index0 - 1 }}_permission_{{ loop.index0 -1 }}
    {%- endif %}

{% endif %}

{% endfor %}

{% endfor %}
