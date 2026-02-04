# {{/*kast - Kubernetes arcane spelling technology
# Copyright (C) 2026 kazapeke@gmail.com
# Licensed under the GNU GPL v3. See LICENSE file for details.
# */}}
# {{- define "aws.ack-s3-controller" }}
# {{- $root := index . 0 -}}
# {{- $glyphDefinition := index . 1 }}
# {{- $k8sClusters := get (include "runicIndexer.runicIndexer" (list $root.Values.lexicon (default dict $glyphDefinition.selector) "k8s-cluster" $root.Values.chapter.name) | fromJson) "results" }}
# {{- range $k8sCluster := $k8sClusters }}
# {{- $controllerName := default "ack-s3-controller" $glyphDefinition.controllerName }}
# {{- $namespace := default "ack-system" $glyphDefinition.namespace }}
# {{- $serviceAccountName := default "ack-s3-controller" $glyphDefinition.serviceAccountName }}
# {{- $path := default "/ack/" $glyphDefinition.path }}
# {{- $region := default $k8sCluster.region $glyphDefinition.region }}
# {{- $accountID := default $k8sCluster.accountID $glyphDefinition.accountID }}
# {{- $oidcID := default $k8sCluster.oidcID $glyphDefinition.oidcID }}
# ---
# apiVersion: iam.services.k8s.aws/v1alpha1
# kind: Role
# metadata:
#   name: {{ $glyphDefinition.name }}
#   namespace: {{ $namespace }}
#   labels:
#     {{- include "common.all.labels" $root | nindent 4 }}
#     app.kubernetes.io/component: ack-s3-controller
#     {{- with $glyphDefinition.labels }}
#     {{- toYaml . | nindent 4 }}
#     {{- end }}
# spec:
#   name: {{ $glyphDefinition.name }}
#   path: {{ $path }}
#   description: {{ default (printf "IAM Role for %s" $controllerName) $glyphDefinition.roleDescription | quote }}
#   {{- with $glyphDefinition.permissionsBoundary }}
#   permissionsBoundary: {{ . }}
#   {{- end }}
#   assumeRolePolicyDocument: |
#     {
#       "Version": "2012-10-17",
#       "Statement": [
#         {
#           "Effect": "Allow",
#           "Principal": {
#             "Federated": "arn:aws:iam::{{ $accountID }}:oidc-provider/oidc.eks.{{ $region }}.amazonaws.com/id/{{ $oidcID }}"
#           },
#           "Action": "sts:AssumeRoleWithWebIdentity",
#           "Condition": {
#             "StringEquals": {
#               "oidc.eks.{{ $region }}.amazonaws.com/id/{{ $oidcID }}:sub": "system:serviceaccount:{{ $namespace }}:{{ $serviceAccountName }}",
#               "oidc.eks.{{ $region }}.amazonaws.com/id/{{ $oidcID }}:aud": "sts.amazonaws.com"
#             }
#           }
#         }
#       ]
#     }
#   policies:
#     - arn:aws:iam::{{ $accountID }}:policy{{ $path }}{{ $glyphDefinition.name }}-iam-policy
#   {{- if $glyphDefinition.tags }}
#   tags:
#     {{- range $glyphDefinition.tags }}
#     - key: {{ .key }}
#       value: {{ .value }}
#     {{- end }}
#   {{- else }}
#   tags:
#     - key: Name
#       value: {{ $glyphDefinition.name }}
#     - key: ManagedBy
#       value: ack-iam-controller
#     - key: Component
#       value: ack-s3-controller
#   {{- end }}
# ---
# apiVersion: iam.services.k8s.aws/v1alpha1
# kind: Policy
# metadata:
#   name: {{ $glyphDefinition.name }}-iam-policy
#   namespace: {{ $namespace }}
#   labels:
#     {{- include "common.all.labels" $root | nindent 4 }}
#     app.kubernetes.io/component: ack-s3-controller
#     {{- with $glyphDefinition.labels }}
#     {{- toYaml . | nindent 4 }}
#     {{- end }}
# spec:
#   name: {{ $glyphDefinition.name }}-iam-policy
#   path: {{ $path }}
#   description: {{ default (printf "IAM Policy for %s to manage S3 resources" $controllerName) $glyphDefinition.policyDescription | quote }}
#   policyDocument: |
#     {
#       "Version": "2012-10-17",
#       "Statement": [
#         {
#           "Effect": "Allow",
#           "Action": [
#             "s3:CreateBucket",
#             "s3:DeleteBucket",
#             "s3:ListBucket",
#             "s3:ListAllMyBuckets",
#             "s3:GetBucketLocation",
#             "s3:GetBucketVersioning",
#             "s3:PutBucketVersioning",
#             "s3:GetBucketAcl",
#             "s3:PutBucketAcl",
#             "s3:GetBucketCORS",
#             "s3:PutBucketCORS",
#             "s3:DeleteBucketCORS",
#             "s3:GetBucketWebsite",
#             "s3:PutBucketWebsite",
#             "s3:DeleteBucketWebsite",
#             "s3:GetBucketLogging",
#             "s3:PutBucketLogging",
#             "s3:GetBucketNotification",
#             "s3:PutBucketNotification",
#             "s3:GetBucketPolicy",
#             "s3:PutBucketPolicy",
#             "s3:DeleteBucketPolicy",
#             "s3:GetBucketRequestPayment",
#             "s3:PutBucketRequestPayment",
#             "s3:GetBucketTagging",
#             "s3:PutBucketTagging",
#             "s3:DeleteBucketTagging",
#             "s3:GetLifecycleConfiguration",
#             "s3:PutLifecycleConfiguration",
#             "s3:DeleteLifecycleConfiguration",
#             "s3:GetReplicationConfiguration",
#             "s3:PutReplicationConfiguration",
#             "s3:DeleteReplicationConfiguration",
#             "s3:GetEncryptionConfiguration",
#             "s3:PutEncryptionConfiguration",
#             "s3:DeleteEncryptionConfiguration",
#             "s3:GetBucketPublicAccessBlock",
#             "s3:PutBucketPublicAccessBlock",
#             "s3:DeleteBucketPublicAccessBlock",
#             "s3:GetAccelerateConfiguration",
#             "s3:PutAccelerateConfiguration",
#             "s3:GetBucketOwnershipControls",
#             "s3:PutBucketOwnershipControls",
#             "s3:DeleteBucketOwnershipControls",
#             "s3:GetIntelligentTieringConfiguration",
#             "s3:PutIntelligentTieringConfiguration",
#             "s3:DeleteIntelligentTieringConfiguration",
#             "s3:GetInventoryConfiguration",
#             "s3:PutInventoryConfiguration",
#             "s3:DeleteInventoryConfiguration",
#             "s3:GetMetricsConfiguration",
#             "s3:PutMetricsConfiguration",
#             "s3:DeleteMetricsConfiguration",
#             "s3:GetAnalyticsConfiguration",
#             "s3:PutAnalyticsConfiguration",
#             "s3:DeleteAnalyticsConfiguration",
#             "kms:CreateGrant",
#             "kms:DescribeKey",
#             "kms:Decrypt",
#             "kms:Encrypt",
#             "kms:GenerateDataKey",
#             "kms:GenerateDataKeyWithoutPlaintext"
#           ],
#           "Resource": "*"
#         }
#       ]
#     }
#   {{- if $glyphDefinition.tags }}
#   tags:
#     {{- range $glyphDefinition.tags }}
#     - key: {{ .key }}
#       value: {{ .value }}
#     {{- end }}
#   {{- else }}
#   tags:
#     - key: Name
#       value: {{ $glyphDefinition.name }}-iam-policy
#     - key: ManagedBy
#       value: ack-iam-controller
#     - key: Component
#       value: ack-s3-controller
#   {{- end }}
# {{- end }}
# {{- end }}
