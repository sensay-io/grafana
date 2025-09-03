#!/bin/sh
set -eu

# --- 0) Inputs / defaults ---
# Optional Supabase – keep as-is (don’t require it)
SUPABASE_PROJECTS="${SUPABASE_PROJECTS:-}"

# Pushgateway vars: provide safe defaults for host/port; require password
: "${PUSHGATEWAY_HOST:=pushgateway.railway.internal}"
: "${PUSHGATEWAY_PORT:=9091}"
: "${PUSHGATEWAY_PASSWORD:?Set PUSHGATEWAY_PASSWORD env var for Pushgateway basic_auth}"

# --- generate Supabase jobs: (your existing function) ---
# ... keep your generate_supabase_jobs() exactly as you have it ...

# Render template with Supabase jobs first (as you already do)
awk -v jobs="$(generate_supabase_jobs "$SUPABASE_PROJECTS" || true)" '
  /# SUPABASE_JOBS_PLACEHOLDER/ { print jobs; next }
  { print }
' /etc/prometheus/prom.yml.tpl >/etc/prometheus/prom.yml

# --- 1) Escape values for sed and replace placeholders in-place ---
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
