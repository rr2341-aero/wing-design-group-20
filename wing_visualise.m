function wing_visualise(results)
% WING_VISUALISE  Structural visualisation plots for the G11 wing design.
%
%   wing_visualise(results)   % pass results struct from run_wing_design
%   wing_visualise()          % auto-loads wing_design_results.mat
%
%   Generates three figures:
%     Fig 1 - Wing planform (top-down), colour-coded by upper skin thickness
%     Fig 2 - 3-D wingbox perspective with ribs, spar webs, upper/lower skins
%     Fig 3 - Structural cross-section slices at 25%, 50%, 75% semi-span
%
%   Figures are exported as PDFs to the /figures/ folder.

%% ── Load results ──────────────────────────────────────────────────────────
if nargin < 1
    fn = fullfile(fileparts(mfilename('fullpath')), 'wing_design_results.mat');
    if ~exist(fn, 'file')
        error('wing_design_results.mat not found. Run run_wing_design.m first.');
    end
    S = load(fn);
    results = S.results;
end

p       = results.params;
ssr     = results.ssr;
lp      = results.lower;
spars   = results.spars;
loads   = results.loads;
str     = results.stringer;

%% ── Geometry helper functions ─────────────────────────────────────────────
s       = p.semi_span;
lam_rad = p.sweep_LE * pi / 180;

chord_  = @(y) p.c_root * (1 - (1 - p.lambda) .* y ./ s);
xLE_    = @(y) y .* tan(lam_rad);
xFS_    = @(y) xLE_(y) + p.xfs .* chord_(y);
xRS_    = @(y) xLE_(y) + p.xrs .* chord_(y);
xTE_    = @(y) xLE_(y) + chord_(y);

%% ── Pre-compute rib-station geometry ──────────────────────────────────────
y_r     = ssr.y_pos;          % rib y-positions [m]
n_r     = ssr.n_ribs;
xFS_r   = xFS_(y_r);
xRS_r   = xRS_(y_r);
h_r     = ssr.h_box;          % wingbox height at each rib [m]
c_box_r = ssr.c_box;          % wingbox width  at each rib [m]

t_upper = ssr.t_skin_manu;    % upper skin thickness [mm], length n_r
t_lower = lp.t_skin;          % lower skin thickness [mm], length n_r
t_min   = min(t_upper);
t_max   = max(t_upper);
t_norm  = (t_upper - t_min) ./ (t_max - t_min + eps);

cmap    = parula(256);

%% ════════════════════════════════════════════════════════════════════════════
%  FIGURE 1 – Wing Planform (top-down, colour-coded by upper skin thickness)
%% ════════════════════════════════════════════════════════════════════════════
f1 = figure('Color','w', 'Position',[40 50 1120 550], 'Name','Wing Planform');
ax1 = axes(f1);
hold(ax1,'on'); axis(ax1,'equal');

% --- Colour panels by upper skin thickness (wingbox region) ---
for j = 1:n_r - 1
    py = [xFS_r(j),  xRS_r(j),  xRS_r(j+1), xFS_r(j+1)];
    px = [y_r(j),    y_r(j),    y_r(j+1),   y_r(j+1)  ];
    t_avg = (t_upper(j) + t_upper(j+1)) / 2;
    ci = max(1, min(256, round((t_avg - t_min)/(t_max - t_min + eps)*255)+1));
    patch(ax1,  px, py, cmap(ci,:), 'EdgeColor','none');  % right wing
    patch(ax1, -px, py, cmap(ci,:), 'EdgeColor','none');  % left wing
end

% --- Fuel tank shading ---
y_fuel = p.fuel_span_frac * s;
patch(ax1, [0, y_fuel,  y_fuel,  0], ...
           [xFS_(0), xFS_(y_fuel), xRS_(y_fuel), xRS_(0)], ...
           [0.25 0.55 1.0], 'FaceAlpha',0.20, 'EdgeColor','none');
