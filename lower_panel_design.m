function result = lower_panel_design(p, loads, ssr_upper, stringer_lower)
% LOWER_PANEL_DESIGN  Design the lower (tension) wing panel.
%
%   result = lower_panel_design(p, loads, ssr_upper)
%   result = lower_panel_design(p, loads, ssr_upper, stringer_lower)
%
%   The lower skin is primarily in tension during positive-g manoeuvres.
%   Design is governed by:
%     - Tensile yield:     t_plus  = N / sigma_y_t
%     - Reversed loading:  t_minus (compression during negative-g)
%       using panel buckling with full, half, or no-stringer panels
%
%   The rib positions are inherited from the upper panel SSR design.
%
%   Inputs:
%       p              - wing_params() struct
%       loads          - wing_loads() struct (positive manoeuvre case)
%       ssr_upper      - result struct from ssr_design()
%       stringer_lower - (optional) struct with fields:
%                          .n_root  number of stringers at root
%                          .h       stringer web height [mm]
%                          .ts      stringer thickness [mm]
%                          .r_sfw   flange-to-web ratio
%                        Defaults to {n=8, h=20, ts=2.4, r_sfw=0.3} if omitted.
%
%   Output:
%       result    - struct with skin thicknesses, panel types, stresses, mass

%% ===================== Material Shorthand =====================
E       = p.mat.E;
sig_yc  = p.mat.sigma_y_c / 1e6;   % [MPa]
sig_yt  = p.mat.sigma_y_t / 1e6;   % [MPa]
nu      = p.mat.nu;
rho_al  = p.mat.rho;

%% ===================== Use Upper Panel Rib Positions =====================
y_pos  = ssr_upper.y_pos;
c_box  = ssr_upper.c_box;
h_box  = ssr_upper.h_box;
BM     = ssr_upper.BM;
L_rib  = ssr_upper.L_rib;
n_ribs = ssr_upper.n_ribs;

%% ===================== Lower Panel Stringer Parameters =====================
% Apply defaults if stringer_lower not supplied
if nargin < 4 || isempty(stringer_lower)
    stringer_lower.n_root = 8;
    stringer_lower.ts     = 2.4;
    stringer_lower.h      = 20;
    stringer_lower.r_sfw  = 0.3;
end

n_l   = stringer_lower.n_root;   % Number of lower stringers at root
ts_l  = stringer_lower.ts;        % Stringer thickness [mm]
h_l   = stringer_lower.h;         % Stringer web height [mm]
r_sfw = stringer_lower.r_sfw;     % Flange-to-web ratio

d_l    = r_sfw * h_l;
A_s_l  = ts_l * h_l + 2 * d_l * ts_l;   % Z-section area [mm^2]
b1_l   = c_box(1) / n_l * 1000;          % Panel pitch at root [mm]

%% ===================== Compute Loads for Reversed Case =====================
% For negative load factor: compute separate BM
loads_neg = wing_loads(p, abs(p.n_ult_neg));
BM_neg_interp = griddedInterpolant(loads_neg.y, abs(loads_neg.M_nofuel), 'linear');
BM_minus = zeros(1, n_ribs);
for j = 1:n_ribs
    BM_minus(j) = BM_neg_interp(y_pos(j));
end

%% ===================== Skin Thickness at Each Rib Station =====================
t_skin  = zeros(1, n_ribs);
t_plus  = zeros(1, n_ribs);   % Tensile thickness requirement
t1_minus = zeros(1, n_ribs);  % Full-panel buckling thickness (compression)
t2_minus = zeros(1, n_ribs);  % Half-panel buckling thickness
t3_minus = zeros(1, n_ribs);  % Rib-spacing buckling thickness
panel_type = zeros(1, n_ribs);  % 0=no stringer, 0.5=half, 1=full
sig_cr_plus  = zeros(1, n_ribs);
sig_cr_minus = zeros(1, n_ribs);
sig_skin_plus  = zeros(1, n_ribs);
sig_skin_minus = zeros(1, n_ribs);

