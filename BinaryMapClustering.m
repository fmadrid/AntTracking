function [Rectangles] = BinaryMapClustering(Frame,varargin)
%% INPUT VALIDATION
p = inputParser;

  paramName     = 'Frame';
  validationFcn = @(x) validateattributes(x, {'uint8'}, {'size',[NaN,NaN,3]});
  addRequired(p, paramName, validationFcn);

  paramName     = 'BoundingBoxLength';
  defaultVal    = 15;
  validationFcn = @(x) validateattributes(x, {'numeric'}, {'integer', 'scalar', 'positive'});
  addOptional(p, paramName, defaultVal, validationFcn);

  paramName     = 'PercentageFill';
  defaultVal    = 0.5;
  validationFcn = @(x) validateattributes(x, {'numeric'}, {'real', 'scalar', '>',0, '<=',1});
  addOptional(p, paramName, defaultVal, validationFcn);
  
  paramName     = 'MaxCount';
  defaultVal    = 20;
  validationFcn = @(x) validateattributes(x, {'numeric'}, {'integer', 'scalar', 'positive'});
  addOptional(p, paramName, defaultVal, validationFcn);
  
  paramName     = 'RedMask';
  defaultVal    = [];
  validationFcn = @(x) validateattributes(x, {'uint8'}, {'size',[NaN,NaN,3]});
  addParamater(p, paramName, defaultVal, validationFcn);
  
  paramName     = 'BlueMask';
  defaultVal    = [];
  validationFcn = @(x) validateattributes(x, {'uint8'}, {'size',[NaN,NaN,3]});
  addParamater(p, paramName, defaultVal, validationFcn);
  
  p.parse(Frame, varargin{:});
  INPUTS = p.Results;
  
  %% BEGIN
  tic
  if isempty(INPUTS.RedMask)
    RedMask = ones(size(BinaryMap));
  end
  if isempty(INPUTS.RedMask)
    BlueMask = ones(size(BinaryMap));
  end
  
  BinaryMap = im2bw(Frame,0.10);   % Convert image to a binary iamge
  BinaryMap = BinaryMap & RedMask & BlueMask;
  
  S = zeros(size(BinaryMap));
  for i = 1:numel(BinaryMap)
    if BinaryMap(i) == 1
      [I,J] = ind2sub(size(BinaryMap),i);
      R1 = I:min(size(BinaryMap,1),I+INPUTS.BoundingBoxLength);
      R2 = J:min(size(BinaryMap,2),J+INPUTS.BoundingBoxLength);
      S(i) = sum(sum(BinaryMap(R1,R2)))/(INPUTS.BoundingBoxLength*INPUTS.BoundingBoxLength);
    end

%     [I,J] = ind2sub(size(BinaryMap),i);
%     if abs(size(BinaryMap,1) - I < INPUTS.BoundingBoxLength) || abs(size(BinaryMap,2) - J < INPUTS.BoundingBoxLength)
%       continue
%     end
%     R1 = I:min(size(BinaryMap,1),I+INPUTS.BoundingBoxLength);
%     R2 = J:min(size(BinaryMap,2),J+INPUTS.BoundingBoxLength);
%     S(i) = sum(sum(BinaryMap(R1,R2)))/(INPUTS.BoundingBoxLength*INPUTS.BoundingBoxLength);
  end

  Rectangles = {};
  newS = S;
  k = 0;
  while true
    k = k + 1;
    if k > INPUTS.MaxCount
      break;
    end
    
    [M,I] = max(newS(:));
    if M < INPUTS.PercentageFill || M == 0
      break;
    end
    [Y,X] = ind2sub(size(BinaryMap),I);
    Rectangles{end+1} = [X Y INPUTS.BoundingBoxLength INPUTS.BoundingBoxLength];
    newS(max(1,Y-INPUTS.BoundingBoxLength):min(size(BinaryMap,1),Y+INPUTS.BoundingBoxLength), max(1,X-INPUTS.BoundingBoxLength):min(size(BinaryMap,2),X+INPUTS.BoundingBoxLength)) = 0;
  end
  
end

%rectangle('Position',[X-WIDTH Y-WIDTH 2*WIDTH 2*WIDTH], 'LineWidth',2, 'EdgeColor','r');