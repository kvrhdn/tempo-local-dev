{
  // minimize resources so we can pack more components on this poor laptop
  local resources_small = {
    requests: {
      cpu: '100m',
      memory: '100Mi',
    },
    limits: {
      cpu: '4',
      memory: '8Gi',
    },
  },

  _config+:: {
    distributor+: {
      replicas: 1,
      resources: resources_small,
    },
    ingester+: {
      replicas: 3,
      resources: resources_small,
    },
    compactor+: {
      replicas: 1,
      resources: resources_small,
    },
    query_frontend+: {
      replicas: 1,
      resources: resources_small,
    },
    querier+: {
      replicas: 1,
      resources: resources_small,
    },
    memcached+: {
      replicas: 0,
      resources: resources_small,
    },
    vulture+: {
      replicas: 1,
      resources: resources_small,
    },
  },
}