patch(ax1, [0, -y_fuel, -y_fuel, 0], ...
           [xFS_(0), xFS_(y_fuel), xRS_(y_fuel), xRS_(0)], ...
           [0.25 0.55 1.0], 'FaceAlpha',0.20, 'EdgeColor','none');

% --- Wing outline: LE and TE ---
y_v = linspace(0, s, 300);
plot(ax1,  y_v,  xLE_(y_v), 'k-', 'LineWidth',2.0);
plot(ax1,  y_v,  xTE_(y_v), 'k-', 'LineWidth',2.0);
plot(ax1, -y_v,  xLE_(y_v), 'k-', 'LineWidth',2.0);
plot(ax1, -y_v,  xTE_(y_v), 'k-', 'LineWidth',2.0);
% Tip chord
plot(ax1, [ s,  s], [xLE_(s), xTE_(s)], 'k-', 'LineWidth',1.5);
plot(ax1, [-s, -s], [xLE_(s), xTE_(s)], 'k-', 'LineWidth',1.5);
% Fuselage side walls
plot(ax1, [ p.fus_w/2,  p.fus_w/2], [xLE_(0), xTE_(0)], 'k-', 'LineWidth',1.5);
plot(ax1, [-p.fus_w/2, -p.fus_w/2], [xLE_(0), xTE_(0)], 'k-', 'LineWidth',1.5);

% --- Front and rear spars ---
h_fs = plot(ax1,  y_v,  xFS_(y_v), 'b-', 'LineWidth',1.6);
       plot(ax1, -y_v,  xFS_(y_v), 'b-', 'LineWidth',1.6);
h_rs = plot(ax1,  y_v,  xRS_(y_v), 'r-', 'LineWidth',1.6);
       plot(ax1, -y_v,  xRS_(y_v), 'r-', 'LineWidth',1.6);

% --- Ribs ---
for j = 1:n_r
    plot(ax1, [ y_r(j),  y_r(j)], [xFS_r(j), xRS_r(j)], '-', ...
        'Color',[0.55 0.55 0.55], 'LineWidth',0.6);
    plot(ax1, [-y_r(j), -y_r(j)], [xFS_r(j), xRS_r(j)], '-', ...
        'Color',[0.55 0.55 0.55], 'LineWidth',0.6);
end

% --- Engine markers ---
y_eng = p.engine_eta * s;
x_eng = xLE_(y_eng) + 0.37 * chord_(y_eng);
h_eng = plot(ax1,  y_eng, x_eng, 'k^', 'MarkerSize',12, 'MarkerFaceColor',[0.15 0.15 0.15]);
        plot(ax1, -y_eng, x_eng, 'k^', 'MarkerSize',12, 'MarkerFaceColor',[0.15 0.15 0.15]);
text(ax1,  y_eng + 0.3, x_eng - 0.15, 'Engine', 'FontSize',9, 'Color','k');

% --- Fuselage outline ---
plot(ax1, [-p.fus_w/2, -p.fus_w/2,  p.fus_w/2,  p.fus_w/2, -p.fus_w/2], ...
          [ xLE_(0),    xTE_(0),     xTE_(0),    xLE_(0),    xLE_(0)], ...
          'k-', 'LineWidth',2.5);

% --- Fuel label ---
text(ax1, y_fuel*0.45, xFS_(y_fuel*0.45) + 0.12, 'Fuel', ...
    'FontSize',10, 'Color',[0 0.25 0.75], 'HorizontalAlignment','center');

% --- Colourbar ---
colormap(ax1, cmap);
clim(ax1, [t_min, t_max]);
cb1 = colorbar(ax1, 'Location','eastoutside');
cb1.Label.String = 'Upper skin thickness [mm]';
cb1.Label.FontSize = 12;

% --- Formatting ---
set(ax1, 'YDir','reverse', 'FontSize',12);   % LE at top
xlabel(ax1, 'Spanwise y [m]', 'FontSize',14);
ylabel(ax1, 'Chordwise x [m]', 'FontSize',14);
title(ax1, 'G11 Wing Planform  –  Upper Skin Thickness (colour)', 'FontSize',14);

