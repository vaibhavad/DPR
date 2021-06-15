import json
from tqdm import tqdm
import csv

WIKI_JSONL_LOCATION = '/scratch/vaibhav/full_wiki_segments.jsonl'
TARGET_LOCATION = '/scratch/vaibhav/full_wiki_segments.tsv'

i = 1
with open(WIKI_JSONL_LOCATION, 'r') as f:
    with open(TARGET_LOCATION, "w", newline="") as csvfile:
        writer = csv.writer(csvfile, delimiter="\t")
        writer.writerow(['id', 'text', 'title'])
        
        for line in tqdm(f):
            data = json.loads(line.strip())
            writer.writerow([i, data["contents"], data["title"]])
            i += 1
