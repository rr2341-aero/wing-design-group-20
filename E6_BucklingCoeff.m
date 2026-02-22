1%% Skin-Stringer-Rib Selection For Top Panel
2% Code to aid selection of skin, stringer and rib parameters
4clear
5clc
6close all
8%res contains all possible data
9%res1 contains geometric and manufacturing valid data of res
10%res2 contains data from res1 that satisfies geometric constraints
11%res3 contains data from res2 that contains sensible number of ribs
12%% Declare Constant Properties
13%
14% _Can change this code block to suit application_
16%Wing properties at root
17c = ;%chord, m
18b_box = 0.5*c;%wing box width, m
19h_box = 0.12*c;%wing box height, m
21W = 45583;%aircraft mass, kg
22M = ;%max bending moment, Nm
24%Define E in GPa
25E = 73.85;
26spanLength = ;% in m
28sigma_yield = ;%Mpa
29rho = ;%kg/m^3
30%%
31% Can calculate compressive load/unit length acting on panels via N = M/(bh),
32% a force-moment couple
34N = M/(b_box*h_box);%compressive load, N/m
35%%
36% Now define some other useful function handles
38%equation for t_eff
39effectiveThickness = @(var_t,var_b,var_A_s) var_t + var_A_s./var_b;
41%equation for A_stringer
42stringerArea = @(var_h,var_d,var_t_s,var_t_d) var_h .* var_t_s + var_d .* var_t_d;
43%% Define variables
44% Free variables to select are h,d,t,t_s,t_d,b
45%
46% Selecting b,h/b,d/h gives b,d,h
47%
48% Selecting t_s, t_d/t_s, t_s/t gives t_s,t_d,t
49%
50% Note that for ESDU dataset, d/h can equal 0.3,0.4,0.5; t_d/t_s = 1 or 2; t_s/t
51% = 0.5,0.6,0.7,0.8,0.9,1,1.25,1.5,2 and h/b = 0.1 -> 1
52%
53%
54%% Initial Buckling

55% First consider initial buckling of beam. Assume minimum aluminium machined
56% thickness is 1 mm and consider 1 mm increments on top of that. Assume tolerance
57% of 0.1 mm
58%
59% From now on, all dimensions in mm
61%first consider b,h/b,d/h
62n = 5:5:30;%number of panels %<--
63b = b_box./n * 1000;
64h_b_ratio = 0.1:0.1:1;
65d_h_ratio = [0.3 0.4 0.5];
67%now consider t_s, t_d/t_s, t_s/t
68t_s = 1:1:10; %<--
69td_ts_ratio = [1 2];
70ts_t_ratio = [0.5 0.6 0.7 0.8 0.9 1 1.25 1.5 2];
72%create table containing all permutations
73res = combinations(b,h_b_ratio,d_h_ratio,t_s,td_ts_ratio,ts_t_ratio);
74disp("Number of combinations: " + height(res));
75%compute other geometric properties
76res.h = res.b .* res.h_b_ratio;
77res.d = res.h .* res.d_h_ratio;
78res.t_d = res.t_s .* res.td_ts_ratio;
79res.t = res.t_s ./ res.ts_t_ratio;
81res.A_s = stringerArea(res.h,res.d,res.t_s,res.t_d);%stringer area,mm^2
82res.t_eff = effectiveThickness(res.t,res.b,res.A_s);%effective skin thickness
84res.A_total = res.t_eff .* (b_box * 1000);%mm^2
85%%
86%Computationally expensive, takes around 15 minutes for 1.5 million combos
87%from these permutations, compute buckling coefficient
88K = zeros(height(res),1);
90%find K from ESDU71014 dataset
91for i = 1:height(res)
K(i) = BucklingCoeff(res.d_h_ratio(i),res.td_ts_ratio(i),res.ts_t_ratio(i),res.
h_b_ratio(i));
93end
95res.K = K;
96res.compressiveStress = N./(res.t*1000);%compute actual compresive stress, MPa
97res(isnan(K),:) = [];%remove any isnan in K due to failed interpolation
98disp("Number of combinations after removing K data that was outside ESDU dataset: "
+ height(res));
99%%
100% Note that:
101%
102%
103%
104% so K = sigma_cr/sigma_0 * 3.62, or sigma_cr = K * sigma_0 / 3.62
105%
106% sigma_0 is the initial buckling of the plate (i.e SS plate buckling) while

