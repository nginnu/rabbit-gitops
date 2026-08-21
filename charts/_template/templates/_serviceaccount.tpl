{{- define "platform-service.serviceaccount" -}}
{{- range $name, $svc := .Values.services }}
{{- $lbls := dict "svc" (set $svc "name" $name) "root" $ -}}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ $svc.serviceAccount | default $name }}
  namespace: {{ include "platform-service.namespace" $ }}
  labels:
    {{- include "platform-service.labels" $lbls | nindent 4 }}
{{- end }}
{{- end -}}
