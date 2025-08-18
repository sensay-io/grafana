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

  # Supabase projects - dynamically generated from SUPABASE_PROJECTS
  # SUPABASE_JOBS_PLACEHOLDER