% Dummy handles for legend
hs1 = patch(ax1,NaN,NaN,cmap(200,:),'DisplayName','Upper skin (thickness)');
hs2 = patch(ax1,NaN,NaN,[0.25 0.55 1.0],'FaceAlpha',0.3,'DisplayName','Fuel tank');
legend(ax1, [hs1, hs2, h_fs, h_rs, h_eng], ...
    {'Upper skin (t coded)','Fuel tank','Front spar','Rear spar','Engine'}, ...
    'Location','northeast','FontSize',10);
grid(ax1,'on');

%% ════════════════════════════════════════════════════════════════════════════
%  FIGURE 2 – 3-D Wingbox Perspective
%% ════════════════════════════════════════════════════════════════════════════
f2 = figure('Color','w', 'Position',[70 70 1060 640], 'Name','3D Wingbox');
ax2 = axes(f2);
hold(ax2,'on'); grid(ax2,'on');

% Rib step: show ~14 rib plates to avoid crowding
rib_step = max(1, round(n_r / 14));

for j = 1:n_r - 1
    ci = max(1, min(256, round(((t_norm(j)+t_norm(j+1))/2)*255)+1));

    % Upper skin panel  (z = +h/2)
    Xu = [xFS_r(j),   xRS_r(j),   xRS_r(j+1),  xFS_r(j+1) ];
    Yu = [y_r(j),     y_r(j),     y_r(j+1),    y_r(j+1)   ];
    Zu = [h_r(j)/2,   h_r(j)/2,   h_r(j+1)/2,  h_r(j+1)/2 ];
    patch(ax2, Xu, Yu, Zu, cmap(ci,:), 'EdgeColor',[0.50 0.50 0.50], 'LineWidth',0.3);

    % Lower skin panel  (z = -h/2)
    patch(ax2, Xu, Yu, -Zu, [0.40 0.70 0.40], ...
          'EdgeColor',[0.30 0.55 0.30], 'LineWidth',0.3);

    % Front spar web
    patch(ax2, ...
        [xFS_r(j),  xFS_r(j+1), xFS_r(j+1),  xFS_r(j)  ], ...
        [y_r(j),    y_r(j+1),   y_r(j+1),    y_r(j)    ], ...
        [h_r(j)/2,  h_r(j+1)/2,-h_r(j+1)/2, -h_r(j)/2 ], ...
        [0.15 0.35 0.82], 'EdgeColor','none', 'FaceAlpha',0.68);

    % Rear spar web
    patch(ax2, ...
        [xRS_r(j),  xRS_r(j+1), xRS_r(j+1),  xRS_r(j)  ], ...
        [y_r(j),    y_r(j+1),   y_r(j+1),    y_r(j)    ], ...
        [h_r(j)/2,  h_r(j+1)/2,-h_r(j+1)/2, -h_r(j)/2 ], ...
        [0.82 0.15 0.15], 'EdgeColor','none', 'FaceAlpha',0.68);
end

% Rib plates
for j = 1:rib_step:n_r
    patch(ax2, ...
        [xFS_r(j), xRS_r(j), xRS_r(j), xFS_r(j)], ...
        [y_r(j),   y_r(j),   y_r(j),   y_r(j)  ], ...
        [h_r(j)/2, h_r(j)/2,-h_r(j)/2,-h_r(j)/2], ...
        [0.92 0.86 0.08], 'EdgeColor','k', 'FaceAlpha',0.75, 'LineWidth',0.7);
end

% Formatting
colormap(ax2, cmap);
clim(ax2, [t_min, t_max]);
cb2 = colorbar(ax2, 'Location','eastoutside');
cb2.Label.String = 'Upper skin thickness [mm]';
cb2.Label.FontSize = 12;

