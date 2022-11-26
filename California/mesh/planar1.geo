/*
/**
 * @file
 *
 * @author D. Li 
 *
 * @section LICENSE
 * Copyright (c) 2022-2023
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 
 * 3. Neither the name of the copyright holder nor the names of its
 *    contributors may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE  USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 
18.03.2020
Create a planar fault in whole-space (tpv3) of given dimension and dip angle, the nucleation is also included in the geometry
To use obtain the mesh:
gmsh tpv3-200.geo -3 -optimize
To convert the mesh:
gmsh2gambit -i tpv3-200.msh -o tpv3-200.neu

 */


lc = 25e3;
lc_fault = 2000;

Fault_length = 120e3;
Fault_width = 15e3;
Fault_dip = 90*Pi/180.;

//Nucleation in X,Z local coordinates
X_nucl = 0e3;
Width_nucl = 0.5*Fault_width;
R_nucl = 1.5e3;
lc_nucl = 200;

Xmax = 140e3;
Xmin = -80e3;
Ymin = -50e3; 
Ymax =  -Ymin;
Zmin = -50e3;


//Create the Volume
Point(1) = {Xmin, Ymin, 0, lc};
Point(2) = {Xmin, Ymax, 0, lc};
Point(3) = {Xmax, Ymax, 0, lc};
Point(4) = {Xmax, Ymin, 0, lc};
Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};
Line Loop(5) = {1,2,3,4};
Plane Surface(1) = {5};
Extrude {0,0, Zmin} { Surface{1}; }

//Create the fault
Point(100) = {-0.5*Fault_length, Fault_width  *Cos(Fault_dip), -Fault_width  *Sin(Fault_dip), lc};
Point(101) = {-0.5*Fault_length, 0, 0e3, lc};
Point(102) = {0.5*Fault_length, 0,  0e3, lc};
Point(103) = {0.5*Fault_length, Fault_width  *Cos(Fault_dip), -Fault_width  *Sin(Fault_dip), lc};
Line(100) = {100, 101};
Line(101) = {101, 102};
Line{101} In Surface{1};
Line(102) = {102, 103};
Line(103) = {103, 100};

Point(106) = {0.5*Fault_length+40e3,41.4e3*Sin(15*Pi/180) ,  0e3, lc};
Point(107) = {0.5*Fault_length+40e3,41.4e3*Sin(15*Pi/180) , -Fault_width, lc};
Line(104) = {107,103};
Line(105) = {106,107};
Line(106) = {102,106};
Line{106} In Surface{1};
// Line(107) = {103,102};

Point(108) = {0.5*Fault_length+40e3+10e3,41.4e3*Sin(15*Pi/180) ,  0e3, lc};
Point(109) = {0.5*Fault_length+40e3+10e3,41.4e3*Sin(15*Pi/180) , -Fault_width, lc};
Line(108) = {109,107};
Line(109) = {108,109};
Line(110) = {106,108};
Line{110} In Surface{1};
// Line(111) = {107,106};

Line Loop(105) = {100,101,102,103};
Plane Surface(100) = {105};
// Line{107} In Surface{100};

Line Loop(106) = {104,-102,106,105};
Plane Surface(101) = {106};
// Line{111} In Surface{101};

Line Loop(107) = {108,-105,110,109};
Plane Surface(102) = {107};



//There is a bug in "Attractor", we need to define a Ruled surface in FaceList
Line Loop(206) = {100,101,102,103};
Line Loop(207) = {104,-102,106,105};
Line Loop(208) = {108,-105,110,109};
Ruled Surface(111) = {206};
Ruled Surface(112) = {207};
Ruled Surface(113) = {208};


Surface{100,101,102} In Volume{1};

//1.2 Managing coarsening away from the fault
// Attractor field returns the distance to the curve (actually, the
// distance to 100 equidistant points on the curve)
Field[1] = Attractor;
Field[1].FacesList = {111,112,113};

// Matheval field returns "distance squared + lc/20"
Field[2] = MathEval;
Field[2].F = Sprintf("0.05*F1 +50*(F1/2.5e3)^2 + %g", lc_fault);

//3.4.5 Managing coarsening around the nucleation Patch
//equivalent of propagation size on element
Field[6] = Threshold;
Field[6].IField = 1;
Field[6].LcMin = lc_fault;
Field[6].LcMax = lc;
Field[6].DistMin = 2*lc_fault;
Field[6].DistMax = 2*lc_fault+0.001;

Field[7] = Min;
Field[7].FieldsList = {2,6};

Background Field = 7;

Physical Line("edge",111) = {100,109,103,104,108};
Physical Surface("boundary_zpos",101) = {1};
Physical Surface("fault",103) = {100,101,102};
Physical Surface("boundary_xpos",105) = {22};
Physical Surface("boundary_xneg",106) = {14};
Physical Surface("boundary_ypos",107) = {18};
Physical Surface("boundary_yneg",108) = {26};
Physical Surface("boundary_zneg",109) = {27};

Physical Volume("material-id:1",1) = {1};


