# Earthquakes and aseismic slip on planar faults in California

This is a workplace for using Pylith v3 for aseismic and seismic fault deformation.

## Step 1: Create geometry and mesh files with Cubit/Trelis

In Trelis, run "playback planar_fault.jou" to create a planar fault buried in a box volume and mesh into tetrahedra elements. Then run "play set_bc.jou" to set boundary condition for each curve (fault boundes), surface and volume (v_domain). The boundary condition must be labeled correctly. The same labels are used in pylith input files, say pylichapp.cfg. 

![image](https://github.com/daisy20170101/pylith_related/blob/main/California/figures/1d_velocity.jpeg)
Figure 1. Cutview of a planar fault in tetrahedra mesh and 1d density/velocity model used in this study.

## Step 2: Axial displacement loading

pylith step01_axialdisp.cfg  mat_elastic.cfg

## Step 3: Coseismic displacement on the fault

pylith  step02_coseismic.cfg mat_viscoelastic.cfg 

The distribution of coseismic slip on the fault is linearly decreasing from 1.0 m (pure left-lateral) to 0.1 m at the bottom of fault. 

![image](https://github.com/daisy20170101/pylith_related/blob/main/California/figures/dispX-coseis.png)
Figure 2. Coseismic displacement on a left-lateral strikeslip fault in the entire domain. Blue lines are adaptive tetrahedra elements created by Cubit. 

## Step 4: Interseismic slip rate loading on the fault

pylith  step03_interseismic.cfg mat_viscoelastic.cfg 

