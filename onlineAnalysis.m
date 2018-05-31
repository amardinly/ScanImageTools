function out = onlineAnalysis(vals,varargin);

flush=00;
if flush
    vars = whos;
    vars = vars([vars.persistent]);
    varName = {vars.name};
    clear(varName{:});
    out = [];
    return
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
persistent lastAcq saveFlag nZ i history frameRate movingAverage historyFrames BL_Frames postStimFrames writeLoc lastVol
out =[];       %required output to ScanImage
if isempty(history) %if this is the first r yb
    historyLength = 4; % seconds
    Bl_sec = 2;
    postStimSec = 2 ;
    frameRate = evalin('base','hSI.hRoiManager.scanFrameRate/numel(hSI.hFastZ.userZs)');
    nZ=evalin('base','numel(hSI.hFastZ.userZs)');
    movingAverage=3;
    saveFlag = false;
    historyFrames = round(historyLength*frameRate);
    BL_Frames = round(Bl_sec*frameRate);
    postStimFrames = round(postStimSec*frameRate);
    lastAcq=1;
    writeLoc ='Z:\holography\Data\Alan\DataTransferNode\data';%save directory to the server for me to read data

    history=single(nan(numel(vals),historyFrames));
    i = 0;
    lastVol = floor(evalin('base','hSI.hDisplay.stripeDataBuffer{3}.acqNumber')/nZ);
end

thisFrame = evalin('base','hSI.hScan2D.hAcq.hFpga.AcqStatusAcquiredFrames');
thisVol = floor(thisFrame/nZ);
%if we've completed a new volume, update history 
% store nans on frames that we've skipped so we fucking know we skipped
% them
if thisVol > lastVol;
    %update frame
    steps = thisVol - lastVol;
%      disp(['steps = ' num2str(steps)]);
    placeholder = nan(numel(vals),steps-1);
%      disp(['size placeholder = ' num2str(size(placeholder))])
    mVals = [placeholder vals];
%     disp(['size mVals = ' num2str(size(mVals))])
%     disp(['size history = ' num2str(size(history))])

    history(:, 1: end-steps) = history(:, steps+1:end);
    history(:,end-steps+1:end)=mVals;    
end
    
acqNumber = evalin('base','hSI.hDisplay.stripeDataBuffer{3}.acqNumber');

% disp([' acqNumber = ' num2str(acqNumber]))

if acqNumber > lastAcq;
    saveFlag = true;
    lastAcq = acqNumber;
end

%check speed of evalin base
frameNumberAcq = evalin('base','hSI.hDisplay.stripeDataBuffer{3}.frameNumberAcq');
frameNumberAcq = max([0 frameNumberAcq]);


%   disp([' frameNumberAcq = ' num2str(frameNumberAcq)])
%   disp([' frameRate = ' num2str(frameRate)])
%   disp([' saveFlag = ' num2str(saveFlag)])

if frameNumberAcq>= frameRate && saveFlag;  %if we're 1 sec past a stimulus...
delta=floor(frameRate);
% 
baseline = mean(history(:, end-(delta*2)+1:end-delta+1), 2);
signal = mean(history(:, end-delta:end),2);
dff = (signal - baseline) ./ baseline;


 save(writeLoc,'dff');
 disp('saved 1 file');
 saveFlag=false;
end

lastVol = thisVol;%update last volume
end
