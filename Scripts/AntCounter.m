%% INFORMATION
% This script exemplifies how to use many (or all) of the ant tracking functions in the project. A user may simply modify the values of the PARAMETERS
% to run various experiments, or combine the specific functions to customize their own experiment.
%
% Copyright fmadr002[at]ucr[dot]edu March 1st 2019

%% PARAMETERS
% Script
VIDEO_FILENAME    = 'C:\Users\fmadr\Documents\MATLAB\Projects\AntTracking\SampleVideo.MP4'; % MP4 video file location
VARIABLE_FILENAME = 'C:\Users\fmadr\Documents\MATLAB\Projects\AntTracking\Experiment.mat';  % Experiment data output location
SHOW_PROGRESS_BAR =  true; % Enable if you are sitting at the computer and want to see the progress of the algorithm or disable for a minor
                           % increase to performance

% Average Frame
% The speed of the algorithm is dependent on the resolution of the video and the number of frames. Approximately 8000 frames at a resolution of 1920 x 1080 takes about 3.5 minutes.
START_TIME_REFERENCE       = 0;   % Some real-valued time step less than the video duration
NUMBER_OF_FRAMES_REFERENCE = -1;  % The more frames the better but the longer it will take. Use -1 for ALL FRAMES

% Get Bounding Box
BINARY_THRESHOLD = 0.25; % How sensitive the algorithm is to fluctuations in the image data (i.e. detecting movement. Recommended Range: [0.2 0.35]
AREA_LB          = 100;  % Minimum area threshold of the ant bounding box. Recommended Value: 100
AREA_UB          = 1000; % Maximum area threshold of the ant bounding box. Recommended Value: 1000

% Ant Counting
REGIONS                   = 4;   % Number of specific regions to count ants
START_TIME_COUNTING       = 0;   % Some real-valued time step to begin the ant counting
NUMBER_OF_FRAMES_COUNTING = -1; % The number of frames in which to count the ants.

%% Step 1 - Preproecssing
% The objective is to get a base frame devoid of any ants to more easily count the ants in Step 2.

VideoData = VideoReader(VIDEO_FILENAME); % Facilitates the reading from the video file (be sure to set VideoData.CurrentTime to 0 if you top and start reading)
if(NUMBER_OF_FRAMES_REFERENCE == -1)
  AverageFrame = GetAverageFrame(VideoData, 'TimeStart', START_TIME_REFERENCE, 'FrameCount', floor(VideoData.Duration * VideoData.FrameRate), 'ShowProgressBar', SHOW_PROGRESS_BAR);
else
  AverageFrame = GetAverageFrame(VideoData, 'TimeStart', START_TIME_REFERENCE, 'FrameCount', NUMBER_OF_FRAMES_REFERENCE, 'ShowProgressBar', SHOW_PROGRESS_BAR);
end

% Using an external video player (e.g. VLC Media Player) scrub through the video to find timesteps where the regions you wish to spot fix is devoid of ants. Get a start and end time.
input = 'Yes';
CleanFrame = AverageFrame;
while(strcmp(input,'Yes'))
  figHandle = DisplayImage(CleanFrame, 'Average Frame');
  input = questdlg('Run spot fix on frame data?');
  
  if(ishandle(figHandle))
      delete(figHandle);
  end
  
  switch(input)
    case 'Yes'
      input1 = inputdlg("Start Time: ");
      input2 = inputdlg("End Time: ");
      CleanFrame = FrameSpotFix(AverageFrame, VideoData, [str2num(input1{1}), str2num(input2{1})], 'ShowProgressBar', SHOW_PROGRESS_BAR);
    case 'No'
      break;
    case 'Cancel'
      return;
  end
    
end

%% Step 2 - Ant Counting
% This steps counts the number of ants in each frame by subtracting the 'CleanFrame' from each frame in the video to generate a difference frame. Any differences with an appropriate bounding box area is assumed to be an ant.

Regions = PromptRegions(REGIONS, CleanFrame); % Get the specific regions to count the ants in
VideoData = ResetVideoReader(VideoData);

if NUMBER_OF_FRAMES_COUNTING == -1
  MaxFrameCount = floor((VideoData.Duration - START_TIME_COUNTING) * VideoData.FrameRate);
else
  MaxFrameCount = NUMBER_OF_FRAMES_COUNTING;
end

% Initializes the progress bar
if SHOW_PROGRESS_BAR
  waitFigure = waitbar(0, sprintf('Processing frame %0.0f of %0.0f', 0, MaxFrameCount), 'Name', 'Counting the Ants'); 
end

Count        = zeros(MaxFrameCount-1, REGIONS);
CurrentFrame = 1;
while hasFrame(VideoData) && CurrentFrame <= MaxFrameCount
  if ishandle(waitFigure)
    waitbar(CurrentFrame / MaxFrameCount, waitFigure, sprintf('Processing frame %0.0f of %0.0f', CurrentFrame, MaxFrameCount)); 
  end
  BB                    = GetBoundingBoxes(CleanFrame, readFrame(VideoData), 'BinarizeThreshold', BINARY_THRESHOLD, 'AreaLimits', [AREA_LB AREA_UB]);
  Count(CurrentFrame,:) = BoundingBoxesInRegion(Regions, BB);
  CurrentFrame          = CurrentFrame + 1;
end
if ishandle(waitFigure)
  delete(waitFigure)
end

%% Step 3 - Cleanup
% Saves necessary and deletes unnecessasry variables
outputFile = fopen('Experiment.txt','w');
fprintf(outputFile, '==================================================\n');
fprintf(outputFile, '  Ant Counter (version 1.0)                       \n');
fprintf(outputFile, '==================================================\n\n');
fprintf(outputFile, '---PARAMETERS---\n');
fprintf(outputFile, 'VIDEO_FILENAME:             %s\n',    VIDEO_FILENAME);
fprintf(outputFile, 'VARIABLE_FILENAME:          %s\n',    VARIABLE_FILENAME);
fprintf(outputFile, 'SHOW_PROGRESS_BAR:          %d\n',    SHOW_PROGRESS_BAR);
fprintf(outputFile, 'START_TIME_REFERENCE:       %0.4f\n', START_TIME_REFERENCE);
fprintf(outputFile, 'NUMBER_OF_FRAMES_REFERENCE: %0.0f\n', NUMBER_OF_FRAMES_REFERENCE);
fprintf(outputFile, 'BINARY_THRESHOLD:           %0.4f\n', BINARY_THRESHOLD);
fprintf(outputFile, 'AREA_LB:                    %0.0f\n', AREA_LB);
fprintf(outputFile, 'AREA_UB:                    %0.0f\n', AREA_UB);
fprintf(outputFile, 'REGIONS:                    %0.0f\n', REGIONS);
fprintf(outputFile, 'START_TIME_COUNTING:        %0.4d\n', START_TIME_COUNTING);
fprintf(outputFile, 'NUMBER_OF_FRAMES_COUNTING:  %0.0d\n', NUMBER_OF_FRAMES_COUNTING);
fprintf(outputFile, '\n');
fprintf(outputFile, '---RESULTS---\n');
for r = 1:size(REGIONS,2)
  fprintf(outputFile, '\tRegion:   %0.0f\n', r);
  fprintf(outputFile, '\t\tMin:    %0.0f\n', min(Count(:,r)));
  fprintf(outputFile, '\t\tMax:    %0.0f\n', max(Count(:,r)));
  fprintf(outputFile, '\t\tMean:   %0.2f\n', mean(Count(:,r)));
  fprintf(outputFile, '\t\tStdDev: %0.2f\n', std(Count(:,r)));
end
fclose(outputFile);

save(VARIABLE_FILENAME, 'CleanFrame', 'Count');
clear AREA_LB AREA_UB AverageFrame BB BINARY_THRESHOLD CurrentFrame input MaxFrameCount NUMBER_OF_FRAMES_COUNTING ...
  NUMBER_OF_FRAMES_REFERENCE Regions REGIONS SHOW_PROGRESS_BAR START_TIME_COUNTING START_TIME_REFERENCE VARIABLE_FILENAME VIDEO_FILENAME ...
  VideoData waitFigure figHandle input1 input2 k outputFile r X


%% Helper Functions

function VideoData = ResetVideoReader(VideoData)
  VideoData.CurrentTime = 0;
end

function Regions = PromptRegions(RegionCount, Frame)
  Regions = zeros(RegionCount, 4);
  figHandle = DisplayImage(Frame, 'Select a region');
  for r = 1:RegionCount
    R = drawrectangle;
    Regions(r, :) = R.Position;
  end
  if ishandle(figHandle)
    delete(figHandle)
  end
end

function figHandle = DisplayImage(Image, str)
  figHandle = figure('Name', str);
  imshow(Image);
end