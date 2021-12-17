tempo_dir = decode_json(read_file('config.json'))['tempo_dir']

# Manual tasks

local_resource('tk export', 'make tk')

# Docker builds

custom_build(
    'grafana/tempo',
    'cd ' + tempo_dir + ' && make docker-tempo',
    tag='latest',
    deps=[tempo_dir + 'cmd/tempo/', tempo_dir + 'modules/', tempo_dir + 'pkg/', tempo_dir + 'tempodb', tempo_dir + 'vendor/'],
)
custom_build(
    'grafana/tempo-query',
    'cd ' + tempo_dir + ' && make docker-tempo-query',
    tag='latest',
    deps=[tempo_dir + 'cmd/tempo-query/', tempo_dir + 'vendor/'],
)
custom_build(
    'grafana/tempo-vulture',
    'cd ' + tempo_dir + ' && make docker-tempo-vulture',
    tag='latest',
    deps=[tempo_dir + 'cmd/tempo-vulture/', tempo_dir + 'vendor/'],
)

# Kubernetes

k8s_yaml(listdir('tk/yaml/'))

k8s_resource('grafana', port_forwards='3000')
k8s_resource('prometheus', port_forwards='9090')

k8s_resource('query-frontend', port_forwards=['3200', '16686'])
k8s_resource('querier', port_forwards=['3201'])
k8s_resource('distributor', port_forwards=['3202', '4317'])
k8s_resource('ingester', port_forwards=['3203'])
k8s_resource('metrics-generator', port_forwards=['3204'])
k8s_resource('compactor', port_forwards=['3205'])

k8s_resource('minio', port_forwards=['9000'])
