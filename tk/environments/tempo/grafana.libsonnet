local grafana = import 'grafana/grafana.libsonnet';

{
  _images+:: {
    grafana: 'grafana/grafana:latest',
  },

  grafana:
    grafana +
    grafana.withAnonymous() +
    grafana.withTheme('light') +
    grafana.withRootUrl('http://grafana') +
    grafana.withImage($._images.grafana) +

    grafana.withGrafanaIniConfig({
      sections+: {
        feature_toggles: {
          enable: 'tempoSearch,tempoServiceGraph,tempoApmTable',
        },
      },
    }) +

    grafana.addDatasource(
      'tempo',
      grafana.datasource.new('Tempo', 'http://query-frontend:3200', 'tempo', default=true) +
      grafana.datasource.withJsonData({
        httpMethod: 'GET',
        serviceMap: {
          datasourceUid: 'prometheus',
        },
      }) +
      { uid: 'tempo' },
    ) +
    grafana.addDatasource(
      'jaeger',
      grafana.datasource.new('Jaeger (but actually Tempo)', 'http://query-frontend:16686', 'jaeger') +
      { uid: 'jaeger' },
    ) +
    grafana.addDatasource(
      'prometheus',
      grafana.datasource.new('Prometheus', 'http://prometheus/prometheus', 'prometheus') +
      { uid: 'prometheus' },
    ),
}
