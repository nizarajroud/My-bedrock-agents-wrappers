#!/bin/bash
# Script to configure agent for a project (updates DRAFT)

PROJECT_NAME=$1
AGENT_ID="4EBXLZQW3Q"
REGION="ca-central-1"
PROFILE="csna-operations-sso"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTRUCTIONS_DIR="${SCRIPT_DIR}/instruction-files"

if [ -z "$PROJECT_NAME" ]; then
    echo "Usage: $0 <project-name>"
    echo ""
    echo "Available instruction files:"
    ls -1 ${INSTRUCTIONS_DIR}/*.md 2>/dev/null | xargs -n 1 basename -s .md
    exit 1
fi

INSTRUCTIONS_FILE="${INSTRUCTIONS_DIR}/${PROJECT_NAME}.md"

if [ ! -f "$INSTRUCTIONS_FILE" ]; then
    echo "Error: Instruction file not found: ${INSTRUCTIONS_FILE}"
    echo ""
    echo "Available instruction files:"
    ls -1 ${INSTRUCTIONS_DIR}/*.md 2>/dev/null | xargs -n 1 basename -s .md
    exit 1
fi

INSTRUCTIONS=$(cat ${INSTRUCTIONS_FILE})

echo "Configuring agent for project: ${PROJECT_NAME}"
echo "Using instructions from: ${INSTRUCTIONS_FILE}"

# Update agent DRAFT with new instructions
echo "Updating agent DRAFT..."
aws bedrock-agent update-agent \
    --agent-id ${AGENT_ID} \
    --agent-name "generic-agent" \
    --description "Agent for ${PROJECT_NAME}" \
    --instruction "${INSTRUCTIONS}" \
    --agent-resource-role-arn "arn:aws:iam::026991214828:role/service-role/AmazonBedrockExecutionRoleForAgents_OGKJF3WCP4" \
    --foundation-model "arn:aws:bedrock:ca-central-1:026991214828:inference-profile/us.anthropic.claude-sonnet-4-5-20250929-v1:0" \
    --region ${REGION} \
    --profile ${PROFILE} \
    --no-cli-pager > /dev/null

echo ""
echo "=== Summary ==="
echo "Project: ${PROJECT_NAME}"
echo "Agent ID: ${AGENT_ID}"
echo "Agent DRAFT updated with ${PROJECT_NAME} instructions"
echo ""
echo "Next steps:"
echo "1. Switch data source: ./switch_project.sh ${PROJECT_NAME}"
echo "2. Query the agent - it will use ${PROJECT_NAME} instructions and data"
