%% Write Custom HoloRequest
theListofHolos='1';

loc=FrankenScopeRigFile;
holoRequest.objective = 20;
holoRequest.zoom = 1;
holoRequest.xoffset=0;
holoRequest.yoffset= 0;
holoRequest.hologram_config= 'DLS';
holoRequest.ignoreROIdata = 1;
lx= 514;
ly= 512;
MODxoffset = (holoRequest.xoffset/lx)*512;
MODyoffset = (holoRequest.yoffset/ly)*512;
    
rois = hSI.hIntegrationRoiManager.roiGroup.rois;
centerXY = zeros(length(rois),2);
for idx = 1:length(rois)
    centerXY(idx,1:2) = rois(idx).scanfields.centerXY;
    centerZ(idx,1) = rois(idx).zs;
end

pixelToRefTransform = hSI.hRoiManager.currentRoiGroup.rois(1).scanfields(1).pixelToRefTransform;
centerXY = scanimage.mroi.util.xformPoints(centerXY,inv(pixelToRefTransform));  
holoRequest.targets=[centerXY centerZ];

rois=HI3Parse(theListofHolos);

[listOfPossibleHolos convertedSequence] = convertSequence(rois);
holoRequest.rois=listOfPossibleHolos;
holoRequest.Sequence = {convertedSequence};
    
holoRequest.xoffset=MODxoffset;
holoRequest.yoffset=MODyoffset;
save([loc.HoloRequest 'holoRequest.mat'],'holoRequest');
save([loc.HoloRequest_DAQ 'holoRequest.mat'],'holoRequest');