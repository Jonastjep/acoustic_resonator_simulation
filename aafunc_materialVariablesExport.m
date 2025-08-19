function varFilename = aafunc_materialVariablesExport(fstart,fend,nb_pts,eta, varFilename)
    %  eta = [eta_mAlN, eta_mSapph, eta_mMo, eta_mAl, eta_kT, eta_eps] and fstart,fend in GHz
    arguments
        fstart (1,1) double = 0;
        fend   (1,1) double = 40;
        nb_pts (1,1) double = 1000000;
        eta (1,:) double = [1e-4, 1e-4, 1e-4, 1e-4, 0, 0];
        varFilename {mustBeTextScalar} = 'allVariables';
    end  % default value

    %% Import constant lossless parameters
    constants;
    
    %% Simulation range parameters in GHz    
    f = linspace(fstart*1e9, fend*1e9, nb_pts);
    omega = 2*pi*f;
    
    %% Loss factors
    % Piezoelectric losses
    eta_mAlN = eta(1);
    eta_mSapph = eta(2);
    eta_mMo = eta(3);
    eta_mAl = eta(4);
    eta_kT = eta(5);
    eta_eps = eta(6);
    
    %% Dielectric constants
    eps_AlN = eps_AlN.*(1-1i*eta_eps); % lossy dielectric constant
    
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
    h = e33AlN/eps_AlN;
    
    varFilename = [varFilename, '.mat'];
    save(varFilename)