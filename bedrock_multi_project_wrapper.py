import os
import boto3
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("bedrock-agent-multi-project")

@mcp.tool()
def query_agent(prompt: str, session_id: str | None = None) -> str:
    """Query Bedrock agent (uses DRAFT with latest instructions)"""
    client = boto3.client('bedrock-agent-runtime', region_name=os.getenv('AWS_REGION'))
    
    if not session_id:
        session_id = f"kiro-{os.urandom(8).hex()}"
    
    config = boto3.session.Config(read_timeout=180)
    client = boto3.client('bedrock-agent-runtime', region_name=os.getenv('AWS_REGION'), config=config)
    
    response = client.invoke_agent(
        agentId=os.getenv('AGENT_ID'),
        agentAliasId="TSTALIASID",  # Test alias always points to DRAFT
        sessionId=session_id,
        inputText=prompt
    )
    
    completion = ""
    for event in response.get("completion"):
        if "chunk" in event:
            chunk = event["chunk"]
            if "bytes" in chunk:
                completion += chunk["bytes"].decode()
    
    return completion

if __name__ == "__main__":
    mcp.run()
