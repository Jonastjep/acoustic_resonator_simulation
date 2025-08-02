clear

%% Unwrapping of the phase if needed
unwrapped = 0; % if we want the phase to be unwarapped automatically

%% Simulation range parameters
% in GHz
fstart = 5;
fend = 40; 
nb_pts = 100000;

%% Plot and data saving
saveplot = 1;
fstartstr = strrep(sprintf("%.3f", fstart), ".", "-");
fendstr = strrep(sprintf("%.3f", fend), ".", "-");
figName = sprintf('S11_Z_%sto%sGHz_AlNOnly_%s',fstartstr,fendstr);

%% Simulation Loss factors
eta = [1e-5, 4e-5, 1e-4, 1e-4, 0, 0];

%% Material and HBAR parameter creation (all stored in one file)
varFilename = 'allVariables_AlN';
file = aafunc_materialVariablesExport(fstart,fend,nb_pts,eta,varFilename);
load(file);
delete(file)

%% Plotting variables (titles, filenames)
% placeholder names for title in plot
mech = '\eta_m'; % char array for mecanical loss factor
diel = ['\eta_',char(949)]; % char for writing eta_eps because \varepsilon doesn't exist in tex
piezCoupl = '\eta_{k_t}';

%used to add an indication of what variable was changed
varnameForFilename = "eta_mSapph_Em1toEm7"; 
varnameForPltTitle = [mech, ' Sapphire'];

%% Transfer matrix impedance calculations
% Front layer (no Al electrode)
ZTop = 0;

% Backing plate (no Mo + Sapphire substrate)
M_Bulk = 0;

% Piezo transfer matrix and full stack
M_Piezo = aafunc_acousticTransferMatrixPiezo(omega, ZAlN, ZTop, gammaAlN, phi, C0);

% Propagation of the initial force vector at the sapphire face (F = 0)
Fv_air = [0;vAlN]; %we also define the F at the sapphire to be zero as it is in contact with air
VI = pagemtimes(M_Piezo,Fv_air);

% Calculation of impedance from resultant I-V vecor
Z_in = VI(1,:)./VI(2,:);

% Theoretical first peak due to piezo layer
f_r = vAlN / (2 * dAlN);      % Hz
fprintf('Expected resonance: %.2f GHz\n', f_r * 1e-9);

%% S11 data prep
[~ , mag_db, ~ , ~ , phase_deg] = aafunc_ZtoS11data(Z_in, unwrapped);
%% Z data prep
[mag_db_z, ~ , ~ , phase_deg_z] = aafunc_ZtoZdata(Z_in, unwrapped);

%% Plotting
% set(0, 'defaultTextInterpreter', 'latex');
% set(0, 'defaultTextInterpreter', 'tex');
f1 = figure('Color', 'w', 'Position', [100, 100, 1700, 600]);

% magnitude S11 dB
ax1 = subplot(2,2,1);
plot(f*1e-9, mag_db, 'b');
% yline(0,'k--',Layer='bottom',Alpha=0.5)
ylabel('|S_{11}| [dB]');
title('Bode Plots of S-parameter S_{11}');
grid on;
set(gca, 'XTickLabel', []); 
ylim padded;

% phase S11 degrees
ax2 = subplot(2,2,2);
plot(f*1e-9, mag_db_z, 'b');
% yline(0,'k--',Layer='bottom',Alpha=0.5)
ylabel('|Z_{in}| [dB\Omega]');
title('Bode Plots of Impedance Z_{in}');
grid on;
set(gca, 'XTickLabel', []);  
ax2.Position(1)=0.52; %% position =[x_position y_position widht length] all are in some unit
ylim padded;

% magnitude Z in ohms
ax3 = subplot(2,2,3);
plot(f*1e-9, phase_deg, 'r');
% yline(0,'k--',Layer='bottom',Alpha=0.5)
xlabel('Frequency [GHz]');
ylabel('S_{11} Phase [°]');
ax3.Position(2)=0.22; % Y pos
ylim padded;

grid on;
% phase of Z (degrees)
ax4 = subplot(2,2,4);
plot(f*1e-9, phase_deg_z, 'r');
% yline(0,'k--',Layer='bottom',Alpha=0.5)
xlabel('Frequency [GHz]');
ylabel('Z_{in} Phase [°]');
grid on;
ax4.Position(1)=0.52; % X pos
ax4.Position(2)=0.22; % Y pos
ylim padded;

linkaxes([ax1, ax3], 'x');
linkaxes([ax2, ax4], 'x');

place = 'singlePlots'; % variable should be 'multiPlots' or 'singlePlots'; 
if saveplot
    aafunc_figureSave(f1, figName, place, Z_in, eta)
end