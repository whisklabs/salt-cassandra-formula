{%- from 'cassandra/settings.sls' import cassandra with context %}

{% if cassandra.install_java %}
openjdk-7-jre-headless:
  pkg.installed:
    - require_in:
      - pkg: cassandra_package
{% endif %}

cassandra_repo_key:
  cmd.run:
    - name: "apt-key adv --keyserver pgp.mit.edu --recv 2B5C1B00"
    - unless: apt-key export 2B5C1B00 | grep 'BEGIN PGP'
    - require_in:
      - pkgrepo: cassandra_package

cassandra_package:
  pkgrepo.managed:
    - humanname: Cassandra Debian Repo
    - name: deb https://www.apache.org/dist/cassandra/debian {{ cassandra.series }} main
    - file: /etc/apt/sources.list.d/cassandra.sources.list
    - keyid: F758CE318D77295D
    - keyserver: pgp.mit.edu
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
      - file: cassandra_configuration