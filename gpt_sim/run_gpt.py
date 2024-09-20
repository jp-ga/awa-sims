import os
import subprocess
import yaml

run_dir = os.getcwd()
save_dir = '/nfs/user/jg2347/AWA/data/gpt/saved_runs/last_run'

with open('sim_params.yml') as f:
    sim_params = yaml.safe_load(f)

variables_string = ''
for key, value in sim_params.items():
    variables_string += f'{key}={value} '

stats = [
    'avgx',
    'avgy',
    'avgz',
    'avgr',
    'avgBx',
    'avgBy',
    'avgBz',
    'avgG',
    'avgt',
    'avgp',
    'stdx',
    'stdy',
    'stdz',
    'stdBx',
    'stdBy',
    'stdBz',
    'stdG',
    'stdt',
    'nemixrms',
    'nemiyrms',
    'nemirrms',
    'nemizrms',
    'numpar',
    'Q'
]

stats_string = ''
for stat in stats:
    stats_string += f'{stat} '

cmd_str = f"""
echo "-----------------------------------------------------Slots available..."
echo $NSLOTS
cd {run_dir}
echo "-----------------------------------------------------Running GPT simulation..."
gpt -v -j 4 -o {save_dir}/out.gdf gpt.in {variables_string} | tee {save_dir}/out.log
echo "-----------------------------------------------------Running GDFA snapshot stats..."
gdfa -o {save_dir}/stats_t.gdf {save_dir}/out.gdf time {stats_string}
echo "-----------------------------------------------------Running GDFA screen stats..."
gdfa -o {save_dir}/stats_z.gdf {save_dir}/out.gdf position {stats_string}
echo "-----------------------------------------------------Done!"
"""

subprocess.run(cmd_str, shell=True)