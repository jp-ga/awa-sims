#$ -q all.q
#$ -l mem_free=8G
#$ -pe sge_pe 4
cd /nfs/user/jg2347/AWA/awa-sims/gpt_sim
source /home/jg2347/.bashrc
mamba activate awa-sims
python run_gpt.py