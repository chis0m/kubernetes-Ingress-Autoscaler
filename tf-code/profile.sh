#!/bin/sh
set -e

USER=judah
PROFILE=judah
ROLE_NAME=eks-admin
CLUSTER_NAME=judah-cluster
KEY_ID=AKIASAYO3OYO55VSKY2L
SECRET=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

# execute
ARN=$(aws iam get-role --role-name ${ROLE_NAME} --output text --query 'Role.Arn')

# aws configure set profile.${PROFILE}.role_arn ${ARN}
# aws configure set profile.${PROFILE}.source_profile ${PROFILE}

# sudo cat >> ~/.aws/credentials <<EOF

# [${PROFILE}]
# aws_access_key_id = ${KEY_ID}
# aws_secret_access_key = ${SECRET}
# EOF

# aws sts get-caller-identity --profile ${PROFILE}

aws eks update-kubeconfig --name ${CLUSTER_NAME} --region us-east-1 --profile ${USER}


