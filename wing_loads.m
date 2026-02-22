function loads = wing_loads(p, n_load)
% WING_LOADS  Compute spanwise aerodynamic, inertial & total loads.
%
%   loads = wing_loads(p, n_load)
%
%   Builds on the approach in prelim_load_ben.m but packages the results
%   into a struct for downstream use.
%
%   Inputs:
%       p       - parameter struct from wing_params()
%       n_load  - load factor to analyse (e.g. p.n_ult_pos = 3.75)
%
%   Output:
%       loads   - struct with fields:
%           .y          - spanwise stations [m]
%           .lift       - lift per unit span [N/m]
%           .w_wing     - wing weight per unit span [N/m]  (downward = negative)
%           .w_fuel     - fuel weight per unit span [N/m]  (downward = negative)
%           .w_total    - net load per unit span [N/m]
%           .V          - shear force [N]   (integrated tip-to-root)
%           .M          - bending moment [Nm] (integrated tip-to-root)
%           .M_nofuel   - BM for no-fuel case [Nm]
%           .V_nofuel   - SF for no-fuel case [N]
%           .T          - torque per unit span [Nm/m] (about wingbox centre)

if nargin < 2
    n_load = p.n_ult_pos;         % Default: ultimate positive manoeuvre
end

y    = p.y;
span = p.semi_span;
N    = p.N_stations;

%% ===================== Aerodynamic Lift (Elliptic) =====================
W_total = p.MTOW * p.g * n_load;            % Total lift required [N]
L0      = 2 * W_total / (pi * span);        % Elliptic peak lift/span
lift    = L0 * sqrt(max(1 - (y/span).^2, 0));  % [N/m]

%% ===================== Wing Structural Weight =====================
% Distribute proportional to c(y)*t/c(y) ∝ c^2 * tc
c_dist = chord_at_y(p, y);
tc_dist = p.tc_root + (p.tc_tip - p.tc_root) * (y / span);
shape   = c_dist .* (c_dist .* tc_dist);     % ∝ structural volume
W_wing  = p.wing_mass * p.g * n_load;
k_wing  = W_wing / trapz(y, shape);
w_wing  = k_wing * shape;                    % [N/m], downward

%% ===================== Fuel Weight =====================
fuel_b = p.fuel_span_frac * span;
W_fuel = p.fuel_mass * p.g * n_load;
w_fuel = zeros(size(y));
% Distribute fuel proportional to wingbox cross-section area
fuel_shape = (c_dist .* p.box_width_frac) .* (c_dist .* p.box_height_frac);
fuel_mask  = y <= fuel_b;
fuel_shape(~fuel_mask) = 0;
if trapz(y, fuel_shape) > 0
    k_fuel = W_fuel / trapz(y, fuel_shape);
    w_fuel = k_fuel * fuel_shape;
else
    w_fuel(fuel_mask) = W_fuel / fuel_b;     % Fallback: uniform
end

%% ===================== Point Loads =====================
w_point = zeros(size(y));

% Engine
eng_y = p.engine_eta * span;
[~, eng_idx] = min(abs(y - eng_y));
W_engine = p.engine_mass * p.g * n_load;
w_point(eng_idx) = W_engine;

% Undercarriage (at root)
W_uc = p.uc_mass * p.g * n_load / 2;        % Per wing
w_point(1) = w_point(1) + W_uc;

%% ===================== Net Distributed Load =====================
%   Positive = upward (lift), Negative = downward (weight)
w_total = lift - w_wing - w_fuel;            % Distributed part

%% ===================== No-Fuel Case =====================
w_total_nf = lift - w_wing;

%% ===================== Shear Force (tip-to-root integration) =====================
V      = -flip(cumtrapz(flip(y), flip(w_total)));
V_pt   = -flip(cumsum(flip(w_point)));
V_total = V + V_pt;

V_nf   = -flip(cumtrapz(flip(y), flip(w_total_nf)));
V_nf   = V_nf + V_pt;

%% ===================== Bending Moment =====================
M_total  = -flip(cumtrapz(flip(y), flip(V_total)));
M_nofuel = -flip(cumtrapz(flip(y), flip(V_nf)));

%% ===================== Torque (about wingbox centre) =====================
% Moment arms (fraction of chord)
ac_x    = 0.25;                              % Aerodynamic centre x/c
box_cx  = p.xfs + p.box_width_frac / 2;     % Wingbox centre x/c
arm_a   = (box_cx - ac_x);                   % Lift moment arm (x/c)

% Wing CG roughly at 0.40c for NACA 64A series
wing_cg_x = 0.40;
arm_w     = (box_cx - wing_cg_x);

% Fuel CG roughly at mid-box
fuel_cg_x = box_cx;
arm_f     = (box_cx - fuel_cg_x);            % ~0

% Distributed torque [Nm/m]
T_lift = lift .* c_dist * arm_a;
T_wing = -w_wing .* c_dist * arm_w;         % Wing weight torque
T_fuel = -w_fuel .* c_dist * arm_f;
T_aero = p.CM0 * 0.5 * p.rho_cruise * p.V_cruise^2 * c_dist.^2;  % Pitching moment

t_total = T_lift + T_wing + T_fuel + T_aero;

% Integrate torque from tip to root
T_integrated = -flip(cumtrapz(flip(y), flip(t_total)));

%% ===================== Package Output =====================
loads.y         = y;
loads.c         = c_dist;
loads.lift      = lift;
loads.w_wing    = w_wing;
loads.w_fuel    = w_fuel;
loads.w_total   = w_total;
loads.w_point   = w_point;
loads.V         = V_total;
loads.M         = M_total;
loads.V_nofuel  = V_nf;
loads.M_nofuel  = M_nofuel;
loads.T         = T_integrated;
loads.n         = n_load;
loads.eng_idx   = eng_idx;

% Store individual load contributions for downstream use
loads.W_engine  = W_engine;
loads.W_uc      = W_uc;

end
