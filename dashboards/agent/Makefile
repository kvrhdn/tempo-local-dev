AGENT_DIR := $(shell cat ../../config.json | jq .agent_dir)

json: agent vendor
	mkdir -p json
	jsonnet -J vendor -S dashboards.jsonnet -m json

agent:
	ln -s $(AGENT_DIR) agent

vendor:
	jb update

.PHONY: clean
clean:
	rm -rf json agent vendor
