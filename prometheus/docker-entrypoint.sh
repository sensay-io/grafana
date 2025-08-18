#!/bin/sh
set -eu

# Require the new configuration format
: "${SUPABASE_PROJECTS:?Set SUPABASE_PROJECTS env var (format: project_id:KEY_REF;project_id2:KEY_REF2)}"

# Function to generate Supabase job configuration
generate_supabase_jobs() {
    local projects="$1"
    local jobs=""
    
    # Split projects by semicolon and process each
    echo "$projects" | tr ';' '\n' | while IFS=':' read -r project_id key_ref; do
        # Skip empty lines
        [ -z "$project_id" ] && continue
        
        # Get the secret key value from the environment variable reference
        key_value=$(eval echo "\${$key_ref}")
        
        # Generate job configuration
        cat << EOF

  - job_name: supabase-${project_id}
    scheme: https
    metrics_path: "/customer/v1/privileged/metrics"
    params:
      supabase_grafana: ["true"]
    basic_auth:
      username: service_role
      password: ${key_value}
    static_configs:
      - targets: ["${project_id}.supabase.co"]
EOF
    done
}

echo "Generating Prometheus configuration from SUPABASE_PROJECTS..."

# Generate Supabase jobs from SUPABASE_PROJECTS
supabase_jobs=$(generate_supabase_jobs "$SUPABASE_PROJECTS")

# Replace placeholder with generated jobs
sed -e "s|# SUPABASE_JOBS_PLACEHOLDER|${supabase_jobs}|g" \
    /etc/prometheus/prom.yml.tpl > /etc/prometheus/prom.yml

echo "Generated Prometheus configuration:"
cat /etc/prometheus/prom.yml

# Exec the original prometheus entrypoint
exec /bin/prometheus "$@"
