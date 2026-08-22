{{/*
VirtualService — the mesh half of canary traffic routing.

Rendered only for a Rollout with trafficRouting on, and always in the same
namespace as that Rollout: argo-rollouts finds the route to rewrite by name
(trafficRouting.istio.virtualServices[].routes) and the CRD offers no
namespace key, so the pair must already sit together.

Nothing here is hand-synced with the Rollout side — everything derives from
the same values block: the route names come from the list the Rollout
references, and the destinations are the stable/canary Service pair
_service.tpl renders. The 100/0 weights are the pre-rollout state
argo-rollouts starts from and rewrites on every setWeight step. This
replaces the hand-applied VirtualService the infra repo used to carry — an
out-of-band object drifts silently, and this one drifted the moment its
Rollout learned its route's name.

Ownership split that makes the pair safe under selfHeal: Argo owns this
object's shape (hosts, routes, destinations), the controller owns the
weights at runtime — the ApplicationSet's ignoreDifferences keeps those two
from fighting over the object mid-rollout.
*/}}
{{- define "platform-service.virtualservice" -}}
{{- range $name, $svc := .Values.services }}
{{- if and (eq $svc.workloadKind "Rollout") $svc.rollout.trafficRouting }}
{{- $lbls := dict "svc" (set $svc "name" $name) "root" $ -}}
{{- $stable := $svc.rollout.stableService | default $name -}}
{{- $canary := $svc.rollout.canaryService | default (printf "%s-canary" $name) -}}
{{- range $vs := $svc.rollout.trafficRouting.istio.virtualServices }}
---
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: {{ $vs.name }}
  namespace: {{ include "platform-service.namespace" $ }}
  labels:
    {{- include "platform-service.labels" $lbls | nindent 4 }}
spec:
  hosts:
    - {{ printf "%s.%s.svc.cluster.local" $name (include "platform-service.namespace" $) }}
  http:
    {{- range $route := $vs.routes }}
    - name: {{ $route }}
      route:
        - destination:
            host: {{ $stable }}
            port:
              number: 80
          weight: 100
        - destination:
            host: {{ $canary }}
            port:
              number: 80
          weight: 0
    {{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}
