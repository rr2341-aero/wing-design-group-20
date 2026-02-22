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

%% ===================== Define Sweep Ranges =====================
n_range  = 16:2:32;            % Number of stringers at root
h_range  = 50:5:100;           % Stringer web height [mm]
ts_range = [1.5, 2.0, 2.5];   % Stringer thickness [mm]
r_sfw    = 0.3;                % Flange/web ratio (fixed)

%% ===================== Initialise Storage =====================
n_n  = length(n_range);
n_h  = length(h_range);
n_ts = length(ts_range);

mass_grid = NaN(n_n, n_h, n_ts);
best_mass = Inf;
best = struct();

total_runs = n_n * n_h * n_ts;
run_count  = 0;

fprintf('SSR Optimisation: %d combinations to evaluate\n', total_runs);
fprintf('Sweep ranges:\n');
fprintf('  n_root : %d to %d\n', n_range(1), n_range(end));
fprintf('  h      : %.0f to %.0f mm\n', h_range(1), h_range(end));
fprintf('  ts     : %.1f to %.1f mm\n', ts_range(1), ts_range(end));
fprintf('Progress: ');

%% ===================== Sweep Loop =====================
for i_n = 1:n_n
    for i_h = 1:n_h
        for i_ts = 1:n_ts
            run_count = run_count + 1;

            stringer.n_root = n_range(i_n);
            stringer.ts     = ts_range(i_ts);
            stringer.h      = h_range(i_h);
            stringer.r_sfw  = r_sfw;

            try
                % Suppress prints during sweep
                evalc('res = ssr_design(p, loads, stringer);');
                m = res.mass_total;

                if isfinite(m) && m > 0
                    mass_grid(i_n, i_h, i_ts) = m;

                    if m < best_mass
                        best_mass = m;
                        best.mass     = m;
                        best.n_root   = n_range(i_n);
                        best.h        = h_range(i_h);
                        best.ts       = ts_range(i_ts);
                        best.n_ribs   = res.n_ribs;
                        best.result   = res;
                        best.stringer = stringer;
                    end
                end
            catch
                % Skip failed combinations
                mass_grid(i_n, i_h, i_ts) = NaN;
            end

            if mod(run_count, max(1, floor(total_runs/20))) == 0
                fprintf('|');
            end
        end
    end
end
fprintf(' Done!\n\n');

%% ===================== Report =====================
if isfinite(best_mass)
    fprintf('============================================\n');
    fprintf('  OPTIMAL UPPER PANEL CONFIGURATION\n');
    fprintf('============================================\n');
    fprintf('  Stringers at root:  %d\n',   best.n_root);
    fprintf('  Stringer height:    %.1f mm\n', best.h);
    fprintf('  Stringer thickness: %.1f mm\n', best.ts);
    fprintf('  Number of ribs:     %d\n',   best.n_ribs);
    fprintf('  Total mass (upper): %.1f kg\n', best.mass);
    fprintf('============================================\n');
else
    fprintf('WARNING: No valid configurations found!\n');
end

%% ===================== Package Sweep Data =====================
sweep_results.n_range   = n_range;
sweep_results.h_range   = h_range;
sweep_results.ts_range  = ts_range;
sweep_results.mass_grid = mass_grid;

end
