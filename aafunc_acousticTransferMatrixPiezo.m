function M = aafunc_acousticTransferMatrixPiezo(omega, Z0, Zb, gamma, phi, C0)
    N = numel(omega);

    Q0 = cos(gamma) - 1 + 1i.*Zb.*sin(gamma)./Z0;

    M1 = zeros(2, 2, N);
    M1(1,1,:) = 1;
    M1(1,2,:) = 1i.*phi.^2./(omega*C0);
    M1(2,1,:) = 1i.*omega.*C0;
    M1(2,2,:) = 0;

    M2 = zeros(2, 2, N);
    M2(1,1,:) = cos(gamma)+1i.*Zb.*sin(gamma)./Z0;
    M2(1,2,:) = Zb.*cos(gamma)+1i.*Z0.*sin(gamma);
    M2(2,1,:) = 1i.*sin(gamma)./Z0;
    M2(2,2,:) = 2.*(cos(gamma)-1) + 1i.*Zb.*sin(gamma)./Z0;

    scaling = reshape(1 ./ (phi .* Q0), 1, 1, []);
    M = scaling.*pagemtimes(M1,M2);