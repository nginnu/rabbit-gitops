{{/*
DestinationRule — the stable/canary subsets argo-rollouts routes between.

The controller does not create this object, it only maintains it: without
the object present the Rollout sits Degraded on DestinationRuleNotFound.
Rendered bare — no labels on the subsets — because the pod-template-hash
labels are the controller's to write as ReplicaSets change, which is why
the ApplicationSet carries ignoreDifferences for them.

Host and subset names come from the same rollout values block the
VirtualService destinations reference.
*/}}
{{- define "platform-service.destinationrule" -}}
{{- range $name, $svc := .Values.services }}
{{- if and (eq $svc.workloadKind "Rollout") $svc.rollout.trafficRouting }}
{{- if $svc.rollout.trafficRouting.istio.destinationRule }}
{{- $lbls := dict "svc" (set $svc "name" $name) "root" $ -}}
{{- $dr := $svc.rollout.trafficRouting.istio.destinationRule -}}
---
apiVersion: networking.istio.io/v1
kind: DestinationRule
metadata:
  name: {{ $dr.name }}
  namespace: {{ include "platform-service.namespace" $ }}
  labels:
    {{- include "platform-service.labels" $lbls | nindent 4 }}
spec:
  host: {{ $svc.rollout.stableService | default $name }}
  subsets:
    - name: {{ $dr.stableSubsetName }}
    - name: {{ $dr.canarySubsetName }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}
