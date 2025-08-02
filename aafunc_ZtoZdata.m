function [mag_dB, mag_lin, phase_rad, phase_deg] = aafunc_ZtoZdata(Z, unwrapped)
    arguments
        Z (1,:) double = [1i 1i 1i 1i 1i 1i 1i 1i 1i]
        unwrapped (1,1) double = 0;
    end  % default value

    mag_lin = abs(Z);
    mag_dB = 20 * log10(mag_lin);
    
    phase_rad = angle(Z);
    if unwrapped
        phase_rad = unwrap(phase_rad);
    end

    phase_deg = angle(Z) * (180/pi);
    if unwrapped
        phase_deg = unwrap(phase_deg);
    end
    