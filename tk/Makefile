TEMPO_DIR := $(shell cat ../config.json | jq .tempo_dir)

.PHONY: export-manifests
export-manifests: vendor
	rm -rf yaml/
	tk export yaml/ environments/tempo

vendor:
	jb update

	# manually add a symlink to the local Tempo repository
	ln -s $(TEMPO_DIR)/operations/jsonnet/microservices vendor/microservices
	ln -s $(TEMPO_DIR)/example/tk/lib/minio vendor/minio

	# agent jsonnet tries to mount /etc/machine-id by default, which doesn't work
	patch -p0 -i agent-machine-id.patch

.PHONY: fmt
fmt:
	jsonnetfmt -i environments/tempo/*.{j,lib}sonnet

.PHONY: clean
clean:
	rm -rf vendor yaml