% Legend proxies
leg2 = [ patch(ax2,NaN,NaN,NaN,cmap(200,:), 'DisplayName','Upper skin (thickness coded)'), ...
         patch(ax2,NaN,NaN,NaN,[0.40 0.70 0.40], 'DisplayName','Lower skin'), ...
         patch(ax2,NaN,NaN,NaN,[0.15 0.35 0.82], 'DisplayName','Front spar web'), ...
         patch(ax2,NaN,NaN,NaN,[0.82 0.15 0.15], 'DisplayName','Rear spar web'), ...
         patch(ax2,NaN,NaN,NaN,[0.92 0.86 0.08], 'DisplayName','Ribs') ];
legend(ax2, leg2, 'Location','northeast', 'FontSize',10);

xlabel(ax2,'Chordwise x [m]','FontSize',13);
ylabel(ax2,'Spanwise y [m]','FontSize',13);
zlabel(ax2,'Vertical z [m]','FontSize',13);
title(ax2,'G11 Wingbox Structure  –  3D Perspective','FontSize',14);
set(ax2,'FontSize',11);
view(ax2,-38,28);
axis(ax2,'tight');

%% ════════════════════════════════════════════════════════════════════════════
%  FIGURE 3 – Structural Cross-Sections at 25%, 50%, 75% semi-span
%% ════════════════════════════════════════════════════════════════════════════
f3 = figure('Color','w', 'Position',[110 110 1250 480], 'Name','Cross-Sections');

% Stringer Z-section dimensions [m]
h_str_m  = str.h  / 1000;              % web height
d_str_m  = str.r_sfw * str.h / 1000;  % flange width
ts_str_m = str.ts / 1000;             % section thickness (for line weight only)

eta_vals  = [0.25, 0.50, 0.75];
eta_label = {'25% span','50% span','75% span'};

ax3_handles = gobjects(1,3);

