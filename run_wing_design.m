%% RUN_WING_DESIGN  Master script for G11 wing structural optimisation.
%
%   This script orchestrates the full wing design workflow:
%     1. Load aircraft & wing parameters
%     2. Compute spanwise loads (aero, inertial, torque)
%     3. Design upper panel (Skin-Stringer-Rib) using Catchpole/Farrar
%     4. Optimise upper panel stringer geometry
%     5. Design lower panel
%     6. Design spar webs and caps
%     7. Summarise total wing mass
%     8. Generate all plots
%
%   Building on: prelim_load_ben.m (loads) + prev year Wing code (SSR method)
%   Technique reference: Lecture 3 - Wing Structural Design

clc; clear; close all;

fprintf('==============================================\n');
fprintf('   G11 WING STRUCTURAL DESIGN & OPTIMISATION  \n');
fprintf('==============================================\n\n');

%% ================================================================
%  STEP 1: PARAMETERS
% =================================================================
fprintf('>> Loading parameters...\n');
p = wing_params();
fprintf('   Wingspan:    %.2f m\n', p.b);
fprintf('   Semi-span:   %.2f m\n', p.semi_span);
fprintf('   Root chord:  %.2f m\n', p.c_root);
fprintf('   Tip chord:   %.2f m\n', p.c_tip);
fprintf('   MTOW:        %.0f kg\n', p.MTOW);
fprintf('   n_ult:       +%.2f / %.2f\n\n', p.n_ult_pos, p.n_ult_neg);

%% ================================================================
%  STEP 2: WING LOADS
% =================================================================
fprintf('>> Computing wing loads (n = +%.2f)...\n', p.n_ult_pos);
loads_pos = wing_loads(p, p.n_ult_pos);

fprintf('>> Computing wing loads (n = %.2f)...\n', p.n_ult_neg);
loads_neg = wing_loads(p, abs(p.n_ult_neg));

fprintf('   Max shear force: %.1f kN\n', max(abs(loads_pos.V))/1e3);
fprintf('   Max bending moment: %.1f kNm\n', max(abs(loads_pos.M))/1e3);
fprintf('   Max torque: %.1f kNm\n\n', max(abs(loads_pos.T))/1e3);

%% ================================================================
%  STEP 3: UPPER PANEL SSR DESIGN (single configuration)
% =================================================================
fprintf('>> Designing upper panel (initial configuration)...\n');
stringer_init.n_root = 26;
stringer_init.ts     = 2.0;      % [mm]
stringer_init.h      = 76.4;     % [mm]
stringer_init.r_sfw  = 0.3;

ssr_init = ssr_design(p, loads_pos, stringer_init);

%% ================================================================
%  STEP 4: UPPER PANEL OPTIMISATION
% =================================================================
run_optimisation = true;   % <<< Set to true to run full sweep (slow!)

if run_optimisation
    fprintf('\n>> Running upper panel optimisation sweep...\n');
    [best_upper, sweep] = ssr_optimise(p, loads_pos);
    ssr_final = best_upper.result;
    stringer_final = best_upper.stringer;
else
    fprintf('\n>> Skipping optimisation sweep (set run_optimisation=true to enable)\n');
    fprintf('   Using initial configuration.\n');
    ssr_final = ssr_init;
    stringer_final = stringer_init;
end

%% ================================================================
%  STEP 5: LOWER PANEL OPTIMISATION + DESIGN
% =================================================================
run_lower_optimisation = true;   % <<< Set to false to skip (uses defaults)

if run_lower_optimisation
    fprintf('\n>> Running lower panel optimisation sweep...\n');
    [best_lower, sweep_lower] = lower_panel_optimise(p, loads_pos, ssr_final);
    stringer_lower_final = best_lower.stringer;
else
    fprintf('\n>> Skipping lower panel optimisation (using defaults).\n');
    stringer_lower_final.n_root = 8;
    stringer_lower_final.ts     = 2.4;
    stringer_lower_final.h      = 20;
    stringer_lower_final.r_sfw  = 0.3;
end

fprintf('>> Designing lower panel...\n');
lower = lower_panel_design(p, loads_pos, ssr_final, stringer_lower_final);

%% ================================================================
%  STEP 6: SPAR DESIGN
% =================================================================
fprintf('\n>> Designing spars...\n');
spars = spar_design(p, loads_pos);

