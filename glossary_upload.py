import csv
import json
import os
import requests
from azure.identity import DefaultAzureCredential

PURVIEW_NAME = os.getenv("PURVIEW_NAME")
GLOSSARY_NAME = os.getenv("GLOSSARY_NAME", "Enterprise Business Glossary")
CSV_FILE = "glossary_terms.csv"

# Get token
credential = DefaultAzureCredential()
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
glossary = next(g for g in glossaries if g["name"] == GLOSSARY_NAME)
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
        print(f"✅ Uploaded term: {row['termName']} - Status: {term_resp.status_code}")
        if not term_resp.ok:
            print(term_resp.text)