for k = 1:3
    y_k  = eta_vals(k) * s;
    c_k  = chord_(y_k);
    tc_k = p.tc_root + (p.tc_tip - p.tc_root) * eta_vals(k);   % local t/c

    % Nearest rib for structural data
    [~, j_k] = min(abs(y_r - y_k));
    h_k      = h_r(j_k);           % wingbox height [m]
    b_k      = c_box_r(j_k);       % wingbox width  [m]
    n_str_k  = ssr.n_str(j_k);

    t_up_m  = t_upper(j_k) / 1000;
    t_lo_m  = t_lower(j_k) / 1000;

    % Nearest load station for spar thicknesses
    [~, idx_s] = min(abs(loads.y - y_k));
    tw_f_m  = max(spars.tw_front_manu(idx_s), 1) / 1000;
    tw_r_m  = max(spars.tw_rear_manu(idx_s),  1) / 1000;
    tf_f_m  = max(spars.tf_front(idx_s),      1) / 1000;
    tf_r_m  = max(spars.tf_rear(idx_s),       1) / 1000;

    % Wingbox coordinates: x=0 at FS, x=b_k at RS, z=0 at centreline
    x0 = 0;   x1 = b_k;
    zu = h_k / 2;   zl = -h_k / 2;

    ax3 = subplot(1,3,k,'Parent',f3);
    ax3_handles(k) = ax3;
    hold(ax3,'on'); axis(ax3,'equal');

    % --- Airfoil silhouette (NACA 4-digit thickness distribution) ---
    xn = linspace(0, 1, 200);
    y_af = 5*tc_k*(0.2969*sqrt(xn) - 0.1260*xn - 0.3516*xn.^2 ...
                 + 0.2843*xn.^3 - 0.1015*xn.^4) * c_k;
    x_af = xn * c_k - p.xfs * c_k;    % shift: FS at x=0
    fill(ax3, [x_af, fliplr(x_af)], [y_af, -fliplr(y_af)], ...
        [0.92 0.92 0.92], 'EdgeColor',[0.40 0.40 0.40], ...
        'LineWidth',0.8, 'FaceAlpha',0.55);

    % --- Upper skin (blue panel) ---
    patch(ax3, [x0, x1, x1, x0], [zu, zu, zu-t_up_m, zu-t_up_m], ...
        [0.18 0.40 0.88], 'EdgeColor','k', 'LineWidth',0.8);

    % --- Lower skin (green panel) ---
    patch(ax3, [x0, x1, x1, x0], [zl+t_lo_m, zl+t_lo_m, zl, zl], ...
        [0.20 0.72 0.28], 'EdgeColor','k', 'LineWidth',0.8);

    % --- Front spar web ---
    patch(ax3, [-tw_f_m, 0, 0, -tw_f_m], [zu, zu, zl, zl], ...
        [0.15 0.35 0.82], 'EdgeColor','k', 'LineWidth',0.8);

    % --- Rear spar web ---
    patch(ax3, [x1, x1+tw_r_m, x1+tw_r_m, x1], [zu, zu, zl, zl], ...
        [0.82 0.15 0.15], 'EdgeColor','k', 'LineWidth',0.8);

    % --- Spar caps (extend inward from each spar) ---
    b_cap_vis = min(0.06 * c_k, b_k * 0.20);   % visual cap width
    cap_col   = [0.65 0.42 0.10];
    % Front spar: upper and lower caps
    patch(ax3, [0, b_cap_vis, b_cap_vis, 0], [zu, zu, zu+tf_f_m, zu+tf_f_m], ...
        cap_col, 'EdgeColor','k', 'LineWidth',0.6);
    patch(ax3, [0, b_cap_vis, b_cap_vis, 0], [zl-tf_f_m, zl-tf_f_m, zl, zl], ...
        cap_col, 'EdgeColor','k', 'LineWidth',0.6);
    % Rear spar: upper and lower caps
    patch(ax3, [x1-b_cap_vis, x1, x1, x1-b_cap_vis], [zu, zu, zu+tf_r_m, zu+tf_r_m], ...
        cap_col, 'EdgeColor','k', 'LineWidth',0.6);
    patch(ax3, [x1-b_cap_vis, x1, x1, x1-b_cap_vis], [zl-tf_r_m, zl-tf_r_m, zl, zl], ...
        cap_col, 'EdgeColor','k', 'LineWidth',0.6);

    % --- Upper stringers (simplified Z-section: web + foot flange) ---
    % Show max 14 stringers for readability
    str_step  = max(1, ceil(n_str_k / 14));
    str_pitch = b_k / n_str_k;
    z_base    = zu - t_up_m;      % inner face of upper skin
    z_web_end = z_base - h_str_m; % bottom of stringer web

    for si = 1:str_step:n_str_k
        xs = x0 + (si - 0.5) * str_pitch;
        % Foot (skin-side) flange
        plot(ax3, [xs - d_str_m/2, xs + d_str_m/2], [z_base,    z_base   ], ...
            'b-', 'LineWidth',1.1);
        % Web
        plot(ax3, [xs,             xs            ], [z_base,    z_web_end], ...
            'b-', 'LineWidth',1.1);
        % Free flange
        plot(ax3, [xs - d_str_m/2, xs + d_str_m/2], [z_web_end, z_web_end], ...
            'b-', 'LineWidth',1.1);
    end

    % --- Annotations ---
    title(ax3, sprintf('%s  (y = %.1f m)', eta_label{k}, y_k), 'FontSize',11);
    if k == 1
        ylabel(ax3,'Vertical [m]','FontSize',11);
    end
    xlabel(ax3,'Chordwise [m]','FontSize',11);
    set(ax3,'FontSize',10);
    grid(ax3,'on');

    % Dimension callout below the cross-section
    info = sprintf( ...
        'c = %.2f m,  h_{box} = %.0f mm\nt_{up} = %d mm,  t_{lo} = %d mm\n%d stringers (showing %d)', ...
        c_k, h_k*1000, t_upper(j_k), t_lower(j_k), ...
        n_str_k, length(1:str_step:n_str_k));
    ylims = ylim(ax3);
    text(ax3, b_k/2, ylims(1) - 0.02*(ylims(2)-ylims(1)), info, ...
        'FontSize',8, 'HorizontalAlignment','center', 'VerticalAlignment','top');

    % x-limits: show full airfoil chord with small margin
    xlim(ax3, [-p.xfs*c_k - 0.06, b_k + (1-p.xrs)*c_k + 0.06]);