%% ================================================================
%  STEP 7: MASS SUMMARY
% =================================================================
mass_upper = ssr_final.mass_total;
mass_lower = lower.mass_total;
mass_spars = spars.mass_total;
mass_wing  = mass_upper + mass_lower + mass_spars;

fprintf('\n');
fprintf('==============================================\n');
fprintf('   WING MASS SUMMARY (per wing)              \n');
fprintf('==============================================\n');
fprintf('   Upper panel (skin+stringer+ribs): %7.1f kg\n', mass_upper);
fprintf('   Lower panel (skin+stringer):      %7.1f kg\n', mass_lower);
fprintf('   Spars (webs + caps):              %7.1f kg\n', mass_spars);
fprintf('   ----------------------------------------\n');
fprintf('   TOTAL per wing:                   %7.1f kg\n', mass_wing);
fprintf('   TOTAL both wings:                 %7.1f kg\n', mass_wing * 2);
fprintf('   Wing mass / MTOW:                 %5.1f %%\n', ...
    mass_wing * 2 / (p.MTOW * p.g) * p.g * 100);
fprintf('==============================================\n\n');

%% ================================================================
%  STEP 8: PLOTS
% =================================================================
fprintf('>> Generating plots...\n\n');

y     = loads_pos.y;
y_rib = ssr_final.y_pos;

% ---- Plot formatting settings ----
lineW = 2.0;
tickF = 14;
labelF = 16;
legendF = 12;

%% --- FIGURE 1: Wing Loads (3-panel) ---
f1 = figure('Color','w','Position',[50 50 800 750],'Name','Wing Loads');
tiledlayout(3,1,'TileSpacing','compact','Padding','compact')

nexttile
plot(y, loads_pos.w_total/1e3, 'LineWidth', lineW); hold on
plot(y, loads_pos.lift/1e3, '--', 'LineWidth', 1.2);
plot(y, -loads_pos.w_wing/1e3, '--', 'LineWidth', 1.2);
plot(y, -loads_pos.w_fuel/1e3, '--', 'LineWidth', 1.2);
ylabel('Load [kN/m]','FontSize',labelF)
legend('Net load','Lift','Wing weight','Fuel weight','FontSize',legendF,'Location','best')
grid on; set(gca,'FontSize',tickF)

nexttile
plot(y, loads_pos.V/1e3, 'LineWidth', lineW);
ylabel('Shear Force [kN]','FontSize',labelF)
grid on; set(gca,'FontSize',tickF)

nexttile
plot(y, loads_pos.M/1e6, 'LineWidth', lineW); hold on
plot(y, loads_pos.M_nofuel/1e6, '--', 'LineWidth', 1.2);
ylabel('Bending Moment [MN\cdotm]','FontSize',labelF)
xlabel('Spanwise coordinate y [m]','FontSize',labelF)
legend('With fuel','No fuel','FontSize',legendF)
grid on; set(gca,'FontSize',tickF)

%% --- FIGURE 2: Torque ---
f2 = figure('Color','w','Position',[100 100 700 400],'Name','Wing Torque');
plot(y, loads_pos.T/1e3, 'LineWidth', lineW);
xlabel('Spanwise coordinate y [m]','FontSize',labelF)
ylabel('Torque [kN\cdotm]','FontSize',labelF)
grid on; set(gca,'FontSize',tickF)
title('Spanwise Torque Distribution')

%% --- FIGURE 3: Upper Panel - Skin Thickness & Rib Spacing ---
f3 = figure('Color','w','Position',[150 150 900 650],'Name','Upper Panel SSR');
tiledlayout(2,2,'TileSpacing','compact','Padding','compact')

nexttile
stairs(y_rib, ssr_final.t_skin_manu, 'b-', 'LineWidth', lineW); hold on
plot(y_rib, ssr_final.t_skin, 'r--', 'LineWidth', 1.2);
ylabel('Skin thickness [mm]','FontSize',labelF)
xlabel('y [m]','FontSize',labelF)
legend('Manufacturable','Ideal','FontSize',legendF)
grid on; set(gca,'FontSize',tickF)
title('Upper Skin Thickness')

nexttile
bar(y_rib, ssr_final.L_rib * 1000, 'FaceColor', [0.3 0.6 0.9]);
ylabel('Rib spacing [mm]','FontSize',labelF)
xlabel('y [m]','FontSize',labelF)
grid on; set(gca,'FontSize',tickF)
title('Rib Spacing')

