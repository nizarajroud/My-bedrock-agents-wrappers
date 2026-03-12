# My-bedrock-agents-wrappers
./create_project_kb.sh projectA your-project-a-bucket-2222323

./switch_project.sh 

./switch_project.sh projectA

## 1. create_project_kb.sh
Purpose: Set up a new project with its own S3 bucket and data source

What it does:
- Creates an S3 bucket for the project (if it doesn't exist)
- Enables versioning on the bucket
- Adds the bucket as a data source to the generic knowledge base
- Starts initial ingestion of documents
- Idempotent (safe to run multiple times)

Usage:
bash
./create_project_kb.sh projectA my-project-a-bucket


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


## 2. switch_project.sh
Purpose: Switch the active project context

What it does:
- Lists all available projects (when run without arguments)
- Syncs the specified project's data source
- Makes that project's data the active context for the agent

Usage:
bash
# List projects
./switch_project.sh

# Switch to projectA
./switch_project.sh projectA


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


## 3. create_project_version.sh
Purpose: Create agent version with project-specific instructions (not fully implemented)

Status: Created but not tested - requires:
- Project-specific instruction files
- Manual agent alias creation
- This was part of the original multi-alias approach

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


## Workflow Summary:

1. Add new project: ./create_project_kb.sh projectA bucket-name
2. Upload documents to S3 bucket
3. Switch context: ./switch_project.sh projectA
4. Query agent - it will use projectA data

The agent uses one knowledge base (LZE51GHMVX / "cdbac-kb") with multiple data sources, switching between them by syncing the active project.