107% sigma_cr is the buckling stress for the skin-stringer combo
109%compute initial buckling stress sigma_0
110res.sigma_0 = 3.62 .* E.* 1e9 .* (res.t./res.b).^2 ./1e6;%MPa
111res.sigma_cr = res.K .* res.sigma_0 ./ 3.62;
113%compute other values
114res.As_bt_ratio = res.A_s ./ (res.b .* res.t);
116%% FARRAR EFFICIENCY
117% Consider flexural buckling mode
119%compute Farrar efficiency from Niu dataset for Z-stringer -> slight
120%difference to integrally machined stringer
121F = zeros(height(res),1);
122for i = 1:height(res)
F(i) = Farrar(res.ts_t_ratio(i),res.As_bt_ratio(i));
124end
125res.Farrar = F;
127%%
128% Now, note Farrar equation:
129%
130%
131%
132% where L is rib spacing and Et is transverse E and approximate as E. Can now
133% compute ideal rib spacing for maintaining good Farrar Efficiency
135%length in mm
136res.L = (res.Farrar ./ (res.sigma_cr.*1e6)).^2 .* N .* E * 1e9 * 1e3;
138%calculate number of ribs required
139res.ribNumber = spanLength * 1000 ./ res.L;
140res.ribNumber = ceil(res.ribNumber);
141%% Effect of Rib Spacing
142% Now consider effect of rib spacing on variables
143% _*Now run ribSpacingVisualisation.mlx to ensure correct data is populated. If
already run, then ignore*_
144% _*Notation of files "totalWeightF_0_95" denotes total wing weight for Farrar
145% efficiency = 0.95*_
147%calculate mass (for equations, refer to ribSpacingVisualisation.mlx)
149res.I = b_box*1000 * res.t_eff * (h_box*1000/2).^2 *2;%moment of inertia, mm^4
150res.F_crushing = M^2 .* res.L./1000 * h_box .* res.t_eff/1000 * b_box ./ (2 * E * 1
e9 * (res.I * 1e-12).^2);%N
151res.t_rib_yield = res.F_crushing ./ (b_box .* sigma_yield * 1e6) * 1000;%yield
thickness of rib,mm
152res.t_rib_buckle = ( res.F_crushing .* h_box ^ 2 ./ (3.62 * E * 1e9 * b_box) )
.^(1/3) * 1000;%buckling thickness,mm
154%find minimum rib thickness, need thickest one
155res.t_rib = zeros(length(res.t_rib_buckle),1);%mm
156for i = 1:length(res.t_rib)

