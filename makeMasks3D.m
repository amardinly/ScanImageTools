%% assign all 3 planes in base;

%top left, top right, bottom left
img{1}=ImageData;
img{2}=ImageData;
img{3}=ImageData;

%%
% define options
Opts.maxSourcesPerPlane = 200;
Opts.channel = 'red';

if strcmp(Opts.channel,'red');
    channel = 1;
elseif strcmp(Opts.channel,'green');
    channel = 2;
else
    disp('Error - select red or green');
end

for n = 1:numel(img);
imgData(:,:,n) = single(img{n}(:,:,channel));
end
Zplanes = hSI.hFastZ.userZs;
%% 
[sources]=extractROIs3(imgData,Opts);
imagingScanfield = hSI.hRoiManager.currentRoiGroup.rois(1).scanfields(1);
i=0;
for n = 1:numel(sources);
    theSources=sources{n};
    for k = 1:size(theSources,3);
        mask = theSources(:,:,k);
        intsf = scanimage.mroi.scanfield.fields.IntegrationField.createFromMask(imagingScanfield,mask);
        intsf.threshold = 100;
        introi = scanimage.mroi.Roi();
        introi.discretePlaneMode=1;
        introi.add(Zplanes(n), intsf);
        hSI.hIntegrationRoiManager.roiGroup.add(introi);
        i=i+1;
    end
end
disp(['Added ' num2str(i) ' sources to integration']);