for j = 1:n_ribs
    if c_box(j) <= 0 || h_box(j) <= 0
        continue;
    end

    % --- Running loads ---
    N_plus  = BM(j) / (c_box(j) * h_box(j));          % [N/m] - tension
    N_minus = BM_minus(j) / (c_box(j) * h_box(j));    % [N/m] - compression

    % --- Tensile thickness requirement ---
    t_plus(j) = (N_plus / (sig_yt * 1e6)) * 1000;     % [mm]

    % --- Compressive buckling thicknesses ---
    b_panel = b1_l / 1000;    % [m]
    % Full panel (stringer pitch = b1_l)
    t1_minus(j) = ((N_minus / (3.62 * E) * b_panel^2)^(1/3)) * 1000;
    % Half panel (2 * b1_l)
    t2_minus(j) = ((N_minus / (3.62 * E) * (2*b_panel)^2)^(1/3)) * 1000;
    % Rib-pitch buckling
    if j <= length(L_rib) && L_rib(j) > 0
        Kc_val = ((c_box(j)/L_rib(j) + L_rib(j)/c_box(j))^2) * ...
                 (pi^2 / (12*(1 - nu^2)));
        t3_minus(j) = ((N_minus * L_rib(j)^2 / (Kc_val * E))^(1/3)) * 1000;
    end

    % --- Determine governing thickness and panel type ---
    t_govern = max(t_plus(j), t1_minus(j));
    t_skin(j) = max(ceil(t_govern), 1);   % Round up, min 1mm

    if t_skin(j) < t2_minus(j)
        panel_type(j) = 1;    % Full panel (all stringers)
    elseif t_skin(j) < t3_minus(j)
        panel_type(j) = 0.5;  % Half panel (every other stringer)
    else
        panel_type(j) = 0;    % No stringers needed
    end

    % --- Buckling check with Catchpole ---
    ts_t = ts_l / t_skin(j);
    As_bt = A_s_l / (b1_l * t_skin(j));
    if panel_type(j) == 0.5
        As_bt = As_bt * 0.5;
    elseif panel_type(j) == 0
        As_bt = 0;
    end

    if As_bt > 0.01
        sig_ratio = catchpole_interp(As_bt, ts_t);
    else
        sig_ratio = 1.0;
    end

    sig_skin_plus(j)  = N_plus / (t_skin(j)/1000) / 1e6;   % [MPa]
    sig_skin_minus(j) = N_minus / (t_skin(j)/1000) / 1e6;   % [MPa]
    sig_cr_plus(j)  = sig_ratio * sig_skin_plus(j) * max(panel_type(j), 0.01);
    sig_cr_minus(j) = sig_ratio * sig_skin_minus(j) * max(panel_type(j), 0.01);

    % --- Increase thickness if buckling exceeds yield ---
    while (sig_cr_plus(j) > sig_yt || sig_cr_minus(j) > sig_yc) && t_skin(j) < 20
        t_skin(j) = t_skin(j) + 1;
        sig_skin_plus(j)  = N_plus / (t_skin(j)/1000) / 1e6;
        sig_skin_minus(j) = N_minus / (t_skin(j)/1000) / 1e6;
        ts_t_new = ts_l / t_skin(j);
        As_bt_new = A_s_l / (b1_l * t_skin(j)) * max(panel_type(j), 0.01);
        if As_bt_new > 0.01
            sig_ratio = catchpole_interp(As_bt_new, ts_t_new);
        else
            sig_ratio = 1.0;
        end
        sig_cr_plus(j)  = sig_ratio * sig_skin_plus(j);
        sig_cr_minus(j) = sig_ratio * sig_skin_minus(j);
    end
end

%% ===================== Mass Calculation =====================
mass_skin = 0;
for j = 1:n_ribs-1
    area_j = ((c_box(j) + c_box(j+1)) / 2) * L_rib(j);
    mass_skin = mass_skin + (t_skin(j)/1000) * area_j * rho_al;
end

% Stringer mass – all n_l stringers run the full span to the outermost rib.
% Consistent with the upper panel: pitch narrows as the box tapers, which
% only improves buckling resistance; b1_l is already the conservative value.
total_str_len = n_l * y_pos(end);
mass_stringer = (A_s_l / 1e6) * total_str_len * rho_al;

mass_total = mass_skin + mass_stringer;

%% ===================== Package Results =====================
result.t_skin       = t_skin;
result.t_plus       = t_plus;
result.t1_minus     = t1_minus;
result.t2_minus     = t2_minus;
result.t3_minus     = t3_minus;
result.panel_type   = panel_type;
result.sig_cr_plus  = sig_cr_plus;
result.sig_cr_minus = sig_cr_minus;
result.sig_skin_plus  = sig_skin_plus;
result.sig_skin_minus = sig_skin_minus;
result.mass_skin     = mass_skin;
result.mass_stringer = mass_stringer;
result.mass_total    = mass_total;
result.stringer      = stringer_lower;   % store for downstream use

fprintf('\n--- Lower Panel Design ---\n');
fprintf('  Skin mass:            %.1f kg\n', mass_skin);
fprintf('  Stringer mass:        %.1f kg\n', mass_stringer);
fprintf('  TOTAL (lower panel):  %.1f kg\n', mass_total);

end
