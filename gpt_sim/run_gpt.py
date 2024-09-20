import os, subprocess

run_dir = os.getcwd()
save_dir = '/nfs/user/jg2347/AWA/data/gpt/saved_runs/last_run'

sim_params = {
    'solfocusingi': 550.0,
    'solmatchingi': 200.0,
    'gunphase': 50.0,
    'linacphase': -10.0,
    'laserradius': 0.002,
    'charge': 1.0e-9,
    'nparticles': 262144,
}
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
cd {run_dir}
gpt -v -j 1 -o {save_dir}/out.gdf gpt.in {variables_string} | tee {save_dir}/out.log
gdfa -o {save_dir}/stats_t.gdf {save_dir}/out.gdf time {stats_string}
gdfa -o {save_dir}/stats_z.gdf {save_dir}/out.gdf position {stats_string}
"""

subprocess.run(cmd_str, shell=True)