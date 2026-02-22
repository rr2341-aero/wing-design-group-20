function p = wing_params()
% WING_PARAMS  Central parameter file for the G11 aircraft wing.
%   Returns a struct 'p' containing all geometric, mass, material
%   and flight-condition parameters needed by the wing structural
%   design scripts.
%
%   Source: AVD_G11 conceptual design report & prelim_load_ben.m
%
%   Usage:  p = wing_params();

%% ======================== Aircraft Geometry ========================
p.b          = 34.78;                       % Total wingspan [m]
p.fus_w      = 2.1814;                      % Fuselage half-width (approx) [m]
p.semi_span  = (p.b - p.fus_w) / 2;        % Semi-span outboard of fuselage [m]
p.y_root     = p.fus_w / 2;                 % y-coordinate at wing root [m]

p.lambda     = 0.31;                        % Taper ratio  ct/cr
p.tc_root    = 0.14;                        % Root t/c ratio (NACA 64A410 style)
p.tc_tip     = 0.10;                        % Tip  t/c ratio
p.sweep_LE   = 23.7;                        % LE sweep [deg]
p.sweep_25   = 20.0;                        % Quarter-chord sweep [deg]
p.dihedral   = 5.0;                         % Dihedral angle [deg]

% Chord lengths
p.c_root     = 2 * p.b * 0.5 / ...         % Root chord [m]  (from S & b & lambda)
               ((1 + p.lambda));            %   cr = 2S / (b*(1+lambda))
%   -- override with actual value if known from AVD_G11 --
p.c_root     = 5.76;                        % Root chord [m]  (G11 value)
p.c_tip      = p.lambda * p.c_root;         % Tip chord  [m]

% Wing reference area
p.S_ref      = p.b * p.c_root * (1 + p.lambda) / 2;  % [m^2]

%% ======================== Spar Locations (as fraction of chord) ========================
p.xfs        = 0.12;                        % Front spar  x/c
p.xrs        = 0.70;                        % Rear  spar  x/c
p.box_width_frac = p.xrs - p.xfs;           % Wingbox width / chord

%% ======================== Airfoil cross-section ratios ========================
%   From NACA 64A410 digitised data between front and rear spar
p.box_h_upper =  0.0485;                    % Upper skin z/c  at front spar
p.box_h_lower = -0.00735;                   % Lower skin z/c  at front spar
p.box_height_frac = p.box_h_upper - p.box_h_lower;  % Total box height / chord
p.front_spar_h_frac = 0.069;                % Front spar height / chord
p.rear_spar_h_frac  = 0.06215;              % Rear  spar height / chord

%% ======================== Masses ========================
p.MTOW       = 66704.28;                    % Max take-off mass [kg]
p.g          = 9.81;                        % Gravity [m/s^2]
p.W0         = p.MTOW * p.g;                % MTOW weight [N]

p.wing_mass_frac = 0.075;                    % Wing structural mass / MTOW (one wing)
p.wing_mass  = p.wing_mass_frac * p.MTOW;   % One-wing structural mass [kg]

% Fuel
p.fuel_vol_total = 15200;                   % Total fuel volume [L]
p.fuel_vol   = p.fuel_vol_total / 2;        % Fuel per wing [L]
p.fuel_rho   = 800;                         % Jet-A1 density [kg/m^3]
p.fuel_mass  = p.fuel_vol / 1000 * p.fuel_rho;  % Fuel mass per wing [kg]
p.fuel_span_frac = 0.75;                    % Fuel tank extent as fraction of semi-span

% Engine (pylon + nacelle mounted under wing)
p.engine_mass = 5700 + 3106.3;              % Engine + pylon mass [kg]
p.engine_eta  = 0.34;                       % Engine spanwise location (fraction of semi-span)

% Undercarriage (main gear - one leg per wing)
p.uc_mass    = 5271.2;                      % Total UC mass [kg]
p.uc_eta     = 0.0;                         % UC at wing root

%% ======================== Load Factors ========================
p.n_ult_pos  = 3.75;                        % Ultimate positive load factor (2.5 * 1.5)
p.n_ult_neg  = -1.5;                        % Ultimate negative load factor (-1.0 * 1.5)
p.n_limit    = 2.5;                         % Limit positive load factor
p.FoS        = 1.5;                         % Factor of safety

%% ======================== Flight Conditions ========================
p.alt_cruise = 43000 * 0.3048;              % Cruise altitude [m]
p.M_cruise   = 0.81;                        % Cruise Mach number
try
    [~, a_cr, ~, p.rho_cruise] = atmosisa(p.alt_cruise);
catch
    % Fallback ISA calculation if Aerospace Toolbox not available
    g0 = 9.80665; R = 287.0531; gam = 1.4; L = 0.0065;
    T_cr = 288.15 - L * min(p.alt_cruise, 11000);
    if p.alt_cruise > 11000
        T_cr = 216.65;                       % Stratosphere (constant T)
        rho_11 = 1.225 * (216.65/288.15)^(g0/(L*R) - 1);
        p.rho_cruise = rho_11 * exp(-g0*(p.alt_cruise-11000)/(R*216.65));
    else
        p.rho_cruise = 1.225 * (T_cr/288.15)^(g0/(L*R) - 1);
    end
    a_cr = sqrt(gam * R * T_cr);
end
p.V_cruise   = p.M_cruise * a_cr;           % Cruise TAS [m/s]
p.rho_SL     = 1.225;                       % Sea-level density [kg/m^3]
p.CL_alpha   = 5.2;                         % Lift-curve slope [1/rad]
p.CM0        = -0.09;                       % Zero-lift pitching moment coeff

%% ======================== Material Properties ========================
% Primary skin / stringer material:  Al 7068-T6511
p.mat.name       = 'Al 7068-T6511';
p.mat.E          = 71.2e9;                  % Young's modulus [Pa]
p.mat.Et         = 71.2e9;                  % Tangent modulus [Pa]
p.mat.G          = 26.9e9;                  % Shear modulus [Pa]
p.mat.sigma_y_c  = 655e6;                   % Compressive yield [Pa]
p.mat.sigma_y_t  = 683e6;                   % Tensile yield [Pa]
p.mat.sigma_ult  = 710e6;                   % Ultimate tensile [Pa]
p.mat.tau_y      = 655e6 / sqrt(3);         % Shear yield (von Mises) [Pa]
p.mat.nu         = 0.343;                   % Poisson's ratio
p.mat.rho        = 2850;                    % Density [kg/m^3]

% Rib material:  Al 7075-T6
p.rib.E          = 67e9;                    % Young's modulus [Pa]
p.rib.G          = 25.2e9;                  % Shear modulus [Pa]
p.rib.sigma_y    = 541e6;                   % Yield [Pa]
p.rib.rho        = 2910;                    % Density [kg/m^3]

%% ======================== Discretisation ========================
p.N_stations = 1000;                        % Number of spanwise stations
p.y = linspace(0, p.semi_span, p.N_stations); % Spanwise coordinates [m]

end
