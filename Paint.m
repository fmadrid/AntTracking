function [M] = Paint(Frame)

M = logical(zeros(size(Frame)));

%Original
M = M | Frame;


% Left (First n-1 cols)
M(:,1:end-1) = M(:,1:end-1) | Frame(:, 2:end);

% Top (First n-1 rows)
M(1:end-1,:) = M(1:end-1,:) | Frame(2:end,:);

% Right (First n-1 cols)
M(:,2:end) = M(:,2:end) | Frame(:, 1:end-1);

% Down (Last n-1 rows)
M(2:end,:) = M(2:end,:) | Frame(1:end-1,:);

% Top-left
M(1:end-1,1:end-1) = M(1:end-1,1:end-1) | Frame(2:end,2:end);

% Top-Right
M(1:end-1,2:end) = M(1:end-1,2:end) | Frame(2:end,1:end-1);

% Bottom-Right
M(2:end,2:end) = M(2:end,2:end) | Frame(1:end-1,1:end-1);


% Bottom-Left
M(2:end,1:end-1) = M(2:end,1:end-1) | Frame(1:end-1, 2:end);


end

