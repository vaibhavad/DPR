import json
from glob import glob

CONV_DIR = '/Users/vaibhav/Coqoa/final_conversations'

REWRITES_DIR = '/Users/vaibhav/canard/rewrites/pg/qrecc_model'
REWRITES_DPR_INPUT_FILE = '/Users/vaibhav/canard/data/ocoqa_qrecc_dpr_format.csv'

DPR_RETRIEVER_RESULTS = 'results/ocoqa_qrecc.json'
DPR_READER_RESULTS = 'results/reader_ocoqa_qrecc.json'

DPR_OUTPUT_RETRIEVER_DIR = 'results/retriever/pg/qrecc/'
DPR_OUTPUT_READER_DIR = 'results/reader/pg/qrecc/'

canard_count = 0
canard_rewrites =  {}
files = sorted(glob(REWRITES_DIR + '/*'))

for file in files:
    id = file.split('/')[-1]
    ques = []
    with open(file, 'r') as f:
        for line in f:
            ques.append(line.strip())
            canard_count += 1
    canard_rewrites[id] = ques

ocoqa_count = 0
with open(REWRITES_DPR_INPUT_FILE, 'r') as f:
    for line in f:
        ocoqa_count += 1

assert canard_count == ocoqa_count

# Retriever results
with open(DPR_RETRIEVER_RESULTS, 'r') as f:
    retriever_results = json.load(f)

assert len(retriever_results) == canard_count

# retriever_results_map = {}

# for result in retriever_results:
#     q = result["question"]
#     if q not in retriever_results_map:
#         retriever_results_map[q] = result["ctxs"]

# with open('results/retriever/ocoqa.json', 'w') as f:
#     json.dump(retriever_results_map, f)

i = 0
for file in files:
    id = file.split('/')[-1]
    conv_retriever_results = []
    for q in canard_rewrites[id]:
        if q.lower().strip('?').strip() != retriever_results[i]["question"]:
            print(i)
            print(q.lower().strip('?').strip())
            print(retriever_results[i]["question"])
            print()
        conv_retriever_results.append(retriever_results[i]["ctxs"])
        i += 1
    with open(DPR_OUTPUT_RETRIEVER_DIR + id, 'w') as f:
        json.dump(conv_retriever_results, f)

# Readeer results
with open(DPR_READER_RESULTS, 'r') as f:
    reader_results = json.load(f)

assert len(reader_results) == canard_count

reader_results_map = {}

for result in reader_results:
    q = result["question"]
    if q not in reader_results_map:
        reader_results_map[q] = result["predictions"]

# with open('results/reader/reader_ocoqa.json', 'w') as f:
#     json.dump(reader_results_map, f)

i = 0
for file in files:
    id = file.split('/')[-1]
    conv_reader_results = []
    for q in canard_rewrites[id]:
        dpr_q = q.lower().strip('?').strip()
        if dpr_q not in reader_results_map:
            print(i)
            print(dpr_q)
            print()
            dpr_q = dpr_q.replace("’", "'")
        conv_reader_results.append(reader_results_map[dpr_q])
        i += 1
    with open(DPR_OUTPUT_READER_DIR + id, 'w') as f:
        json.dump(conv_reader_results, f)
