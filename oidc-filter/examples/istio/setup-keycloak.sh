#!/bin/bash

set -eux

# kubectl -n oidc port-forward svc/keycloak 8080:8080 &
# port_forward_pid=$!

sleep 2

export TKN=$(curl -X POST 'http://localhost:8080/realms/master/protocol/openid-connect/token' \
 -H "Content-Type: application/x-www-form-urlencoded" \
 -d "username=admin" \
 -d 'password=admin' \
 -d 'grant_type=password' \
 -d 'client_id=admin-cli' | jq -r '.access_token')

curl -X POST 'http://localhost:8080/admin/realms/master/clients' \
 -H "authorization: Bearer ${TKN}" \
 -H "Content-Type: application/json" \
 --data \
 '{
    "id": "test",
    "name": "test",
    "redirectUris": ["*"]
 }' 

export CLIENT_SECRET=$(curl 'http://localhost:8080/admin/realms/master/clients/test/client-secret' \
 -H "authorization: Bearer ${TKN}" \
 -H "Content-Type: application/json" | jq -r '.value')

# kill -9 $port_forward_pid