end

sgtitle(f3,'G11 Wingbox Cross-Sections','FontSize',14,'FontWeight','bold');

% Legend on the rightmost subplot
ax_r = ax3_handles(3);
hl = [ patch(ax_r,NaN,NaN,[0.92 0.92 0.92],'EdgeColor',[0.4 0.4 0.4], ...
             'DisplayName','Airfoil silhouette'), ...
       patch(ax_r,NaN,NaN,[0.18 0.40 0.88],'DisplayName','Upper skin'), ...
       patch(ax_r,NaN,NaN,[0.20 0.72 0.28],'DisplayName','Lower skin'), ...
       patch(ax_r,NaN,NaN,[0.15 0.35 0.82],'DisplayName','Front spar web'), ...
       patch(ax_r,NaN,NaN,[0.82 0.15 0.15],'DisplayName','Rear spar web'), ...
       patch(ax_r,NaN,NaN,[0.65 0.42 0.10],'DisplayName','Spar caps'), ...
       plot( ax_r,NaN,NaN,'b-','LineWidth',1.5,'DisplayName','Stringers (Z-section)') ];
legend(ax_r, hl, 'Location','southeast', 'FontSize',8);

%% ════════════════════════════════════════════════════════════════════════════
%  FIGURE 4 – Stringer Layout on Upper and Lower Skins (Planform View)
%% ════════════════════════════════════════════════════════════════════════════
f4 = figure('Color','w', 'Position',[160 140 1200 580], 'Name','Stringer Layout');

col_up   = [0.15 0.35 0.80];   % blue  – upper stringers
col_full = [0.08 0.58 0.12];   % green – lower full panel
col_half = [0.88 0.50 0.00];   % orange – lower half panel

y_v4 = linspace(0, s, 300);

% ── Upper skin ──────────────────────────────────────────────────────────────
ax4a = subplot(1,2,1,'Parent',f4);
hold(ax4a,'on'); axis(ax4a,'equal');

% Wing outline
plot(ax4a,  y_v4,  xLE_(y_v4), 'k-', 'LineWidth',1.5);
plot(ax4a,  y_v4,  xTE_(y_v4), 'k-', 'LineWidth',1.5);
plot(ax4a, [s,s], [xLE_(s), xTE_(s)], 'k-', 'LineWidth',1.5);
plot(ax4a, [p.fus_w/2, p.fus_w/2], [xLE_(0), xTE_(0)], 'k-', 'LineWidth',1.5);

% Spars
plot(ax4a, y_v4, xFS_(y_v4), 'b-', 'LineWidth',1.0);
plot(ax4a, y_v4, xRS_(y_v4), 'r-', 'LineWidth',1.0);

% Rib lines (faint)
for j = 1:n_r
    plot(ax4a, [y_r(j), y_r(j)], [xFS_r(j), xRS_r(j)], '-', ...
        'Color',[0.78 0.78 0.78], 'LineWidth',0.5);
end

