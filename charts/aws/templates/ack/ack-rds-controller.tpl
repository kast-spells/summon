# {{/*kast - Kubernetes arcane spelling technology
# Copyright (C) 2026 kazapeke@gmail.com
# Licensed under the GNU GPL v3. See LICENSE file for details.
# */}}
# {{- define "aws.ack-rds-controller" }}
# {{- $root := index . 0 -}}
# {{- $glyphDefinition := index . 1 }}
# {{- $k8sClusters := get (include "runicIndexer.runicIndexer" (list $root.Values.lexicon (default dict $glyphDefinition.selector) "k8s-cluster" $root.Values.chapter.name) | fromJson) "results" }}
# {{- range $k8sCluster := $k8sClusters }}
# {{- $controllerName := default "ack-rds-controller" $glyphDefinition.controllerName }}
# {{- $namespace := default "ack-system" $glyphDefinition.namespace }}
# {{- $serviceAccountName := default "ack-rds-controller" $glyphDefinition.serviceAccountName }}
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
#     app.kubernetes.io/component: ack-rds-controller
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
#       value: ack-rds-controller
#   {{- end }}
# ---
# apiVersion: iam.services.k8s.aws/v1alpha1
# kind: Policy
# metadata:
#   name: {{ $glyphDefinition.name }}-iam-policy
#   namespace: {{ $namespace }}
#   labels:
#     {{- include "common.all.labels" $root | nindent 4 }}
#     app.kubernetes.io/component: ack-rds-controller
#     {{- with $glyphDefinition.labels }}
#     {{- toYaml . | nindent 4 }}
#     {{- end }}
# spec:
#   name: {{ $glyphDefinition.name }}-iam-policy
#   path: {{ $path }}
#   description: {{ default (printf "IAM Policy for %s to manage RDS resources" $controllerName) $glyphDefinition.policyDescription | quote }}
#   policyDocument: |
#     {
#       "Version": "2012-10-17",
#       "Statement": [
#         {
#           "Effect": "Allow",
#           "Action": [
#             "rds:CreateDBInstance",
#             "rds:DeleteDBInstance",
#             "rds:DescribeDBInstances",
#             "rds:ModifyDBInstance",
#             "rds:RebootDBInstance",
#             "rds:StartDBInstance",
#             "rds:StopDBInstance",
#             "rds:CreateDBSubnetGroup",
#             "rds:DeleteDBSubnetGroup",
#             "rds:DescribeDBSubnetGroups",
#             "rds:ModifyDBSubnetGroup",
#             "rds:CreateDBParameterGroup",
#             "rds:DeleteDBParameterGroup",
#             "rds:DescribeDBParameterGroups",
#             "rds:ModifyDBParameterGroup",
#             "rds:DescribeDBParameters",
#             "rds:CreateDBSnapshot",
#             "rds:DeleteDBSnapshot",
#             "rds:DescribeDBSnapshots",
#             "rds:AddTagsToResource",
#             "rds:ListTagsForResource",
#             "rds:RemoveTagsFromResource",
#             "ec2:DescribeSecurityGroups",
#             "ec2:DescribeSubnets",
#             "ec2:DescribeVpcs",
#             "iam:CreateRole",
#             "iam:DeleteRole",
#             "iam:UpdateRole",
#             "iam:TagRole",
#             "iam:UntagRole",
#             "iam:PutRolePolicy",
#             "iam:AttachRolePolicy",
#             "iam:DetachRolePolicy",
#             "kms:CreateGrant",
#             "kms:DescribeKey",
#             "kms:Decrypt",
#             "kms:Encrypt",
#             "kms:GenerateDataKey",
#             "kms:GenerateDataKeyWithoutPlaintext",
#             "kms:ReEncryptFrom",
#             "kms:ReEncryptTo"
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
#       value: ack-rds-controller
#   {{- end }}
# {{- end }}
# {{- end }}
