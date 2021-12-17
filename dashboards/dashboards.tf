resource "grafana_folder" "tempo" {
  title = "Grafana Tempo"
}

resource "grafana_dashboard" "tempo" {
  for_each = fileset(local.config.tempo_dir, "operations/tempo-mixin/yamls/*.json")

  config_json = file("${local.config.tempo_dir}${each.key}")
  folder      = grafana_folder.tempo.id
}

resource "grafana_folder" "agent" {
  title = "Grafana Agent"
}

resource "grafana_dashboard" "agent" {
  for_each = fileset(path.module, "agent/json/*.json")

  config_json = file(each.key)
  folder      = grafana_folder.agent.id
}
