#!/bin/sh
set -eu

# Require the new configuration format
: "${SUPABASE_PROJECTS:?Set SUPABASE_PROJECTS env var (format: project_id:KEY_REF:DISPLAY_NAME;project_id2:KEY_REF2:DISPLAY_NAME2)}"

# Function to generate Supabase job configuration
generate_supabase_jobs() {
  local projects="$1"
  local jobs=""

  # Split projects by semicolon and process each
  echo "$projects" | tr ';' '\n' | while IFS=':' read -r project_id key_ref display_name; do
    # Skip empty lines
    [ -z "$project_id" ] && continue

    # Use project_id as display name if not provided (backward compatibility)
    if [ -z "$display_name" ]; then
      display_name="$project_id"
    fi

    # Get the secret key value from the environment variable reference
    key_value=$(eval echo "\${$key_ref}")

    # Generate job configuration
    cat <<EOF

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
    metric_relabel_configs:
      - source_labels: [supabase_project_ref]
        target_label: project_name
        replacement: '${display_name}'
      - source_labels: [supabase_project_ref]
        target_label: project_display
        replacement: '${display_name} (${project_id})'
EOF
  done
}

echo "Generating Prometheus configuration from SUPABASE_PROJECTS..."

# Generate Supabase jobs from SUPABASE_PROJECTS
supabase_jobs=$(generate_supabase_jobs "$SUPABASE_PROJECTS")

# Create config by replacing placeholder with generated jobs
# Use awk to avoid sed escaping issues with special characters
awk -v jobs="$supabase_jobs" '
/# SUPABASE_JOBS_PLACEHOLDER/ { print jobs; next }
{ print }
' /etc/prometheus/prom.yml.tpl >/etc/prometheus/prom.yml

# Pushgateway vars: provide safe defaults for host/port; require password
: "${PUSHGATEWAY_HOST:=pushgateway.railway.internal}"
: "${PUSHGATEWAY_PORT:=9091}"
# : "${PUSHGATEWAY_PASSWORD:?Set PUSHGATEWAY_PASSWORD env var for Pushgateway basic_auth}"

sed_escape() {
  printf '%s' "$1" | sed -e 's/[\/&|\\]/\\&/g'
}
PUSHGATEWAY_HOST_ESCAPED="$(sed_escape "$PUSHGATEWAY_HOST")"
PUSHGATEWAY_PORT_ESCAPED="$(sed_escape "$PUSHGATEWAY_PORT")"
PUSHGATEWAY_PASSWORD_ESCAPED="$(sed_escape "$PUSHGATEWAY_PASSWORD")"

sed -i \
  -e "s|\${PUSHGATEWAY_HOST}|${PUSHGATEWAY_HOST_ESCAPED}|g" \
  -e "s|\${PUSHGATEWAY_PORT}|${PUSHGATEWAY_PORT_ESCAPED}|g" \
  -e "s|\${PUSHGATEWAY_PASSWORD}|${PUSHGATEWAY_PASSWORD_ESCAPED}|g" \
  /etc/prometheus/prom.yml

echo "Generated Prometheus configuration:"
grep -n 'pushgateway' -n /etc/prometheus/prom.yml &&
  grep -n '\${PUSHGATEWAY_' /etc/prometheus/prom.yml || true

# Exec Prometheus
exec /bin/prometheus "$@"
