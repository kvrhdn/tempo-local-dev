{
  local k = import 'ksonnet-util/kausal.libsonnet',
  local container = k.core.v1.container,

  local jaeger_tracing = container.withEnvMixin([
    container.envType.new('JAEGER_ENDPOINT', 'http://grafana-agent:14268/api/traces'),
    container.envType.new('JAEGER_TAGS', 'namespace=%s,cluster=%s' % [$._config.namespace, $._config.cluster]),
    container.envType.new('JAEGER_SAMPLER_TYPE', 'const'),
    container.envType.new('JAEGER_SAMPLER_PARAM', '1'),
  ]),
  tempo_distributor_container+::
    jaeger_tracing,

  tempo_ingester_container+::
    jaeger_tracing,

  tempo_generator_container+::
    jaeger_tracing,

  tempo_compactor_container+::
    jaeger_tracing,

  tempo_query_frontend_container+::
    jaeger_tracing,

  tempo_query_container+::
    jaeger_tracing,

  tempo_querier_container+::
    jaeger_tracing,
}
