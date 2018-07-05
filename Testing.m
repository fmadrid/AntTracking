%% PARAMETERS
VIDEO_FILE       = 'C:\Users\fmadr\Documents\MATLAB\Datasets\AntVideos\Testing\Test_1080_24FPS_L.MP4';
IGNORE_THRESHOLD = 50;
FRAME_RANGE      = [1 1];

EXTRACT_VIDEO        = true;
CONVERT_TO_FRAME     = true;
GET_DIFFERENCE_FRAME = true;

%% BEGIN
  fprintf("==================================================\n");
  fprintf(" Video Parsing\n");
  fprintf("==================================================\n");
  
%% Extract Video informaiton
if EXTRACT_VIDEO
  
  fprintf("-----------------------------------\n");
  fprintf(" Extracting Video Information\n");
  fprintf("-----------------------------------\n");
  fprintf("Reading video data: ");
  tic
  VideoData = VideoReader(VIDEO_FILE);
  timeElapsed = toc;
  fprintf("%f seconds\n", timeElapsed);
  fprintf("\tVideo File: %s\n", VIDEO_FILE);
  fprintf("\tResolution: %d x %d\n", VideoData.Height, VideoData.Width);
  fprintf("\tDuration:   %3.2f seconds\n", VideoData.Duration);
  fprintf("\tFrames:     %.0f\n", VideoData.FrameRate * VideoData.Duration);
end

%% Convert video to frame data
if CONVERT_TO_FRAME
  fprintf("-----------------------------------\n");
  fprintf(" Extracting Frame Data\n");
  fprintf("-----------------------------------\n");

  fprintf("Reading frame data: ");
  tic
  k=1;
  FrameData = struct('cdata',zeros(VideoData.Height,VideoData.Width,3,'uint8'),'colormap',[]);
  W = waitbar(k/(VideoData.FrameRate * VideoData.Duration),'Reading Frame Data');
  while hasFrame(VideoData)
    waitbar(k/(VideoData.FrameRate * VideoData.Duration),W,'Reading Frame Data');
    FrameData(k).cdata = readFrame(VideoData);
    k = k+1;
  end
  close(W);
  timeElapsed = toc;
  fprintf("%f seconds\n", timeElapsed);
end

%% Calculating Difference Frames
if GET_DIFFERENCE_FRAME
  fprintf("-----------------------------------\n");
  fprintf(" Calculating Difference Frames\n");
  fprintf("-----------------------------------\n");
  DifferenceData = FrameData;

  fprintf("Calculating difference data: ");
  W = waitbar(0,'Calculating Difference Data');
  tic
  for i = 2:length(FrameData)
    DifferenceData(i).cdata = FrameData(i).cdata- FrameData(i-1).cdata;
    waitbar(i/length(FrameData),W,'Calculating Difference Data');
  end
  close(W);
  timeElapsed = toc;
  fprintf("%f seconds\n", timeElapsed);
  clear FrameData;
end

%% Convert to RED Spectrum
fprintf("-----------------------------------\n");
fprintf(" Converting to RG Spectrum\n");
fprintf("-----------------------------------\n");
fprintf("\tThreshold: %d\n", IGNORE_THRESHOLD);
fprintf("\tRange:     [%d, %d]\n", FRAME_RANGE(1), FRAME_RANGE(2));
fprintf("\tProcessing Frames: ");

tic
 W = waitbar(0,'Calculating Frame Difference Data');
FrameData = struct('cdata',zeros(VideoData.Height,VideoData.Width,3,'uint8'),'colormap',[]);
for i = 1: length(DifferenceData)
  waitbar(i/length(DifferenceData),W,'Calculating Frame Difference Data');
  I = sum(DifferenceData(i + FRAME_RANGE(1)-1).cdata >= IGNORE_THRESHOLD,3) == 3;
  FrameData(i).cdata = uint8(I * 255);
  FrameData(i).cdata(:,:,2) = 0;
  FrameData(i).cdata(:,:,3) = 0;
end
close(W);
timeElapsed = toc;
fprintf("%f seconds\n", timeElapsed);
%clear DifferenceData;

%% Write Video
fprintf("-----------------------------------\n");
fprintf(" Writing to Video\n");
fprintf("-----------------------------------\n");
fprintf("\tWriting Video: ");
tic
writer = VideoWriter(['DifferenceRed_' int2str(IGNORE_THRESHOLD) '.mp4'], 'MPEG-4');
writer.FrameRate = VideoData.FrameRate;
open(writer)
W = waitbar(0,'Writing Video');
for i = 1:length(FrameData)
  waitbar(i/length(FrameData),W,'Writing Video');
  writeVideo(writer,FrameData(i));
end
close(W);
close(writer);
timeElapsed = toc;
fprintf("%f seconds\n", timeElapsed);