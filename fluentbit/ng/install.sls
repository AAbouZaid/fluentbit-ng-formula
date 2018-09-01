{% from slspath + '/map.jinja' import fluentbit with context %}

{% if fluentbit.pkg.deps %}
{{ sls }}~dependencies:
  pkg.installed:
    - names: {{ fluentbit.pkg.deps }}
{% endif %}

{% if fluentbit.repo.enabled %}
{{ sls }}~repository:
  pkgrepo.managed:
    - humanname: {{ fluentbit.pkg.name }} Repo.
  {% if grains['os_family'] == 'Debian' %}
    - name: '{{ fluentbit.repo.name }}'
    - file: {{ fluentbit.repo.file }}
    - key_url: {{ fluentbit.repo.key }}
  {% elif grains['os_family'] == 'RedHat' %}
    - baseurl: '{{ fluentbit.repo.name }}'
    - gpgkey: {{ fluentbit.repo.key }}
    - gpgcheck: 1
  {% endif %}
  {% if fluentbit.pkg.deps %}
    - require:
      - pkg: {{ sls }}_dependencies
  {% endif %}
{% endif %}

{{ sls }}~system_package:
  pkg.installed:
    - name: {{ fluentbit.pkg.name }}
