function sigma_ratio = catchpole_interp(As_bt, ts_t, data_dir)
% CATCHPOLE_INTERP  Interpolate the Catchpole diagram for sigma_cr/sigma_0.
%
%   sigma_ratio = catchpole_interp(As_bt, ts_t)
%   sigma_ratio = catchpole_interp(As_bt, ts_t, data_dir)
%
%   Uses digitised Catchpole curves stored as CSV files.
%   Each CSV has two columns: [As/(bt) , sigma_cr/sigma_0]
%   File names encode the ts/t ratio: e.g. '0.40.csv', '1.00.csv'
%
%   Inputs:
%       As_bt    - Stringer area ratio  A_s / (b * t)
%       ts_t     - Stringer-to-skin thickness ratio  t_s / t
%       data_dir - (optional) path to folder containing the CSVs
%                  Default: 'prev year code for wing\Wing'
%
%   Output:
%       sigma_ratio - stress ratio  sigma_cr / sigma_0

if nargin < 3
    data_dir = fullfile(fileparts(mfilename('fullpath')), ...
        'prev year code for wing', 'Wing');
end

% Clamp inputs to range of available data
if ts_t < 0.4;  ts_t = 0.4;  end
if ts_t > 1.4;  ts_t = 1.4;  end

% Determine bracketing curves
if ts_t < 0.9
    lo = 0.1 * floor(10 * ts_t);
    hi = lo + 0.1;
    lo_file = fullfile(data_dir, sprintf('0.%d0.csv', round(10*lo)));
    hi_file = fullfile(data_dir, sprintf('0.%d0.csv', round(10*hi)));
elseif ts_t < 1.0
    lo = 0.9;  hi = 1.0;
    lo_file = fullfile(data_dir, '0.90.csv');
    hi_file = fullfile(data_dir, '1.00.csv');
elseif ts_t < 1.2
    lo = 1.0;  hi = 1.2;
    lo_file = fullfile(data_dir, '1.00.csv');
    hi_file = fullfile(data_dir, '1.20.csv');
else
    lo = 1.2;  hi = 1.4;
    lo_file = fullfile(data_dir, '1.20.csv');
    hi_file = fullfile(data_dir, '1.40.csv');
end

lo_data = readmatrix(lo_file);
hi_data = readmatrix(hi_file);

lo_val = interp1(lo_data(:,1), lo_data(:,2), As_bt, 'linear', 'extrap');
hi_val = interp1(hi_data(:,1), hi_data(:,2), As_bt, 'linear', 'extrap');

sigma_ratio = interp1([lo, hi], [lo_val, hi_val], ts_t, 'linear', 'extrap');

% Ensure physically meaningful (> 0)
sigma_ratio = max(sigma_ratio, 0.01);

end
