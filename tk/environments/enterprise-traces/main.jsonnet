// The following is here to support a local Grafana instance using a local
// Tempo as a datasource, components that are not codified in the helm chart.

// Currently, helm is used to deploy the `tempo-distributed` chart locally.

local local_config = import '../../config.json';

local k = import 'ksonnet-util/kausal.libsonnet';
local configMap = k.core.v1.configMap;

local grafana = import 'grafana/grafana.libsonnet';

{
  local this = self,

  _images+:: {
    // images can be overridden here if desired
    grafana: 'grafana/grafana-enterprise:latest',
  },

  _config+:: {
    cluster: 'k3d-local-dev',
    namespace: 'default',

    grafana_cloud: local_config.grafana_enterprise,

    // whether to send traces to local Tempo, this creates a feedback loop but
    // results in more and richer traces
    self_ingest: true,
  },

  _enterprise+:: {
    license: local_config.grafana_enterprise.license,
  },

  secret:
    local k = import 'ksonnet-util/kausal.libsonnet';
    k.core.v1.secret.new(
      'metamonitoring-credentials',
      {
        // base64 the base64, so that when the secret is mounted, the original
        // base64 is the string value to use as the API key.
        'cloud-api-key': std.base64(local_config.grafana_cloud.api_key),
      },
      'Opaque',
    ),

  grafana:
    grafana +
    // grafana.withAnonymous() +
    grafana.withTheme('dark') +
    grafana.withRootUrl('http://localhost:3000') +
    grafana.withImage($._images.grafana) +
    grafana.withEnterpriseLicenseText($._enterprise.license) +
    grafana.addPlugin('grafana-enterprise-traces-app') +

    grafana.withGrafanaIniConfig({
      sections+: {
        feature_toggles: {
          enable: 'tempoSearch,tempoServiceGraph,tempoApmTable',
        },
      },
    }) +
    {
      pluginsConfigMap:
        configMap.new('grafana-plugins', {
          'instance-mgmt.yml': k.util.manifestYaml({
            apiVersion: 1,
            apps: [
              {
                type: 'grafana-enterprise-traces-app',
                jsonData: {
                  backendUrl: 'http://tempo-distributed-enterprise-gateway:3100',
                  base64EncodedAccessTokenSet: true,
                },
                secureJsonData: {
                  base64EncodedAccessToken: local_config.grafana_enterprise.token,
                },
              },
            ],
          }),
        }),

      grafana_deployment+:
        k.util.configMapVolumeMount(self.pluginsConfigMap, self._config.provisioningDir + '/plugins'),


    },

}
