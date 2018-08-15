#!/bin/bash

kubectl apply -f istio/secret.yaml

echo "waiting ingressgateway mounts secret..."
val=`kubectl exec -ti $(kubectl get po -l istio=ingressgateway -n istio-system -o jsonpath={.items[0]..metadata.name}) -n istio-system -- ls /etc/istio/ingressgateway-certs`
while [ "x$val" = "x" ]; do
  sleep 3
  val=`kubectl exec -ti $(kubectl get po -l istio=ingressgateway -n istio-system -o jsonpath={.items[0]..metadata.name}) -n istio-system -- ls /etc/istio/ingressgateway-certs`
done
echo "ok!"

kubectl apply -f istio/frontend-ingress-gateway.yaml

kubectl apply -f <( istioctl kube-inject -f mysql.yaml )
kubectl apply -f <( istioctl kube-inject -f mysql-apiserver.yaml )
kubectl apply -f <( istioctl kube-inject -f frontend.yaml )
