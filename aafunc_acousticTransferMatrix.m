function M = aafunc_acousticTransferMatrix(Z, gamma)
% with gamma = alpha*d+(omega/c)*d*1i (alpha being the acoustic attenuation in layer) and Z = rho*c*A
    N = numel(gamma);

    M = zeros(2, 2, N);
    M(1,1,:) = cos(gamma);
    M(1,2,:) = 1i*Z.*sin(gamma);
    M(2,1,:) = 1i*sin(gamma)./Z;
    M(2,2,:) = cos(gamma);