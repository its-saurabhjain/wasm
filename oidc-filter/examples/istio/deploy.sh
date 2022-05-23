#!/bin/bash

kind create cluster || echo cluster already exists
istioctl manifest apply -y
kubectl create ns keycloak
kubectl apply -n keycloak -f https://raw.githubusercontent.com/keycloak/keycloak-quickstarts/latest/kubernetes-examples/keycloak.yaml
kubectl rollout status deployment/keycloak -n keycloak
source setup-keycloak.sh

kubectl create ns httpapp
kubectl label namespace httpapp istio-injection=enabled || true
kubectl apply -f httpbin.yaml -n httpapp
kubectl apply -f httpbin-gateway.yaml

kubectl rollout status deployment/httpbin
HTTPBIN_POD=$(kubectl get pods -lapp=httpbin -o jsonpath='{.items[0].metadata.name}')
$HTTPBIN_POD=kubectl get pods -lapp=httpbin -n httpapp -o jsonpath='{.items[0].metadata.name}'
kubectl cp ../../oidc.wasm  ${HTTPBIN_POD}:/var/local/lib/wasm-filters/oidc.wasm --container istio-proxy

kubectl apply -f istio-auth.yaml -n httpapp
sed -e "s/INSERT_CLIENT_SECRET_HERE/${CLIENT_SECRET}/" envoyfilter.yaml | kubectl apply -f -