clear

fstart  = 10;
fend  = 40;
nb_pts = 1000000;

%% Loss factor modifications
eta_mAl = 1e-3; %Loss factor

%% Simulation range parameters in GHz    
f = linspace(fstart*1e9, fend*1e9, nb_pts);
omega = 2*pi*f;

% Geometrical parameters
r_el = 100*1e-6;
A_el = pi*r_el.^2;
d = 500*1e-9;

%% Material constants
c33AlN = 395.*1e9;
rhoAlN = 3260; % Tirado thesis
e33AlN = 1.5; % C/m^2  Tirado thesis; piezoelectric stress constant

eps_0 = 8.85.*1e-12; %permittivity of free space
eps_r_AlN = 8.7; 
eps_AlN = eps_0.*eps_r_AlN; % isotropic in Z, so this is dielectric constant

c_33AlN = c33AlN + e33AlN^2./eps_AlN; % stiffened elastic constant
vAlN_ll = sqrt(c_33AlN./rhoAlN); %stiffened acoustic velocity (lossless)


C_0 = eps_AlN.*A_el./d;
% Rm = eta_mAl.*c_33AlN.*d./(A_el.*e33AlN.^2);
Rm = 2*eta_mAl.*c_33AlN.*d.^2./(pi.*vAlN_ll.*A_el.*e33AlN.^2);
Lm = c_33AlN.*d.^3/(A_el.*e33AlN.^2.*pi^2*vAlN_ll.^2);
Cm = A_el.*e33AlN.^2/(d*c_33AlN);

f_res = 1/(2*pi*sqrt(Lm*Cm));
fprintf('Resonance frequency: %.3f GHz\n', f_res * 1e-9);

Y = 1i.*omega.*C_0 + 1./(Rm + 1i.*omega.*Lm + 1./(1i*omega*Cm));
Z = 1./Y;

% Z0 = 50;
% Gamma_shunt  = (Z0.*Y - 1) ./ (Z0.*Y + 1);

[S11, mag_dB, mag_lin, phase_rad, phase_deg] = aafunc_ZtoS11data(Z);

figure;
ax1 = subplot(2,1,1);
plot(f * 1e-9, mag_dB);
ylabel('|Z_{in}|');
title('Z_{in} Magnitude testing');
set(gca, 'XTickLabel', []);
grid on;
xlim tight
ylim padded

ax3 = subplot(2,1,2);
plot(f * 1e-9, phase_deg);
xlabel('Frequency GHz');
ylabel('Z_{in} Phase [rad]');
ax3.Position(2)=0.22; % Y pos
grid on;
xlim tight

linkaxes([ax1, ax3], 'x');