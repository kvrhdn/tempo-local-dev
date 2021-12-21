local mixin = import 'grafana-agent-mixin/mixin.libsonnet';

{
  [name]: std.manifestJsonEx(mixin.grafanaDashboards[name], '  ')
  for name in std.objectFields(mixin.grafanaDashboards)
}
