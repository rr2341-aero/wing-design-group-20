function [best, sweep_results] = lower_panel_optimise(p, loads, ssr_upper)
% LOWER_PANEL_OPTIMISE  Sweep lower-panel stringer parameters for minimum mass.
%
%   [best, sweep_results] = lower_panel_optimise(p, loads, ssr_upper)
%
%   Iterates over:
%       n_root  - number of stringers at root
%       h       - stringer web height [mm]
%       ts      - stringer thickness [mm]
%
%   For each combination, runs lower_panel_design() and records mass_total
%   (skin + stringer).  The rib positions are inherited from ssr_upper so
%   the upper and lower panels share the same structural frame.
%
%   Inputs:
%       p         - wing_params() struct
%       loads     - wing_loads() struct (positive-g case)
%       ssr_upper - ssr_design() result struct (provides rib positions)
%
%   Outputs:
%       best          - struct with optimal stringer params & mass
%       sweep_results - struct with mass_grid for carpet plotting
%
%   PARALLELISED VERSION: uses parfor over all parameter combinations.
%   Requires the Parallel Computing Toolbox.
%   Opens a parallel pool automatically if one is not already running.

%% ===================== Define Sweep Ranges =====================
n_range  = 4:2:18;             % Number of lower stringers at root
h_range  = 15:5:65;            % Stringer web height [mm]
ts_range = [1.5, 2.0, 2.5];   % Stringer thickness [mm]
r_sfw    = 0.3;                % Flange/web ratio (fixed)

%% ===================== Initialise Storage =====================
n_n  = length(n_range);
n_h  = length(h_range);
n_ts = length(ts_range);

total_runs = n_n * n_h * n_ts;

fprintf('Lower Panel Optimisation: %d combinations to evaluate\n', total_runs);
fprintf('Sweep ranges:\n');
fprintf('  n_root : %d to %d\n',       n_range(1),  n_range(end));
fprintf('  h      : %.0f to %.0f mm\n', h_range(1),  h_range(end));
fprintf('  ts     : %.1f to %.1f mm\n', ts_range(1), ts_range(end));

%% ===================== Start / reuse Parallel Pool =====================
pool = gcp('nocreate');
if isempty(pool)
    fprintf('Starting parallel pool...\n');
    pool = parpool('local');
end
fprintf('Running parallel sweep (%d workers)...\n', pool.NumWorkers);

%% ===================== Flatten parameter grid =====================
[grid_n, grid_h, grid_ts] = ndgrid(1:n_n, 1:n_h, 1:n_ts);
grid_n  = grid_n(:);
grid_h  = grid_h(:);
grid_ts = grid_ts(:);

%% ===================== Preallocate result arrays =====================
mass_flat   = NaN(total_runs, 1);
valid_flat  = false(total_runs, 1);
result_flat = cell(total_runs, 1);

%% ===================== Parallel Sweep =====================
parfor k = 1:total_runs
    i_n  = grid_n(k);
    i_h  = grid_h(k);
    i_ts = grid_ts(k);

    stringer_lower = struct( ...
        'n_root', n_range(i_n),  ...
        'ts',     ts_range(i_ts), ...
        'h',      h_range(i_h),  ...
        'r_sfw',  r_sfw );

    try
        res = local_lower_wrapper(p, loads, ssr_upper, stringer_lower);

        if isfinite(res.mass_total) && res.mass_total > 0
            mass_flat(k)   = res.mass_total;
            valid_flat(k)  = true;
            result_flat{k} = res;
        end
    catch
        % Leave as NaN / false for invalid combinations
    end
end

fprintf('Parallel sweep complete.\n\n');

%% ===================== Reshape mass grid for output =====================
mass_grid = NaN(n_n, n_h, n_ts);
for k = 1:total_runs
    mass_grid(grid_n(k), grid_h(k), grid_ts(k)) = mass_flat(k);
end

%% ===================== Find Best Configuration =====================
valid_idx = find(valid_flat);
best = struct();

if isempty(valid_idx)
    fprintf('WARNING: No valid lower-panel configurations found!\n');
else
    [~, rel_idx] = min(mass_flat(valid_idx));
    k_best = valid_idx(rel_idx);

    best.mass   = mass_flat(k_best);
    best.n_root = n_range(grid_n(k_best));
    best.h      = h_range(grid_h(k_best));
    best.ts     = ts_range(grid_ts(k_best));
    best.result = result_flat{k_best};

    stringer_best.n_root = best.n_root;
    stringer_best.ts     = best.ts;
    stringer_best.h      = best.h;
    stringer_best.r_sfw  = r_sfw;
    best.stringer = stringer_best;

    fprintf('============================================\n');
    fprintf('  OPTIMAL LOWER PANEL CONFIGURATION\n');
    fprintf('============================================\n');
    fprintf('  Stringers at root:  %d\n',     best.n_root);
    fprintf('  Stringer height:    %.1f mm\n', best.h);
    fprintf('  Stringer thickness: %.1f mm\n', best.ts);
    fprintf('  Total mass (lower): %.1f kg\n', best.mass);
    fprintf('============================================\n');
end

%% ===================== Package Sweep Data =====================
sweep_results.n_range   = n_range;
sweep_results.h_range   = h_range;
sweep_results.ts_range  = ts_range;
sweep_results.mass_grid = mass_grid;

end


%% ===================== Local helper: suppress lower_panel_design output =====================
function res = local_lower_wrapper(p, loads, ssr_upper, stringer_lower)
    evalc('res = lower_panel_design(p, loads, ssr_upper, stringer_lower);');
end
