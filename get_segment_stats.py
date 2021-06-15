import json

SEGMENTS_LOCATION = '/scratch/vaibhav/full_wiki_segments.jsonl'
TARGET_LOCATION = '/scratch/vaibhav/segment_stats.txt'

with open(TARGET_LOCATION, 'w') as f:
    with open(SEGMENTS_LOCATION, 'r') as corpus:
        for line in corpus:
            segment = json.loads(line)
            f.write(str(len(segment["contents"])))
            f.write('\n')
