{% set zfs = salt.pillar.get('zfs') %}

{% for zfs_dataset in zfs.get('fs', ()) %}
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
{% endfor %}
