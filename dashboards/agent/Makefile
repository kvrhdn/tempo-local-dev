AGENT_DIR := $(shell cat ../../config.json | jq .agent_dir)

json: vendor
	mkdir -p json
	jsonnet -J vendor -S dashboards.jsonnet -m json

vendor:
	jb update

	# manually add a symlink to the local Agent repository
	ln -s $(AGENT_DIR)/production/grafana-agent-mixin vendor/grafana-agent-mixin

.PHONY: clean
clean:
	rm -rf json vendor
