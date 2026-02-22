function result = ssr_design(p, loads, stringer)
% SSR_DESIGN  Skin-Stringer-Rib design for the upper (compression) panel.
%
%   result = ssr_design(p, loads, stringer)
%
%   Implements the Catchpole / Farrar method from Lecture 3:
%     1. At each spanwise station compute the running load N = M/(c*h)
%     2. Find initial buckling stress sigma_0 from panel buckling
%     3. Use Catchpole diagram to get sigma_cr/sigma_0
%     4. Use Farrar diagram to get efficiency factor F
%     5. Equate Farrar column stress to panel buckling to find rib spacing L
%     6. Step along the span by L, updating stringer count as the wing tapers
%
%   Inputs:
%       p        - parameter struct from wing_params()
%       loads    - loads struct from wing_loads()
%       stringer - struct with fields:
%           .n_root   - number of stringers at root
%           .ts       - stringer thickness [mm]
%           .h        - stringer web height [mm]
%           .r_sfw    - flange-to-web height ratio (e.g. 0.3)
%
%   Output:
%       result   - struct with rib positions, skin thicknesses, stresses,
%                  stringer counts, Farrar factors, rib thicknesses, masses

%% ===================== Unpack Stringer Geometry =====================
n_root = stringer.n_root;
ts     = stringer.ts;            % [mm]
h_s    = stringer.h;             % [mm]
r_sfw  = stringer.r_sfw;

d_s    = r_sfw * h_s;            % Flange width [mm]
A_s    = ts * h_s + 2 * d_s * ts;  % Z-stringer area [mm^2]

%% ===================== Material Shorthand =====================
E       = p.mat.E;               % [Pa]
Et      = p.mat.Et;              % [Pa]
sig_yc  = p.mat.sigma_y_c;      % [Pa]  compressive yield
sig_yt  = p.mat.sigma_y_t;      % [Pa]  tensile yield
rho_al  = p.mat.rho;            % [kg/m^3]
rho_rib = p.rib.rho;
E_rib   = p.rib.E;

%% ===================== Wing Box Geometry at Root =====================
c_root_box = chord_at_y(p, 0) * p.box_width_frac;   % Wingbox width at root [m]
h_root_box = chord_at_y(p, 0) * p.box_height_frac;  % Wingbox height at root [m]
b1         = c_root_box / n_root * 1000;             % Panel pitch at root [mm]

%% ===================== Interpolation of loads onto rib stations =====================
BM_interp = griddedInterpolant(loads.y, loads.M_nofuel, 'linear');
                 % Use no-fuel BM (worst case for upper panel compression)

%% ===================== Main Loop: March from Root to Tip =====================
y_pos    = [];        % Rib spanwise positions [m]
BM_sec   = [];        % BM at each rib station [Nm]
c_box    = [];        % Wingbox width at each station [m]
h_box    = [];        % Wingbox height at each station [m]
N_run    = [];        % Running load [N/m]
t_skin   = [];        % Skin thickness [mm]
sig_0    = [];        % Initial buckling stress [MPa]
sig_cr   = [];        % Critical buckling stress [MPa]
F_farr   = [];        % Farrar factor
L_rib    = [];        % Rib spacing [m]
n_str    = [];        % Number of stringers at station

i = 1;
y_cur = 0;            % Start at wing root

while y_cur < p.semi_span * 0.98   % Stop near tip
    y_pos(i) = y_cur;

    % -- Geometry at this station --
    c_i = chord_at_y(p, y_cur);
    c_box(i) = c_i * p.box_width_frac;
    h_box(i) = c_i * p.box_height_frac;

    % -- Bending moment --
    BM_sec(i) = abs(BM_interp(y_cur));

    % -- Running load --
    if c_box(i) > 0 && h_box(i) > 0
        N_run(i) = BM_sec(i) / (c_box(i) * h_box(i));  % [N/m]
    else
        break;
    end

    % -- Number of stringers at this station --
    % Stringer k occupies the pitch band [(k-1)*b1, k*b1] from the FS.
    % It exists where its centre (k-0.5)*b1 lies inside the box width c_box.
    % n_str = round(c_box/b1) counts how many complete bands fit.
    n_str(i) = max(round(n_root * c_box(i) / c_root_box), 1);

    % -- Skin thickness from panel buckling --
    %    sigma_0 = 3.62 * E * (t / b_panel)^2   =>  t = (N * b^2 / (3.62*E))^(1/3)
    b_panel = b1 / 1000;                     % [m] (use root panel pitch)
    t_skin(i) = ((N_run(i) / (3.62 * E) * b_panel^2)^(1/3)) * 1000;  % [mm]

    if t_skin(i) < 0.5
        t_skin(i) = 0.5;                     % Minimum gauge
    end

    sig_0(i) = N_run(i) / (t_skin(i) / 1000) / 1e6;  % [MPa]

    % -- Area and thickness ratios --
    ts_t  = ts / t_skin(i);
    As_bt_val = A_s / (b1 * t_skin(i));

    % -- Catchpole: sigma_cr / sigma_0 --
    sig_ratio = catchpole_interp(As_bt_val, ts_t);
    sig_cr(i) = sig_ratio * sig_0(i);        % [MPa]

    % -- Check against material yield --
    if sig_cr(i) > sig_yc / 1e6
        fprintf('  Station %d (y=%.2fm): sigma_cr=%.0f MPa > sigma_yc=%.0f MPa. Capping.\n', ...
            i, y_cur, sig_cr(i), sig_yc/1e6);
        sig_cr(i) = sig_yc / 1e6;
    end

    % -- Farrar factor --
    F_farr(i) = farrar_interp(As_bt_val, ts_t);

    % -- Rib spacing from Farrar column formula --
    %    sigma_f = F / sqrt(L / (N * Et))
    %    Set sigma_f = sigma_cr  =>  L = N * Et * (F / sigma_cr)^2
    %    (stresses in Pa for consistency)
    sig_cr_Pa = sig_cr(i) * 1e6;
    if sig_cr_Pa > 0
        L_rib(i) = N_run(i) * Et * (F_farr(i) / sig_cr_Pa)^2;
    else
        L_rib(i) = 0.5;  % Fallback
    end

    % Clamp rib spacing to manufacturing-realistic range
    % Min 400 mm: no transport-aircraft rib is closer than ~300-400 mm
    % Max 1000 mm: wider than this sacrifices skin stability and flutter stiffness
    L_rib(i) = max(min(L_rib(i), 1.00), 0.40);

    % -- Advance to next station --
    y_cur = y_cur + L_rib(i);
    i = i + 1;
