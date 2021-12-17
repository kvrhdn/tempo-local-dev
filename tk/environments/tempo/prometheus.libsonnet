local prometheus = import 'prometheus/prometheus.libsonnet';

prometheus {
  _config+:: {
    prometheus_external_hostname: 'http://prometheus',
  },
}