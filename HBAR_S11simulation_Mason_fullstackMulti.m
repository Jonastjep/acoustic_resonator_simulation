clear
unwrapped = 0;

%%%%%%%%%%%%%%%%%% INCREASING THE LOSS OF ALN ALONE MAKES THE PLOT MORE
%%%%%%%%%%%%%%%%%% READABLE!!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set(pAlAlNMo,'visible','off') %if you want to check that the plots are properly superposed

%% Simulation range parameters
% in GHz
fstart = 0;
fend = 40; 
nb_pts = 5000000;

%% Simulation Loss factors
eta = [1e-5, 1e-5, 1e-2, 1e-2, 0, 0];

%% Material and HBAR parameter creation (all stored in one file)
varFilename = 'allVariables_multiLossAlN';

%% Material and HBAR parameter creation (all stored in one file)
file = aafunc_materialVariablesExport(fstart,fend,nb_pts,eta,varFilename);
load(file);
delete(file);

%% Transfer matrix impedance calculations
% Front layer (Al electrode)
Fv_Al = [0;vAl]; %vector od shape [F; v] used in network analysis. Because Al layer is the last, assumption is F = 0 and v = v_Al
M_Al = aafunc_acousticTransferMatrix(ZAl, gammaAl);
MFv_Al = pagemtimes(M_Al,Fv_Al);
Z_layerAl = MFv_Al(1,:)./MFv_Al(2,:);

% Backing plate (Mo Electrode)
Fv_Mo = [0;vMo];
M_Mo = aafunc_acousticTransferMatrix(ZMo, gammaMo);
MFv_Mo = pagemtimes(M_Mo,Fv_Mo);
Z_layerMo = MFv_Mo(1,:)./MFv_Mo(2,:);

% Transfer matrix and impedance of: AlN + Mo + Al
M_Piezo = aafunc_acousticTransferMatrixPiezo(omega, ZAlN, Z_layerAl, gammaAlN, phi, C0);
M_fullStack = pagemtimes(M_Piezo,M_Mo);
VI = pagemtimes(M_fullStack,Fv_Mo);
Z_in = VI(1,:)./VI(2,:);
[S11_AlNMoAl, mag_dB_AlNMoAl, mag_lin_AlNMoAl, phase_rad_AlNMoAl, phase_deg_AlNMoAl] = aafunc_ZtoS11data(Z_in,unwrapped);

% Transfer matrix and impedance of: AlN + Mo
M_Piezo = aafunc_acousticTransferMatrixPiezo(omega, ZAlN, 0, gammaAlN, phi, C0);
M_fullStack = pagemtimes(M_Piezo,M_Mo);
VI = pagemtimes(M_fullStack,Fv_Mo);
Z_in = VI(1,:)./VI(2,:);
[S11_AlNMo, mag_dB_AlNMo, mag_lin_AlNMo, phase_rad_AlNMo, phase_deg_AlNMo] = aafunc_ZtoS11data(Z_in,unwrapped);

% Transfer matrix and impedance of: AlN + Mo other side
Fv_AlN = [0;vAlN];
M_Piezo = aafunc_acousticTransferMatrixPiezo(omega, ZAlN, Z_layerMo, gammaAlN, phi, C0);
VI = pagemtimes(M_Piezo,Fv_AlN);
Z_in = VI(1,:)./VI(2,:);
[S11_AlNMo1, mag_dB_AlNMo1, mag_lin_AlNMo1, phase_rad_AlNMo1, phase_deg_AlNMo1] = aafunc_ZtoS11data(Z_in,unwrapped);

% Transfer matrix and impedance of: AlN + Al
M_Piezo = aafunc_acousticTransferMatrixPiezo(omega, ZAlN, Z_layerAl, gammaAlN, phi, C0);
VI = pagemtimes(M_Piezo,Fv_AlN);
Z_in = VI(1,:)./VI(2,:);
[S11_AlNAl, mag_dB_AlNAl, mag_lin_AlNAl, phase_rad_AlNAl, phase_deg_AlNAl] = aafunc_ZtoS11data(Z_in,unwrapped);

% Transfer matrix and impedance of: AlN
M_Piezo = aafunc_acousticTransferMatrixPiezo(omega, ZAlN, 0, gammaAlN, phi, C0);
VI = pagemtimes(M_Piezo,Fv_AlN);
Z_in = VI(1,:)./VI(2,:);
[S11_AlN, mag_dB_AlN, mag_lin_AlN, phase_rad_AlN, phase_deg_AlN] = aafunc_ZtoS11data(Z_in,unwrapped);

% Transfer matrix and impedance of: Al+AlN+Mo+Sapphire
% Backing plate (Mo + Sapphire substrate)
Fv_AlN = [0;vSapph];
M_Sapph = aafunc_acousticTransferMatrix(ZSapph, gammaSapph);
M_Bulk = pagemtimes(M_Mo,M_Sapph);
M_Piezo = aafunc_acousticTransferMatrixPiezo(omega, ZAlN, Z_layerAl, gammaAlN, phi, C0);
M_fullStack = pagemtimes(M_Piezo,M_Bulk);
VI = pagemtimes(M_fullStack,Fv_AlN);
Z_in = VI(1,:)./VI(2,:);
[S11_Fullstack, mag_dB_Fullstack, mag_lin_Fullstack, phase_rad_Fullstack, phase_deg_Fullstack] = aafunc_ZtoS11data(Z_in);

%% Plotting
figure;
hold on
pFullstack = plot(f * 1e-9, mag_dB_Fullstack);
pAlAlNMo = plot(f * 1e-9, mag_dB_AlNMoAl);
pAlNMo = plot(f * 1e-9, mag_dB_AlNMo);
pAlAlN = plot(f * 1e-9, mag_dB_AlNAl);
pAlN = plot(f * 1e-9, mag_dB_AlN);
xlabel('Frequency (GHz)');
ylabel('|S_{11}| (dB)');
legend('Al-AlN-Mo-Sapphire', 'Al-AlN-Mo', 'AlN-Mo', 'Al-AlN', 'AlN');
% legend('AlN-Mo', 'Mo-AlN', 'Al-AlN', 'AlN');
title('S_{11} Magnitudes of different individual layers');
hold off;
