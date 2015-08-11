{%- from 'cassandra/settings.sls' import cassandra with context %}

{% if cassandra.install_java %}
openjdk-8-jre-headless:
  pkg.installed:
    - require_in:
      - pkg: cassandra_package
{% endif %}

cassandra_package:
  pkgrepo.managed:
    - humanname: Cassandra Debian Repo
    - name: deb http://debian.datastax.com/community stable main
    - file: /etc/apt/sources.list.d/cassandra.sources.list
    - key_url: http://debian.datastax.com/debian/repo_key
  pkg.installed:
    - name: {{ cassandra.package_name }}
    - version: {{ cassandra.version }}

cassandra_configuration:
  file.managed:
    - name: {{ cassandra.conf_path }}
    - user: root
    - group: root
    - mode: 644
    - source: salt://cassandra/conf/cassandra_{{ cassandra.series }}.yaml
    - template: jinja
    - require:
      - pkg: cassandra_package

{% for d in cassandra.config.data_file_directories %}
data_file_directories_{{ d }}:
  file.directory:
    - name: {{ d }}
    - user: cassandra
    - group: cassandra
    - mode: 755
    - makedirs: True
{% endfor %}

commitlog_directory:
  file.directory:
    - name: {{ cassandra.config.commitlog_directory }}
    - user: cassandra
    - group: cassandra
    - mode: 755
    - makedirs: True

saved_caches_directory:
  file.directory:
    - name: {{ cassandra.config.saved_caches_directory }}
    - user: cassandra
    - group: cassandra
    - mode: 755
    - makedirs: True

cassandra_service:
  service.running:
    - name: cassandra
    - enable: True
    - watch:
      - pkg: cassandra_package
      - file: cassandra_configuration
