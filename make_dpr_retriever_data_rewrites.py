import json
from tqdm import tqdm
from datetime import datetime, timedelta
from glob import glob
import pickle
import os

WIKI_JSONL_LOCATION = '/scratch/vaibhav/full_wiki_segments.jsonl'
CONV_DIR = '/scratch/vaibhav/final_final_conversations'
REWRITES_DIR = ['/scratch/vaibhav/rewrites/train/ocoqa/t5/qrecc_model',
                '/scratch/vaibhav/rewrites/dev/ocoqa/t5/qrecc_model',
                '/scratch/vaibhav/rewrites/test/ocoqa/t5/qrecc_model']
OUTPUT_FILE = ['/scratch/vaibhav/DPR-data/data/retriever/ocoqa-rewrites-t5-qrecc-train.json',
               '/scratch/vaibhav/DPR-data/data/retriever/ocoqa-rewrites-t5-qrecc-dev.json',
               '/scratch/vaibhav/DPR-data/data/retriever/ocoqa-rewrites-t5-qrecc-test.json']
OUTPUT_FILE_CSV = ['/scratch/vaibhav/DPR-data/data/retriever/qas/ocoqa-rewrites-t5-qrecc-train.csv',
                   '/scratch/vaibhav/DPR-data/data/retriever/qas/ocoqa-rewrites-t5-qrecc-dev.csv',
                   '/scratch/vaibhav/DPR-data/data/retriever/qas/ocoqa-rewrites-t5-qrecc-test.csv']
GOLD_PASSAGE_INFO_FILE = ['/scratch/vaibhav/DPR-data/data/gold_passages_info/ocoqa-rewrites-t5-qrecc-train.json',
                          '/scratch/vaibhav/DPR-data/data/gold_passages_info/ocoqa-rewrites-t5-qrecc-dev.json',
                          '/scratch/vaibhav/DPR-data/data/gold_passages_info/ocoqa-rewrites-t5-qrecc-test.json']
DEV_IDS_FILE = '/scratch/vaibhav/dev_list.txt'
TEST_IDS_FILE = '/scratch/vaibhav/test_list.txt'
MIN_CONV_LENGTH = 10
CONVS_PICKLE_FILE = '/scratch/vaibhav/convs.pkl'
DATA_PICKLE_FILE = '/scratch/vaibhav/all_data'

all_segments = {}
i = 1
with open(WIKI_JSONL_LOCATION, 'r') as f:
    for line in tqdm(f):
        data = json.loads(line.strip())
        if data["title"] not in all_segments:
            all_segments[data["title"]] = {}
        if data["sub_title"] not in all_segments[data["title"]]:
            all_segments[data["title"]][data["sub_title"]] = []
        data["id"] = i
        all_segments[data["title"]][data["sub_title"]].append(data)
        i += 1
        # all_segments[data["title"]].append(data)

convs = [[], [], []]
files = sorted(glob(CONV_DIR + '/*'))

dev_ids = []
with open(DEV_IDS_FILE) as f:
    for line in f:
        dev_ids.append(line.strip())

test_ids = []
with open(TEST_IDS_FILE) as f:
    for line in f:
        test_ids.append(line.strip())
turns = 0

if not os.path.exists(CONVS_PICKLE_FILE):
    for file in tqdm(files):
        with open(file, 'r') as f:
            conv = json.load(f)
            if len(conv["turns"]) >= MIN_CONV_LENGTH:
                turns += len(conv['turns'])
                if conv['id'] in dev_ids:
                    convs[1].append(conv)
                elif conv['id'] in test_ids:
                    convs[2].append(conv)
                else:
                    convs[0].append(conv)

    with open(CONVS_PICKLE_FILE, 'wb') as f:
        pickle.dump(convs, f)
else:
    print('Loading conversations from pickle file ....')
    with open(CONVS_PICKLE_FILE, 'rb') as f:
        convs = pickle.load(f)

