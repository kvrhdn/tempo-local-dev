local prometheus = import 'prometheus/prometheus.libsonnet';

prometheus {
  _config+:: {
    prometheus_external_hostname: 'http://prometheus',

    // We do not scrape any instances, only receive data through remote write
    prometheus_enabled_features+: ['remote-write-receiver'],
  },
}
