function [Rectangles] = BinaryMapClustering(Frame, Level, varargin)
%% INPUT VALIDATION
p = inputParser;

paramName     = 'Frame';
validationFcn = @(x) validateattributes(x, {'uint8'}, {'size',[NaN,NaN,3]});
addRequired(p, paramName, validationFcn);

paramName     = 'Level';
validationFcn = @(x) validateattributes(x, {'numeric'}, {'scalar', '>=', 0, '<=', 1});
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
defaultVal    = 1.0;
validationFcn = @(x) validateattributes(x, {'numeric'}, {'real','>=',0,'<=',1.0});
addParameter(p,paramName,defaultVal,validationFcn);

paramName     = 'GreenMask';
defaultVal    = 1.0;
validationFcn = @(x) validateattributes(x, {'numeric'}, {'real','>=',0,'<=',1.0});
addParameter(p,paramName,defaultVal,validationFcn);

paramName     = 'BlueMask';
defaultVal    = 1.0;
validationFcn = @(x) validateattributes(x, {'numeric'}, {'real','>=',0,'<=',1.0});
addParameter(p,paramName,defaultVal,validationFcn);

p.parse(Frame, Level, varargin{:});
INPUTS = p.Results;
  
%% BEGIN
BinaryMap = im2bw(Frame,INPUTS.Level);   % Convert image to a binary iamge

if INPUTS.RedMask ~= 1.0
  BinaryMap = BinaryMap & Frame(:,:,1) < INPUTS.RedMask;
end
if INPUTS.GreenMask ~= 1.0
  BinaryMap = BinaryMap & Frame(:,:,2) < INPUTS.GreenMask * 255;
end
if INPUTS.BlueMask ~= 1.0
  BinaryMap = BinaryMap & Frame(:,:,2) < INPUTS.BlueMask;
end

S = zeros(size(BinaryMap));
for i = 1:numel(BinaryMap)
  if BinaryMap(i) == 1
    [I,J] = ind2sub(size(BinaryMap),i);
    R1 = I:min(size(BinaryMap,1),I+INPUTS.BoundingBoxLength);
    R2 = J:min(size(BinaryMap,2),J+INPUTS.BoundingBoxLength);
    S(i) = sum(sum(BinaryMap(R1,R2)))/(INPUTS.BoundingBoxLength*INPUTS.BoundingBoxLength);
  end
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