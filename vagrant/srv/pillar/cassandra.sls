cassandra:
  version: 2.0.11
  install_java: True
  config:
    cluster_name: test-cluster
    seeds:
      - '10.245.1.2'
    listen_address: {{ grains['ip_interfaces']['eth1'][0] }}
    rpc_address: {{ grains['ip_interfaces']['eth1'][0] }}
    endpoint_snitch: GossipingPropertyFileSnitch