for idx in [0, 1, 2]:
    # convs = []
    # turns = 0.0
    # files = sorted(glob(CONV_DIR + '/*'))

    # for file in tqdm(files):
    #     with open(file, 'r') as f:
    #         conv = json.load(f)
    #         ist_timestamp = datetime.strptime(
    #             conv["timestamp"], '%Y-%m-%d %H:%M:%S') + timedelta(hours=IST_TIME_OFFSET)
    #         conv["id"] = file.split('/')[-1]
    #         condition = (len(conv["turns"]) >= MIN_CONV_LENGTH and 'additional_answers' in conv and len(conv["additional_answers"]) >= MIN_ANNOTATION_LENGTH) and ist_timestamp <= end_date
    #         if idx == 0 and (not condition):
    #             convs.append(conv)
    #         if idx == 1 and condition:
    #             convs.append(conv)

    if not os.path.exists(DATA_PICKLE_FILE + '-' + str(idx) + '.pkl'):

        all_ques = []
        all_ans = []
        all_rewrites = []

        for conv in tqdm(convs[idx]):
            ques = []
            ans = []
            rewrites = []
            for i, turn in enumerate(conv["turns"]):
                if i % 2 == 0:
                    ques.append({"id": conv["id"],
                                "text": turn["text"],
                                "passage_title": turn["passage_title"],
                                "passage_sub_title": turn["passage_sub_title"]})
                else:
                    ans.append(turn)
            with open(REWRITES_DIR[idx] + '/' + conv["id"], 'r') as f:
                for line in f:
                    rewrites.append(line.lower().strip('?').strip())
            if len(rewrites) != len(ans):
                ans.append({"text": "UNANSWERABLE",
                            "passage_title": ques[-1]["passage_title"],
                            "passage_sub_title": ques[-1]["passage_sub_title"]})
            # if idx == 0:
            #     ques = ques[:len(ans)]
            #     rewrites = rewrites[:len(ans)]
            if not len(ques) == len(ans) == len(rewrites):
                print(len(ques), len(ans), len(rewrites))
                assert False
            all_ques.extend(ques)
            all_ans.extend(ans)
            all_rewrites.extend(rewrites)

        assert len(all_ques) == len(all_ans) == len(all_rewrites)
        with open(DATA_PICKLE_FILE + '-' + str(idx) + '.pkl', 'wb') as f:
            pickle.dump([all_ques, all_ans, all_rewrites], f)
    else:
        print('Loading data from pickle file ....')
        with open(DATA_PICKLE_FILE + '-' + str(idx) + '.pkl', 'rb') as f:
            all_ques, all_ans, all_rewrites = pickle.load(f)


    j = 0
    training_data = []
    gold_passages_info = []
    actual_segment = 0
    heuristic_segment = 0
    for i, rewrite in enumerate(tqdm(all_rewrites)):
        ans = all_ans[i]
        ques = all_ques[i]
        # if ans["text"] != 'UNANSWERABLE':
        j += 1
        if idx == 0:
            dataset = 'ocoqa_train_t5_qrecc'
        elif idx == 1:
            dataset = 'ocoqa_dev_t5_qrecc'
        else:
            dataset = 'ocoqa_test_t5_qrecc'
        data = {"dataset": dataset,
                "question": rewrite,
                "answers": [ans["text"]],
                "positive_ctxs": []}
        # assert len(ques["passage_title"]) > 0
        # assert len(ques["passage_sub_title"]) > 0
        conv_id = ques["id"]
        if len(ans["passage_title"]) == 0 or len(ans["passage_sub_title"]) == 0:
            for k in range(i-1, 0, -1):
                if len(all_ans[k]["passage_title"]) > 0 and len(all_ans[k]["passage_sub_title"]) > 0 and all_ques[k]["id"] == conv_id:
                    passage_title = all_ans[k]["passage_title"]
                    passage_sub_title = all_ans[k]["passage_sub_title"]
                    break
                if len(all_ques[k]["passage_title"]) > 0 and len(all_ques[k]["passage_sub_title"]) > 0 and all_ques[k]["id"] == conv_id:
                    passage_title = all_ques[k]["passage_title"]
                    passage_sub_title = all_ques[k]["passage_sub_title"]
                    break
        else:
            passage_title = ans["passage_title"]
            passage_sub_title = ans["passage_sub_title"]
            

        assert passage_title != ""
        assert passage_sub_title != ""
        # passage_title = passage_title.strip('.')
        passage_sub_title = passage_sub_title.strip('.')
        assert passage_title in all_segments
        assert passage_sub_title in all_segments[passage_title]
        segment = None
        if "evidence" in ans and len(ans["evidence"]) > 0:
            for ans_segment in all_segments[passage_title][passage_sub_title]:
                if ans["evidence"] in ans_segment["contents"]:
                    segment = ans_segment
                    actual_segment += 1
                    break
            # assert ans["evidence"] in segment["contents"]
            # for segment in all_segments[ans["passage_title"]]:
            #     if ans["evidence"] in segment["contents"]:
            #         dpr_segment = {"title": segment["title"],
            #                         "text": segment["contents"],
            #                         "score": 1000,
            #                         "title_score": 1,
            #                         "passage_id": str(segment["id"])}
            #         data["positive_ctxs"].append(dpr_segment)
            #         break
        if segment is None:
            heuristic_segment += 1
            segment = all_segments[passage_title][passage_sub_title][0]
        dpr_segment = {"title": segment["title"],
                        "text": segment["contents"],
                        "score": 1000,
                        "title_score": 1,
                        "passage_id": str(segment["id"])}
        data["positive_ctxs"].append(dpr_segment)
        data["negative_ctxs"] = []
        data["hard_negative_ctxs"] = []
        training_data.append(data)

        obj = {}
        obj["question"] = rewrite
        obj["question_tokens"] = rewrite
        obj["title"] = passage_title
        obj["short_answers"] = [ans["text"]]
        obj["doc_url"] = "https://www.google.com"
        obj["example_id"] = i
        obj["context"] = segment["contents"]
        gold_passages_info.append(obj)

    print("actual_segment", actual_segment)
    print("heuristic_segment", heuristic_segment)
    with open(OUTPUT_FILE[idx], "w") as writer:
        writer.write(json.dumps(training_data, indent=4) + "\n")
    print(j)
    print(f"Saved data to {OUTPUT_FILE[idx]}")

    with open(GOLD_PASSAGE_INFO_FILE[idx], 'w') as f:
        json.dump(fp=f, obj={"data": gold_passages_info})

    print(f"Saved data to {GOLD_PASSAGE_INFO_FILE[idx]}")

    j = 0
    with open(OUTPUT_FILE_CSV[idx], 'w') as f:
        for i, rewrite in enumerate(tqdm(all_rewrites)):
            ans = all_ans[i]
            # if ans["text"] != 'UNANSWERABLE':
            j += 1
            f.write(rewrite)
            f.write('\t')
            f.write(str([ans["text"]]))
            f.write('\n')
    print(j)
    print(f"Saved data to {OUTPUT_FILE_CSV[idx]}")

    # j = 0
    # gold_passages_info = []
    # for i, rewrite in enumerate(tqdm(all_rewrites)):
    #     ans = all_ans[i]
    #     if ans["text"] != 'UNANSWERABLE':
    #         j += 1
    #         obj = {}
    #         obj["question"] = rewrite
    #         obj["question_tokens"] = rewrite
    #         obj["title"] = ans["passage_title"]
    #         obj["short_answers"] = [ans["text"]]
    #         obj["doc_url"] = "https://www.google.com"
    #         obj["example_id"] = i
    #         for segment in all_segments[ans["passage_title"]]:
    #             if ans["evidence"] in segment["contents"]:
    #                 obj["context"] = segment["contents"]
    #         if "context" not in obj:
    #             obj["context"] = all_segments[ans["passage_title"]][0]["contents"]
    #         gold_passages_info.append(obj)

    # with open(GOLD_PASSAGE_INFO_FILE[idx], 'w') as f:
    #     json.dump(fp=f, obj={"data": gold_passages_info})

    # print(j)
    # print(f"Saved data to {GOLD_PASSAGE_INFO_FILE[idx]}")
