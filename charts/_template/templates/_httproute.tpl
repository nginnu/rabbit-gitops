{{- define "platform-service.httproute" -}}
{{- range $name, $svc := .Values.services }}
{{- if $svc.route }}
{{- $lbls := dict "svc" (set $svc "name" $name) "root" $ -}}
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: {{ $name }}
  namespace: {{ include "platform-service.namespace" $ }}
  labels:
    {{- include "platform-service.labels" $lbls | nindent 4 }}
spec:
  hostnames:
    {{- range $svc.route.hostnames }}
    - {{ . }}
    {{- end }}
  parentRefs:
    # group and kind are defaulted by the API server, so a route written
    # without them comes back with them and ArgoCD reads the difference as
    # drift — the Application sits OutOfSync forever while every object it
    # manages is already correct.
    - group: gateway.networking.k8s.io
      kind: Gateway
      name: {{ $svc.route.gateway | default "external" }}
      namespace: {{ $svc.route.gatewayNamespace | default "gateway" }}
      {{- with $svc.route.section }}
      sectionName: {{ . }}
      {{- end }}
  rules:
    {{- range $svc.route.rules }}
    - matches:
        - path: { type: PathPrefix, value: {{ .path }} }
      {{- with .rewrite }}
      filters:
        - type: URLRewrite
          urlRewrite:
            path: { type: ReplacePrefixMatch, replacePrefixMatch: {{ . }} }
      {{- end }}
      backendRefs:
        # Same reason as parentRefs above: group "" (core), kind Service and
        # weight 1 are all filled in on admission.
        {{- if and (eq $svc.workloadKind "Rollout") $svc.rollout.trafficRouting }}
        - group: ""
          kind: Service
          name: istio-ingressgateway
          namespace: istio-system
          port: 80
          weight: 1
        {{- else }}
        - group: ""
          kind: Service
          name: {{ $name }}
          port: 80
          weight: 1
        {{- end }}
    {{- end }}
{{- end }}
{{- end }}
{{- end -}}
