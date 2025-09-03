#!/usr/bin/env sh
set -eu

HASH="${PUSHGATEWAY_HASH:?Set PUSHGATEWAY_HASH to a bcrypt hash}"

WEBCFG="/tmp/pushgateway-web.yml" # writable without root
cat >"$WEBCFG" <<EOF
basic_auth_users:
  pusher: "$HASH"
EOF

exec /bin/pushgateway \
  --web.listen-address=[::]:9091 \
  --web.config.file="$WEBCFG"
