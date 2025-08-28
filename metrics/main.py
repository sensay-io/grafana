from fastapi import FastAPI, HTTPException
from prometheus_client import Gauge, generate_latest, REGISTRY
from starlette.responses import Response
import time
import uvicorn
import os
from dotenv import load_dotenv
import httpx
from gql import gql, Client
from gql.transport.requests import RequestsHTTPTransport
import asyncio
from typing import Dict, List

load_dotenv()

app = FastAPI(title="Metrics Server", description="Simple server providing Prometheus metrics")

current_time_gauge = Gauge('current_time_seconds', 'Current Unix timestamp in seconds')
linear_open_issues_gauge = Gauge('linear_open_issues_total', 'Total number of open issues per team in Linear', ['team_name', 'team_id'])

@app.get("/")
async def root():
    return {"status": "healthy", "message": "Metrics server is running"}

async def fetch_linear_metrics():
    """Fetch open issues count per team from Linear."""
    api_key = os.getenv("LINEAR_API_KEY")
    
    if not api_key:
        print("WARNING: LINEAR_API_KEY not set - Linear metrics will be empty")
        return {}
    
    try:
        transport = RequestsHTTPTransport(
            url="https://api.linear.app/graphql",
            headers={"Authorization": api_key},
            use_json=True,
        )
        
        client = Client(transport=transport, fetch_schema_from_transport=False)
        
        query = gql("""
            query Teams {
                teams {
                    nodes {
                        id
                        name
                        issues(filter: { state: { type: { nin: ["completed", "canceled"] } } }, first: 1000) {
                            nodes {
                                id
                            }
                        }
                    }
                }
            }
        """)
        
        result = client.execute(query)
        
        metrics = {}
        for team in result.get("teams", {}).get("nodes", []):
            team_name = team["name"]
            team_id = team["id"]
            open_issues = len(team["issues"]["nodes"])
            metrics[(team_name, team_id)] = open_issues
            
        return metrics
        
    except Exception as e:
        print(f"Error fetching Linear metrics: {e}")
        return {}

@app.get("/metrics", response_class=Response)
async def metrics():
    current_time_gauge.set(time.time())
    
    linear_metrics = await fetch_linear_metrics()
    
    for (team_name, team_id), count in linear_metrics.items():
        linear_open_issues_gauge.labels(team_name=team_name, team_id=team_id).set(count)
    
    metrics_data = generate_latest(REGISTRY)
    return Response(content=metrics_data, media_type="text/plain; charset=utf-8")

@app.get("/health")
async def health():
    return {"status": "healthy", "timestamp": time.time()}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)