{% set p  = salt['pillar.get']('cassandra', {}) %}
{% set pc = p.get('config', {}) %}
{% set g  = salt['grains.get']('cassandra', {}) %}
{% set gc = g.get('config', {}) %}

{% set install_java   = g.get('install_java', p.get('install_java', False)) %}
{% set version        = g.get('version', p.get('version', '2.0.11')) %}
{% set series         = g.get('version', p.get('series', '20x')) %}
{% set package_name   = g.get('package_name', p.get('package_name', 'cassandra')) %}
{% set conf_path      = g.get('conf_path', p.get('conf_path', '/etc/cassandra/cassandra.yaml')) %}
{% set auto_discovery = g.get('auto_discovery', p.get('auto_discovery', False)) %}

{% set default_config = {
  'cluster_name': 'Test Cluster',
  'data_file_directories': ['/var/lib/cassandra/data'],
  'commitlog_directory': '/var/lib/cassandra/commitlog',
  'saved_caches_directory': '/var/lib/cassandra/saved_caches',
  'seeds': ["127.0.0.1"],
  'listen_address': 'localhost',
  'rpc_address': 'localhost',
  'endpoint_snitch': 'SimpleSnitch'
  }%}

{%- set config = default_config %}

{%- do config.update(pc) %}
{%- do config.update(gc) %}

{%- if auto_discovery %}

{%- set force_mine_update = salt['mine.send']('network.get_hostname') %}
{%- set cassandra_host_dict = salt['mine.get']('cassandra_cluster_name:' + config.cluster_name, 'network.get_hostname', 'grain') %}
{%- set cassandra_hosts = cassandra_host_dict.values() %}
{%- do cassandra_hosts.sort() %}
{%- do config.update({'seeds':cassandra_hosts[:4]}) %}
{%- endif %}

{%- set cassandra = {} %}

{%- do cassandra.update({
  'version': version,
  'series': series,
  'install_java': install_java,
  'package_name': package_name,
  'conf_path': conf_path,
  'config': config
   }) %}