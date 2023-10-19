{{- $name := printf "svc-%s-platform-registry-api" .Release.Name -}}

apiVersion: v1
kind: Service
metadata:
  labels:
    kloudlite.io/wg-device.name: registry
  name: {{ $name }}
spec:
  ports:
  - name: registry-80
    port: 80
    protocol: TCP
    targetPort: 4000
  - name: registry-9092
    port: 9092
    protocol: TCP
    targetPort: 9092
  selector:
    app: {{ .Release.Name }}-wg
  type: ClusterIP
