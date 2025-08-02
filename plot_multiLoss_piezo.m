clear
saveplot = 0;

unwrapped = 1;

%% Simulation range parameters
% in GHz
fstart = 10.2768;
fend = 12.5;
nb_pts = 10000;

% placeholder names for title in plot
mech = '\eta_m'; % char array for mecanical loss factor
diel = ['\eta_',char(949)]; % char for writing eta_eps because \varepsilon doesn't exist in tex
piezCoupl = '\eta_{k_t}';

%used to add an indication of what variable was changed
varnameForFilename = "eta_mAlN_Em1toEm7"; 
varnameForPltTitle = [mech, ' AlN'];

eta_m_AlN_all = [1e-2 1e-3 1e-4 1e-5 1e-6];
eta_eps_AlN_all = [9.9e-1 5e-1 2.5e-1 1e-1 1e-2 1e-4 0];

lossArr = eta_eps_AlN_all; %REMEMBER TO CHANGE THE VAR IN THE LOOP IF YOU GO FOR ANOTHER LOSS MECHANISM

strs = compose("%.0e", lossArr); %for legend purposes, transforms array into cell with strings inside

N = numel(lossArr);
f = linspace(fstart*1e9, fend*1e9, nb_pts);
mag_dB_all = zeros(N,nb_pts);
phase_deg_all = zeros(N,nb_pts);
mag_dB_z_all = zeros(N,nb_pts);
phase_deg_z_all = zeros(N,nb_pts);

i = 1;
for loss = lossArr
    %  eta = [eta_mAlN, eta_mSapph, eta_mMo, eta_mAl, eta_kT, eta_eps]
    eta = [1e-4, 1e-4, 1e-4, 1e-4, 0, loss]; %REMEMBER TO CHANGE HERE IF YOU GO FOR ANOTHER LOSS MECHANISM
    [f, mag_dB, phase_deg,mag_dB_z,phase_deg_z] = aafunc_dataExport_piezo(fstart,fend,nb_pts,eta,unwrapped);
    mag_dB_all(i, :) = mag_dB;
    phase_deg_all(i, :) = phase_deg;
    mag_dB_z_all(i, :) = mag_dB_z;
    phase_deg_z_all(i, :) = phase_deg_z;
    i = i+1;
end

f1 = figure("Color", "w", "Position", [100, 100, 1700, 600]);

% magnitude S11 dB
ax1 = subplot(2,2,1);
plot(f*1e-9, mag_dB_all);
% yline(0,"k--",Layer="bottom",Alpha=0.5)
ylabel("|S_{11}| [dB]");
title(sprintf('Bode Plots of S_{11} with varying %s', varnameForPltTitle),FontSize=13);
legend(strs);
lgd.Layout.Location = "best";
set(gca, "XTickLabel", []);
grid on;
xlim tight
ylim padded

% phase of S11 (degrees)
ax3 = subplot(2,2,3);
plot(f*1e-9, phase_deg_all);
% yline(0,"k--",Layer="bottom",Alpha=0.5)
xlabel("Frequency [GHz]");
ylabel("S_{11} Phase [°]");
legend(strs);
ax3.Position(2)=0.22; % Y pos
grid on;
xlim tight
ylim padded

% magnitude Z dB
ax2 = subplot(2,2,2);
plot(f*1e-9, mag_dB_z_all);
% yline(0,"k--",Layer="bottom",Alpha=0.5)
ylabel("|Z_{in}| [dB\Omega]");
title(sprintf('Bode Plots of Z_{in} with varying %s', varnameForPltTitle),FontSize=13);
set(gca, "XTickLabel", []);
legend(strs);
ax2.Position(1)=0.52; %% position =[x_position y_position widht length] all are in some unit
grid on;
xlim tight
ylim padded

% phase of Z (degrees)
ax4 = subplot(2,2,4);
plot(f*1e-9, phase_deg_z_all);
% yline(0,"k--",Layer="bottom",Alpha=0.5)
xlabel("Frequency [GHz]");
ylabel("Z_{in} Phase [°]");
legend(strs);
ax4.Position(1)=0.52; % X pos
ax4.Position(2)=0.22; % Y pos
grid on;
xlim tight
ylim padded

linkaxes([ax1, ax3], "x");
linkaxes([ax2, ax4], "x");

if saveplot
    fstartstr = strrep(sprintf("%.3f", fstart), ".", "-");
    fendstr = strrep(sprintf("%.3f", fend), ".", "-");
    figName = sprintf('S11_Z_%sto%sGHz_Bode_piezMultiLoss_%s',fstartstr,fendstr,varnameForFilename);

    mkdir(['results/plots/multiPlots/',figName])
    saveas(f1,['results/plots/multiPlots/',figName,'/',figName],'fig');
    saveas(f1,['results/plots/multiPlots/',figName,'/',figName],'epsc');
    print(['results/plots/multiPlots/',figName,'/',figName], '-dpng', '-r300');
    save(['results/plots/multiPlots/',figName,'/',figName],'mag_dB_all','mag_dB_z_all','phase_deg_all','phase_deg_z_all','lossArr','-mat')

    fileID = fopen(['results/plots/multiPlots/',figName,'/lossFactorsArchive.txt'],'w');
    fprintf(fileID,'Format: eta = [eta_mAlN, eta_mSapph, eta_mMo, eta_mAl, eta_kT, eta_eps]\r\n');
    fprintf(fileID,'[%.0e, %.0e, %.0e, %.0e, %.0e, %.0e]\r\n', eta);
    fprintf(fileID,'\r\nLoss factor values that were plotted:\r\n');
    fprintf(fileID,'% g',lossArr);
    fclose(fileID);
end