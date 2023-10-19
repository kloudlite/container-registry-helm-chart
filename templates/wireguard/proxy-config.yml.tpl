{{- $name := printf "%s-wg-proxy-config" .Release.Name -}}

apiVersion: v1
data: 
  config.json: |+
    {"services":[{"id":"registry-api","name":"container-registry-api.kl-core.svc.cluster.local","servicePort":4000,"proxyPort":4000},{"id":"registry-kafka1","name":"redpanda.kl-core.svc.cluster.local","servicePort":9092,"proxyPort":9092}]}
kind: ConfigMap
metadata:
  name: {{ $name }}
