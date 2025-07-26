import csv
import json
import os
import requests
from azure.identity import ClientSecretCredential

PURVIEW_NAME = os.getenv("PURVIEW_NAME")
GLOSSARY_NAME = os.getenv("GLOSSARY_NAME", "Enterprise Business Glossary")
CSV_FILE = "glossary_terms.csv"

# Use explicit client credential auth
credential = ClientSecretCredential(
    tenant_id=os.getenv("AZURE_TENANT_ID"),
    client_id=os.getenv("AZURE_CLIENT_ID"),
    client_secret=os.getenv("AZURE_CLIENT_SECRET")
)
token = credential.get_token("https://purview.azure.net/.default").token

# Get glossary ID
headers = {
    "Authorization": f"Bearer {token}"
}
response = requests.get(
    f"https://{PURVIEW_NAME}.purview.azure.com/catalog/api/atlas/v2/glossary",
    headers=headers
)
response.raise_for_status()
glossaries = response.json()
glossary = next((g for g in glossaries if g["name"] == GLOSSARY_NAME), None)
if not glossary:
    raise Exception(f"Glossary named '{GLOSSARY_NAME}' not found in Purview.")
glossary_id = glossary["guid"]

# Create terms
with open(CSV_FILE, newline='') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        payload = {
            "name": row["termName"],
            "shortDescription": row["shortDescription"],
            "longDescription": row["longDescription"],
            "anchor": {"glossaryGuid": glossary_id}
        }
        term_resp = requests.post(
            f"https://{PURVIEW_NAME}.purview.azure.com/catalog/api/atlas/v2/glossary/term",
            headers={**headers, "Content-Type": "application/json"},
            json=payload
        )
        if term_resp.ok:
            print(f"✅ Uploaded term: {row['termName']}")
        else:
            print(f"❌ Failed to upload term: {row['termName']}")
            print(term_resp.status_code)
            print(term_resp.text)
