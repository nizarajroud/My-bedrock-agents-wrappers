import subprocess
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("claude-cli")

@mcp.tool()
def ask_claude(prompt: str) -> str:
    """Ask Claude CLI (includes Terraform skills)"""
    result = subprocess.run(
        ["claude", prompt],
        capture_output=True,
        text=True,
        timeout=180
    )
    
    if result.returncode != 0:
        return f"Error: {result.stderr or result.stdout}"
    
    return result.stdout

if __name__ == "__main__":
    mcp.run()
