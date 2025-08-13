#!/bin/sh
set -eu

# Require the secret
: "${SUPABASE_PROJECT_REF:?Set SUPABASE_PROJECT_REF env var}"
: "${SUPABASE_SERVICE_ROLE_KEY:?Set SUPABASE_SERVICE_ROLE_KEY env var}"

# Replace environment variable placeholders
sed -e "s/\${SUPABASE_PROJECT_REF}/${SUPABASE_PROJECT_REF}/g" \
    -e "s/\${SUPABASE_SERVICE_ROLE_KEY}/${SUPABASE_SERVICE_ROLE_KEY}/g" \
    /etc/prometheus/prom.yml.tpl > /etc/prometheus/prom.yml

# Exec the original prometheus entrypoint
exec /bin/prometheus "$@"
