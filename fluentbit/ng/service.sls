{% from slspath + '/map.jinja' import fluentbit with context %}

{{ sls }}~config_file:
  file.managed:
    - name: {{ fluentbit.service.file }}
    - source: salt://{{ slspath }}/templates/service.{{ grains.init }}.conf.jinja
    - template: jinja
    - context:
        service_name: {{ fluentbit.service.name }}
        conf_file: {{ fluentbit.pkg.dirs.conf }}/{{ fluentbit.pkg.name }}.conf
        exec_file: {{ fluentbit.pkg.dirs.bin }}/{{ fluentbit.pkg.name }}
        vars: {{ fluentbit.service.config.vars }}
    - require:
      - pkg: {{ slspath }}.install~system_package

{% if grains.init == 'systemd' %}
{{ sls }}~systemctl_reload:
  module.run:
    - service.systemctl_reload
{% endif %}

{{ sls }}~up_and_running:
  service.running:
    - name: {{ fluentbit.service.name }}
    - enable: True
    - require:
      - pkg: {{ slspath }}.install~system_package
      - file: {{ sls }}~config_file
