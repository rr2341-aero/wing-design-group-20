% housekeeping
clear,clc
3
CLmin = -1.2; % change
5
nPositiveLimit = 2.53;
nPositiveUltimateLimit = 1.5 * nPositiveLimit;
nNegativeLimit = -1;
9
V_B = 40.8;
V_A = 106;
V_C = 138;
V_D = 172;
V_lower = (2*45583*9.81/(1.225*122.5*-1*CLmin))^0.5;
V_lowerultimate = (2*45583*9.81*1.5/(1.225*122.5*-1*CLmin))^0.5;
V_Aultimate = (2*45583*9.81*nPositiveUltimateLimit/(1.225*122.5*1.34))^0.5;
17
Vpositive = (0:1:V_A);
stall_linePositive = 0.5 * 1.225 * (Vpositive.^2) * 122.5 * 1.34 / (45583 * 9.81);
20
VpositiveUltimate = (V_A:1:V_Aultimate);
stall_linePositiveUltimate = 0.5 * 1.225 * (VpositiveUltimate.^2) * 122.5 * 1.34 /
(45583 * 9.81);
23
122
Vnegative = (0:1:V_lower);
stall_lineNegative = 0.5 * 1.225 * (Vnegative.^2) * 122.5 * CLmin / (45583 * 9.81);
26
VnegativeUltimate = (V_lower:1:V_lowerultimate);
stall_lineNegativeUltimate = 0.5 * 1.225 * (VnegativeUltimate.^2) * 122.5 * CLmin /
(45583 * 9.81);
29
% Gust
mu = 2 * 3650 / (1.225 * 9.81 * 3.91 * 5.11);
K = 0.88 * mu / (5.3 + mu);
33
Ude = [20 15.2 7.6]; % V_B V_C V_D
U = K * Ude; % U_B U_C U_D
VgustV_D = (0:1:V_D);
VgustV_C = (0:1:V_C);
VgustV_B = (0:1:V_B);
39
gustLineV_D = 1 + (1.225 * U(3) * VgustV_D * 5.11) / (2 * 3650);
gustlLineV_C = 1 + (1.225 * U(2) * VgustV_C * 5.11) / (2 * 3650);
gustLineV_B = 1 + (1.225 * U(1) * VgustV_B * 5.11) / (2 * 3650);
43
44
45
figure
hold on
48
% Velocity Lines
plot([V_A,V_A],[nPositiveLimit,nNegativeLimit],':k','LineWidth',1.5)
plot([V_C,V_C],[nPositiveLimit,nNegativeLimit],':k','LineWidth',1.5)
plot([V_B,V_B],[(0.5 * 1.225 * V_B^2 * 122.5 * 1.34)/(45583 * 9.81), (0.5 * 1.225 *
V_B^2 * 122.5 * CLmin)/(45583 * 9.81)],':k','LineWidth',1.5)
53
54
% Limit Load
h1 = plot(Vpositive,stall_linePositive,'-k','LineWidth',1.5); % assign for legend
plot(Vnegative,stall_lineNegative,'-k','LineWidth',1.5);
%plot([V_A,V_D],[nPositiveLimit,nPositiveLimit],'-k');
plot([106,V_D],[nPositiveLimit,nPositiveLimit],'-k','LineWidth',1.5);
plot([V_D,V_D],[0,nPositiveLimit],'-k','LineWidth',1.5);
plot([V_C,V_D],[-1,0],'-k','LineWidth',1.5);
plot([V_lower,V_C],[-1,-1],'-k','LineWidth',1.5);
63
% Ultimate Load
h2 = plot(VpositiveUltimate,stall_linePositiveUltimate,'--m','LineWidth',1.5); %
assign for legend
plot(VnegativeUltimate,stall_lineNegativeUltimate,'--m','LineWidth',1.5);
plot([V_Aultimate,V_D],[nPositiveUltimateLimit,nPositiveUltimateLimit],'--m','LineWidth',1.5);
plot([V_D,V_D],[nPositiveLimit,nPositiveUltimateLimit],'--m','LineWidth',1.5);
plot([V_C,V_D],[1.5*nNegativeLimit,0],'--m','LineWidth',1.5);
plot([V_lowerultimate,V_C],[1.5*nNegativeLimit,1.5*nNegativeLimit],'--m','LineWidth',1.5)
71
h5 = plot(VgustV_D,gustLineV_D,'-.g','LineWidth',1.5);
123
plot(VgustV_D,-1 * gustLineV_D + 2,'-.g','LineWidth',1.5);
74
h4 = plot(VgustV_C,gustlLineV_C,'g','LineWidth',1.5);
plot(VgustV_C,-1 * gustlLineV_C + 2,'g','LineWidth',1.5);
plot([V_C,V_D],[gustlLineV_C(end),gustLineV_D(end)],'g','LineWidth',1.5)
plot([V_C,V_D],[-1 * gustlLineV_C(end) + 2,-1 * gustLineV_D(end) + 2],'g','LineWidth
',1.5)
79
h3 = plot(VgustV_B,gustLineV_B,'--g','LineWidth',1.5);
plot(VgustV_B,-1 * gustLineV_B + 2,'--g','LineWidth',1.5);
plot([V_B,V_C],[gustLineV_B(end),gustlLineV_C(end)],'--g','LineWidth',1.5)
plot([V_B,V_C],[-1 * gustLineV_B(end) + 2,-1 * gustlLineV_C(end) + 2],'--g','LineWidth',1.5)
84
p = [h1;h2;h3;h4;h5];
86
% annotate velocity lines
text(V_A,0,'\leftarrow V_A')
text(V_C,0,'\leftarrow V_C')
text(V_B,0,'\leftarrow V_B')
text(V_D,0,'\leftarrow V_D')
92
93
legend(p,'Limit Load','Ultimate Load','Vb Gust Line','Vc Gust Line','Vd Gust Line')
95
96
legend('Location','northwest')
98
xlabel("EAS (m/s)")
ylabel("Load Factor, n")
101
grid on
ax = gca;
ax.XMinorGrid = 'on';
ax.YMinorGrid = "on";
hold off
