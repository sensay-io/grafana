#!/usr/bin/env sh
set -eu

# Require bcrypt hash in env
PASSWORD_HASH="${PUSHGATEWAY_HASH:?Set PUSHGATEWAY_HASH to a bcrypt hash}"

# Write minimal web.yml
cat >/etc/pushgateway-web.yml <<EOF
basic_auth_users:
  pusher: "${PASSWORD_HASH}"
EOF

# Start Pushgateway on IPv6, port 9091, with auth
exec /bin/pushgateway \
  --web.listen-address=[::]:9091 \
  --web.config.file=/etc/pushgateway-web.yml