end

n_ribs = length(y_pos);

%% ===================== Rib Thickness =====================
% Rib crushing load method (from lecture / prev year code)
Kc = 3.62;
tr = zeros(1, n_ribs);
for j = 1:n_ribs
    if j < n_ribs && L_rib(j) > 0
        T_eff = (1/F_farr(j)) * sqrt(N_run(j) * L_rib(j) / E_rib) * 1000; % [mm]
        I_pan = (c_box(j) * (T_eff/1000)^3 / 12) + ...
                 c_box(j) * (T_eff/1000) * (h_box(j)/2)^2;
        if I_pan > 0
            F_crush = BM_sec(j)^2 * L_rib(j) * h_box(j) * (T_eff/1000) * c_box(j) / ...
                      (2 * E_rib * I_pan^2);
            tr(j) = ((F_crush * h_box(j)^2 / (Kc * E_rib * c_box(j)))^(1/3)) * 1000; % [mm]
        end
    end
end
tr_manu = max(ceil(tr), 1);   % Manufacturable (round up to nearest mm, min 1mm)

%% ===================== Mass Calculation =====================
% -- Skin mass --
mass_skin = 0;
for j = 1:n_ribs-1
    area_j = ((c_box(j) + c_box(j+1)) / 2) * L_rib(j);
    mass_skin = mass_skin + (t_skin(j)/1000) * area_j * rho_al;
end

% -- Stringer mass --
%    All n_root stringers run from root to the outermost rib (y_pos(end)).
total_stringer_length = n_root * y_pos(end);
mass_stringer = (A_s / 1e6) * total_stringer_length * rho_al;

% -- Rib mass --
%    Use approximate rib cross-section area from NACA 64A airfoil
rib_area_frac = 0.0025;         % Approximate rib area / chord^2 from prev year
c_at_ribs = chord_at_y(p, y_pos);
V_ribs = (tr_manu / 1000) .* c_at_ribs.^2 * rib_area_frac;
mass_ribs = sum(V_ribs * rho_rib);

% -- Total per wing (upper panel) --
mass_total = mass_skin + mass_stringer + mass_ribs;

%% ===================== Package Results =====================
result.y_pos     = y_pos;
result.n_ribs    = n_ribs;
result.BM        = BM_sec;
result.c_box     = c_box;
result.h_box     = h_box;
result.N_run     = N_run;
result.t_skin    = t_skin;
result.t_skin_manu = max(ceil(t_skin), 1);
result.sig_0     = sig_0;
result.sig_cr    = sig_cr;
result.F_farr    = F_farr;
result.L_rib     = L_rib;
result.n_str     = n_str;
result.tr        = tr;
result.tr_manu   = tr_manu;
result.mass_skin     = mass_skin;
result.mass_stringer = mass_stringer;
result.mass_ribs     = mass_ribs;
result.mass_total    = mass_total;

fprintf('\n--- Upper Panel SSR Design ---\n');
fprintf('  Number of ribs:       %d\n', n_ribs);
fprintf('  Skin mass:            %.1f kg\n', mass_skin);
fprintf('  Stringer mass:        %.1f kg\n', mass_stringer);
fprintf('  Rib mass:             %.1f kg\n', mass_ribs);
fprintf('  TOTAL (upper panel):  %.1f kg\n', mass_total);

end
