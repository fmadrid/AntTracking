function [AvgFrameData] = GetAverageFrame(VideoData, varargin)
% AverageImage = GetAverageFrame(VideoReader('FILENAME'), TimeStart = 0, FrameCount = VideoData.Duration * VideoData.FrameRate)
% This function returns the average image data over some specified number of frames beginning at time TimeStart. By default, this function averages 
% the entire video though a user can specify a start time (in seconds) and a frame count.
%
% INPUT:    VideoData  - A VideoReader object initialized with a file name to some MP4 file.
%           TimeStart  - The time in seconds to begin averaging the video. Ensure this value is smaller than VideoData.Duration (i.e. the length
%                        of the video in seconds.
%           FrameCount - The number of frames to average beginning at TimeStart. By default, use all the frames (if you change the TimeStart, you
%                        should also change this parameter.)
%
% OPTIONS:  ShowProgressBar - Displays a percentage based progress bar, useful for impatient users (like me) who like to see about how much longer
%                             the function will take :)
%
% EXAMPLE: AverageImage = GetAverageFrame(VideoReader('SampleVideo.MP4'), 100, 600);
%          Samples the first 600 frames beginning at time stamp 100 seconds from videofile 'SampleVideo.MP4' averaging their values.
%
% Copyright: FrankMadrid fmadr002[at]ucr[dot]com February 2019
%% INPUT VALIDATION
p = inputParser;

paramName     = 'VideoData';
validationFcn = @(x) validateattributes(x, {'VideoReader'}, {'nonempty', 'scalar'});
addRequired(p, paramName, validationFcn);

paramName     = 'TimeStart';
defaultVal    = 0;
validationFcn = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'scalar', 'nonnegative', '<=', VideoData.Duration});
addParameter(p, paramName, defaultVal, validationFcn);

paramName     = 'FrameCount';
defaultVal    = VideoData.Duration * VideoData.FrameRate;
validationFcn = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'scalar', 'nonnegative', '<=', VideoData.Duration * VideoData.FrameRate});
addParameter(p, paramName, defaultVal, validationFcn);

paramName     = 'ShowProgressBar';
defaultVal    = false;
validationFcn = @(x) validateattributes(x, {'logical'}, {'nonempty', 'scalar'});
addParameter(p, paramName, defaultVal, validationFcn);

p.parse(VideoData, varargin{:});
INPUTS = p.Results;
assert((VideoData.Duration - INPUTS.TimeStart) * VideoData.FrameRate - INPUTS.FrameCount >= 0, '[GetAverageFrame] Only %0.2f frames of %0.2f frames remaining at time %0.4f\n', ...
    (VideoData.Duration - INPUTS.TimeStart) * VideoData.FrameRate, INPUTS.FrameCount, INPUTS.TimeStart);

%% BEGIN PROCESSING
MAXIMUM_PIXEL_INTENSITY = 255;  % Pixel components are in the range of [0,255]
VideoData.CurrentTime   = INPUTS.TimeStart; % This is required in the event that this VideoReader has been used to already ready frame data.
AvgFrameData = double(zeros(VideoData.Height, VideoData.Width)); % Preallocate memory for video data.

% Initializes the progress bar
if(INPUTS.ShowProgressBar)
    waitFigure = waitbar(0, sprintf('Reading frame %0.0f of %0.0f', 0, INPUTS.FrameCount), 'Name', 'Calculating Average Frame'); 
end

% Begins sampling from the video file
CurrentFrame = 0;
while hasFrame(VideoData) && CurrentFrame < INPUTS.FrameCount
  
  % Update the progress bar
  if(INPUTS.ShowProgressBar)
    waitbar(CurrentFrame / INPUTS.FrameCount, waitFigure, sprintf('Reading frame %0.0f of %0.0f', CurrentFrame, INPUTS.FrameCount)); 
  end
  
  % Read/Process/Accumulate video data
  FrameData = double(readFrame(VideoData)) / MAXIMUM_PIXEL_INTENSITY;
  AvgFrameData = AvgFrameData + FrameData;
  CurrentFrame = CurrentFrame + 1;
end

% Prepare averaged image
AvgFrameData = uint8(AvgFrameData / CurrentFrame * MAXIMUM_PIXEL_INTENSITY);

% Cleanup progress bar
if(INPUTS.ShowProgressBar)
  delete(waitFigure);
end

