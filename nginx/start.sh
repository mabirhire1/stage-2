#!/bin/sh
set -e

# install envsubst (gettext) at container runtime (no image build)
# small runtime cost once at container start — acceptable for testing/CI
if ! command -v envsubst >/dev/null 2>&1; then
  apk add --no-cache gettext
fi

# create final config from template, substituting env vars
envsubst '\$ACTIVE_POOL \$APP_PORT \$BLUE_HOST \$BLUE_PORT \$GREEN_HOST \$GREEN_PORT' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# start nginx in foreground
nginx -g 'daemon off;'
