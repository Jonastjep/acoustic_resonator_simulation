clear
unwrapped = 0;

%% Simulation range parameters
% in GHz
fstart = 8;
fend = 15; 
nb_pts = 500000;

%% Simulation Loss factors
eta = [1e-4, 1e-5, 1e-4, 1e-4, 0, 0];
eta_Mid = 1e-4;
thickMid = [150*1e-9];%[100*1e-9 150*1e-9 200*1e-9 250*1e-9];

%% Material and HBAR parameter creation (all stored in one file)
varFilename = 'allVariables_multiLossAlN';

%% Material and HBAR parameter creation (all stored in one file)
file = aafunc_materialVariablesExport(fstart,fend,nb_pts,eta,varFilename);
load(file);
delete(file);

%% Parameters for midplate (user entry)
vMid_ll = 951;    %random resin values (ECLBC-CF 0.00)                  %vSapph_ll; 
rhoMid = 1471; %random resin values                                  %rhoSapph;
zMid_charac = rhoMid.*vMid_ll; %just to see in this case, Z0 = 1398921 or 1.3Mrayl


%% Transfer matrix impedance calculations
% Piezo transfer matrix
M_Piezo = aafunc_acousticTransferMatrixPiezo(omega, ZAlN, 0, gammaAlN, phi, C0);

Fv_AlN = [0;vAlN];
VI = pagemtimes(M_Piezo,Fv_AlN);

% Calculation of impedance from resultant I-V vecor
Z_in = VI(1,:)./VI(2,:);

%% S11 data prep
[~ , mag_db, ~ , ~ , phase_deg] = aafunc_ZtoS11data(Z_in);
%% Z data prep
[mag_db_z, ~ , ~ , phase_deg_z] = aafunc_ZtoZdata(Z_in);

%% Transfer matrix impedance calculations for stacked AlN-mid-AlN
% Automatically calculated material parameters
vMid = vMid_ll./(1-1i.*eta_Mid);
ZMid = A_el*rhoMid.*vMid;
% Collection arrays
N = numel(thickMid);
mags = zeros(N,nb_pts);
phases = zeros(N,nb_pts);
i = 1;
for d = thickMid
    
    % Mid plate
    % Automatically calculated material parameters
    gammaMid = (omega./vMid).*d;
    c33Mid = vMid^2*rhoMid;

    % Midlayer transfer matrix
    M_Mid = aafunc_acousticTransferMatrix(ZMid, gammaMid);
    
    % Piezo transfer matrix and full stack
    M_Piezo = aafunc_acousticTransferMatrixPiezo(omega, ZAlN, 0, gammaAlN, phi, C0);
    
    M_half = pagemtimes(M_Mid,M_Piezo);
    M_fullstack = pagemtimes(M_Piezo,M_half);
    
    % Propagation of the initial force vector at the sapphire face (F = 0)
    Fv_AlN = [0;vAlN]; %we also define the F at the sapphire to be zero as it is in contact with air
    VI = pagemtimes(M_fullstack,Fv_AlN);
    
    % Calculation of impedance from resultant I-V vecor
    Z_in = VI(1,:)./VI(2,:);
    
    %% S11 data prep
    [~ , mag_dbStack, ~ , ~ , phase_degStack] = aafunc_ZtoS11data(Z_in);
    %% Z data prep
    [mag_db_zStack, ~ , ~ , phase_deg_zStack] = aafunc_ZtoZdata(Z_in);

    mags(i,:) = mag_dbStack;
    phases(i,:) = phase_degStack;
    i = i+1;
end

f1 = figure('Color', 'w', 'Position', [100, 100, 900, 600]);
names = cell(N+1,1);
names(1) = {'AlN'};
i = 2;
for d = thickMid
    names(i) = {['AlN-resin-AlN d=', num2str(d)]};
    i = i+1;
end

% magnitude S11 dB
ax1 = subplot(2,1,1);
hold on
m1 = plot(f * 1e-9, mag_db,'r');
m2 = plot(f * 1e-9, mags);
legend(names);
ylabel('|S_{11}| [dB]');
% set(gca, 'XTickLabel', []);
grid on;
xlim tight
ylim padded

% phase S11 (degrees)
ax3 = subplot(2,1,2);
hold on
p1 = plot(f * 1e-9, phase_deg,'r');
p2 = plot(f * 1e-9, phases,pi);
legend(names);
xlabel('Frequency [GHz]');
ylabel('S_{11} Phase [°]');
ax3.Position(2)=0.22; % Y pos
grid on;
xlim tight

linkaxes([ax1, ax3], 'x');

