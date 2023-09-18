{{- $name := print (include "registry-helmchart.fullname" .) "-auth" -}}
{{- $namespace := .Release.namespace -}}

apiVersion: v1
kind: Service
metadata:
  name: {{ $name }}
  namespace: {{ $namespace }}
spec:
  ports:
  - name: "auth"
    port: 80
    protocol: TCP
    targetPort: 3000

  - name: "admin"
    port: 4000
    protocol: TCP
    targetPort: 4000
  selector:
    name: {{ $name }}
