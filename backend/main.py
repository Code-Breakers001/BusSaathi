import os
from dotenv import load_dotenv
from fastapi import FastAPI
from supabase import create_client, Client

load_dotenv()

app = FastAPI(title="Bus Saathi API")
supabase: Client = create_client(
    supabase_url=os.getenv("supabase_url"),
    supabase_key=os.getenv("supabase_key")
)

@app.get("/")
def hello():
    return {"message": "Welcome to Bus Saathi"}

@app.get("/stops")
def get_stops():
    stops = supabase.table("stops").select("*").order("stop_order").execute()
    return {"stops": stops.data}