nexttile
plot(y_rib, ssr_final.sig_0, 'b-', 'LineWidth', lineW); hold on
plot(y_rib, ssr_final.sig_cr, 'r-', 'LineWidth', lineW);
yline(p.mat.sigma_y_c/1e6, 'k--', 'LineWidth', 1.2);
ylabel('Stress [MPa]','FontSize',labelF)
xlabel('y [m]','FontSize',labelF)
legend('\sigma_0','\sigma_{cr}','\sigma_{y,c}','FontSize',legendF)
grid on; set(gca,'FontSize',tickF)
title('Upper Panel Stresses')

nexttile
stairs(y_rib, ssr_final.tr_manu, 'b-', 'LineWidth', lineW); hold on
plot(y_rib, ssr_final.tr, 'r--', 'LineWidth', 1.2);
ylabel('Rib thickness [mm]','FontSize',labelF)
xlabel('y [m]','FontSize',labelF)
legend('Manufacturable','Ideal','FontSize',legendF)
grid on; set(gca,'FontSize',tickF)
title('Rib Thickness')

%% --- FIGURE 4: Lower Panel ---
f4 = figure('Color','w','Position',[200 200 900 500],'Name','Lower Panel');
tiledlayout(1,2,'TileSpacing','compact','Padding','compact')

nexttile
plot(y_rib, lower.t_skin, 'k-x', 'LineWidth', lineW); hold on
plot(y_rib, lower.t_plus, 'b--', 'LineWidth', 1.2);
plot(y_rib, lower.t1_minus, 'r--', 'LineWidth', 1.2);
plot(y_rib, lower.t2_minus, 'g--', 'LineWidth', 1.2);
ylabel('Skin thickness [mm]','FontSize',labelF)
xlabel('y [m]','FontSize',labelF)
legend('t_{skin}','t^+','t_1^-','t_{1/2}^-','FontSize',legendF,'Location','best')
grid on; set(gca,'FontSize',tickF)
title('Lower Skin Thickness')

nexttile
plot(y_rib, lower.sig_skin_plus, 'b-x', 'LineWidth', lineW); hold on
plot(y_rib, -lower.sig_skin_minus, 'r-o', 'LineWidth', lineW);
yline(p.mat.sigma_y_t/1e6, 'b--', 'LineWidth', 1.2);
yline(-p.mat.sigma_y_c/1e6, 'r--', 'LineWidth', 1.2);
ylabel('Stress [MPa]','FontSize',labelF)
xlabel('y [m]','FontSize',labelF)
legend('\sigma_{tens}','\sigma_{comp}','\sigma_{y,t}','\sigma_{y,c}', ...
    'FontSize',legendF,'Location','best')
grid on; set(gca,'FontSize',tickF)
title('Lower Panel Stresses')

%% --- FIGURE 5: Spar Thicknesses ---
f5 = figure('Color','w','Position',[250 250 900 500],'Name','Spar Design');
tiledlayout(1,2,'TileSpacing','compact','Padding','compact')

nexttile
plot(y(1:end-1), spars.tw_front(1:end-1), 'b-', 'LineWidth', lineW); hold on
plot(y(1:end-1), spars.tw_rear(1:end-1), 'r-', 'LineWidth', lineW);
plot(y(1:end-1), spars.tw_front_manu(1:end-1), 'b--', 'LineWidth', 1.0);
plot(y(1:end-1), spars.tw_rear_manu(1:end-1), 'r--', 'LineWidth', 1.0);
ylabel('Web thickness [mm]','FontSize',labelF)
xlabel('y [m]','FontSize',labelF)
legend('Front (ideal)','Rear (ideal)','Front (mfg)','Rear (mfg)', ...
    'FontSize',legendF,'Location','best')
grid on; set(gca,'FontSize',tickF)
title('Spar Web Thickness')

nexttile
plot(y(1:end-1), spars.tau_front(1:end-1), 'b-', 'LineWidth', lineW); hold on
plot(y(1:end-1), spars.tau_rear(1:end-1), 'r-', 'LineWidth', lineW);
yline(p.rib.sigma_y/sqrt(3)/1e6, 'k--', 'LineWidth', 1.2);
ylabel('Shear stress [MPa]','FontSize',labelF)
xlabel('y [m]','FontSize',labelF)
legend('Front spar','Rear spar','\tau_{yield}', ...
    'FontSize',legendF,'Location','best')
