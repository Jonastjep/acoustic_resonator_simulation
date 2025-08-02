function [S11, mag_dB, mag_lin, phase_rad, phase_deg] = aafunc_ZtoS11data(Z, unwrapped)
    arguments
        Z (1,:) double = [1i 1i 1i 1i 1i 1i 1i 1i 1i]
        unwrapped (1,1) double = 0;
    end  % default value
    
    S11 = (Z - 50)./(Z + 50);
    mag_lin = abs(S11);  
    mag_dB = 20 * log10(mag_lin);
    
    phase_rad = angle(S11);
    if unwrapped
        phase_rad = unwrap(phase_rad);
    end

    phase_deg = angle(S11) * (180/pi);
    if unwrapped
        phase_deg = unwrap(phase_deg);
    end
