function [best, sweep_results] = ssr_optimise(p, loads)
% SSR_OPTIMISE  Sweep stringer parameters to find minimum-mass upper panel.
%
%   [best, sweep_results] = ssr_optimise(p, loads)
%
%   Iterates over:
%       n_root  - number of stringers at root
%       h       - stringer web height [mm]
%       ts      - stringer thickness [mm]
%
%   For each combination, runs ssr_design() and records the total mass.
%   Returns the best combination and the full sweep data.
%
%   Inputs:
%       p     - wing_params() struct
%       loads - wing_loads() struct
%
%   Outputs:
%       best           - struct with optimal stringer params & mass
%       sweep_results  - struct with matrices for carpet plotting
%
%   PARALLELISED VERSION: uses parfor over all parameter combinations.
%   Requires the Parallel Computing Toolbox.
%   Opens a parallel pool automatically if one is not already running.

%% ===================== Define Sweep Ranges =====================
n_range  = 16:2:32;            % Number of stringers at root
h_range  = 50:5:100;           % Stringer web height [mm]
ts_range = [1.5, 2.0, 2.5];   % Stringer thickness [mm]
r_sfw    = 0.3;                % Flange/web ratio (fixed)

%% ===================== Initialise Storage =====================
n_n  = length(n_range);
n_h  = length(h_range);
n_ts = length(ts_range);

total_runs = n_n * n_h * n_ts;

fprintf('SSR Optimisation: %d combinations to evaluate\n', total_runs);
fprintf('Sweep ranges:\n');
fprintf('  n_root : %d to %d\n', n_range(1), n_range(end));
fprintf('  h      : %.0f to %.0f mm\n', h_range(1), h_range(end));
fprintf('  ts     : %.1f to %.1f mm\n', ts_range(1), ts_range(end));

%% ===================== Start Parallel Pool =====================
pool = gcp('nocreate');
if isempty(pool)
    fprintf('Starting parallel pool...\n');
    pool = parpool('local');  % Capture return value so pool is not empty below
                               % To limit cores: parpool('local', N)
end
fprintf('Running parallel sweep (%d workers)...\n', pool.NumWorkers);

%% ===================== Flatten parameter grid =====================
% parfor works best over a single linear index, so flatten the 3-D grid
% into a 1-D list of parameter combinations.
[grid_n, grid_h, grid_ts] = ndgrid(1:n_n, 1:n_h, 1:n_ts);
grid_n  = grid_n(:);
grid_h  = grid_h(:);
grid_ts = grid_ts(:);

%% ===================== Preallocate result arrays =====================
% parfor requires output arrays to be preallocated and indexed by the
% loop variable. No conditional updates to shared variables allowed.
mass_flat   = NaN(total_runs, 1);
valid_flat  = false(total_runs, 1);
result_flat = cell(total_runs, 1);   % store full result for valid runs

%% ===================== Parallel Sweep =====================
parfor k = 1:total_runs
    i_n  = grid_n(k);
    i_h  = grid_h(k);
    i_ts = grid_ts(k);

stringer = struct( ...
    'n_root', n_range(i_n), ...
    'ts',     ts_range(i_ts), ...
    'h',      h_range(i_h), ...
    'r_sfw',  r_sfw );

    try
        % evalc suppresses fprintf output from ssr_design during the sweep
        res = local_evalc_wrapper(p, loads, stringer);

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
    fprintf('WARNING: No valid configurations found!\n');
else
    [~, rel_idx] = min(mass_flat(valid_idx));
    k_best = valid_idx(rel_idx);

    best.mass     = mass_flat(k_best);
    best.n_root   = n_range(grid_n(k_best));
    best.h        = h_range(grid_h(k_best));
    best.ts       = ts_range(grid_ts(k_best));
    best.result   = result_flat{k_best};
    best.n_ribs   = best.result.n_ribs;

    stringer_best.n_root = best.n_root;
    stringer_best.ts     = best.ts;
    stringer_best.h      = best.h;
    stringer_best.r_sfw  = r_sfw;
    best.stringer = stringer_best;

    fprintf('============================================\n');
    fprintf('  OPTIMAL UPPER PANEL CONFIGURATION\n');
    fprintf('============================================\n');
    fprintf('  Stringers at root:  %d\n',   best.n_root);
    fprintf('  Stringer height:    %.1f mm\n', best.h);
    fprintf('  Stringer thickness: %.1f mm\n', best.ts);
    fprintf('  Number of ribs:     %d\n',   best.n_ribs);
    fprintf('  Total mass (upper): %.1f kg\n', best.mass);
    fprintf('============================================\n');
end

%% ===================== Package Sweep Data =====================
sweep_results.n_range   = n_range;
sweep_results.h_range   = h_range;
sweep_results.ts_range  = ts_range;
sweep_results.mass_grid = mass_grid;

end


%% ===================== Local helper: suppress ssr_design output =====================
% A named local function is needed because evalc() cannot capture output
% from anonymous functions, and parfor does not support nested functions.
function res = local_evalc_wrapper(p, loads, stringer)
    evalc('res = ssr_design(p, loads, stringer);');
end
