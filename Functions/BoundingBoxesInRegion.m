function Count = BoundingBoxesInRegion(Regions, BoundingBoxes)
%% INPUT VALIDATION
p = inputParser;

paramName     = 'Regions';
validationFcn = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'ncols',4, 'nonnegative'});
addRequired(p, paramName, validationFcn);

paramName     = 'BoundingBoxes';
validationFcn = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'ncols',4, 'nonnegative'});
addRequired(p, paramName, validationFcn);

p.parse(Regions, BoundingBoxes);

%% PROCESSING

BoxCenters = floor([BoundingBoxes(:,2) + BoundingBoxes(:,4) * 0.5, BoundingBoxes(:,1) + BoundingBoxes(:,4) * 0.3]);
RegionYRange = [Regions(:,1) Regions(:,1) + Regions(:,3)];
RegionXRange = [Regions(:,2) Regions(:,2) + Regions(:,4)];

Count = zeros(1, size(Regions,1));
for r = 1 : size(Regions,1)
  Count(r) = sum(RegionXRange(r,1) <= BoxCenters(:,1) & BoxCenters(:,1) <= RegionXRange(r,2) & RegionYRange(r,1) <= BoxCenters(:,2) & BoxCenters(:,2) <= RegionYRange(r,2));
end
