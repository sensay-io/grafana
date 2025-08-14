global:
  scrape_interval: 60s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  # - job_name: 'example_api'
  #   scheme: http
  #   static_configs:
  #     - targets: ['example_api:9091']

  #  ? TODO: add your services here
  # - job_name: 'your-job-name'
  #   scheme: https
  #   static_configs:
  #     - targets: ['URL_GOES_HERE']
  #   basic_auth:
  #     username: HTTP_AUTH_USERNAME_GOES_HERE
  #     password: HTTP_AUTH_PASSWORD_GOES_HERE%

  # Supabase Project 1
  - job_name: supabase-${SUPABASE_PROJECT_1_REF}
    scheme: https
    metrics_path: "/customer/v1/privileged/metrics"
    params:
      supabase_grafana: ["true"]
    basic_auth:
      username: service_role
      password: ${SUPABASE_PROJECT_1_SERVICE_ROLE_KEY}
    static_configs:
      - targets: ["${SUPABASE_PROJECT_1_REF}.supabase.co"]

  # Supabase Project 2
  - job_name: supabase-${SUPABASE_PROJECT_2_REF}
    scheme: https
    metrics_path: "/customer/v1/privileged/metrics"
    params:
      supabase_grafana: ["true"]
    basic_auth:
      username: service_role
      password: ${SUPABASE_PROJECT_2_SERVICE_ROLE_KEY}
    static_configs:
      - targets: ["${SUPABASE_PROJECT_2_REF}.supabase.co"]

  # Add more projects as needed:
  # - job_name: supabase-${SUPABASE_PROJECT_3_REF}
  #   scheme: https
  #   metrics_path: "/customer/v1/privileged/metrics"
  #   params:
  #     supabase_grafana: ["true"]
  #   basic_auth:
  #     username: service_role
  #     password: ${SUPABASE_PROJECT_3_SERVICE_ROLE_KEY}
  #   static_configs:
  #     - targets: ["${SUPABASE_PROJECT_3_REF}.supabase.co"]
