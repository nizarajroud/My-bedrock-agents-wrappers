#!/bin/bash
# Script to switch active project by syncing its data source

PROJECT_NAME=$1
REGION="ca-central-1"
PROFILE="csna-operations-sso"
KB_ID="LZE51GHMVX"

if [ -z "$PROJECT_NAME" ]; then
    echo "Usage: $0 <project-name>"
    echo ""
    echo "Available projects:"
    aws bedrock-agent list-data-sources \
        --knowledge-base-id ${KB_ID} \
        --region ${REGION} \
        --profile ${PROFILE} \
        --query 'dataSourceSummaries[*].[name,dataSourceId]' \
        --output table \
        --no-cli-pager
    exit 1
fi

# Find data source ID for project
DS_ID=$(aws bedrock-agent list-data-sources \
    --knowledge-base-id ${KB_ID} \
    --region ${REGION} \
    --profile ${PROFILE} \
    --query "dataSourceSummaries[?contains(name,'${PROJECT_NAME}')].dataSourceId" \
    --output text)

if [ -z "$DS_ID" ]; then
    echo "Error: Project '${PROJECT_NAME}' not found"
    exit 1
fi

echo "Switching to project: ${PROJECT_NAME}"
echo "Data Source ID: ${DS_ID}"
echo "Starting ingestion..."

# Start ingestion job
JOB_ID=$(aws bedrock-agent start-ingestion-job \
    --knowledge-base-id ${KB_ID} \
    --data-source-id ${DS_ID} \
    --region ${REGION} \
    --profile ${PROFILE} \
    --query 'ingestionJob.ingestionJobId' \
    --output text)

echo "Ingestion Job ID: ${JOB_ID}"
echo ""
echo "Project switched. The agent will now use ${PROJECT_NAME} data."
