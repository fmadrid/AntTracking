function [Boxes] = GetBoundingBoxes(AverageFrame, Frame, varargin)
% 
%
% INPUTS: 
%
% OUTPUT: 
%
% OPTIONS:  
%
%Example: 
%
% Copyright: FrankMadrid fmadr002[at]ucr[dot]com February 2019

%% INPUT VALIDATION
p = inputParser;

paramName     = 'AverageFrame';
validationFcn = @(x) validateattributes(x, {'uint8'}, {'size', size(Frame)});
addRequired(p, paramName, validationFcn);

paramName     = 'Frame';
validationFcn = @(x) validateattributes(x, {'uint8'}, {'size', size(AverageFrame)});
addRequired(p, paramName, validationFcn);

paramName     = 'BinarizeThreshold';
defaultVal    = 0.25;
validationFcn = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'scalar', 'nonnegative', '<=', 1});
addOptional(p, paramName, defaultVal, validationFcn);

paramName     = 'AreaLimits';
defaultVal    = [100 1000];
validationFcn = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'vector', 'nonnegative', 'increasing', 'numel', 2});
addOptional(p, paramName, defaultVal, validationFcn);

p.parse(AverageFrame, Frame, varargin{:});
INPUTS = p.Results;

%% BEGIN PROCESSING
BW = im2bw(uint8(abs(double(AverageFrame) - double(Frame))), INPUTS.BinarizeThreshold);
BB = cell2mat(transpose(struct2cell(regionprops(BW, 'BoundingBox'))));
Boxes = BB(find(BB(:,3) .* BB(:,4) >= INPUTS.AreaLimits(1) & BB(:,3) .* BB(:,4) <= INPUTS.AreaLimits(2)),:);
