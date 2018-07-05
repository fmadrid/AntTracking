%% PARAMETERS
VIDEO_FILE           = 'C:\Users\fmadr\Documents\MATLAB\Datasets\AntVideos\Testing\Test_1080_24FPS_L.MP4';
DIFFERENCE_FILE      = 'C:\Users\fmadr\Documents\MATLAB\Datasets\AntVideos\Testing\Difference.mp4';
TRACKING_FILE        = 'C:\Users\fmadr\Documents\MATLAB\Datasets\AntVideos\Testing\Tracking3.mp4';
BOUNDING_BOX_LENGTH  = 25;
DIFFERENCE_THRESHOLD = 0.1;
NUMBER_OF_ANTS       = 16;

GENERATE_DIFFERENCE_VIDEO = true;
PROCESS_DIFFERENCE_VIDEO = true;

%% BEGIN
fprintf('==================================================\n');
fprintf(' Video Parsing\n');
fprintf('==================================================\n');
  
%% GENERATE DIFFERENCE VIDEO
if GENERATE_DIFFERENCE_VIDEO
  
  % Extract input video information
  VideoData = VideoReader(VIDEO_FILE);
  fprintf('-----------------------------------\n');
  fprintf(' Extracting Video Information\n');
  fprintf('-----------------------------------\n');
  fprintf('Reading video data:\n ');
  fprintf('\tVideo File: %s\n', VIDEO_FILE);
  fprintf('\tResolution: %d x %d\n', VideoData.Height, VideoData.Width);
  fprintf('\tDuration:   %3.2f seconds\n', VideoData.Duration);
  fprintf('\tFrames:     %d\n', ceil(VideoData.FrameRate*VideoData.Duration));

  % Initialize output video
  trackingWriter = VideoWriter(TRACKING_FILE, 'MPEG-4');
  trackingWriter.FrameRate = VideoData.FrameRate;
  open(trackingWriter);
  
%   differenceWriter = VideoWriter(DIFFERENCE_FILE, 'MPEG-4');
%   differenceWriter.FrameRate = VideoData.FrameRate;
%   open(differenceWriter);
  
  % Initialize Loading Bar
  W = waitbar(0, 'Beginning video processing', 'Name', 'Difference Video Writer', 'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
  setappdata(W,'canceling',0);
  
  k = 1;
  Frame = readFrame(VideoData);
  
  while hasFrame(VideoData)
%     fprintf('Processing Frame: %d.\n', k);
    if getappdata(W,'canceling')
          break
    end

    waitbar(k/ceil(VideoData.FrameRate*VideoData.Duration),W, ['Processing Frame: ' int2str(k) ' of ' int2str(ceil(VideoData.FrameRate*VideoData.Duration))], 'Name', 'Difference Video Maker');
    
%     fprintf('\tReading Frame: ');
    tic
    NextFrame = readFrame(VideoData);
    elapsedTime = toc;
%     fprintf('%f\n', elapsedTime);
    
%     fprintf('\tGetting Rectangles: ');
    tic
    Rectangles = BinaryMapClustering(imabsdiff(Frame,NextFrame),BOUNDING_BOX_LENGTH,DIFFERENCE_THRESHOLD, 16);
    elapsedTime = toc;
%     fprintf('%f\n', elapsedTime);
    
%     fprintf('\tDrawing Rectangles: ');
    tic
    TempFrame = NextFrame;
    for i = 1 : numel(Rectangles)
      bb = Rectangles{i};
      from_row = max(1,bb(2));
      to_row = min(from_row + bb(3) - 1,1080);
      from_col = max(1,ceil(bb(1)));
      to_col = min(from_col + bb(4) - 1, 1920);
      red = [255, 0, 0];
      
      TempFrame(from_row:to_row, [from_col, to_col], 1) = red(1);
      TempFrame(from_row:to_row, [from_col, to_col], 2) = red(2);
      TempFrame(from_row:to_row, [from_col, to_col], 3) = red(3);
      
      TempFrame([from_row, to_row], from_col+1:to_col-1, 1) = red(1);
      TempFrame([from_row, to_row], from_col+1:to_col-1, 2) = red(2);
      TempFrame([from_row, to_row], from_col+1:to_col-1, 3) = red(3);
    end
    elapsedTime = toc;
%     fprintf('%f', elapsedTime)
    
%     fprintf('Writing to file: ');
    tic
    writeVideo(trackingWriter,TempFrame);
    elapsedTime = toc;
%     fprintf('%f\n', elapsedTime);
    Frame = NextFrame;
    k = k + 1;
  end
  
  delete(W);
  fprintf('Wrote [%d] of [%d] frames to file.\n', k, ceil(VideoData.FrameRate*VideoData.Duration));
  close(trackingWriter);
  
  
  clear VIDEO_FILE IGNORE_THRESHOLD Difference FrameData NextFrameData VideoData writer GENERATE_DIFFERENCE_VIDEO I k t;
  
end
