
TITLE, STRING = "AWA cathode to EYG5";

REAL eex_dip_energy = 41.929;
  
REAL sol_focusing_i = 550.0;
  REAL sol_matching_i = 200.0;
  REAL gun_phase = 50.0;
  REAL linac_phase = -10.0;
  REAL dq4_k1 = 0.261428;
  REAL dq5_k1 = -0.670359;
  REAL dq6_k1 = 0.621865;
  REAL dq7_k1 = -0.309544;
  REAL rq_k1 = -1.945;
  
REAL charge = 1e-09;
  REAL laser_radius = 0.002;
  
REAL csr_on = 1.0;
  REAL gun_field_maps = 2;
  REAL linac_field_maps = 2;
  REAL autophase = 6;
  REAL ps_dump_freq = 100000000;
  REAL stat_dump_freq = 10;
  REAL repart_freq = 100000000;
  REAL grid_points = 32;
  
OPTION,     PSDUMPFREQ = ps_dump_freq,    STATDUMPFREQ = stat_dump_freq,      AUTOPHASE = autophase,    REPARTFREQ = repart_freq,     VERSION = 20220100;

STRING path_fieldmaps3d = "../../../data/opal/awa_fieldmaps_3D";
STRING path_fieldmaps2d = "../../../data/opal/awa_fieldmaps_2D";
STRING path_fringes = "../../../data/opal/awa_fringes";

REAL initial_kinetic_energy = 1.4;
  REAL rf_frequency = 1.3e9;
  
beam_1: BEAM,     PARTICLE = ELECTRON,     ENERGY = initial_kinetic_energy * 1e-9 + EMASS,      BFREQ = rf_frequency * 1E-6,      BCURRENT = charge * rf_frequency,      NPART = grid_points^3 * 8;
  
dist_1: DISTRIBUTION,     TYPE = FLATTOP,    SIGMAR = laser_radius,      TRISE = 300.0e-15/2.35*1.6869,      TFALL = 300.0e-15/2.35*1.6869,      TPULSEFWHM = 8e-12,     CUTOFFLONG = 4.0,      NBIN = 5,      EMISSIONSTEPS = 500,      EMISSIONMODEL = ASTRA,    EKIN = initial_kinetic_energy,      EMITTED = True,     WRITETOFILE = True;
    
REAL gun_inj_amp = 61.26;
 
cathode: SOURCE,     ORIGIN = {0.0, 0.0, 0.0};

if (gun_field_maps == 2.0){    REAL gun_freq = 1300.013338990260;
    REAL gun_len  = 0.292707450;
    REAL gun_amplitude = gun_inj_amp;
     STRING gun_fieldmap = "${path_fieldmaps2d}/gun.T7";
}else {    REAL gun_freq = 1300.0;
    REAL gun_len  = 2.327100e-01;
    REAL gun_amplitude = - gun_inj_amp;
     STRING gun_fieldmap = "${path_fieldmaps3d}/gun3d.T7";
}
gun: RFCAVITY,    ORIGIN = {0.0, 0.0, 0.0},     L = gun_len,     VOLT = gun_amplitude,    LAG = (gun_phase + 90.0) * Pi /180.0,     FMAPFN = gun_fieldmap,    TYPE = "STANDING",    FREQ = gun_freq,    APVETO = TRUE;

sol_focusing: SOLENOID,     ORIGIN = {0.0, 0.0, 0.0},     L = 0.5,     KS = (sol_focusing_i/550.0)*0.12017,      FMAPFN = "${path_fieldmaps2d}/1T7.T7";

sol_matching: SOLENOID,     ORIGIN = {0.0, 0.0, 0.0},     L = 0.486,     KS = sol_matching_i/440.0*0.61126,      FMAPFN = "${path_fieldmaps2d}/M440.T7";

aperture: DRIFT,    ORIGIN = {0.0, 0.0, 2.43},    L=0.005,    APERTURE="RECTANGLE(0.06,0.08,1)";

REAL klystron_2 = 1.0;
 REAL Klystron_3 = 1.0;
 
REAL linac_1_amplitude = 22.06*Klystron_2;
REAL linac_2_amplitude = 22.06*Klystron_2;
REAL linac_3_amplitude = 22.06*Klystron_3;
REAL linac_5_amplitude = 22.06*Klystron_3;

REAL linac_1_zc = 1.1810;
 REAL linac_2_zc = 3.9735;
 REAL linac_3_zc = 5.5415;
 REAL linac_5_zc = 9.0107;
 
