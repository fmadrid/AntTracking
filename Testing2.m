%% PARAMETERS
VIDEO_FILE           = 'C:\Users\fmadr\Documents\MATLAB\Datasets\AntVideos\Testing\Test_1080_24FPS_L.MP4';
TRACKING_FILE        = 'C:\Users\fmadr\Documents\MATLAB\Datasets\AntVideos\Testing\Tracking.mp4';
BOUNDING_BOX_LENGTH  = 30;
DIFFERENCE_THRESHOLD = 0.1;
MAX_ANT_COUNT        = 16;
BOUNDING_BOX_COLOR   = [255 0.0 0.0];

%% BEGIN
fprintf('==================================================\n');
fprintf(' Video Parsing\n');
fprintf('==================================================\n');

% Extract input video information
VideoData   = VideoReader(VIDEO_FILE);
TotalFrames = ceil(VideoData.FrameRate*VideoData.Duration);
fprintf('-----------------------------------\n');
fprintf(' Extracting Video Information\n');
fprintf('-----------------------------------\n');
fprintf('Reading video data:\n ');
fprintf('\tVideo File: %s\n',            VIDEO_FILE);
fprintf('\tResolution: %d x %d\n',       VideoData.Height, VideoData.Width);
fprintf('\tDuration:   %3.2f seconds\n', VideoData.Duration);
fprintf('\tFrames:     %d\n',            TotalFrames);

% Initialize output video
trackingWriter = VideoWriter(TRACKING_FILE, 'MPEG-4');
trackingWriter.FrameRate = VideoData.FrameRate;
open(trackingWriter);

% Initialize Loading Bar
title = 'Ant Tracking Video';
msg = 'Initializing Video';
W = waitbar(0, msg, 'Name', title, 'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
setappdata(W,'canceling',0);


CurrentFrameID = 1;
CurrentFrame = readFrame(VideoData);

% For each frame within the video
while hasFrame(VideoData)

  % If 'cancel' button was selected, terminate video processing
  if getappdata(W,'canceling')
        break
  end

  msg = ['Processing Frame: ' int2str(CurrentFrameID) ' of ' int2str(TotalFrames)];
  waitbar(CurrentFrameID/TotalFrames,W, msg, 'Name', 'Difference Video Maker');

  NextFrame = readFrame(VideoData);

  % Get rectangle information [X,Y,W,H] for sufficiently different movement
  Rectangles = BinaryMapClustering(imabsdiff(CurrentFrame,NextFrame),DIFFERENCE_THRESHOLD,...
    BOUNDING_BOX_LENGTH,DIFFERENCE_THRESHOLD, MAX_ANT_COUNT, 'GreenMask', 0.5);
  Frame = NextFrame;

  % Draw each rectangle to the frame
  for i = 1 : numel(Rectangles)
    BoundingBox = Rectangles{i};
    from_row = Clamp(BoundingBox(2),1,VideoData.Height);
    to_row   = Clamp(from_row + BoundingBox(3) - 1,1,VideoData.Height);
    from_col = Clamp(ceil(BoundingBox(1)),1,VideoData.Width);
    to_col   = Clamp(from_col + BoundingBox(4) - 1, 1,VideoData.Width);

    Frame(from_row:to_row, [from_col, to_col], 1) = BOUNDING_BOX_COLOR(1);
    Frame(from_row:to_row, [from_col, to_col], 2) = BOUNDING_BOX_COLOR(2);
    Frame(from_row:to_row, [from_col, to_col], 3) = BOUNDING_BOX_COLOR(3);

    Frame([from_row, to_row], from_col+1:to_col-1, 1) = BOUNDING_BOX_COLOR(1);
    Frame([from_row, to_row], from_col+1:to_col-1, 2) = BOUNDING_BOX_COLOR(2);
    Frame([from_row, to_row], from_col+1:to_col-1, 3) = BOUNDING_BOX_COLOR(3);
  end

  writeVideo(trackingWriter,Frame);

  CurrentFrame = NextFrame;
  CurrentFrameID = CurrentFrameID + 1;
end

delete(W);
fprintf('Wrote [%d] of [%d] frames to file.\n', CurrentFrameID, TotalFrames);
close(trackingWriter);

clear VIDEO_FILE IGNORE_THRESHOLD Difference FrameData NextFrameData VideoData writer GENERATE_DIFFERENCE_VIDEO I k t;
  
