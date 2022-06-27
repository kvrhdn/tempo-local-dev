local agent = import 'grafana-agent/v1/main.libsonnet';
local k = import 'ksonnet-util/kausal.libsonnet';

{
  _config+:: {
    grafana_cloud+: {
      api_key: error 'must specify Grafana Cloud API key',
      metrics_tenant: error 'must specify Grafana Cloud Metrics tenant ID',
      logs_tenant: error 'must specify Grafana Cloud Logs tenant ID',
      traces_tenant: error 'must specify Grafana Cloud Traces tenant ID',
    },
  },

  local containerPort = k.core.v1.containerPort,

  agent:
    agent.new(namespace=$._config.namespace) +
    agent.withImages($._images) +

    // Metrics
    agent.withMetricsConfig(agent.defaultMetricsConfig {
      global+: {
        scrape_interval: '15s',
        external_labels+: {
          cluster: $._config.cluster,
        },
      },
    }) +
    agent.withMetricsInstances(agent.scrapeInstanceKubernetes {}) +
    agent.withRemoteWrite([
      {
        url: $._config.grafana_cloud.metrics.url,
        basic_auth: {
          username: $._config.grafana_cloud.metrics.tenant,
          password: $._config.grafana_cloud.api_key,
        },
      },
    ]) +

    // Logs
    agent.withLogsConfig(agent.scrapeKubernetesLogs) +
    agent.withLogsClients(
      agent.newLogsClient({
        scheme: 'https',
        hostname: $._config.grafana_cloud.logs.hostname,
        username: $._config.grafana_cloud.logs.tenant,
        password: $._config.grafana_cloud.api_key,
      })
    ) +

    // Traces
    agent.withTracesConfig({
      receivers: {
        jaeger: {
          protocols: {
            thrift_http: null,
          },
        },
      },
      spanmetrics: {
        metrics_instance: 'kubernetes',
      },
      service_graphs: {
        enabled: true,
      },
      //tail_sampling: {
      //  policies: [
      //    {
      //      string_attribute: {
      //        key: 'name',
      //        values: ['^(?!HTTP GET - metrics).*$'],
      //        enabled_regex_matching: true,
      //      },
      //    },
      //  ],
      //  decision_wait: '2s',
      //},
    }) +
    agent.withPortsMixin([
      containerPort.new('thrift-http', 14268) +
      containerPort.withProtocol('TCP'),
    ]) +
    agent.withTracesRemoteWrite(
      [
        {
          endpoint: '%s:443' % $._config.grafana_cloud.traces.endpoint,
          basic_auth: {
            username: $._config.grafana_cloud.traces.tenant,
            password: $._config.grafana_cloud.api_key,
          },
          retry_on_failure: {
            enabled: true,
          },
        },
      ] + (
        if $._config.self_ingest then [
          {
            endpoint: 'distributor:4317',
            insecure: true,
            retry_on_failure: {
              enabled: false,
            },
          },
        ] else []
      )
    ) +
    agent.withTracesScrapeConfigs(agent.tracesScrapeKubernetes) +

    {},

  // manually remove machine-id mounts from vendor lib, these don't work (for some reason)
}
