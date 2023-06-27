#!/bin/bash

set -m

# Install routes
IFS=',' read -ra SUBNETS <<< "${ADVERTISE_ROUTES}"
for s in "${SUBNETS[@]}"; do
  ip route add "$s" via "${CONTAINER_GATEWAY}"
done

# Set login server for tailscale
if [[ -z "$LOGIN_SERVER" ]]; then
	LOGIN_SERVER=https://controlplane.tailscale.com
fi

# Start tailscaled and bring tailscale up
/usr/local/bin/tailscaled ${TAILSCALED_ARGS} &
until /usr/local/bin/tailscale up \
  --reset --authkey=${AUTH_KEY} \
	--login-server ${LOGIN_SERVER} \
	--advertise-routes="${ADVERTISE_ROUTES}" \
  ${TAILSCALE_ARGS}
do
    sleep 0.1
done
echo Tailscale started

fg %1
