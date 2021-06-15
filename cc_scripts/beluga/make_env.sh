conda create -y --name DPR python=3.6.8
conda activate DPR

conda install -y -c conda-forge faiss
conda install -y -c conda-forge spacy=2.3.1
conda install -y -c conda-forge jsonlines
conda install -y -c conda-forge srsly

# pip uninstall spacy

cd DPR
pip install .

# pip uninstall spacy
# conda install -y -c conda-forge spacy=2.3.1