clear

%% Simulation range parameters
% in GHz
fstart = 0.5;
fend = 15; 
nb_pts = 500000;

%% Simulation Loss factors
eta = [1e-6, 1e-4, 1e-4, 1e-4, 0, 0];

%% Material and HBAR parameter creation (all stored in one file)
varFilename = 'allVariables_multiLossAlN';
file = aafunc_materialVariablesExport(fstart,fend,nb_pts,eta,varFilename);
load(file);
delete(file);

%% Transfer matrix impedance calculations
% Front layer (Al electrode)
Fv_Al = [0;vAl]; %vector od shape [F; v] used in network analysis. Because Al layer is the last, assumption is F = 0 and v = v_Al
M_Al = aafunc_acousticTransferMatrix(ZAl, gammaAl);
MFv_Al = pagemtimes(M_Al,Fv_Al);
ZTop = MFv_Al(1,:)./MFv_Al(2,:);

% Backing plate (Mo + Sapphire substrate)
Fv_Sapph = [0;vSapph]; %we also define the F at the sapphire to be zero as it is in contact with air
M_Sapph = aafunc_acousticTransferMatrix(ZSapph, gammaSapph);
M_Mo = aafunc_acousticTransferMatrix(ZMo, gammaMo);
M_Bulk = pagemtimes(M_Mo,M_Sapph);
MFv_Bulk = pagemtimes(M_Bulk,Fv_Sapph);
Z_Bulk = MFv_Bulk(1,:)./MFv_Bulk(2,:);

% Piezo transfer matrix and full stack
M_Piezo = aafunc_acousticTransferMatrixPiezo(omega, ZAlN, ZTop, gammaAlN, phi, C0);
M_fullStack = pagemtimes(M_Piezo,M_Bulk);

% Propagation of the initial force vector at the sapphire face (F = 0)
VI = pagemtimes(M_fullStack,Fv_Sapph);

% Calculation of impedance from resultant I-V vecor
Z_in = VI(1,:)./VI(2,:);

% Theoretical first peak due to piezo layer
dAlN = 500*1e-9;
f_r = vAlN / (2 * dAlN);      % Hz
fprintf('Expected resonance: %.2f GHz\n', f_r * 1e-9);

%% S11 data prep
[~ , mag_db, ~ , ~ , phase_deg] = aafunc_ZtoS11data(Z_in);
%% Z data prep
[mag_db_z, ~ , ~ , phase_deg_z] = aafunc_ZtoZdata(Z_in);

%% Plotting
figure;
hold on
plot(f * 1e-9, mag_db, 'b');
xlabel('Frequency (GHz)');
ylabel('|S_{11}| (dB)');
title('S_{11} Magnitude');

% save('testFitting_Mason.mat','f','S11','mag_lin','mag_db','phase_deg','phase_rad')