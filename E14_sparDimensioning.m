1% housekeeping
2clear,clc
4CLmin = -1.2; % change
6nPositiveLimit = 2.53;
7nPositiveUltimateLimit = 1.5 * nPositiveLimit;
8nNegativeLimit = -1;
10V_B = 40.8;
11V_A = 106;
12V_C = 138;
13V_D = 172;
14V_lower = (2*45583*9.81/(1.225*122.5*-1*CLmin))^0.5;
15V_lowerultimate = (2*45583*9.81*1.5/(1.225*122.5*-1*CLmin))^0.5;
16V_Aultimate = (2*45583*9.81*nPositiveUltimateLimit/(1.225*122.5*1.34))^0.5;
18Vpositive = (0:1:V_A);
19stall_linePositive = 0.5 * 1.225 * (Vpositive.^2) * 122.5 * 1.34 / (45583 * 9.81);
21VpositiveUltimate = (V_A:1:V_Aultimate);
22stall_linePositiveUltimate = 0.5 * 1.225 * (VpositiveUltimate.^2) * 122.5 * 1.34 /
(45583 * 9.81);

24Vnegative = (0:1:V_lower);
25stall_lineNegative = 0.5 * 1.225 * (Vnegative.^2) * 122.5 * CLmin / (45583 * 9.81);
27VnegativeUltimate = (V_lower:1:V_lowerultimate);
28stall_lineNegativeUltimate = 0.5 * 1.225 * (VnegativeUltimate.^2) * 122.5 * CLmin /
(45583 * 9.81);
30% Gust
31mu = 2 * 3650 / (1.225 * 9.81 * 3.91 * 5.11);
32K = 0.88 * mu / (5.3 + mu);
34Ude = [20 15.2 7.6]; % V_B V_C V_D
35U = K * Ude; % U_B U_C U_D
36VgustV_D = (0:1:V_D);
37VgustV_C = (0:1:V_C);
38VgustV_B = (0:1:V_B);
40gustLineV_D = 1 + (1.225 * U(3) * VgustV_D * 5.11) / (2 * 3650);
41gustlLineV_C = 1 + (1.225 * U(2) * VgustV_C * 5.11) / (2 * 3650);
42gustLineV_B = 1 + (1.225 * U(1) * VgustV_B * 5.11) / (2 * 3650);
46figure
47hold on
49% Velocity Lines
50plot([V_A,V_A],[nPositiveLimit,nNegativeLimit], ':k','LineWidth ',1.5)
51plot([V_C,V_C],[nPositiveLimit,nNegativeLimit], ':k','LineWidth ',1.5)
52plot([V_B,V_B],[(0.5 * 1.225 * V_B^2 * 122.5 * 1.34)/(45583 * 9.81), (0.5 * 1.225 *
V_B^2 * 122.5 * CLmin)/(45583 * 9.81)], ':k','LineWidth ',1.5)
55% Limit Load
56h1 = plot(Vpositive,stall_linePositive, '-k','LineWidth ',1.5); % assign for legend
57plot(Vnegative,stall_lineNegative, '-k','LineWidth ',1.5);
58%plot([V_A,V_D],[nPositiveLimit,nPositiveLimit], '-k');
59plot([106,V_D],[nPositiveLimit,nPositiveLimit], '-k','LineWidth ',1.5);
60plot([V_D,V_D],[0,nPositiveLimit], '-k','LineWidth ',1.5);
61plot([V_C,V_D],[-1,0], '-k','LineWidth ',1.5);
62plot([V_lower,V_C],[-1,-1], '-k','LineWidth ',1.5);
64% Ultimate Load
65h2 = plot(VpositiveUltimate,stall_linePositiveUltimate, '--m','LineWidth ',1.5); %
assign for legend
66plot(VnegativeUltimate,stall_lineNegativeUltimate, '--m','LineWidth ',1.5);
67plot([V_Aultimate,V_D],[nPositiveUltimateLimit,nPositiveUltimateLimit], '--m','
LineWidth ',1.5);
68plot([V_D,V_D],[nPositiveLimit,nPositiveUltimateLimit], '--m','LineWidth ',1.5);
69plot([V_C,V_D],[1.5*nNegativeLimit,0], '--m','LineWidth ',1.5);
70plot([V_lowerultimate,V_C],[1.5*nNegativeLimit,1.5*nNegativeLimit], '--m','LineWidth '
,1.5)
72h5 = plot(VgustV_D,gustLineV_D, '-.g','LineWidth ',1.5);

73plot(VgustV_D,-1 * gustLineV_D + 2, '-.g','LineWidth ',1.5);
75h4 = plot(VgustV_C,gustlLineV_C, 'g','LineWidth ',1.5);
76plot(VgustV_C,-1 * gustlLineV_C + 2, 'g','LineWidth ',1.5);
77plot([V_C,V_D],[gustlLineV_C(end),gustLineV_D(end)], 'g','LineWidth ',1.5)
78plot([V_C,V_D],[-1 * gustlLineV_C(end) + 2,-1 * gustLineV_D(end) + 2], 'g','LineWidth
',1.5)
80h3 = plot(VgustV_B,gustLineV_B, '--g','LineWidth ',1.5);
81plot(VgustV_B,-1 * gustLineV_B + 2, '--g','LineWidth ',1.5);
82plot([V_B,V_C],[gustLineV_B(end),gustlLineV_C(end)], '--g','LineWidth ',1.5)
83plot([V_B,V_C],[-1 * gustLineV_B(end) + 2,-1 * gustlLineV_C(end) + 2], '--g','
LineWidth ',1.5)
85p = [h1;h2;h3;h4;h5];
87% annotate velocity lines
88text(V_A,0, '\leftarrow V_A ')
89text(V_C,0, '\leftarrow V_C ')
90text(V_B,0, '\leftarrow V_B ')
91text(V_D,0, '\leftarrow V_D ')
94legend(p, 'Limit Load ','Ultimate Load ','Vb Gust Line ','Vc Gust Line ','Vd Gust Line ')
97legend( 'Location ','northwest ')
99xlabel("EAS (m/s)")
100ylabel("Load Factor, n")
102grid on
103ax = gca;
104ax.XMinorGrid = 'on';
105ax.YMinorGrid = "on";
106hold off