if (linac_field_maps == 2.0){    REAL linac_len = 1.20713354;
      REAL linac_freq = 1300.000246546;
    STRING linac_fieldmap = "${path_fieldmaps2d}/DriveLinac.T7";
  }else {    REAL linac_len  = 1.1;
    REAL linac_freq = 1300.400;
    STRING linac_fieldmap = "${path_fieldmaps3d}/drivelinaccplr_posY.ascii";
  }
linac_1: RFCAVITY,     ORIGIN = {0.0, 0.0, linac_1_zc - linac_len/2.},    ORIENTATION = {0.0, 0.0, -90.0},      L = linac_len,     VOLT = linac_1_amplitude,     LAG = linac_phase * Pi / 180.0,    FMAPFN = linac_fieldmap,     TYPE = "STANDING",    FREQ = linac_freq;

linac_2: RFCAVITY,     ORIGIN = {0.0, 0.0, linac_2_zc - linac_len/2.},    ORIENTATION = {0.0, 0.0, 90.0},      L = linac_len,     VOLT = linac_2_amplitude,     LAG = linac_phase * Pi / 180.0,    FMAPFN = linac_fieldmap,    TYPE = "STANDING",    FREQ = linac_freq;

linac_3: RFCAVITY,    ORIGIN = {0.0, 0.0, linac_3_zc - linac_len/2.},    ORIENTATION = {0.0, 0.0, 90.0},      L = linac_len,     VOLT = linac_3_amplitude,    LAG = linac_phase * Pi / 180.0,    FMAPFN = linac_fieldmap,    TYPE = "STANDING",    FREQ = linac_freq;

linac_5: RFCAVITY,    ORIGIN = {0.0, 0.0, linac_5_zc - linac_len/2.},    ORIENTATION = {0.0, 0.0, -90.0},      L = linac_len,     VOLT = linac_5_amplitude,     LAG = linac_phase * Pi / 180.0,     FMAPFN = linac_fieldmap,    TYPE = "STANDING",    FREQ = linac_freq;

REAL dq_len = 0.12;
  
dq4: QUADRUPOLE,    L = dq_len,     ORIGIN = {0.0, 0.0, 13.8002 - dq_len/2},     K1 = dq4_k1;
dq5: QUADRUPOLE,     L = dq_len,     ORIGIN = {0.0, 0.0, 14.0652 - dq_len/2},     K1 = dq5_k1;
dq6: QUADRUPOLE,     L = dq_len,     ORIGIN = {0.0, 0.0, 14.3152 - dq_len/2},     K1 = dq6_k1;
dq7: QUADRUPOLE,     L = dq_len,     ORIGIN = {0.0, 0.0, 14.5852 - dq_len/2},     K1 = dq7_k1;

REAL eex_dip_len = 0.3;
  
