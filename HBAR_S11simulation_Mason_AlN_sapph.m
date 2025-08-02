clear

%% Simulation range parameters
% in GHz
fstart = 0;
fend = 40; 

f = linspace(fstart*1e9, fend*1e9, 1000000); %linear frequency
omega = 2*pi*f; %angular frequency

%% Material and HBAR parameter creation (all stored in one file)
materialConstants;

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
plot(f * 1e-9, mag_dB,'b');
xlabel('Frequency (GHz)');
ylabel('|S_{11}| (dB)');
title('S_{11} Magnitude');