clear

load("BVD_data.mat");

f0 = mean(freq);

f0_init = 1.1790e+10;
f0_lb = f0_init - 1e6;
f0_ub = f0_init + 1e6;

kint = 2e+07;
kext = 2e+07;

strt = 13000;
ed = strt+5000;

f = freq(strt:ed,1);
S11 = S(strt:ed,5);

param_init = [f0, f0_lb, f0_ub, kint, 0, inf, kext, 0, inf];

[out, S11_fit] = aafunc_magfit_fromS11(f, S11, param_init, 1);