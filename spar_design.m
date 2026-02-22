function result = spar_design(p, loads)
% SPAR_DESIGN  Design front and rear spar webs and caps.
%
%   result = spar_design(p, loads)
%
%   Spar web thickness is sized by shear buckling:
%       tau_buckling = Ks * E * (tw / h_spar)^2
%   where Ks = 8.1 for a built-in plate.
%
%   Shear flow from combined shear force and torque:
%       q_front = V/(2*h_f) + T/(2*A_box)
%       q_rear  = V/(2*h_r) - T/(2*A_box)
%
%   Spar caps are sized by bending stress / cap buckling.
%
%   Inputs:
%       p     - wing_params() struct
%       loads - wing_loads() struct
%
%   Output:
%       result - struct with web & cap thicknesses, stresses, masses

%% ===================== Setup =====================
y = loads.y;
N = length(y);
c = loads.c;                           % Chord at each station [m]

% Spar heights [m] at each station
h_front = p.front_spar_h_frac * c;    % Front spar height
h_rear  = p.rear_spar_h_frac  * c;    % Rear spar height

% Wingbox enclosed area [m^2]
A_box = p.box_width_frac * c .* (p.front_spar_h_frac + p.rear_spar_h_frac)/2 .* c;

% Material
E_spar  = p.rib.E;                    % Spar web material (Al 7075-T6)
G_spar  = p.rib.G;
rho_spar = p.rib.rho;
tau_y   = p.rib.sigma_y / sqrt(3);    % Shear yield [Pa]
Ks      = 8.1;                        % Buckling coefficient (built-in plate)

%% ===================== Shear Flows =====================
V = loads.V;
T = loads.T;

q_front = abs(V) ./ (2 * h_front) + abs(T) ./ (2 * A_box);
q_rear  = abs(V) ./ (2 * h_rear)  - abs(T) ./ (2 * A_box);
q_rear  = abs(q_rear);   % Take magnitude

%% ===================== Web Thickness =====================
% From:  tau = q/tw  and  tau_buckling = Ks*E*(tw/h)^2
% =>  q/tw = Ks*E*(tw/h)^2  =>  tw^3 = q*h^2/(Ks*E)

tw_front = zeros(1, N);
tw_rear  = zeros(1, N);
tau_front = zeros(1, N);
tau_rear  = zeros(1, N);

for i = 1:N-1
    if h_front(i) > 0
        tw_front(i) = (q_front(i) * h_front(i)^2 / (Ks * E_spar))^(1/3);
        tau_front(i) = q_front(i) / tw_front(i);
    end
    if h_rear(i) > 0
        tw_rear(i) = (q_rear(i) * h_rear(i)^2 / (Ks * E_spar))^(1/3);
        tau_rear(i) = q_rear(i) / tw_rear(i);
    end
end

% Convert to mm and make manufacturable
tw_front_mm = tw_front * 1000;
tw_rear_mm  = tw_rear * 1000;
tw_front_manu = max(ceil(tw_front_mm), 1);
tw_rear_manu  = max(ceil(tw_rear_mm), 1);

%% ===================== Spar Caps =====================
% Cap sized by bending: sigma = M*h/(2*I)
% I ≈ b_cap * tf^3/6 + b_cap*tf*(h-tf)^2/2  (two C-caps)
% Also check cap buckling: sigma_buck = Ks * E * (tf/b_cap)^2

% Cap width tapers with chord
b_cap_front = 0.10 * c;     % Cap width = 10% of chord [m]
b_cap_rear  = 0.10 * c;

BM_half = abs(loads.M) / 2;   % Each spar carries half the bending moment

tf_front = zeros(1, N);
tf_rear  = zeros(1, N);
sig_cap_f = zeros(1, N);
sig_cap_r = zeros(1, N);

for i = 1:N-1
    % Front spar cap
    if h_front(i) > 0 && b_cap_front(i) > 0 && BM_half(i) > 0
        % Iterate to find tf that balances bending stress = buckling stress
        for tf_try = 0.001:0.0005:0.050  % [m]
            I_f = b_cap_front(i)*tf_try^3/6 + b_cap_front(i)*tf_try*(h_front(i)-tf_try)^2/2 + ...
                  tw_front(i)*(h_front(i)-2*tf_try)^3/12;
            sig_bend = BM_half(i) * (h_front(i)-tf_try) / (2*I_f);
            sig_buck = Ks * E_spar * (tf_try / b_cap_front(i))^2;
            if sig_buck >= sig_bend
                tf_front(i) = tf_try;
                sig_cap_f(i) = sig_bend;
                break;
            end
        end
    end

    % Rear spar cap
    if h_rear(i) > 0 && b_cap_rear(i) > 0 && BM_half(i) > 0
        for tf_try = 0.001:0.0005:0.050
            I_r = b_cap_rear(i)*tf_try^3/6 + b_cap_rear(i)*tf_try*(h_rear(i)-tf_try)^2/2 + ...
                  tw_rear(i)*(h_rear(i)-2*tf_try)^3/12;
            sig_bend = BM_half(i) * (h_rear(i)-tf_try) / (2*I_r);
            sig_buck = Ks * E_spar * (tf_try / b_cap_rear(i))^2;
            if sig_buck >= sig_bend
                tf_rear(i) = tf_try;
                sig_cap_r(i) = sig_bend;
                break;
            end
        end
    end
end

tf_front_mm = tf_front * 1000;
tf_rear_mm  = tf_rear * 1000;
tf_front_manu = max(ceil(tf_front_mm), 1);
tf_rear_manu  = max(ceil(tf_rear_mm), 1);

%% ===================== Mass Calculation =====================
dy = y(2) - y(1);

% Web mass
vol_web_f = sum(tw_front(1:end-1) .* h_front(1:end-1)) * dy;
vol_web_r = sum(tw_rear(1:end-1) .* h_rear(1:end-1)) * dy;
mass_web  = (vol_web_f + vol_web_r) * rho_spar;

% Cap mass (4 caps: 2 per spar, upper + lower)
vol_cap_f = 2 * sum(b_cap_front(1:end-1) .* tf_front(1:end-1)) * dy;
vol_cap_r = 2 * sum(b_cap_rear(1:end-1) .* tf_rear(1:end-1)) * dy;
mass_cap  = (vol_cap_f + vol_cap_r) * rho_spar;

mass_total = mass_web + mass_cap;

%% ===================== Package Results =====================
result.y = y;
result.tw_front     = tw_front_mm;
result.tw_rear      = tw_rear_mm;
result.tw_front_manu = tw_front_manu;
result.tw_rear_manu  = tw_rear_manu;
result.tau_front    = tau_front / 1e6;    % [MPa]
result.tau_rear     = tau_rear / 1e6;     % [MPa]
result.tf_front     = tf_front_mm;
result.tf_rear      = tf_rear_mm;
result.tf_front_manu = tf_front_manu;
result.tf_rear_manu  = tf_rear_manu;
result.sig_cap_f    = sig_cap_f / 1e6;   % [MPa]
result.sig_cap_r    = sig_cap_r / 1e6;   % [MPa]
result.mass_web     = mass_web;
result.mass_cap     = mass_cap;
result.mass_total   = mass_total;

fprintf('\n--- Spar Design ---\n');
fprintf('  Web mass (front+rear):  %.1f kg\n', mass_web);
fprintf('  Cap mass (front+rear):  %.1f kg\n', mass_cap);
fprintf('  TOTAL spar mass:        %.1f kg\n', mass_total);

end