if(res.t_rib_yield(i) > res.t_rib_buckle(i))
res.t_rib(i) = res.t_rib_yield(i);
else
res.t_rib(i) = res.t_rib_buckle(i);
end
162end
164%rib and effective thickness now known for some Farrar efficiency,
165%calculate weight of top and bottom skin panels comibned
166res.skinPanelWeight = res.t_eff/1000 .* b_box .* 2 .* spanLength .* rho;%in kg
168%calculate weight of ribs
169res.ribWeight = b_box .* h_box .* res.t_rib./1000 .* res.ribNumber .* rho;%kg
171%total weight
172res.totalWeight = res.ribWeight + res.skinPanelWeight;
173%% Now filter the data
175%apply geometric constraints, reduce computations
176idTooThin = res.t<1;%if panel too thin
177idTooHigh = res.h > h_box*1000/2;%if stringer height exceeds half of box height
179res1 = res(~idTooThin & ~idTooHigh,:);
180disp("Number of combinations after manufacturing and geometric constraints: " +
height(res1));
181%%
183%structural constraints
184idNoK = isnan(res1.K);%if failed to interpolate K
185idNoFarrar = isnan(res1.Farrar);%if failed to interpolate Farrar
186idStressFail = res1.compressiveStress > sigma_yield;%compressive stress failure
187idBuckleFail = res1.compressiveStress > res1.sigma_cr;%local buckling failure
188idInefficient = res1.Farrar < 0.7;%inefficient Farrar
190res2 = res1(~idNoK & ~idNoFarrar & ~idStressFail & ~idBuckleFail & ~idInefficient,:)
;
191disp("Number of combinations after structural constraints: " + height(res2));
193%remove excessive ribs
194idTooManyRibs = res2.ribNumber > 40;%too many ribs
195res3 = res2(~idTooManyRibs,:);
196%%
197totalWeightF_0_95 = [NaN 9840.96656851463 5705.59818954976 4229.84109591517
3460.31271482678 3010.35467609802 2699.15313017878 2481.61978000193
2316.62712419509 2193.35339885088 2097.68175067153 2033.15711787399
1961.98431889547 1926.17884426536 1886.16072512349 1842.35822106774
1816.47101247783 1809.44968668313 1778.60530526104 1767.43925949358
1754.53396880451 1762.34692420147 1746.49564536800 1751.90398999538
1733.47204247993 1736.77633987995 1739.19746592955 1740.78482454971
1741.58319809035 1741.63333335214 1740.97243542568 1763.46527016394
1761.60821959401 1759.13114046219 1780.26128157521 1776.73988433291
1772.67047551055 1792.61854250578 1787.62581042807 1806.90344357132
1801.05352169873 1819.71338632664 1838.13227932662 1831.15265180545
1849.01899642823 1841.31338094902 1858.66567603035 1875.81972649217

1867.14997633435 1883.83839560934 1900.34849297870 1916.68573753580
1906.87905714051 1922.80333610824 1938.57089881833 1954.18618789479
1943.35434103425 1958.59991008786 1973.70648395353 1988.67772481925
1976.91388374314 1991.55143622566 2006.06473198382 2020.45682845166
2034.73066039394 2048.88904666846 2035.90547467019 2049.77316492739
2063.53406989697 2077.19058111043 2090.74500258898 2104.19955525055
2090.13232824115 2103.33037665989 2116.43547683245 2129.44953837706
2142.37440669732 2155.21186595829 2167.96364188783 2180.63140441551
2165.30689558945 2177.75358518423 2190.12155264526 2202.41225505737
2214.62710527975 2226.76747379886 2238.83469048297 2250.83004624438
2262.75479461540 2274.61015324329 2257.93413278833 2269.60176115894
2281.20392954617 2292.74171606833 2304.21616967104 2315.62831121863
2326.97913453367 2338.26960738748 2349.50067244470 2360.67324816417];
198L_data = [0 0.0202020202020202 0.0404040404040404 0.0606060606060606
0.0808080808080808 0.101010101010101 0.121212121212121 0.141414141414141
0.161616161616162 0.181818181818182 0.202020202020202 0.222222222222222
0.242424242424242 0.262626262626263 0.282828282828283 0.303030303030303
0.323232323232323 0.343434343434343 0.363636363636364 0.383838383838384
0.404040404040404 0.424242424242424 0.444444444444444 0.464646464646465
0.484848484848485 0.505050505050505 0.525252525252525 0.545454545454545
0.565656565656566 0.585858585858586 0.606060606060606 0.626262626262626
0.646464646464647 0.666666666666667 0.686868686868687 0.707070707070707
0.727272727272727 0.747474747474748 0.767676767676768 0.787878787878788
0.808080808080808 0.828282828282828 0.848484848484849 0.868686868686869
0.888888888888889 0.909090909090909 0.929292929292929 0.949494949494950
0.969696969696970 0.989898989898990 1.01010101010101 1.03030303030303
1.05050505050505 1.07070707070707 1.09090909090909 1.11111111111111
1.13131313131313 1.15151515151515 1.17171717171717 1.19191919191919
1.21212121212121 1.23232323232323 1.25252525252525 1.27272727272727
1.29292929292929 1.31313131313131 1.33333333333333 1.35353535353535
1.37373737373737 1.39393939393939 1.41414141414141 1.43434343434343
1.45454545454545 1.47474747474747 1.49494949494950 1.51515151515152
1.53535353535354 1.55555555555556 1.57575757575758 1.59595959595960
1.61616161616162 1.63636363636364 1.65656565656566 1.67676767676768
1.69696969696970 1.71717171717172 1.73737373737374 1.75757575757576
1.77777777777778 1.79797979797980 1.81818181818182 1.83838383838384
1.85858585858586 1.87878787878788 1.89898989898990 1.91919191919192
1.93939393939394 1.95959595959596 1.97979797979798 2];
200figure
201hold on
202plot(L_data,totalWeightF_0_95)
203scatter(res.L/1000,res.totalWeight, 'ro')
204xlabel("Rib Spacing (m)")
205ylabel("Weight (kg)")
206legend("Minimum Weight","Possible Points")
207xlim([0 2])
208grid on;
209ax = gca;
210ax.XMinorGrid = 'on';
211ax.YMinorGrid = 'on';
213%%
214%possible vs impossible points on same plot