% Upper stringers – fixed fractional position based on ROOT count.
% Using n_root as denominator at every station keeps each stringer at a
% constant fraction of the box width → lines run parallel to the spar.
% Stringers k > n_str(j) have simply terminated (RS side first).
n_root_up = str.n_root;
for k = 1:n_root_up
    fk = (k - 0.5) / n_root_up;   % fixed fraction for all stations

    for j = 1:n_r-1
        exists_j  = (ssr.n_str(j)   >= k);
        exists_j1 = (ssr.n_str(j+1) >= k);

        if exists_j && exists_j1
            % Draw segment parallel to spar
            xk_j  = xFS_r(j)   + fk * c_box_r(j);
            xk_j1 = xFS_r(j+1) + fk * c_box_r(j+1);
            plot(ax4a, [y_r(j), y_r(j+1)], [xk_j, xk_j1], '-', ...
                'Color',col_up, 'LineWidth',0.7);
        elseif exists_j && ~exists_j1
            % Termination marker at the last rib where stringer exists
            xk_end = xFS_r(j) + fk * c_box_r(j);
            plot(ax4a, y_r(j), xk_end, '.', 'Color',col_up, 'MarkerSize',8);
        end
    end
end

% Extend surviving upper stringers from the outermost rib to the physical
% wing tip (y = s).  The stringer bay-loop above only draws to y_r(n_r)
% (~0.98·s); this segment closes the gap to the tip chord line.
c_box_tip_vis = xRS_(s) - xFS_(s);   % wingbox chord at physical tip [m]
for k = 1:n_root_up
    if ssr.n_str(n_r) >= k
        fk     = (k - 0.5) / n_root_up;
        xk_nr  = xFS_r(n_r) + fk * c_box_r(n_r);
        xk_tip = xFS_(s)    + fk * c_box_tip_vis;
        plot(ax4a, [y_r(n_r), s], [xk_nr, xk_tip], '-', ...
            'Color', col_up, 'LineWidth', 0.7);
    end
end

% Formatting
set(ax4a,'YDir','reverse','FontSize',11);
xlabel(ax4a,'Spanwise y [m]','FontSize',12);
ylabel(ax4a,'Chordwise x [m]','FontSize',12);
title(ax4a, sprintf('Upper skin  (n_{root} = %d,  h = %.0f mm,  t_s = %.1f mm)', ...
    str.n_root, str.h, str.ts), 'FontSize',11);
grid(ax4a,'on');
h_up   = plot(ax4a,NaN,NaN,'-','Color',col_up,'LineWidth',1.5,'DisplayName','Stringer (active)');
h_term = plot(ax4a,NaN,NaN,'.','Color',col_up,'MarkerSize',10,'DisplayName','Stringer termination');
legend(ax4a,[h_up, h_term],'Location','northeast','FontSize',9);

% ── Lower skin ──────────────────────────────────────────────────────────────
ax4b = subplot(1,2,2,'Parent',f4);
hold(ax4b,'on'); axis(ax4b,'equal');

% Wing outline
plot(ax4b,  y_v4,  xLE_(y_v4), 'k-', 'LineWidth',1.5);
plot(ax4b,  y_v4,  xTE_(y_v4), 'k-', 'LineWidth',1.5);
plot(ax4b, [s,s], [xLE_(s), xTE_(s)], 'k-', 'LineWidth',1.5);
plot(ax4b, [p.fus_w/2, p.fus_w/2], [xLE_(0), xTE_(0)], 'k-', 'LineWidth',1.5);

% Spars
plot(ax4b, y_v4, xFS_(y_v4), 'b-', 'LineWidth',1.0);
plot(ax4b, y_v4, xRS_(y_v4), 'r-', 'LineWidth',1.0);

% Rib lines with panel-type shading in background
for j = 1:n_r-1
    pt_j = lp.panel_type(j);
    if pt_j == 0
        shade_col = [0.93 0.93 0.93];   % no stringers – light grey patch
    elseif pt_j == 0.5
        shade_col = [1.00 0.94 0.82];   % half panel – light orange
    else
        shade_col = [0.88 0.96 0.88];   % full panel – light green
    end
    patch(ax4b, ...
        [y_r(j),    y_r(j+1), y_r(j+1), y_r(j)  ], ...
        [xFS_r(j),  xFS_r(j+1), xRS_r(j+1), xRS_r(j)], ...
        shade_col, 'EdgeColor','none', 'FaceAlpha',0.6);
