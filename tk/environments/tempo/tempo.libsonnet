local tempo_microservices = import 'microservices/tempo.libsonnet';
local minio = import 'minio/minio.libsonnet';
local tempo_scaling = import 'tempo_scaling.libsonnet';
local tempo_tracing = import 'tempo_tracing.libsonnet';

minio + tempo_microservices + tempo_scaling + tempo_tracing + {

  _config+:: {
    search_enabled: true,
    metrics_generator_enabled: true,

    ingester+: {
      pvc_size: '1Gi',
      pvc_storage_class: 'local-path',
    },
    tempo_ssb+: {
      pvc_size: '1Gi',
      pvc_storage_class: 'local-path',
    },
    metrics_generator+: {
      ephemeral_storage_request_size: '1Mi',
      ephemeral_storage_limit_size: '2Mi',
    },
    distributor+: {
      receivers: {
        otlp: {
          protocols: {
            grpc: null,
          },
        },
        jaeger: {
          protocols: {
            // traces from vulture
            grpc: null,
          },
        },
      },
    },

    backend: 's3',
    bucket: 'tempo',

    overrides: import 'tempo_overrides.libsonnet',
  },

  tempo_config+:: {
    //use_otel_tracer: true,

    server+: {
      log_level: 'debug',
    },
    // override storage config to get Tempo to talk to minio
    storage+: {
      trace+: {
        s3+: {
          endpoint: 'minio:9000',
          access_key: 'tempo',
          secret_key: 'supersecret',
          insecure: true,
        },
      },
    },

    metrics_generator+: {
      processor+: {
        service_graphs+: {
          dimensions: ['cluster', 'namespace'],
        },
        span_metrics+: {
          dimensions: ['cluster', 'namespace'],
        },
      },
      storage+: {
        path: '/var/tempo/wal',
        remote_write+: [
          {
            url: 'http://prometheus:9090/prometheus/api/v1/write',
            send_exemplars: true,
          },
        ],
      },
    },
  },

  local k = import 'ksonnet-util/kausal.libsonnet',
  local container = k.core.v1.container,
  local containerPort = k.core.v1.containerPort,

  tempo_distributor_container+::
    container.withPortsMixin([
      containerPort.new('otlp-grpc', 4317),
      containerPort.new('jaeger-grpc', 14250),
    ]),

  // clear affinity so we can run multiple ingesters on a single node
  tempo_ingester_statefulset+: {
    spec+: {
      template+: {
        spec+: {
          affinity: {},
        },
      },
    },
  },

  // clear affinity so we can run multiple instances of memcached on a single node
  memcached_all+: {
    statefulSet+: {
      spec+: {
        template+: {
          spec+: {
            affinity: {},
          },
        },
      },
    },
  },
}