215figure
216hold on
217scatter(res.L/1000,res.totalWeight,[],"black","filled","MarkerFaceAlpha",0.3)
218scatter(res2.L/1000,res2.totalWeight,[],"blue","filled","MarkerFaceAlpha",0.3)
219scatter(res3.L/1000,res3.totalWeight,[],"red","filled","MarkerFaceAlpha",0.8)
220plot(L_data,totalWeightF_0_95, 'm-','LineWidth ',2)
221xlabel("Rib Spacing (m)")
222ylabel("Weight (kg)")
223legend("Impossible Points","Unrealistic Points","Possible Points","Minimum Weight", '
Location ','southwest ')
224xlim([0 2])
225ylim([0 6000])
226grid on;
227ax = gca;
228ax.XMinorGrid = 'on';
229ax.YMinorGrid = 'on';
231%%
232%Plot of possible designs, with Farrar efficiency
233figure
234hold on
235plot(L_data,totalWeightF_0_95, 'k-','LineWidth ',2)
236scatter(res3.L/1000,res3.totalWeight,[],res3.Farrar, 'filled ',"MarkerFaceAlpha",0.5)
237xlabel("Rib Spacing (m)")
238ylabel("Weight (kg)")
239legend("Minimum Weight","Design Points")
240xlim([0 2])
241ylim([0 6000])
242c = colorbar;
243c.Label.String = "Farrar Efficiency";
244grid on;
245ax = gca;
246ax.XMinorGrid = 'on';
247ax.YMinorGrid = 'on';
248%%
249%Plot of possible designs, with number of ribs
250figure
251hold on
252plot(L_data,totalWeightF_0_95, 'k-','LineWidth ',2)
253scatter(res3.L/1000,res3.totalWeight,[],res3.ribNumber, 'filled ',"MarkerFaceAlpha
",0.5)
254xlabel("Rib Spacing (m)")
255ylabel("Weight (kg)")
256legend("Minimum Weight","Design Points")
257xlim([0 2])
258ylim([0 6000])
259c = colorbar;
260c.Label.String = "Rib Number";
261grid on;
262ax = gca;
263ax.XMinorGrid = 'on';
264ax.YMinorGrid = 'on';
265%%
266%Plot of possible designs, with skin thickness

267figure
268hold on
269plot(L_data,totalWeightF_0_95, 'k-','LineWidth ',2)
270scatter(res3.L/1000,res3.totalWeight,[],res3.t, 'filled ',"MarkerFaceAlpha",0.5)
271xlabel("Rib Spacing (m)")
272ylabel("Weight (kg)")
273legend("Minimum Weight","Design Points")
274xlim([0 2])
275ylim([0 6000])
276c = colorbar;
277c.Label.String = "Skin Thickness (mm)";
278grid on;
279ax = gca;
280ax.XMinorGrid = 'on';
281ax.YMinorGrid = 'on';
282%%
283%Plot of possible designs
284figure
285hold on
286plot(L_data,totalWeightF_0_95, 'k-','LineWidth ',2)
287scatter(res3.L/1000,res3.totalWeight, 'bx')
288xlabel("Rib Spacing (m)")
289ylabel("Weight (kg)")
290legend("Minimum Weight","Design Points")
291xlim([0 2])
292ylim([0 6000])
293grid on;
294ax = gca;
295ax.XMinorGrid = 'on';
296ax.YMinorGrid = 'on';
