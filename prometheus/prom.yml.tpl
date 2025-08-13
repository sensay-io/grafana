global:
  scrape_interval: 15s # Default scrape interval

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

  - job_name: supabase-${SUPABASE_PROJECT_REF}
    scheme: https
    metrics_path: "/customer/v1/privileged/metrics"
    params:
      supabase_grafana: ["true"]
    basic_auth:
      username: service_role
      password: ${SUPABASE_SERVICE_ROLE_KEY}
    static_configs:
      - targets: ["${SUPABASE_PROJECT_REF}.supabase.co"]
