function F = farrar_interp(As_bt, ts_t, data_dir)
% FARRAR_INTERP  Interpolate the Farrar efficiency-factor diagram.
%
%   F = farrar_interp(As_bt, ts_t)
%   F = farrar_interp(As_bt, ts_t, data_dir)
%
%   Uses digitised Farrar curves stored as CSV files.
%   File names are the Farrar factor * 100:  '50.csv' ... '95.csv'
%   Each CSV has columns: [As/(bt) , ts/t]
%
%   Inputs:
%       As_bt    - Stringer area ratio  A_s / (b * t)
%       ts_t     - Stringer-to-skin thickness ratio  t_s / t
%       data_dir - (optional) path to folder containing the CSVs
%
%   Output:
%       F        - Farrar efficiency factor (typically 0.5 - 0.95)

if nargin < 3
    data_dir = fullfile(fileparts(mfilename('fullpath')), ...
        'prev year code for wing', 'Wing');
end

% Available Farrar factor curves
F_vals = [0.50, 0.60, 0.70, 0.75, 0.80, 0.85, 0.90, 0.95];
F_files = {'50.csv','60.csv','70.csv','75.csv','80.csv','85.csv','90.csv','95.csv'};

% Read all digitised curves and build scattered interpolant
x_all = [];
y_all = [];
v_all = [];

for k = 1:length(F_vals)
    data = readmatrix(fullfile(data_dir, F_files{k}));
    n_pts = size(data, 1);
    x_all = [x_all; data(:,1)];   %#ok<AGROW>  % As/(bt)
    y_all = [y_all; data(:,2)];   %#ok<AGROW>  % ts/t
    v_all = [v_all; repmat(F_vals(k), n_pts, 1)]; %#ok<AGROW>
end

SI = scatteredInterpolant(x_all, y_all, v_all, 'linear', 'nearest');
F  = SI(As_bt, ts_t);

% Clamp to physical range
F = max(min(F, 0.98), 0.40);

end
