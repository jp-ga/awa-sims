from jinja2 import Environment, FileSystemLoader
import os, subprocess
import h5py

# Constants:
M_ELECTRON = 0.5109989461e6  # eV/c^2
C_LIGHT = 2.99792458e8  # m/s

# Setup:
gpt_dir = os.path.join(os.path.dirname(__file__), 'gpt_sim')
tmp_dir = os.path.join(opal_dir, 'tmp_run')
single_run_dir = os.path.join(opal_dir, 'single_run')
template_loader = FileSystemLoader(os.path.join(opal_dir, 'templates'))
env = Environment(loader=template_loader)

def run_opal_awa(params: dict, verbose=False):
    """Run OPAL sim with the given parameters."""
    params_copy = params.copy()
    template = env.get_template(params_copy['template_name'])
    num_processors = params_copy['num_processors']
    del params_copy['template_name']
    del params_copy['num_processors']
    with open(os.path.join(tmp_dir, 'input.in'), 'w') as f:
        f.write(template.render(params_copy))
    run_opal_cmd = f"""
    cd {tmp_dir}
    source {opal_init_path}
    mpirun -np {num_processors} --oversubscribe opal --info {int(verbose)} input.in | tee opal.log
    """
    subprocess.run(run_opal_cmd, shell=True)
    # modify to make it compatible with  pysdds
    modify_stat_file(os.path.join(tmp_dir, 'input.stat'))

def modify_stat_file(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()

    modified_lines = []
    block = []
    in_block = False
    block_type = None

    for line in lines:
        stripped_line = line.strip()
        if (stripped_line.startswith('&description') 
            or stripped_line.startswith('&parameter')
            or stripped_line.startswith('&column')
            or stripped_line.startswith('&data')
        ):
            in_block = True
            block_type = stripped_line.split()[0]
            block = [stripped_line]
        elif in_block:
            if stripped_line == '&end':
                block.append(stripped_line)
                modified_lines.append(' '.join(block))
                in_block = False
                block = []
            else:
                block.append(stripped_line)
        else:
            modified_lines.append(line.strip())

    new_file_path = file_path.rsplit('.', 1)[0] + '.sdds'
    with open(new_file_path, 'w') as file:
        for line in modified_lines:
            file.write(line + '\n')

def get_screen_from_h5(h5_path: str) -> dict:
    """"Get screen coordinates from an OPAL h5 file."""
    with h5py.File(h5_path, 'r') as f:
        x = f['Step#0']['x'][:]
        y = f['Step#0']['y'][:]
        z = f['Step#0']['z'][:]
        px = f['Step#0']['px'][:]
        py = f['Step#0']['py'][:]
        pz = f['Step#0']['pz'][:]
        t = f['Step#0']['time'][:]
        screen = {
            'x': x,
            'y': y,
            'z': z,
            'px': px,
            'py': py,
            'pz': pz,
            't': t,
        }
    return screen

def get_phasespace_from_h5(h5_path: str) -> dict:
    """"Get screen coordinates from an OPAL h5 file."""
    with h5py.File(h5_path, 'r') as f:
        x = f['Step#0']['x'][:]
        y = f['Step#0']['y'][:]
        z = f['Step#0']['z'][:]
        px = f['Step#0']['px'][:]
        py = f['Step#0']['py'][:]
        pz = f['Step#0']['pz'][:]
        phasespace = {
            'x': x,
            'y': y,
            'z': z,
            'px': px,
            'py': py,
            'pz': pz,
        }
    return phasespace

def get_coords_from_h5(h5_path: str) -> dict:
    """"Get Bmad-X coordinates from an OPAL h5 file."""
    with h5py.File(h5_path, 'r') as f:
        # ref particle:
        px_ref = f['Step#0'].attrs['RefPartP'][0]
        py_ref = f['Step#0'].attrs['RefPartP'][1]
        pz_ref = f['Step#0'].attrs['RefPartP'][2]
        beta_gamma_ref = (px_ref**2 + py_ref**2 + pz_ref**2)**0.5
        t_ref = f['Step#0'].attrs['TIME'][0]

        # coordinates:
        x = f['Step#0']['x'][:]
        beta_x_gamma = f['Step#0']['px'][:]
        y = f['Step#0']['y'][:]
        beta_y_gamma = f['Step#0']['py'][:]
        t = f['Step#0']['time'][:]
        beta_z_gamma = f['Step#0']['pz'][:]

        # extra variables:
        p = M_ELECTRON * (beta_x_gamma**2 + beta_y_gamma**2 + beta_z_gamma**2)**0.5  # momentum in eV/c
        e = (M_ELECTRON**2 + p**2)**0.5  # energy in eV
        beta = p / e

        # transform coordinates to Bmad cannonical coordinates:
        z = - beta * C_LIGHT * (t - t_ref)  # estimated z coord in m
        px = beta_x_gamma / beta_gamma_ref
        py = beta_y_gamma / beta_gamma_ref
        pz = (beta_z_gamma - beta_gamma_ref) / beta_gamma_ref
        
        # dict with coordinates and ref momentum:
        coords = {
            'x': x,
            'px': px,
            'y': y,
            'py': py,
            'z': z,
            'pz': pz,
            'p0c': beta_gamma_ref * M_ELECTRON,
        }
    return coords


def get_geom_emittance(x_in, p_in):
    """Calculate the geometric emittance from x and p arrays."""
    x = x_in - x_in.mean()
    p = p_in - p_in.mean()
    avg_x_x = (x**2).mean()
    avg_p_p = (p**2).mean()
    avg_x_p = (x*p).mean()
    return (avg_x_x * avg_p_p - avg_x_p**2)**0.5


def evaluate_opal_awa(params) -> dict:
    """Evaluate the OPAL simulation with the given parameters."""
    run_opal_awa(params)
    screen_file = os.path.join(tmp_dir, template_last_screen[params['template_name']])
    coords = get_coords_from_h5(screen_file)
    std_x = coords['x'].std()
    std_y = coords['y'].std()
    std_z = coords['z'].std()
    beam_size = (std_x**2 + std_y**2)**0.5
    beam_size_3d = (std_x**2 + std_y**2 + (10*std_z)**2)**0.5
    particle_loss = (params['n_particles'] - len(coords['x'])) / params['n_particles']
    p0c = coords['p0c']
    output = {
        'std_x': std_x,
        'std_y': std_y,
        'std_z': std_z,
        'beam_size': beam_size,
        'beam_size_3d': beam_size_3d,
        'particle_loss': particle_loss,
        'p0c': p0c
    }
    return output