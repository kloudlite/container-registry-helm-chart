{{- $name := print (include "registry-helmchart.fullname" .) "-registry" -}}
{{- $namespace := .Release.namespace -}}

apiVersion: v1
kind: Service
metadata:
  name: {{ $name }}
  namespace: {{ $namespace }}
spec:
  ports:
  - name: "registry"
    port: 80
    protocol: TCP
    targetPort: 5000
  selector:
    app: {{ $name }}
