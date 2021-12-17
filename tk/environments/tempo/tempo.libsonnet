local tempo_microservices = import 'microservices/tempo.libsonnet';
local minio = import 'minio/minio.libsonnet';
local tempo_scaling = import 'tempo_scaling.libsonnet';
local tempo_tracing = import 'tempo_tracing.libsonnet';

minio + tempo_microservices + tempo_scaling + tempo_tracing + {

  _config+:: {
    search_enabled: true,

    ingester+: {
      pvc_size: '1Gi',
      pvc_storage_class: 'local-path',
    },
    distributor+: {
      receivers: {
        jaeger: {
          protocols: {
            // traces from synthetic-load-generator
            thrift_http: null,
            // traces from vulture
            grpc: null,
          },
        },
        otlp: {
          protocols: {
            grpc: null,
          },
        },
      },
    },

    backend: 's3',
    bucket: 'tempo',
  },

  tempo_config+:: {
    //use_otel_tracer: true,

    server+: {
      // just log everything lol
      log_level: 'debug',
    },

    // manually overriding to get tempo to talk to minio
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
  },

  local k = import 'ksonnet-util/kausal.libsonnet',
  local container = k.core.v1.container,
  local containerPort = k.core.v1.containerPort,

  tempo_distributor_container+::
    container.withPortsMixin([
      containerPort.new('jaeger-http', 14268),
      containerPort.new('jaeger-grpc', 14250),
      containerPort.new('otlp-grpc', 4317),
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