grid on; set(gca,'FontSize',tickF)
title('Spar Web Shear Stress')

%% --- FIGURE 6: Spar Cap Thickness ---
f6 = figure('Color','w','Position',[300 300 900 500],'Name','Spar Caps');
tiledlayout(1,2,'TileSpacing','compact','Padding','compact')

nexttile
plot(y(1:end-1), spars.tf_front(1:end-1), 'b-', 'LineWidth', lineW); hold on
plot(y(1:end-1), spars.tf_rear(1:end-1), 'r-', 'LineWidth', lineW);
ylabel('Cap thickness [mm]','FontSize',labelF)
xlabel('y [m]','FontSize',labelF)
legend('Front','Rear','FontSize',legendF)
grid on; set(gca,'FontSize',tickF)
title('Spar Cap Thickness')

nexttile
plot(y(1:end-1), spars.sig_cap_f(1:end-1), 'b-', 'LineWidth', lineW); hold on
plot(y(1:end-1), spars.sig_cap_r(1:end-1), 'r-', 'LineWidth', lineW);
yline(p.rib.sigma_y/1e6, 'k--', 'LineWidth', 1.2);
ylabel('Cap stress [MPa]','FontSize',labelF)
xlabel('y [m]','FontSize',labelF)
legend('Front','Rear','\sigma_{yield}','FontSize',legendF)
grid on; set(gca,'FontSize',tickF)
title('Spar Cap Bending Stress')

%% --- FIGURE 7: Stringer count and Farrar factor ---
f7 = figure('Color','w','Position',[350 350 900 400],'Name','Stringer & Farrar');
tiledlayout(1,2,'TileSpacing','compact','Padding','compact')

nexttile
stairs(y_rib, ssr_final.n_str, 'b-', 'LineWidth', lineW);
ylabel('Number of stringers','FontSize',labelF)
xlabel('y [m]','FontSize',labelF)
grid on; set(gca,'FontSize',tickF)
title('Stringer Count Along Span')

nexttile
plot(y_rib, ssr_final.F_farr, 'r-o', 'LineWidth', lineW);
ylabel('Farrar factor F','FontSize',labelF)
xlabel('y [m]','FontSize',labelF)
grid on; set(gca,'FontSize',tickF)
ylim([0.4 1.0])
title('Farrar Efficiency Factor')

%% --- Export figures ---
fprintf('>> Saving figures...\n');
fig_dir = fullfile(fileparts(mfilename('fullpath')), 'figures');
if ~exist(fig_dir, 'dir')
    mkdir(fig_dir);
end

exportgraphics(f1, fullfile(fig_dir,'wing_loads.pdf'), 'ContentType','vector');
exportgraphics(f2, fullfile(fig_dir,'wing_torque.pdf'), 'ContentType','vector');
exportgraphics(f3, fullfile(fig_dir,'upper_panel_ssr.pdf'), 'ContentType','vector');
exportgraphics(f4, fullfile(fig_dir,'lower_panel.pdf'), 'ContentType','vector');
exportgraphics(f5, fullfile(fig_dir,'spar_web.pdf'), 'ContentType','vector');
exportgraphics(f6, fullfile(fig_dir,'spar_cap.pdf'), 'ContentType','vector');
exportgraphics(f7, fullfile(fig_dir,'stringer_farrar.pdf'), 'ContentType','vector');

% %% ================================================================
% %  SAVE RESULTS
% % =================================================================
% fprintf('>> Saving results...\n');
% results.params          = p;
% results.loads           = loads_pos;
% results.ssr             = ssr_final;
% results.stringer        = stringer_final;
% results.lower           = lower;
% results.stringer_lower  = stringer_lower_final;
% results.spars           = spars;
% results.mass_total_per_wing = mass_wing;
% save(fullfile(fileparts(mfilename('fullpath')), 'wing_design_results.mat'), 'results');

%% ================================================================
%  STEP 9: WING VISUALISATION
% =================================================================
fprintf('>> Generating wing visualisation...\n');
wing_visualise(results);

fprintf('\n>> DONE. All results saved to wing_design_results.mat\n');
fprintf('>> Figures saved to /figures/ folder.\n');
