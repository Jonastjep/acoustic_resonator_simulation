%% Device parameters
% Geometrical parameters
r_el = 100*1e-6;
A_el = pi*r_el.^2;

% Layer thickness in meters
dAl = 100*1e-9;
dAlN = 500*1e-9;
dMo = 60*1e-9;
dSapph = 250*1e-6;

%% Loss factors
% Piezoelectric losses
eta_mAlN = 1e-1; % mechanical loss factor
eta_kT = 0; %
eta_eps = 0; 

% Substrate losses
eta_mSapph = 1e-4;
eta_mMo = 1e-4;
eta_mAl = 1e-4;

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
eps_AlN = eps_AlN.*(1-1i*eta_eps); %lossy dielectric

%% Piezo and stiffened coefficients
k_t = 0.065; % electromechanical coupling constant
e33AlN = 1.5; % C/m^2  Tirado thesis; piezoelectric stress constant
c_33AlN = c33AlN + e33AlN^2./eps_AlN; % stiffened elastic constant

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

%% Lossy wave vector
kAl = omega./vAl_ll.*(1+1i.*eta_mAl);
kAlN = omega./vAlN_ll.*(1-1i.*eta_mAlN);
kMo = omega./vMo_ll.*(1+1i.*eta_mMo);
kSapph = omega./vSapph_ll.*(1+1i.*eta_mSapph);

%% Lossy sound velocity in m/s 
vAl = vAl_ll./(1-1i.*eta_mAl);
vAlN = vAlN_ll./(1-1i.*eta_mAlN); %stiffened acoustic velocity with loss
vMo = vMo_ll./(1-1i.*eta_mMo);
vSapph =vSapph_ll./(1-1i.*eta_mSapph);

%% Phase evolution within a layer
% with alpha, beta not defined, but alpha = 
gammaAl = (omega./vAl).*dAl;
gammaAlN = (omega./vAlN).*dAlN;
gammaMo = (omega./vMo).*dMo ;
gammaSapph = (omega./vSapph).*dSapph;

%% Lossy characteristic acoustic impedance
% Lossy pure characteristic acoustic impedance
ZAl_noS = rhoAl.*vAl;
ZAlN_noS = rhoAlN.*vAlN; %stiffened characteristic acoustic impedance
ZMo_noS = rhoMo.*vMo;
ZSapph_noS = rhoSapph.*vSapph;

% Lossy material impedance normalized to electrode size
ZAl = A_el.*ZAl_noS;
ZAlN = A_el.*ZAlN_noS;
ZMo = A_el.*ZMo_noS;
ZSapph = A_el.*ZSapph_noS;

%% Device constants
C0 = A_el.*eps_AlN./dAlN; %dielectric capacitance (intrinsic capacitance of piezo actuator)
k_t_lossy = sqrt(k_t) .* (1-1i.*eta_kT);
k_t2 = k_t_lossy.^2;
phi = sqrt(vAlN.*C0.*ZAlN.*k_t2/dAlN);