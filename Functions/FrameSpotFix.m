function [SpotFrameData] = FrameSpotFix(FrameData, VideoData, TimeInterval, varargin)
% [SpotFrameData] = FrameSpotFix(FrameData, VideoReader('SampleVideo.MP4), TimeInterval, 'ShowProgressBar', true)
% This function facilitates the "spot-fixes" an image by replacing a rectangular region with corresponding averaged image data over the specifeid time
% interval. I suggest you use an external video player to find the specific time intervals you wish to use where a particular region is clear of ants.
%
% INPUTS: FrameData    - The source image whose dimensions *must* match the dimensions in VideoReader('Filename')
%         VideoData    - A VideoReader object initialized with a file name to some MP4 file.
%         TimeInterval - A two element vector [t0, t1] signifying the start and end times of the source video to average from.
%
% OUTPUT: SpotFrameData - A modified image with the samem dimensions as FrameData
%
% OPTIONS:  ShowProgressBar - Displays a percentage based progress bar, useful for impatient users (like me) who like to see about how much longer
%                             the function will take :) 
%
%Example: OutputImage = FrameSpotFix(InputImage, VideoReader('SampleVideo.MP4'), [100 110]);
%          This example replaces a region in InputImage with the average data over the time interval 100 seconds to 110 seconds to generate the
%          output image.
%
% Copyright: FrankMadrid fmadr002[at]ucr[dot]com February 2019

%% INPUT VALIDATION
p = inputParser;

paramName     = 'FrameData';
validationFcn = @(x) validateattributes(x, {'uint8'}, {'size', [VideoData.Height VideoData.Width, 3]});
addRequired(p, paramName, validationFcn);

paramName     = 'VideoData';
validationFcn = @(x) validateattributes(x, {'VideoReader'}, {'nonempty', 'scalar'});
addRequired(p, paramName, validationFcn);

paramName     = 'TimeInterval';
validationFcn = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'vector', 'numel', 2, 'nonnegative', '<=' VideoData.Duration, 'increasing'});
addRequired(p, paramName, validationFcn);

paramName     = 'ShowProgressBar';
defaultVal    = false;
validationFcn = @(x) validateattributes(x, {'logical'}, {'nonempty', 'scalar'});
addParameter(p, paramName, defaultVal, validationFcn);

p.parse(FrameData, VideoData, TimeInterval, varargin{:});
INPUTS = p.Results;

%% BEGIN PROCESSING
MAXIMUM_PIXEL_INTENSITY = 255;
VideoData.CurrentTime   = TimeInterval(1);                                                  % Begin reading frame data at time 'BeginTime'
EstimatedFrames         = floor((TimeInterval(2) - TimeInterval(1)) * VideoData.FrameRate); % Number of frames to be read
AvgFrameData            = double(zeros(VideoData.Height, VideoData.Width));                 % Maintain average frame data

% Displays a progress bar
if(INPUTS.ShowProgressBar)
    waitFigure = waitbar(0, sprintf('Reading from timestamp %0.2f of %0.2f', VideoData.CurrentTime / VideoData.FrameRate, TimeInterval(2)), ...
        'Name', 'FrameSpotFix'); 
end
  
% Parse frame data while maintaining a running average.
FrameCount = 0;
while hasFrame(VideoData) && FrameCount <= EstimatedFrames
  
  % Update progress bar
  if(INPUTS.ShowProgressBar)
    waitbar(FrameCount / EstimatedFrames, waitFigure, sprintf('Reading from timestamp %0.2f of %0.2f', VideoData.CurrentTime, TimeInterval(2))); 
  end
  
  % Get/Convert/Accumulate Frame Data
  TempFrameData = double(readFrame(VideoData)) / MAXIMUM_PIXEL_INTENSITY;
  AvgFrameData = AvgFrameData + TempFrameData;
  
  % Increment counter variable
  FrameCount = FrameCount + 1;
end

% Generate frame data from average
AvgFrameData = uint8(AvgFrameData / FrameCount * MAXIMUM_PIXEL_INTENSITY);

% Destroy the progress bar
if(INPUTS.ShowProgressBar)
  delete(waitFigure);
end

% Initiate the spot fix tool
SpotFrameData = FrameData;
imgHandle = figure('Name', 'FrameSpotFix: Highlight an area to patch');
imshow(SpotFrameData);

% Prompt user for rectangle
R = drawrectangle;

% Update Frame
Rectangle.X = floor(R.Position(1):R.Position(1)+R.Position(3));
Rectangle.Y = floor(R.Position(2):R.Position(2)+R.Position(4));
SpotFrameData(Rectangle.Y,Rectangle.X,:) = AvgFrameData(Rectangle.Y,Rectangle.X,:);
delete(imgHandle);