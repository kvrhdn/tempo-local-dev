{
  '*': {
    max_traces_per_user: 15000,  // max traces live in an ingester
    ingestion_rate_limit_bytes: 20000000,  // 20 MB/s
    ingestion_burst_size_bytes: 20000000,  // 20 MB/s
    max_bytes_per_trace: 15 * 1000 * 1000,  // bytes per trace
    max_bytes_per_tag_values_query: 10 * 1000 * 1000,  // max size of a tag-values query
    block_retention: '720h',  // standard 30 day retention

    metrics_generator_processors: ['service-graphs', 'span-metrics'],
  },
}
