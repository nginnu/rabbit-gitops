{{/*
Service — port 80 forwarding to the container's http port.

A traffic-routing Rollout needs a second Service to split between: the
controller pins pod-template-hash onto the stable/canary pair at runtime and
rewrites the VirtualService weights between them, so both carry the plain
selector here — the twin is identical to the stable one except the name.
*/}}
{{- define "platform-service.service" -}}
{{- range $name, $svc := .Values.services }}
{{- $lbls := dict "svc" (set $svc "name" $name) "root" $ -}}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ $name }}
  namespace: {{ include "platform-service.namespace" $ }}
  labels:
    {{- include "platform-service.labels" $lbls | nindent 4 }}
spec:
  selector:
    {{- include "platform-service.selectorLabels" (dict "svc" (dict "name" $name)) | nindent 4 }}
  ports:
    - name: http
      port: 80
      targetPort: http
{{- if and (eq $svc.workloadKind "Rollout") $svc.rollout.trafficRouting }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ $svc.rollout.canaryService | default (printf "%s-canary" $name) }}
  namespace: {{ include "platform-service.namespace" $ }}
  labels:
    {{- include "platform-service.labels" $lbls | nindent 4 }}
spec:
  selector:
    {{- include "platform-service.selectorLabels" (dict "svc" (dict "name" $name)) | nindent 4 }}
  ports:
    - name: http
      port: 80
      targetPort: http
{{- end }}
{{- end }}
{{- end -}}