end

% Rib lines (faint, on top of shading)
for j = 1:n_r
    plot(ax4b, [y_r(j), y_r(j)], [xFS_r(j), xRS_r(j)], '-', ...
        'Color',[0.70 0.70 0.70], 'LineWidth',0.5);
end

% Lower stringers – fixed fractional position based on ROOT count.
% All n_l_root stringers run the full span (consistent with lower_panel_design:
% pitch narrows toward tip, which only helps buckling).  Visibility per bay
% is governed purely by panel_type (full / half / none).
n_l_root = lp.stringer.n_root;
for k = 1:n_l_root
    fk = (k - 0.5) / n_l_root;   % fixed fraction for all stations

    for j = 1:n_r-1
        pt_j = lp.panel_type(j);
        if pt_j == 0, continue; end                          % no stringers in bay
        if pt_j == 0.5 && mod(k,2) == 0, continue; end      % half panel: skip evens

        xk_j  = xFS_r(j)   + fk * c_box_r(j);
        xk_j1 = xFS_r(j+1) + fk * c_box_r(j+1);

        col = col_full;
        if pt_j == 0.5, col = col_half; end

        plot(ax4b, [y_r(j), y_r(j+1)], [xk_j, xk_j1], '-', ...
            'Color',col, 'LineWidth',0.7);
    end
end

% Extend lower stringers from the outermost rib to the physical wing tip.
% All n_l_root stringers extend (consistent with the bay loop above);
% visibility is governed only by panel_type at the last rib.
pt_nr = lp.panel_type(n_r);
if pt_nr > 0
    for k = 1:n_l_root
        if pt_nr == 0.5 && mod(k,2) == 0, continue; end
        fk     = (k - 0.5) / n_l_root;
        xk_nr  = xFS_r(n_r) + fk * c_box_r(n_r);
        xk_tip = xFS_(s)    + fk * c_box_tip_vis;
        col = col_full;
        if pt_nr == 0.5, col = col_half; end
        plot(ax4b, [y_r(n_r), s], [xk_nr, xk_tip], '-', ...
            'Color', col, 'LineWidth', 0.7);
    end
end

% Formatting
set(ax4b,'YDir','reverse','FontSize',11);
xlabel(ax4b,'Spanwise y [m]','FontSize',12);
ylabel(ax4b,'Chordwise x [m]','FontSize',12);
title(ax4b, sprintf('Lower skin  (n_{root} = %d,  h = %.0f mm,  t_s = %.1f mm)', ...
    n_l_root, lp.stringer.h, lp.stringer.ts), 'FontSize',11);
grid(ax4b,'on');

hl1 = patch(ax4b,NaN,NaN,col_full, 'DisplayName','Full panel (all stringers)');
hl2 = patch(ax4b,NaN,NaN,col_half, 'DisplayName','Half panel (every other)');
hl3 = patch(ax4b,NaN,NaN,[0.85 0.85 0.85], 'DisplayName','No stringers');
legend(ax4b,[hl1,hl2,hl3],'Location','northeast','FontSize',9);

sgtitle(f4,'G11 Wing Stringer Layout','FontSize',14,'FontWeight','bold');

%% ── Export figures ────────────────────────────────────────────────────────
fig_dir = fullfile(fileparts(mfilename('fullpath')), 'figures');
if ~exist(fig_dir, 'dir'), mkdir(fig_dir); end
exportgraphics(f1, fullfile(fig_dir,'wing_planform.pdf'),   'ContentType','vector');
exportgraphics(f2, fullfile(fig_dir,'wingbox_3d.pdf'),      'ContentType','vector');
exportgraphics(f3, fullfile(fig_dir,'cross_sections.pdf'),  'ContentType','vector');
exportgraphics(f4, fullfile(fig_dir,'stringer_layout.pdf'), 'ContentType','vector');
fprintf('>> Wing visualisation complete. Figures saved to /figures/\n');

end
