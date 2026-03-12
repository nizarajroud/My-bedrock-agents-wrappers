#!/bin/bash
# Script to add a project data source to existing knowledge base

PROJECT_NAME=$1
S3_BUCKET=$2
REGION="ca-central-1"
PROFILE="csna-operations-sso"
KB_ID="LZE51GHMVX"

if [ -z "$PROJECT_NAME" ] || [ -z "$S3_BUCKET" ]; then
    echo "Usage: $0 <project-name> <s3-bucket-name>"
    exit 1
fi

# Create S3 bucket if it doesn't exist
if ! aws s3 ls "s3://${S3_BUCKET}" --region ${REGION} --profile ${PROFILE} 2>/dev/null; then
    echo "Creating S3 bucket: ${S3_BUCKET}"
    aws s3 mb "s3://${S3_BUCKET}" --region ${REGION} --profile ${PROFILE}
    
    # Enable versioning
    aws s3api put-bucket-versioning \
        --bucket ${S3_BUCKET} \
        --versioning-configuration Status=Enabled \
        --region ${REGION} \
        --profile ${PROFILE}
else
    echo "S3 bucket already exists: ${S3_BUCKET}"
fi

# Check if data source already exists
EXISTING_DS=$(aws bedrock-agent list-data-sources \
    --knowledge-base-id ${KB_ID} \
    --region ${REGION} \
    --profile ${PROFILE} \
    --query "dataSourceSummaries[?name=='${PROJECT_NAME}-source'].dataSourceId" \
    --output text)

if [ -n "$EXISTING_DS" ]; then
    echo "Data source already exists: ${EXISTING_DS}"
    echo ""
    echo "=== Summary ==="
    echo "Project: ${PROJECT_NAME}"
    echo "Data Source ID: ${EXISTING_DS}"
    echo "Knowledge Base ID: ${KB_ID}"
    exit 0
fi

# Add S3 data source
DS_ID=$(aws bedrock-agent create-data-source \
    --knowledge-base-id ${KB_ID} \
    --name "${PROJECT_NAME}-source" \
    --data-source-configuration "type=S3,s3Configuration={bucketArn=arn:aws:s3:::${S3_BUCKET}}" \
    --region ${REGION} \
    --profile ${PROFILE} \
    --query 'dataSource.dataSourceId' \
    --output text)

echo "Created Data Source: ${DS_ID}"

# Start ingestion
aws bedrock-agent start-ingestion-job \
    --knowledge-base-id ${KB_ID} \
    --data-source-id ${DS_ID} \
    --region ${REGION} \
    --profile ${PROFILE}

echo ""
echo "=== Summary ==="
echo "Project: ${PROJECT_NAME}"
echo "Data Source ID: ${DS_ID}"
echo "Knowledge Base ID: ${KB_ID}"
