1% Bending Moment and Shear Force diagrams for wing
2% Convention is, on LH of element, shear force up and bending moment
3% clockwise (or smily face)
4clear
5clc
6close all
8% read data from Excel file, tables have same spanstations
9inertiaTable = readtable( 'AircraftLoads2.xlsx ','Sheet ','Wing Inertia Load ','Range ','
O2:AE160 ');
10aeroTable = readtable("AircraftLoads2.xlsx","Sheet", 'Wing Aero Load ','Range ','O2:
T160 ');
11aeroTable2 = readtable("AircraftLoads2.xlsx","Sheet", 'Wing Aero Load ','Range ','Y2:
AC160 ');
13inertiaTable = table2array(inertiaTable);
14aeroTable = table2array(aeroTable);
15aeroTable2 = table2array(aeroTable2);
17%extract relevant data
19spanStation = inertiaTable(:,1);%span station from centreline in m
20inertiaShearForce = inertiaTable(:,9);%shear force N
21inertiaBendMoment = inertiaTable(:,11);%bending moment Nm
23aeroShearForce = aeroTable(:,4);
24aeroBendMoment = aeroTable(:,6);
26%find where wing actually starts
27wingStart = 1.2;
28idx = find(spanStation == wingStart);
30%fix values to new coordinate system, now wing start, not fuselage
31%centreline, as origin
32spanStation = spanStation(idx:end);
33spanStation = spanStation - wingStart;
34inertiaShearForce = inertiaShearForce(idx:end);
35inertiaBendMoment = inertiaBendMoment(idx:end);
37aeroShearForce = aeroShearForce(idx:end);
38aeroBendMoment = aeroBendMoment(idx:end);
40SF = aeroShearForce + inertiaShearForce;
41BM = aeroBendMoment + inertiaBendMoment;
43%plot graphs
44figure
45hold on
47plot(spanStation,inertiaShearForce, 'b','LineWidth ',1)

48plot(spanStation,aeroShearForce, 'k','LineWidth ',1)
49plot(spanStation,SF, 'r','LineWidth ',2)
51title("Shear Force Diagram")
52xlabel("Distance from start of wing box (m)")
53ylabel("Shear Force (N)")
55legend("Inertia","Aero","Total")
56grid on
57ax = gca;
58ax.XMinorGrid = 'on';
59ax.YMinorGrid = "on";
61figure
62hold on
63plot(spanStation,inertiaBendMoment, 'b','LineWidth ',1)
64plot(spanStation,aeroBendMoment, 'k','LineWidth ',1)
65plot(spanStation,BM, 'r','LineWidth ',2)
67title("Bending Moment Diagram")
68xlabel("Distance from start of wing box (m)")
69ylabel("Bending Moment (Nm)")
71legend("Inertia","Aero","Total")
72grid on
73ax = gca;
74ax.XMinorGrid = 'on';
75ax.YMinorGrid = "on";
77%% Case for VA - n_max = 2.53
79n_max_VA = 2.53;
81SF_max_VA = inertiaShearForce + n_max_VA * aeroShearForce;
82BM_max_VA = inertiaBendMoment + n_max_VA * aeroBendMoment;
84%% Case for VD - n_max = 3.8
86n_max_VD = 3.8;
88SF_max_VD = inertiaShearForce + n_max_VD * aeroShearForce;
89BM_max_VD = inertiaBendMoment + n_max_VD * aeroBendMoment;
91%% Case for VA or VD - n_min = -1.5
93n_min = -1.5;
95SF_min = inertiaShearForce + n_min * aeroShearForce;
96BM_min = inertiaBendMoment + n_min * aeroBendMoment;
98%% Landing Case
100landSF = inertiaTable(:,15);
101landBM = inertiaTable(:,17);

103landSF = landSF(idx:end);
104landBM = landBM(idx:end);
106%% OEI Case
107nOEI = 2.53;
109OEISF = aeroTable2(:,3);
110OEIBM = aeroTable2(:,5);
112OEISF = nOEI * OEISF(idx:end) + inertiaShearForce;
113OEIBM = nOEI * OEIBM(idx:end) + inertiaBendMoment;
115%% For No fuel case
117inertiaTableNoFuel = readtable( 'AircraftLoads2.xlsx ','Sheet ','Wing Inertia Load ','
Range ','AO2:AR160 ');
118inertiaTableNoFuel = table2array(inertiaTableNoFuel);
120inertiaSFNoFuel = inertiaTableNoFuel(:,2);
121inertiaSFNoFuel = inertiaSFNoFuel(idx:end);
122inertiaBMNoFuel = inertiaTableNoFuel(:,4);
123inertiaBMNoFuel = inertiaBMNoFuel(idx:end);
125aeroTableNoFuel = readtable("AircraftLoads2.xlsx","Sheet", 'Wing Aero Load ','Range ','
AI2:AM160 ');
126aeroTableNoFuel = table2array(aeroTableNoFuel);
128aeroSFNoFuel = aeroTableNoFuel(:,3);
129aeroSFNoFuel = aeroSFNoFuel(idx:end);
130aeroBMNoFuel = aeroTableNoFuel(:,5);
131aeroBMNoFuel = aeroBMNoFuel(idx:end);
133SF_max_VA_noFuel = inertiaSFNoFuel + n_max_VA * aeroSFNoFuel;
134BM_max_VA_noFuel = inertiaBMNoFuel + n_max_VA * aeroBMNoFuel;
136SF_max_VD_noFuel = inertiaSFNoFuel + n_max_VD * aeroSFNoFuel;
137BM_max_VD_noFuel = inertiaBMNoFuel + n_max_VD * aeroBMNoFuel;
139SF_min_noFuel = inertiaSFNoFuel + n_min * aeroSFNoFuel;
140BM_min_noFuel = inertiaBMNoFuel + n_min * aeroBMNoFuel;
142aeroTableNoFuelOEI = readtable("AircraftLoads2.xlsx","Sheet", 'Wing Aero Load ','Range
','AQ2:AU160 ');
143aeroTableNoFuelOEI = table2array(aeroTableNoFuelOEI);
145OEISF_NoFuel = aeroTableNoFuelOEI(:,3);
146OEIBM_NoFuel = aeroTableNoFuelOEI(:,5);
148OEISF_NoFuel = inertiaSFNoFuel + nOEI * OEISF_NoFuel(idx:end);
149OEIBM_NoFuel = inertiaBMNoFuel + nOEI * OEIBM_NoFuel(idx:end);
151landNoFuel = readtable( 'AircraftLoads2.xlsx ','Sheet ','Wing Inertia Load ','Range ','
AW2:BA160 ');

152landNoFuel = table2array(landNoFuel);
154landSFNoFuel = landNoFuel(:,3);
155landSFNoFuel = landSFNoFuel(idx:end);
157landBMNoFuel = landNoFuel(:,5);
158landBMNoFuel = landBMNoFuel(idx:end);
161%% plot shear force comparison + envelope
163figure
164hold on
165plot(spanStation,SF_max_VA, 'b')
166plot(spanStation,SF_max_VD, 'g')
167plot(spanStation,SF_min, 'r')
168plot(spanStation,landSF, 'm')
170title("Shear Force Diagram")
171xlabel("Distance from start of wing box (m)")
172ylabel("Shear Force (N)")
174legend("V_A, n = 2.5","V_D, n = 3.8","V_A, n = -1.5","Landing")
175grid on
176ax = gca;
177ax.XMinorGrid = 'on';
178ax.YMinorGrid = "on";
179%% BM
181figure
182hold on
183plot(spanStation,BM_max_VA, 'b')
184plot(spanStation,BM_max_VD, 'g')
185plot(spanStation,BM_min, 'r')
186plot(spanStation,landBM, 'm')
187title("Bending Moment Diagram")
188xlabel("Distance from start of wing box (m)")
189ylabel("Bending Moment (Nm)")
191legend("V_A, n = 2.5","V_D, n = 3.8","V_A, n = -1.5","Landing")
192grid on
193ax = gca;
194ax.XMinorGrid = 'on';
195ax.YMinorGrid = "on";
197%% With gs intead
199W = 45583 * 9.81;
200WNoFuel = W*0.6;
202figure
203hold on
204plot(spanStation,SF_max_VA, 'g','LineWidth ',1.5)
205plot(spanStation,SF_max_VD, 'm','LineWidth ',1.5)

206plot(spanStation,SF_min, 'r','LineWidth ',1.5)
207plot(spanStation,landSF, 'b','LineWidth ',1.5)
208plot(spanStation,OEISF, 'Color ',"#D95319", 'LineWidth ',1.5)
210plot(spanStation,SF_max_VA_noFuel, 'g-.','LineWidth ',1.5)
211plot(spanStation,SF_max_VD_noFuel, 'm-.','LineWidth ',1.5)
212plot(spanStation,SF_min_noFuel, 'r-.','LineWidth ',1.5)
213plot(spanStation,landSFNoFuel, 'b-.','LineWidth ',1.5)
214plot(spanStation,OEISF_NoFuel, '-.','Color ',"#D95319", 'LineWidth ',1.5)%just to make
lines clearer
216plot(spanStation,SF_min, 'k--','LineWidth ',2)
217plot(spanStation,SF_max_VD, 'k--','LineWidth ',2)
219title("Shear Force Diagram")
220xlabel("Distance from start of wing box (m)")
221ylabel("Shear Force (N)")
223legend("V_A, n = 2.5, full fuel","V_D, n = 3.8, full fuel",...
"V_A, n = -1.5, full fuel","Landing, with fuel","OEI, n = 3.8, with fuel",...
"V_A, n = 2.5, no fuel","V_D, n = 3.8, no fuel","V_A, n = -1.5, no fuel",...
"Landing, no fuel","OEI, n = 3.8, no fuel","Envelope","Orientation","horizontal
",...
"NumColumns",2,...
"Location", 'southoutside ')
229grid on
230ax = gca;
231ax.XMinorGrid = 'on';
232ax.YMinorGrid = "on";
233ax.FontSize = 15;
235%%
237figure
238hold on
239plot(spanStation,BM_max_VA, 'g','LineWidth ',1.5)
240plot(spanStation,BM_max_VD, 'm','LineWidth ',1.5)
241plot(spanStation,BM_min, 'r','LineWidth ',1.5)
242plot(spanStation,landBM, 'b','LineWidth ',1.5)
243plot(spanStation,OEIBM, 'color ',"#D95319", 'LineWidth ',1.5)
245plot(spanStation,BM_max_VA_noFuel, 'g-.','LineWidth ',1.5)
246plot(spanStation,BM_max_VD_noFuel, 'm-.','LineWidth ',1.5)
247plot(spanStation,BM_min_noFuel, 'r-.','LineWidth ',1.5)
248plot(spanStation,landBMNoFuel, 'b-.','LineWidth ',1.5)
249plot(spanStation,OEIBM_NoFuel, '-.','color ',"#D95319", 'LineWidth ',1.5)
251plot(spanStation,BM_min, 'k--','LineWidth ',2)
252plot(spanStation,BM_max_VD, 'k--','LineWidth ',2)
255title("Bending Moment Diagram")
256xlabel("Distance from start of wing box (m)")
257ylabel("Bending Moment (Gm)")

258legend("V_A, n = 2.5, full fuel","V_D, n = 3.8, full fuel",...
"V_A, n = -1.5, full fuel","Landing, with fuel","OEI, n = 3.8, with fuel",...
"V_A, n = 2.5, no fuel","V_D, n = 3.8, no fuel","V_A, n = -1.5, no fuel",...
"Landing, no fuel","OEI, n = 3.8, no fuel","Envelope","Orientation","vertical",
...
"NumColumns",2,...
"Location", 'southoutside ')
264grid on
265ax = gca;
266ax.XMinorGrid = 'on';
267ax.YMinorGrid = "on";
268ax.FontSize = 15;
270%% Plot for report
272figure%shear force
273hold on
274plot(spanStation,-SF_max_VA, 'g','LineWidth ',1.5)
275plot(spanStation,-SF_max_VA_noFuel, 'g-.','LineWidth ',1.5)
277plot(spanStation,-SF_max_VD, 'm','LineWidth ',1.5)
278plot(spanStation,-SF_max_VD_noFuel, 'm-.','LineWidth ',1.5)
280plot(spanStation,-OEISF, 'Color ',"#D95319", 'LineWidth ',1.5)
281plot(spanStation,-OEISF_NoFuel, '-.','Color ',"#D95319", 'LineWidth ',1.5)%just to make
lines clearer
283plot(spanStation,-landSF, 'b','LineWidth ',1.5)
284plot(spanStation,-landSFNoFuel, 'b-.','LineWidth ',1.5)
286plot(spanStation,-SF_min, 'r','LineWidth ',1.5)
287plot(spanStation,-SF_min_noFuel, 'r-.','LineWidth ',1.5)
289plot(spanStation,-SF_max_VD, 'k--','LineWidth ',2)
290plot(spanStation,-SF_min, 'k--','LineWidth ',2)
292%title("Shear Force Diagram")
293xlabel("Distance from start of wing box (m)")
294ylabel("Negative Shear Force (N)")
296legend("V_A at n = 2.5 with full fuel","V_A at n = 2.5 with no fuel",...
"V_D at n = 3.8 with full fuel","V_D at n = 3.8 with no fuel",...
"OEI at n = 2.5 with full fuel","OEI at n = 2.5 with no fuel",...
"Landing with full fuel","Landing with no fuel",...
"V_A at n = -1.5 with full fuel","V_A at n = -1.5 with no fuel",...
"Loading Envelope",...
"Orientation","horizontal",...
"NumColumns",2,...
"Location", 'southoutside ')
306grid on
307ax = gca;
308ax.XMinorGrid = 'on';
309ax.YMinorGrid = "on";

310ax.FontSize = 15;
314%%
315figure%shear force
316hold on
317plot(spanStation,BM_max_VA, 'g','LineWidth ',1.5)
318plot(spanStation,BM_max_VA_noFuel, 'g-.','LineWidth ',1.5)
320plot(spanStation,BM_max_VD, 'm','LineWidth ',1.5)
321plot(spanStation,BM_max_VD_noFuel, 'm-.','LineWidth ',1.5)
323plot(spanStation,OEIBM, 'Color ',"#D95319", 'LineWidth ',1.5)
324plot(spanStation,OEIBM_NoFuel, '-.','Color ',"#D95319", 'LineWidth ',1.5)%just to make
lines clearer
326plot(spanStation,landBM, 'b','LineWidth ',1.5)
327plot(spanStation,landBMNoFuel, 'b-.','LineWidth ',1.5)
329plot(spanStation,BM_min, 'r','LineWidth ',1.5)
330plot(spanStation,BM_min_noFuel, 'r-.','LineWidth ',1.5)
332plot(spanStation,BM_max_VD, 'k--','LineWidth ',2)
333plot(spanStation,BM_min, 'k--','LineWidth ',2)
335%title("Bending Moment Diagram")
336xlabel("Distance from start of wing box (m)")
337ylabel("Bending Moment (Nm)")
339legend("V_A at n = 2.5 with full fuel","V_A at n = 2.5 with no fuel",...
"V_D at n = 3.8 with full fuel","V_D at n = 3.8 with no fuel",...
"OEI at n = 2.5 with full fuel","OEI at n = 2.5 with no fuel",...
"Landing with full fuel","Landing with no fuel",...
"V_A at n = -1.5 with full fuel","V_A at n = -1.5 with no fuel",...
"Loading Envelope",...
"Orientation","horizontal",...
"NumColumns",2,...
"Location", 'southoutside ')
349grid on
350ax = gca;
351ax.XMinorGrid = 'on';
352ax.YMinorGrid = "on";
353ax.FontSize = 15;
