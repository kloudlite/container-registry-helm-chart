{{- $name := printf "%s-wg" .Release.Name -}}
{{- $namespace := .Release.Namespace -}}

apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    kloudlite.io/wg-deployment: "true"
  name: {{ $name }}
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: {{ $name }}
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: {{ $name }}
        kloudlite.io/wg-pod: "true"
    spec:
      serviceAccountName: {{ .Release.Name }}
      containers:
      - env:
        - name: CONFIG_FILE
          value: /proxy-config/config.json
        image: ghcr.io/kloudlite/platform/apis/wg-proxy:v1.0.5-nightly
        imagePullPolicy: IfNotPresent
        name: proxy
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /proxy-config
          name: config-path
      - image: ghcr.io/kloudlite/platform/apis/wg-restart:v1.0.5-nightly
        imagePullPolicy: IfNotPresent
        name: wireguard
        ports:
        - containerPort: 51820
          protocol: UDP
        resources:
          limits:
            memory: 128Mi
          requests:
            memory: 64Mi
        securityContext:
          capabilities:
            add:
            - NET_ADMIN
            - SYS_MODULE
          privileged: true
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /etc/wireguard/wg0.conf
          name: wg-config
          subPath: wg0.conf
        - mountPath: /lib/modules
          name: host-volumes
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
      volumes:
      - name: wg-config
        secret:
          defaultMode: 420
          items:
          - key: data
            path: wg0.conf
          secretName: {{ $name }}-server-config
      - hostPath:
          path: /lib/modules
          type: Directory
        name: host-volumes
      - configMap:
          defaultMode: 420
          items:
          - key: config.json
            path: config.json
          name: {{ $name }}-proxy-config
        name: config-path


