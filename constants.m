%% Device parameters
% Geometrical parameters
r_el = 100*1e-6;
A_el = pi*r_el.^2;

% Layer thickness in meters
dAl = 100*1e-9;
dAlN = 500*1e-9;
dMo = 60*1e-9;
dSapph = 250*1e-6;

%% Material density in kg/m^3
rhoAl = 2695; % Tirado thesis
rhoAlN = 3260; % Tirado thesis
rhoMo = 10200; % Tirado thesis
rhoSapph = 3980; % just factual

%% Elastic coefficients c33 (N/m^2) -> 1 newton/square meter = 1.0E-9 GPa
c33Al = 107.9.*1e9;      % Tirado thesis c11 = E(1-P)/((1+P)(1-2P)); E is youngs modulus and P is poisson ratio
c33AlN = 395.*1e9;      % Tirado thesis
c33Mo = 449.2.*1e9;       % Tirado thesis
c33Sapph = 503.3.*1e9;    % Gladden et al.

%% Dielectric constants
eps_0 = 8.85.*1e-12; %permittivity of free space
eps_r_AlN = 8.7; 
eps_AlN = eps_0.*eps_r_AlN; % isotropic in Z, so this is dielectric constant

%% Piezo and stiffened coefficients
k_t = 0.065; % electromechanical coupling constant
e33AlN = 1.5; % C/m^2  Tirado thesis; piezoelectric stress constant
c_33AlN = c33AlN + e33AlN^2./eps_AlN; % stiffened lossless elastic constant

%% Lossless sound velocity in m/s 
vAl_ll = sqrt(c33AlN./rhoAl);
vAlN_ll = sqrt(c_33AlN./rhoAlN); %stiffened acoustic velocity
vMo_ll = sqrt(c33Mo./rhoMo);
vSapph_ll = sqrt(c33Sapph./rhoSapph);

%% Lossless pure characteristic acoustic impedance
ZAl_ll = rhoAl.*vAl_ll;
ZAlN_ll = rhoAlN.*vAlN_ll; %stiffened characteristic acoustic impedance
ZMo_ll = rhoMo.*vMo_ll;
ZSapph_ll = rhoSapph.*vSapph_ll;