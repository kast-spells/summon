{{/*kast - Kubernetes arcane spelling technology
Copyright (C) 2023 namenmalkv@gmail.com
Licensed under the GNU GPL v3. See LICENSE file for details.
*/}}
{{- define "aws.iam-oidc-k8s-role" }}
{{- $root := index . 0 -}}
{{- $glyphDefinition := index . 1}}
{{- $k8sClusters := get (include "runicIndexer.runicIndexer" (list $root.Values.lexicon (default dict $glyphDefinition.selector) "k8s-cluster" $root.Values.chapter.name ) | fromJson) "results" }}
{{- range $k8sCluster := $k8sClusters }}
---
apiVersion: iam.services.k8s.aws/v1alpha1
kind: Role
metadata:
  name: {{ default (include "common.name" $root) $glyphDefinition.name }}
  {{- with $glyphDefinition.namespace }}
  namespace: {{ . }}
  {{- end }}
  labels:
    {{- include "common.all.labels" $root | nindent 4 }}
    {{- with $glyphDefinition.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with $glyphDefinition.annotations }}
  annotations:
    {{- include "common.annotations" $root | nindent 4 }}
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  name: {{ default (include "common.name" $root) $glyphDefinition.name }}
  {{- with $glyphDefinition.path }}
  path: {{ . }}
  {{- end }}
  description: "{{ default (include "common.name" $root) $glyphDefinition.description }}"
  {{- if $glyphDefinition.permissionsBoundary }}
    {{- if $glyphDefinition.permissionsBoundary.selector }}
      {{- $boundaries := get (include "runicIndexer.runicIndexer" (list $root.Values.lexicon $glyphDefinition.permissionsBoundary.selector "aws-permissions-boundary" $root.Values.chapter.name ) | fromJson) "results" }}
      {{- range $boundary := $boundaries }}
  permissionsBoundary: {{ $boundary.arn }}
      {{- end }}
    {{- else }}
  permissionsBoundary: {{ $glyphDefinition.permissionsBoundary }}
    {{- end }}
  {{- end }}
  assumeRolePolicyDocument: |
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Federated": "arn:aws:iam::{{ default $k8sCluster.accountID $glyphDefinition.accountID }}:oidc-provider/oidc.eks.{{ default $k8sCluster.region $glyphDefinition.region }}.amazonaws.com/id/{{ default $k8sCluster.oidcID $glyphDefinition.oidcID }}"
          },
          "Action": "sts:AssumeRoleWithWebIdentity",
          "Condition": {
            "StringEquals": {
              "oidc.eks.{{ default $k8sCluster.region $glyphDefinition.region }}.amazonaws.com/id/{{ default $k8sCluster.oidcID $glyphDefinition.oidcID }}:sub": [
                {{- if $glyphDefinition.serviceAccounts }}
                {{- range $index, $sa := $glyphDefinition.serviceAccounts }}
                {{- if $index }},{{ end }}
                "system:serviceaccount:{{ default $root.Release.Namespace $sa.namespace }}:{{ $sa.name }}"
                {{- end }}
                {{- else }}
                "system:serviceaccount:{{ default $root.Release.Namespace  $glyphDefinition.namespace }}:{{ default (include "common.name" $root) $glyphDefinition.nameOverride }}"
                {{- end }}
              ],
              "oidc.eks.{{ default $k8sCluster.region $glyphDefinition.region }}.amazonaws.com/id/{{ default $k8sCluster.oidcID $glyphDefinition.oidcID }}:aud": "sts.amazonaws.com"
            }
          }
        }
      ]
    }
  policies: # usear runic indexer para traer las policies por selector
  {{- range $policy := $glyphDefinition.policies }}
  {{- $policies := get (include "runicIndexer.runicIndexer" (list $root.Values.lexicon (default dict $policy.selector ) "aws-iam-policy" $root.Values.chapter.name ) | fromJson) "results" }}
    {{- range $policyResult := $policies }}
    - {{ $policyResult.arn }}
    {{- end }}  
  {{- end }}
  tags:
    - key: Name
      value: {{ default (include "common.name" $root) $glyphDefinition.name }}
    - key: ManagedBy
      value: ack-iam-controller
    {{- if $k8sCluster.clusterName }}
    - key: Cluster
      value: {{ $k8sCluster.clusterName }}
    {{- end }}
    {{- if $k8sCluster.labels.environment }}
    - key: Environment
      value: {{ $k8sCluster.labels.environment }}
    {{- end }}
    {{- if $root.Values.book }}
    - key: Application
      value: {{ $root.Values.book.name }}
    {{- end }}
    {{- with $glyphDefinition.component }}
    - key: Component
      value: {{ . }}
    {{- end }}
    {{- range $glyphDefinition.tags }}
    - key: {{ .key }}
      value: {{ .value }}
    {{- end }}
{{- end }}
{{- end }}
