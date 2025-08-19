function S11 = aafunc_magLorentzian(p, f)
    f0 = p(1); kint = p(2); kext = p(3);
    S11 = -1 - (2*kext) ./ (1i*(f - f0) - (kint + kext));
end