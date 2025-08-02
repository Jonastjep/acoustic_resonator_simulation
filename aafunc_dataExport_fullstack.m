function [f, mag_db, phase_deg ,mag_db_z, phase_deg_z] = aafunc_dataExport_fullstack(fstart,fend,nb_pts,eta, unwrapped)
    arguments
        fstart (1,1) double = 0;
        fend   (1,1) double = 40;
        nb_pts (1,1) double = 1000000;
        eta (1,:) double = [1e-1, 1e-4, 1e-4, 1e-4, 0, 0];
        unwrapped (1,1) double = 0;
    end  % default value

    varFilename = 'allVariables_multiLossFullstack';

    %% Material and HBAR parameter creation (all stored in one file)
    file = aafunc_materialVariablesExport(fstart,fend,nb_pts,eta,varFilename);
    load(file);
    
    %% Transfer matrix impedance calculations
    % Front layer (Al electrode)
    Fv_Al = [0;vAl]; %vector od shape [F; v] used in network analysis. Because Al layer is the last, assumption is F = 0 and v = v_Al
    M_Al = aafunc_acousticTransferMatrix(ZAl, gammaAl);
    MFv_Al = pagemtimes(M_Al,Fv_Al);
    ZTop = MFv_Al(1,:)./MFv_Al(2,:);
    
    % Backing plate (Mo + Sapphire substrate)
    M_Sapph = aafunc_acousticTransferMatrix(ZSapph, gammaSapph);
    M_Mo = aafunc_acousticTransferMatrix(ZMo, gammaMo);
    M_Bulk = pagemtimes(M_Mo,M_Sapph);
    
    % Piezo transfer matrix and full stack
    M_Piezo = aafunc_acousticTransferMatrixPiezo(omega, ZAlN, ZTop, gammaAlN, phi, C0);
    M_fullStack = pagemtimes(M_Piezo,M_Bulk);
    
    % Propagation of the initial force vector at the sapphire face (F = 0)
    Fv_Sapph = [0;vSapph]; %we also define the F at the sapphire to be zero as it is in contact with air
    VI = pagemtimes(M_fullStack,Fv_Sapph);
    
    % Calculation of impedance from resultant I-V vecor
    Z_in = VI(1,:)./VI(2,:);
    
    %% S11 data prep
    [~ , mag_db, ~ , ~ , phase_deg] = aafunc_ZtoS11data(Z_in, unwrapped);
    %% Z data prep
    [mag_db_z, ~ , ~ , phase_deg_z] = aafunc_ZtoZdata(Z_in, unwrapped);

    delete(file)
