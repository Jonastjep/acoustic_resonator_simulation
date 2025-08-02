function aafunc_figureSave(fig, figName, place, Z, eta)
    % place variable should be 'multiPlots' or 'singlePlots'; 
    sprintf(['results/plots/',place,'/',figName])
    mkdir(['results/plots/',place,'/',figName])
    saveas(fig,['results/plots/',place,'/',figName,'/',figName],'fig');
    saveas(fig,['results/plots/',place,'/',figName,'/',figName],'epsc');
    print(['results/plots/',place,'/',figName,'/',figName], '-dpng', '-r300');
    save(['results/plots/',place,'/',figName,'/',figName],'Z','-mat')
    
    fileID = fopen(['results/plots/',place,'/',figName,'/lossFactorArchive.txt'],'w');
    fprintf(fileID,'[eta_mAlN, eta_mSapph, eta_mMo, eta_mAl, eta_kT, eta_eps]\r\n');
    fprintf(fileID,'% g', eta);
    fclose(fileID);