{% from slspath + '/map.jinja' import fluentbit with context %}
{% import slspath + '/macros.jinja' as macros %}

# Create global config file.
{{ sls }}~create_main_config_file:
  file.managed:
    - name: {{ fluentbit.pkg.dirs.conf }}/{{ fluentbit.pkg.name }}.conf
    - source: salt://{{ slspath }}/templates/main.conf.jinja
    - template: jinja
    - context:
        section: 'service'
        indent: {{ fluentbit.config.indent }}
        element:
          name: 'Global properties'
          conf: {{ fluentbit.config.service }}
        include: {{ fluentbit.config.include }}
    - require:
      - pkg: {{ slspath }}.install~system_package
    - watch_in:
      - service: {{ slspath }}.service~up_and_running

# Create Fluent Bit sections (input, parser, filter, and output).
{% for section_name, section_conf in fluentbit.config.sections.items() %}

# Create section dirs only if it has config.
{% if section_conf %}
{{ sls }}~create_section_dir_{{ section_name }}:
  file.directory:
    - name: {{ fluentbit.pkg.dirs.conf }}/{{ section_name }}
    - require:
      - pkg: {{ slspath }}.install~system_package

# Delete unmanaged conf files, e.g. config removed from pillar.
{{ sls }}~clean_section_dir_{{ section_name }}:
  file.directory:
    - name: {{ fluentbit.pkg.dirs.conf }}/{{ section_name }}
    - clean: True
    - require:
      - pkg: {{ slspath }}.install~system_package
{% endif %}

# Create configuration for each section.
{% for element_name, element_conf in section_conf.items() %}
{{ sls }}~create_element_conf_file_{{ "%s/%s" % (section_name, element_name) }}:
  file.managed:
    - name: {{ fluentbit.pkg.dirs.conf }}/{{ section_name }}/{{ element_name }}.conf
    - source: salt://{{ slspath }}/templates/section.conf.jinja
    - template: jinja
    - context:
        section: {{ section_name }}
        indent: {{ fluentbit.config.indent }}
        element:
          name: {{ element_name }}
          conf: {{ element_conf }}
    - require:
      - file: {{ sls }}~create_section_dir_{{ section_name }}
    - require_in:
      - file: {{ sls }}~clean_section_dir_{{ section_name }}
    - watch_in:
      - service: {{ slspath }}.service~up_and_running
{% endfor %} # End of element loop.

{% endfor %} # End of section loop.