if (csr_on == 1.0){    CSR_FILTER: FILTER,        TYPE = "Savitzky-Golay",        NPOINTS = 20,         NLEFT = 4,        NRIGHT = 4,        POLYORDER = 4;

    CSR_WK: WAKE,         TYPE = "1D-CSR-IGF",         NBIN = 300,         FILTERS = CSR_FILTER;

    ed1: RBEND,         ANGLE = -20.00 * Pi / 180.0,         FMAPFN = "${path_fringes}/EEXDIP30cm.opal",        ORIGIN = {0.0, 0.0, 15.5872 - eex_dip_len/2},        DESIGNENERGY = eex_dip_energy,        E1 = 0,         L = eex_dip_len,        GAP = 0.05,        WAKEF = CSR_WK;

    ed2: RBEND,        ANGLE = 20.00 * Pi / 180.0,         FMAPFN = "${path_fringes}/EEXDIP30cm.opal",        ORIGIN = {6.183724191328090e-01, 0.0, 1.729616425838092e+01 - eex_dip_len/2},        DESIGNENERGY = eex_dip_energy,         E1 = 20.00 * Pi / 180.0,        L = eex_dip_len,         GAP = 0.05,         WAKEF = CSR_WK;

    ed3: RBEND,         ANGLE = -20.00 * Pi / 180.0,         FMAPFN = "${path_fringes}/EEXDIP30cm.opal",        ORIGIN = {6.183724191328090e-01, 0.0, 1.919667925838093e+01 - eex_dip_len/2},        DESIGNENERGY = eex_dip_energy,         E1 = 0,         L = eex_dip_len,         GAP = 0.05,         WAKEF = CSR_WK;

    ed4: RBEND,        ANGLE = 20.00 * Pi / 180.0,         FMAPFN = "${path_fringes}/EEXDIP30cm.opal",        ORIGIN = {1.236744838265618e+00, 0.0, 2.090564351676185e+01 - eex_dip_len/2},        DESIGNENERGY= eex_dip_energy,         E1 = 20.00 * Pi / 180.0,        L = eex_dip_len,         GAP = 0.05,        WAKEF = CSR_WK;

}else{
    ed1: RBEND,        ANGLE = -20.00 * Pi / 180.0,         FMAPFN = "${path_fringes}/EEXDIP30cm.opal",        ORIGIN = {0.0, 0.0, 15.5872 - eex_dip_len/2},        DESIGNENERGY = eex_dip_energy,         E1 = 0,         L = eex_dip_len,         GAP = 0.05;

    ed2: RBEND,        ANGLE = 20.00 * Pi / 180.0,         FMAPFN = "${path_fringes}/EEXDIP30cm.opal",        ORIGIN = {6.183724191328090e-01, 0.0, 1.729616425838092e+01 - eex_dip_len/2},        DESIGNENERGY = eex_dip_energy,         E1 = 20.00 * Pi / 180.0,        L = eex_dip_len,        GAP = 0.05;

    ed3: RBEND,        ANGLE = -20.00 * Pi / 180.0,         FMAPFN = "${path_fringes}/EEXDIP30cm.opal",        ORIGIN = {6.183724191328090e-01, 0.0, 1.919667925838093e+01 - eex_dip_len/2},        DESIGNENERGY = eex_dip_energy,         E1 = 0,         L = eex_dip_len,         GAP = 0.05;

    ed4: RBEND,         ANGLE = 20.00 * Pi / 180.0,         FMAPFN = "${path_fringes}/EEXDIP30cm.opal",        ORIGIN = {1.236744838265618e+00, 0.0, 2.090564351676185e+01 - eex_dip_len/2},        DESIGNENERGY= eex_dip_energy,         E1 = 20.00 * Pi / 180.0,        L = eex_dip_len,         GAP = 0.05;

}
REAL rq_len = 0.1;
  
rq1: QUADRUPOLE,     L = rq_len,     ORIGIN = {6.183724191328090e-01, 0.0, 1.758116425838092e+01 - rq_len/2},     K1 = rq_k1;
rq2: QUADRUPOLE,     L = rq_len,     ORIGIN = {6.183724191328090e-01, 0.0, 1.891167925838093e+01 - rq_len/2},     K1 = rq_k1;

screen_cathode: MONITOR,     ORIGIN = {0.0, 0.0, 1.0e-3},     OUTFN = "CATHODE_SCREEN.h5";
  
YAG4: MONITOR,     ORIGIN = {0.0, 0.0, 11.372},     OUTFN = "YAG4.h5";
  
YAG5: MONITOR,     ORIGIN = {0.0, 0.0, 14.5852 - dq_len/2 + 0.24},     OUTFN = "YAG5.h5";
  
EYG5: MONITOR,     ORIGIN = {1.236744838265618e+00, 0.0, 2.090564351676185e+01 + eex_dip_len/2 + 0.4},     OUTFN = "EYG5.h5";
  
line_injector: LINE = (cathode, screen_cathode, gun, sol_focusing, sol_matching);
 line_linac: LINE = (linac_1, linac_2, linac_3, linac_5, YAG4);
line_four_quads: LINE = (dq4, dq5, dq6, dq7, YAG5);
line_double_dogleg: LINE = (ed1, ed2, rq1, rq2, ed3, ed4, EYG5);
line_cathode_to_EYG5: LINE = (line_injector, line_linac, line_four_quads, line_double_dogleg);
 
field_solver_1: FIELDSOLVER,     FSTYPE = FFT,     MX = grid_points,    MY = grid_points,     MT = grid_points,     PARFFTX = true,     PARFFTY = true,     PARFFTT = true,     BCFFTX = open,     BCFFTY = open,     BCFFTT = open,    BBOXINCR = 1,     GREENSF = INTEGRATED;

REAL dtG = 1.0E-12;
 REAL dtL = 1.0E-11;
 
TRACK,     LINE = line_cathode_to_EYG5,     BEAM = beam_1,     MAXSTEPS = 1000000,     DT = {dtG, dtL},     ZSTOP = {1.0, 2.090564351676185e+01 + eex_dip_len/2 + 0.4 + 0.3};
 
RUN,     METHOD = "PARALLEL-T",     BEAM = beam_1,     FIELDSOLVER = field_solver_1,     DISTRIBUTION = dist_1;

ENDTRACK;

