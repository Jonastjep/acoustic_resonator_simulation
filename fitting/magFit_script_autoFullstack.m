clear

clear

%% Simulation range parameters
% in GHz

nb_pts = 4000;

step = 0.022435;

for i = 1:5
    fstart = 0.53839+step*i;
    fend = 0.538443+step*i; 

    f = linspace(fstart*1e9, fend*1e9, nb_pts);
    
    %% Simulation Loss factors
    %  eta = [eta_mAlN, eta_mSapph, eta_mMo, eta_mAl, eta_kT, eta_eps] and fstart,fend in GHz
    eta = [1e-5, 4e-7, 1e-4, 1e-4, 0, 0];
    
    [Z_in, M_fullstack] = aafunc_fullstackMatrix(fstart,fend,nb_pts,eta);
    
    %% S11 data prep
    [S11 , mag_db, ~ , ~ , phase_deg] = aafunc_ZtoS11data(Z_in);
    
    f0 = mean(f);
    f0_lb = f0 - 5e5;
    f0_ub = f0 + 5e5;
    
    kint = 1e+04;
    kext = 1e+04;
    
    param_init = [f0, f0_lb, f0_ub, kint, 0, inf, kext, 0, inf];
    
    [out, S11_fit] = aafunc_magfit_fromS11(f, S11, param_init, 1);
end