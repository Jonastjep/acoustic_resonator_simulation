clear

%% Simulation range parameters
% in GHz
fstart = 1;
fend = 6; 

f = linspace(fstart*1e9, fend*1e9, 1000000); %linear frequency
omega = 2*pi*f; %angular frequency

%% Device parameters
% Geometrical parameterseta_AlN
r_el = 100*1e-6;
A_el = pi*r_el.^2;

% Layer thickness in meters
dAl = 100*1e-9;
dAlN = 920*1e-9;
dMo = 100*1e-9;
dSiO2 = 5.44*1e-6; %was dSiO2
dSi = 231.5*1e-6;

%% Loss factors
% Piezoelectric losses
eta_mAlN = 5e-3; % mechanical loss factor
eta_kT = 0; %
eta_eps = 0; 

% Substrate losses
eta_mSiO2 = 1e-4;
eta_mSi = 5e-4;
eta_mMo = 1e-4;
eta_mAl = 1e-4;

%% Material density in kg/m^3
rhoAl = 2700; 
rhoAlN = 3300; 
rhoMo = 10200; 
rhoSiO2 = 2200; 
rhoSi = 2329; 

%% Elastic coefficients c33 (N/m^2) -> 1 newton/square meter = 1.0E-9 GPa
c33AlN = 395.*1e9;      % Tirado thesis

%% Dielectric constants
eps_0 = 8.85.*1e-12; %permittivity of free space
eps_r_AlN = 8.7; 
eps_AlN = eps_0.*eps_r_AlN; % isotropic in Z, so this is dielectric constant
eps_AlN = eps_AlN.*(1-1i*eta_eps); %lossy dielectric

%% Piezo and stiffened coefficients
k_t = 0.065; % electromechanical coupling constant
e33AlN = 1.5; % C/m^2  Tirado thesis; piezoelectric stress constant
c_33AlN = c33AlN + e33AlN^2./eps_AlN; % stiffened elastic constant

%% Lossless sound velocity in m/s 
vAl_ll = 6300;
vAlN_ll = 11050; %stiffened acoustic velocity
vMo_ll = 6636;
vSiO2_ll = 5640;
vSi_ll = 8430;

%% Lossless pure characteristic acoustic impedance
ZAl_ll = rhoAl.*vAl_ll;
ZAlN_ll = rhoAlN.*vAlN_ll; %stiffened characteristic acoustic impedance
ZMo_ll = rhoMo.*vMo_ll;
ZSiO2_ll = rhoSiO2.*vSiO2_ll;

%% Lossy wave vector
kAl = omega./vAl_ll.*(1+1i.*eta_mAl);
kAlN = omega./vAlN_ll.*(1-1i.*eta_mAlN);
kMo = omega./vMo_ll.*(1+1i.*eta_mMo);
kSiO2 = omega./vSiO2_ll.*(1+1i.*eta_mSiO2);
kSi = omega./vSi_ll.*(1+1i.*eta_mSi);

%% Lossy sound velocity in m/s 
vAl = vAl_ll./(1-1i.*eta_mAl);
vAlN = vAlN_ll./(1-1i.*eta_mAlN); %stiffened acoustic velocity with loss
vMo = vMo_ll./(1-1i.*eta_mMo);
vSiO2 =vSiO2_ll./(1-1i.*eta_mSiO2);
vSi =vSi_ll./(1-1i.*eta_mSi);

%% Phase evolution within a layer
% with alpha, beta not defined, but alpha = 
gammaAl = (omega./vAl).*dAl;
gammaAlN = (omega./vAlN).*dAlN;
gammaMo = (omega./vMo).*dMo ;
gammaSiO2 = (omega./vSiO2).*dSiO2;
gammaSi = (omega./vSi).*dSi;

%% Lossy characteristic acoustic impedance
% Lossy pure characteristic acoustic impedance
ZAl_noS = rhoAl.*vAl;
ZAlN_noS = rhoAlN.*vAlN; %stiffened characteristic acoustic impedance
ZMo_noS = rhoMo.*vMo;
ZSiO2_noS = rhoSiO2.*vSiO2;
ZSi_noS = rhoSi.*vSi;

% Lossy material impedance normalized to electrode size
ZAl = A_el.*ZAl_noS;
ZAlN = A_el.*ZAlN_noS;
ZMo = A_el.*ZMo_noS;
ZSiO2 = A_el.*ZSiO2_noS;
ZSi = A_el.*ZSi_noS;

%% Device constants
C0 = A_el.*eps_AlN./dAlN; %dielectric capacitance (intrinsic capacitance of piezo actuator)
k_t_lossy = sqrt(k_t) .* (1-1i.*eta_kT);
k_t2 = k_t_lossy.^2;
phi = sqrt(vAlN.*C0.*ZAlN.*k_t2/dAlN);

%% Transfer matrix impedance calculations
% Front layer (Al electrode)
Fv_Al = [0;vAl];
M_Al = aafunc_acousticTransferMatrix(ZAl, gammaAl);
MFv_Al = pagemtimes(M_Al,Fv_Al);
ZTop = MFv_Al(1,:)./MFv_Al(2,:);

% Backing plate (SiO2 + Si substrate)
M_Si = aafunc_acousticTransferMatrix(ZSi, gammaSi);
M_SiO2 = aafunc_acousticTransferMatrix(ZSiO2, gammaSiO2);
M_Mo = aafunc_acousticTransferMatrix(ZMo, gammaMo);
M_SiO2Si = pagemtimes(M_SiO2,M_Si);
M_Bulk = pagemtimes(M_Mo,M_SiO2Si);

% Piezo transfer matrix and full stack
M_Piezo = aafunc_acousticTransferMatrixPiezo(omega, ZAlN, ZTop, gammaAlN, phi, C0);
M_fullStack = pagemtimes(M_Piezo,M_Bulk);

% Propagation of the initial force vector at the SiO2ire face (F = 0)
Fv_Si = [0;vSi]; %we also define the F at the SiO2ire to be zero as it is in contact with air
VI = pagemtimes(M_fullStack,Fv_Si);

% Calculation of impedance from resultant I-V vecor
Z_in = VI(1,:)./VI(2,:);

%% S11 data prep
[S11, mag_db, mag_lin, phase_rad, phase_deg] = aafunc_ZtoS11data(Z_in);

%% Z data prep
[mag_db_z, mag_lin_z, phase_rad_z, phase_deg_z] = aafunc_ZtoZdata(Z_in);

%% Plotting
figure;
hold on
plot(f * 1e-9, mag_db, 'b');
xlabel('Frequency (GHz)');
ylabel('|S_{11}| (dB)');
title('S_{11} Magnitude');

