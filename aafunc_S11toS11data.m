function [mag_dB, mag_lin, phase_rad, phase_deg] = aafunc_S11toS11data(S11, unwrapped)
    arguments
        S11 (1,:) double = [1i 1i 1i 1i 1i 1i 1i 1i 1i]
        unwrapped (1,1) double = 0;
    end  % default value

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
