function [out, S11_fit] = aafunc_magfit_fromS11(f, S11, p_init, plotting)
    %param_init = [f0, f0_lb, f0_ub, kint, kint_lb, kint_ub, kext, kext_lb, kext_ub]
    
    S11_dB = 20*log10(abs(S11));
    
    p0 = [p_init(1),p_init(4), p_init(7)];
    lb = [p_init(2), p_init(5), p_init(8)];
    ub = [p_init(3), p_init(6), p_init(9)];
    
    fitfun_dB = @(p, fHz) 20*log10(abs(aafunc_magLorentzian(p, fHz) ));
    
    opts = optimoptions('lsqcurvefit','Display','iter','MaxIterations',5000,...
                        'MaxFunctionEvaluations',1e5,'TolFun',1e-12);
    
    [p_fit, ~] = lsqcurvefit(fitfun_dB, p0, f, S11_dB, lb, ub, opts);
    
    % Results
    S11_fit = aafunc_magLorentzian(p_fit, f);
    S11_fit_dB = 20*log10(abs(S11_fit));
    
    % Qs
    f0 = p_fit(1); kint = p_fit(2); kext = p_fit(3);
    Q =  f0 / (kint+kext);    % Hz/Hz → dimensionless
    Qint =  f0 / kint;
    Qext =  f0 / kext;

    out = [f0 kint kext Q Qint Qext];
    
    fprintf('f0 = %.6f GHz | kint = %.3f kHz | kext = %.3f kHz\n', f0/1e9, kint/1e3, kext/1e3);
    fprintf('QL = %.2f | Qint = %.2f | Qext = %.2f\n', Q, Qint, Qext);
    
    if plotting
        figure('Color','w');
        plot(f/1e9, S11_dB, '.', 'DisplayName','Measured |S11| (dB)'); hold on;
        plot(f/1e9, S11_fit_dB, 'r-', 'LineWidth',1.6, 'DisplayName','Fit');
        xlabel('Frequency (GHz)'); ylabel('|S_{11}| (dB)'); grid on; legend('Location','best');
    end
