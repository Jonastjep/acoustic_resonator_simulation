function [f, mag_db, phase_deg ,mag_db_z, phase_deg_z] = aafunc_dataExport_piezo(fstart,fend,nb_pts,eta,unwrapped)
    arguments
        fstart (1,1) double = 0;
        fend   (1,1) double = 40;
        nb_pts (1,1) double = 1000000;
        eta (1,:) double = [1e-1, 1e-4, 1e-4, 1e-4, 0, 0];
        unwrapped (1,1) double = 0;
    end  % default value

    varFilename = 'allVariables_multiLossAlN';

    %% Material and HBAR parameter creation (all stored in one file)
    file = aafunc_materialVariablesExport(fstart,fend,nb_pts,eta,varFilename);
    load(file);
    delete(file);

    %% Transfer matrix impedance calculations    
    % Piezo transfer matrix (Zb = 0, only air on top)
    M_Piezo = aafunc_acousticTransferMatrixPiezo(omega, ZAlN, 0, gammaAlN, phi, C0);
    
    % Propagation of the initial force vector at other piezo face (F = 0)
    Fv_air = [0;vAlN];
    VI = pagemtimes(M_Piezo,Fv_air);
    
    % Calculation of impedance from resultant I-V vecor
    Z_in = VI(1,:)./VI(2,:);
    
    %% S11 data prep
    [~ , mag_db, ~ , ~ , phase_deg] = aafunc_ZtoS11data(Z_in, unwrapped);
    %% Z data prep
    [mag_db_z, ~ , ~ , phase_deg_z] = aafunc_ZtoZdata(Z_in, unwrapped);
    
    delete(file)
    
