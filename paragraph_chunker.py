# module load python/3.6
# module load StdEnv/2020
# module load scipy-stack/2020b
# pip install --no-index --find-links $HOME/python_wheels 'bs4'

import json
from glob import glob
from tqdm import tqdm
from bs4 import BeautifulSoup

WIKI_LOCATION = '/scratch/vaibhav/full_wiki'
TARGET_LOCATION = '/scratch/vaibhav/full_wiki_segments.jsonl'
MIN_PASSAGE_TOKENS = 100

def load_wiki(data_path):
    data = {}
    print('loading: ' + data_path)
    with open(data_path, 'r') as data_file:
        for line in tqdm(data_file):
            article = json.loads(line)
            if len(article["text"]) > 0:
                title = article["title"].split("##")[0]
                if title not in data:
                    data[title] = {}
                sub_title = "##".join(article["title"].split("##")[1:])
                if sub_title == title:
                    sub_title = 'Introduction'
                data[title][sub_title] = {}
                data[title][sub_title]["text"] = article["text"]
    return data

data = load_wiki(WIKI_LOCATION)

count = 0
with open(TARGET_LOCATION, 'w') as f:
    for title in tqdm(data.keys()):
        for sub_title in data[title].keys():
            passage = data[title][sub_title]["text"]
            passage = '\n\n'.join(passage.split('\n\n')[:3])
            soup = BeautifulSoup(passage, features="html.parser")
            passage_plain = soup.get_text()
            passage_tokens = passage_plain.split()
            segment_tokens = []
            i = 0
            while i < len(passage_tokens):
                while len(segment_tokens) < MIN_PASSAGE_TOKENS and i < len(passage_tokens):
                    segment_tokens.append(passage_tokens[i])
                    i +=1
                while segment_tokens[-1][-1] != '.' and i < len(passage_tokens):
                    segment_tokens.append(passage_tokens[i])
                    i +=1
                segment = ' '.join(segment_tokens)
                segment_json = {"title": title, "sub_title": sub_title.strip('.'), "contents": segment}
                json.dump(segment_json, f)
                f.write('\n')
                count += 1
                # print("Passage: " + segment)
                # print("Length: " + str(len(segment.split())))
                # print()
                segment_tokens = []
print("Segments: " + str(count))
