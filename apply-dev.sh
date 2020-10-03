#!/usr/bin/env bash

kubectl delete job --namespace=tfwiki-dev mediawiki-update
kubectl apply -f k8s/dev/mediawiki-update.yml
kubectl apply -f k8s/dev/mediawiki.yaml