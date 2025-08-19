clear

%% Simulation range parameters
% in GHz
fstart = 0.1;
fend = 40; 
nb_pts = 100000;

%% Simulation Loss factors
eta = [1e-4, 1e-4, 1e-4, 1e-4, 0, 0];

%% Material and HBAR parameter creation (all stored in one file)
varFilename = 'allVariables_multiLossAlN';

%% Material and HBAR parameter creation (all stored in one file)
file = aafunc_materialVariablesExport(fstart,fend,nb_pts,eta,varFilename);
load(file);
delete(file);

%% Transfer matrix impedance calculations
% Backing plate (Sapphire substrate)
M_Sapph = aafunc_acousticTransferMatrix(ZSapph, gammaSapph);

% Piezo transfer matrix and full stack
M_Piezo = aafunc_acousticTransferMatrixPiezo(omega, ZAlN, 0, gammaAlN, phi, C0);
M_fullStack = pagemtimes(M_Piezo,M_Sapph);

% Propagation of the initial force vector at the sapphire face (F = 0)
Fv_Sapph = [0;vSapph]; %we also define the F at the sapphire to be zero as it is in contact with air
VI = pagemtimes(M_fullStack,Fv_Sapph);

% Calculation of impedance from resultant I-V vecor
Z_in = VI(1,:)./VI(2,:);

%% S11 data prep
[~ , mag_db, ~ , ~ , phase_deg] = aafunc_ZtoS11data(Z_in);
%% Z data prep
[mag_db_z, ~ , ~ , phase_deg_z] = aafunc_ZtoZdata(Z_in);

%% Plotting
figure;
hold on
plot(f * 1e-9, mag_db,'b');
xlabel('Frequency (GHz)');
ylabel('|S_{11}| (dB)');
title('S_{11} Magnitude');