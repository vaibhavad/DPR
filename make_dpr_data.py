import json
from tqdm import tqdm
from datetime import datetime, timedelta
from glob import glob

WIKI_JSONL_LOCATION = '/scratch/vaibhav/full_wiki_segments.jsonl'
CONV_DIR = '/scratch/vaibhav/final_conversations_2'
REWRITES_DIR = ['/scratch/vaibhav/rewrites/train/ocoqa/t5/qrecc_model',
                '/scratch/vaibhav/rewrites/test/ocoqa/t5/qrecc_model']
OUTPUT_FILE = ['/scratch/vaibhav/DPR-data/data/retriever/ocoqa-rewrites-t5-qrecc.json',
               '/scratch/vaibhav/DPR-data/data/retriever/ocoqa-rewrites-t5-qrecc-test.json']
OUTPUT_FILE_CSV = ['/scratch/vaibhav/DPR-data/data/retriever/qas/ocoqa-rewrites-t5-qrecc.csv',
                   '/scratch/vaibhav/DPR-data/data/retriever/qas/ocoqa-rewrites-t5-qrecc-test.csv']
GOLD_PASSAGE_INFO_FILE = ['/scratch/vaibhav/DPR-data/data/gold_passages_info/ocoqa-rewrites-t5-qrecc.json',
                          '/scratch/vaibhav/DPR-data/data/gold_passages_info/ocoqa-rewrites-t5-qrecc-test.json']

MIN_CONV_LENGTH = 10
MIN_ANNOTATION_LENGTH = 3
IST_TIME_OFFSET = 9.5
END_DATE = '2022-06-07'
end_date = datetime.strptime(END_DATE + " 23:59:59", '%Y-%m-%d %H:%M:%S')

all_segments = {}
i = 1
with open(WIKI_JSONL_LOCATION, 'r') as f:
    for line in tqdm(f):
        data = json.loads(line.strip())
        if data["title"] not in all_segments:
            all_segments[data["title"]] = []
        data["id"] = i
        i += 1
        all_segments[data["title"]].append(data)

for idx in [0,1]:
    convs = []
    turns = 0.0
    files = sorted(glob(CONV_DIR + '/*'))

    for file in tqdm(files):
        with open(file, 'r') as f:
            conv = json.load(f)
            ist_timestamp = datetime.strptime(
                conv["timestamp"], '%Y-%m-%d %H:%M:%S') + timedelta(hours=IST_TIME_OFFSET)
            conv["id"] = file.split('/')[-1]
            condition = (len(conv["turns"]) >= MIN_CONV_LENGTH and 'additional_answers' in conv and len(conv["additional_answers"]) >= MIN_ANNOTATION_LENGTH) and ist_timestamp <= end_date
            if idx == 0 and (not condition):
                convs.append(conv)
            if idx == 1 and condition:
                convs.append(conv)


    all_ques = []
    all_ans = []
    all_rewrites = []

    for conv in tqdm(convs):
        ques = []
        ans = []
        rewrites = []
        for i, turn in enumerate(conv["turns"]):
            if i % 2 == 0:
                ques.append({"id": conv["id"], "text": turn["text"]})
            else:
                ans.append(turn)
        with open(REWRITES_DIR[idx] + '/' + conv["id"], 'r') as f:
            for line in f:
                rewrites.append(line.lower().strip('?').strip())
        ques = ques[:len(ans)]
        rewrites = rewrites[:len(ans)]
        assert len(ques) == len(ans) == len(rewrites)
        all_ques.extend(ques)
        all_ans.extend(ans)
        all_rewrites.extend(rewrites)

    assert len(all_ques) == len(all_ans) == len(all_rewrites)
    print(len(all_ques))

    j = 0
    training_data = []
    for i, rewrite in enumerate(tqdm(all_rewrites)):
        ans = all_ans[i]
        if ans["text"] != 'UNANSWERABLE':
            j += 1
            if idx == 0:
                dataset = 'ocoqa_train_t5_qrecc'
            else:
                dataset = 'ocoqa_test_t5_qrecc'
            data = {"dataset": dataset,
                    "question": rewrite,
                    "answers": [ans["text"]],
                    "positive_ctxs": []}
            for segment in all_segments[ans["passage_title"]]:
                if ans["evidence"] in segment["contents"]:
                    dpr_segment = {"title": segment["title"],
                                "text": segment["contents"],
                                "score": 1000,
                                "title_score": 1,
                                "passage_id": str(segment["id"])}
                    data["positive_ctxs"].append(dpr_segment)
            if len(data["positive_ctxs"]) == 0:
                segment = all_segments[ans["passage_title"]][0]
                dpr_segment = {"title": segment["title"],
                            "text": segment["contents"],
                            "score": 1000,
                            "title_score": 1,
                            "passage_id": str(segment["id"])}
                data["positive_ctxs"].append(dpr_segment)
            data["negative_ctxs"] = []
            data["hard_negative_ctxs"] = []
            training_data.append(data)

    with open(OUTPUT_FILE[idx], "w") as writer:
        writer.write(json.dumps(training_data, indent=4) + "\n")
    print(j)
    print(f"Saved data to {OUTPUT_FILE[idx]}")

    j = 0
    with open(OUTPUT_FILE_CSV[idx], 'w') as f:
        for i, rewrite in enumerate(tqdm(all_rewrites)):
            ans = all_ans[i]
            if ans["text"] != 'UNANSWERABLE':
                j += 1
                f.write(rewrite)
                f.write('\t')
                f.write(str([ans["text"]]))
                f.write('\n')
    print(j)
    print(f"Saved data to {OUTPUT_FILE_CSV[idx]}")

    j = 0
    gold_passages_info = []
    for i, rewrite in enumerate(tqdm(all_rewrites)):
        ans = all_ans[i]
        if ans["text"] != 'UNANSWERABLE':
            j += 1
            obj = {}
            obj["question"] = rewrite
            obj["question_tokens"] = rewrite
            obj["title"] = ans["passage_title"]
            obj["short_answers"] = [ans["text"]]
            obj["doc_url"] = "https://www.google.com"
            obj["example_id"] = i
            for segment in all_segments[ans["passage_title"]]:
                if ans["evidence"] in segment["contents"]:
                    obj["context"] = segment["contents"]
            if "context" not in obj:
                obj["context"] = all_segments[ans["passage_title"]][0]["contents"]
            gold_passages_info.append(obj)

    with open(GOLD_PASSAGE_INFO_FILE[idx], 'w') as f:
        json.dump(fp=f, obj={"data": gold_passages_info})

    print(j)
    print(f"Saved data to {GOLD_PASSAGE_INFO_FILE[idx]}")
