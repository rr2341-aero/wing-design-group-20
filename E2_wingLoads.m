1% Bending Moment and Shear Force diagrams for horizontal tail
2% Convention is, on LH of element, shear force up and bending moment
3% clockwise (or smily face)
4clear
5clc
6close all

8% read data from Excel file, tables have same spanstations
9inertiaTable = readtable( 'TailLoads.xlsx ','Sheet ','Horizontal Tail Inertia ','Range ',
'Q2:AA45 ');
10aeroTable = readtable("TailLoads.xlsx","Sheet", 'Horizontal Tail Aero ','Range ','O2:
T45');
11aeroTable2 = readtable("TailLoads.xlsx","Sheet", 'Horizontal Tail Aero ','Range ','Z2:
AD45 ');
13inertiaTable = table2array(inertiaTable);
14aeroTable = table2array(aeroTable);
15aeroTable2 = table2array(aeroTable2);
17%extract relevant data
19spanStation = inertiaTable(:,1);%span station from centreline in m
21inertiaShearForce = inertiaTable(:,9);%shear force N
22inertiaBendMoment = inertiaTable(:,11);%bending moment Nm
24aeroShearForce = aeroTable(:,4);
25aeroBendMoment = aeroTable(:,6);
27aeroShearForceNoFuel = aeroTable2(:,3);
28aeroBendMomentNoFuel = aeroTable2(:,5);
30%% Case for VA - n_max = 2.53
32n_max_VA = 2.53;
34SF_max_VA = inertiaShearForce + n_max_VA * aeroShearForce;
35BM_max_VA = inertiaBendMoment + n_max_VA * aeroBendMoment;
37SF_max_VA_no_fuel = inertiaShearForce + n_max_VA * aeroShearForceNoFuel;
38BM_max_VA_no_fuel = inertiaBendMoment + n_max_VA * aeroBendMomentNoFuel;
39%% Case for VD - n_max = 3.8
41n_max_VD = 3.8;
43SF_max_VD = inertiaShearForce + n_max_VD * aeroShearForce;
44BM_max_VD = inertiaBendMoment + n_max_VD * aeroBendMoment;
46SF_max_VD_no_fuel = inertiaShearForce + n_max_VD * aeroShearForceNoFuel;
47BM_max_VD_no_fuel = inertiaBendMoment + n_max_VD * aeroBendMomentNoFuel;
48%% Case for VA or VD - n_min = -1.5
50n_min = -1.5;
52SF_min = inertiaShearForce + n_min * aeroShearForce;
53BM_min = inertiaBendMoment + n_min * aeroBendMoment;
55SF_min_no_fuel = inertiaShearForce + n_min * aeroShearForceNoFuel;
56BM_min_no_fuel = inertiaBendMoment + n_min * aeroBendMomentNoFuel;

58%% SF
59W = 45583*9.81;
60W_no_fuel = W * 0.6;
61figure
62hold on
63%plot cases
64plot(spanStation,-SF_max_VA, 'g','LineWidth ',1.5);
65plot(spanStation,-SF_max_VA_no_fuel, 'g-.','LineWidth ',1.5);
67plot(spanStation,-SF_max_VD, 'm','LineWidth ',1.5);
68plot(spanStation,-SF_max_VD_no_fuel, 'm-.','LineWidth ',1.5);
70plot(spanStation,-SF_min, 'r','LineWidth ',1.5);
71plot(spanStation,-SF_min_no_fuel, 'r-.','LineWidth ',1.5);
73%plot envelope
74plot(spanStation,-SF_min, 'k--','LineWidth ',2)
75plot(spanStation,-SF_max_VD, 'k--','LineWidth ',2)
77%title("Shear Force Diagram")
78xlabel("Distance from start of wing box (m)")
79ylabel("Negative Shear Force (N)")
81legend("V_A, n = 2.5, full fuel","V_A, n = 2.5, no fuel","V_D, n = 3.8, full fuel",
...
"V_D, n = 3.8, no fuel","V_A, n = -1.5, full fuel", ...
"V_A, n = -1.5, no fuel","Envelope","Orientation","horizontal",...
"NumColumns",2,...
"Location","southoutside")
88%legend("V_A, n = 2.5, full fuel","V_D, n = 3.8, full fuel",...
% "V_A, n = -1.5, full fuel","Landing, with fuel","OEI, n = 3.8, with fuel",...
% "V_A, n = 2.5, no fuel","V_D, n = 3.8, no fuel","V_A, n = -1.5, no fuel",...
% "Landing, no fuel","OEI, n = 3.8, no fuel","Envelope","Orientation","
horizontal",...
% "NumColumns",2,...
% "Location", 'southoutside ')
94grid on
95ax = gca;
96ax.XMinorGrid = 'on';
97ax.YMinorGrid = "on";
98ax.FontSize = 15;
100%% BM diagram
101W = 45583*9.81;
102W_no_fuel = W * 0.6;
103figure
104hold on
105%plot fuel cases
106plot(spanStation,BM_max_VA, 'g','LineWidth ',1.5);
107plot(spanStation,BM_max_VA_no_fuel, 'g-.','LineWidth ',1.5);
109plot(spanStation,BM_max_VD, 'm','LineWidth ',1.5);

110plot(spanStation,BM_max_VD_no_fuel, 'm-.','LineWidth ',1.5);
112plot(spanStation,BM_min, 'r','LineWidth ',1.5);
113plot(spanStation,BM_min_no_fuel, 'r-.','LineWidth ',1.5);
115%plot envelope
116plot(spanStation,BM_min, 'k--','LineWidth ',2)
117plot(spanStation,BM_max_VD, 'k--','LineWidth ',2)
119%title("Bending Moment (Nm)")
120xlabel("Distance from start of wing box (m)")
121ylabel("Bending Moment (Nm)")
123legend("V_A, n = 2.5, full fuel","V_A, n = 2.5, no fuel","V_D, n = 3.8, full fuel",
...
"V_D, n = 3.8, no fuel","V_A, n = -1.5, full fuel", ...
"V_A, n = -1.5, no fuel","Envelope","Orientation","horizontal",...
"NumColumns",2,...
"Location","southoutside")
130%legend("V_A, n = 2.5, full fuel","V_D, n = 3.8, full fuel",...
% "V_A, n = -1.5, full fuel","Landing, with fuel","OEI, n = 3.8, with fuel",...
% "V_A, n = 2.5, no fuel","V_D, n = 3.8, no fuel","V_A, n = -1.5, no fuel",...
% "Landing, no fuel","OEI, n = 3.8, no fuel","Envelope","Orientation","
horizontal",...
% "NumColumns",2,...
% "Location", 'southoutside ')
136grid on
137ax = gca;
138ax.XMinorGrid = 'on';
139ax.YMinorGrid = "on";
140ax.FontSize = 15;
142%% Plot vertical tail
144aeroTable3 = readtable("TailLoads.xlsx","Sheet", 'Vertical Tail Aero ','Range ','O2:T42
');
145aeroTable3 = table2array(aeroTable3);
146VT_spanStation = aeroTable3(:,1);%span station from centreline in m
148VT_SF = aeroTable3(:,4);
149VT_BM = aeroTable3(:,6);
151W = 45583*9.81;
153figure
154hold on
155%plot fuel cases
156plot(VT_spanStation,VT_SF, 'k','LineWidth ',1.5);
157plot(VT_spanStation,-VT_SF, 'k','LineWidth ',1.5);
159title("Shear Force Diagram")
160xlabel("Distance from start of wing box (m)")

161ylabel("Shear Force (N)")
163grid on
164ax = gca;
165ax.XMinorGrid = 'on';
166ax.YMinorGrid = "on";
167ax.FontSize = 15;
169figure
170hold on
171%plot fuel cases
172plot(VT_spanStation,VT_BM, 'k','LineWidth ',1.5);
173plot(VT_spanStation,-VT_BM, 'k','LineWidth ',1.5);
175title("Bending Moment Diagram")
176xlabel("Distance from start of wing box (m)")
177ylabel("Bending Moment (Nm)")
179grid on
180ax = gca;
181ax.XMinorGrid = 'on';
182ax.YMinorGrid = "on";
183ax.FontSize = 15;
