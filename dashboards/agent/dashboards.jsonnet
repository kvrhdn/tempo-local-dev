local mixin = import 'agent/production/grafana-agent-mixin/mixin.libsonnet';

{
  [name]: std.manifestJsonEx(mixin.grafanaDashboards[name], '  ')
  for name in std.objectFields(mixin.grafanaDashboards)
}
