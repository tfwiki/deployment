#!/usr/bin/env bash

#kubectl delete job mediawiki-update
#kubectl apply -f k8s/common/mediawiki-update.yml
kubectl apply -f k8s/common/mediawiki.yaml
kubectl apply -f k8s/common/run-jobs.yaml
kubectl apply -f k8s/common/update-special-pages.yaml
