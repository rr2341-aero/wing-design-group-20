1%%
2%
3%
4% F - crushing force
5%
6% M - bendning moment
7%
8% s - rib spacing (will use L for nomenclautre)
9%
10% h_c = height of wing box
11%
12% t_e = effective skin thickness
13%
14% c = box chord length
15%
16% E = Young 's Modulus
17%
18% I = moment of area
19%
20% rho = density
21%

22% N.B. Different nomenclatrure may be used in the code
23%
24% Want to plot a graph of weight vs rib spacing, with line denoting weight of
25% skin-stringer and line denoting rib and line denoting total weight
27%Wing properties at root
28c =;%chord, m
29b_box = 0.5*c;%wing box width, m
30h_box = 0.12*c;%wing box height, m
32W = 45583;%aircraft mass, kg
33M = ;%max bending moment, Nm
34N = M/(b_box*h_box);%compressive load, N/m
36%Define E in GPa
37E =;
38spanLength =;% in m
40%yield
41sigma_yield =;%MPa
43rho =;%kg/m^3
44%%
45% Procedure will be as follows. M,h,c,E are known, I may be function of t_eff,
46% t_eff can be obtained from Farrar equation t_eff = 1/F sqrt(NL/E) where N is
47% known, and F can be selected. Vary L.
48%
49% Compute minimum rib thickness that satisfies buckling and yield constraints:
50%
51%
52%
53% Variables self-explanataory. Note I comes from parallel axis theorem.
55%compute crushing force
56L = linspace(0,2,100);%rib spacing in m
57%F = [0.7 0.75 0.8 0.85 0.9 0.95];%Farrrar efficiency
58F = 0.7;
60t_eff = 1./F .* sqrt(N .* L ./ (E*1e9)) * 1000;%effective thickness in mm
61I = (b_box * 1000 * t_eff * (h_box*1000)^2/4*2);%mm^4
62F_crushing = M^2 .* L * h_box .* t_eff/1000 * b_box ./ (2 * E * 1e9 * (I * 1e-12)
.^2);%N
65t_rib_yield = F_crushing ./ (b_box .* sigma_yield * 1e6) * 1000;%yield thickness of
rib,mm
66t_rib_buckle = ( F_crushing .* h_box ^ 2 ./ (3.62 * E * 1e9 * b_box) ).^(1/3) *
1000;%buckling thickness,mm
68%find minimum rib thickness, need thickest one
69t_rib = zeros(1,length(t_rib_buckle));%mm
70for i = 1:length(t_rib)
if(t_rib_yield(i) > t_rib_buckle(i))
t_rib(i) = t_rib_yield(i);

else
t_rib(i) = t_rib_buckle(i);
end
76end
78%rib and effective thickness now known for some Farrar efficiency,
79%calculate weight of top and bottom skin panels comibned
80skinPanelWeight = t_eff/1000 .* b_box .* 2 .* spanLength .* rho;%in kg
82%calculate weight of ribs
83ribNumber = ceil(spanLength./L);%round up to ensure number of ribs are sufficient
84ribWeight = b_box .* h_box .* t_rib./1000 .* ribNumber .* rho;%kg
86%total weight
87totalWeightF_0_7 = ribWeight + skinPanelWeight;
89%plot
90figure
91hold on
92plot(L,skinPanelWeight)
93plot(L,ribWeight)
94plot(L,totalWeightF_0_7)
95legend("Skin Panel","Ribs","Total")
96xlabel("Rib Spacing (m)")
97ylabel("Mass (kg)")
98title("Wing structure mass for Farrar = 0.7")
100%%
101% Repeat for F = 0.75, 0.8, 0.85, 0.9, 0.95
103F = 0.75;
105t_eff = 1./F .* sqrt(N .* L ./ (E*1e9)) * 1000;%effective thickness in mm
106I = (b_box * 1000 * t_eff * (h_box*1000)^2/4*2);%mm^4
107F_crushing = M^2 .* L * h_box .* t_eff/1000 * b_box ./ (2 * E * 1e9 * (I * 1e-12)
.^2);%N
110t_rib_yield = F_crushing ./ (b_box .* sigma_yield * 1e6) * 1000;%yield thickness of
rib,mm
111t_rib_buckle = ( F_crushing .* h_box ^ 2 ./ (3.62 * E * 1e9 * b_box) ).^(1/3) *
1000;%buckling thickness,mm
113%find minimum rib thickness, need thickest one
114t_rib = zeros(1,length(t_rib_buckle));%mm
115for i = 1:length(t_rib)
if(t_rib_yield(i) > t_rib_buckle(i))
t_rib(i) = t_rib_yield(i);
else
t_rib(i) = t_rib_buckle(i);
end
121end
123%rib and effective thickness now known for some Farrar efficiency,

124%calculate weight of top and bottom skin panels comibned
125skinPanelWeight = t_eff/1000 .* b_box .* 2 .* spanLength .* rho;%in kg
127%calculate weight of ribs
128ribNumber = ceil(spanLength./L);%round up to ensure number of ribs are sufficient
129ribWeight = b_box .* h_box .* t_rib./1000 .* ribNumber .* rho;%kg
131%total weight
132totalWeightF_0_75 = ribWeight + skinPanelWeight;
134%plot
135figure
136hold on
137plot(L,skinPanelWeight)
138plot(L,ribWeight)
139plot(L,totalWeightF_0_75)
140legend("Skin Panel","Ribs","Total")
141xlabel("Rib Spacing (m)")
142ylabel("Mass (kg)")
143title("Wing structure mass for Farrar = 0.75")
144%%
145F = 0.8;
147t_eff = 1./F .* sqrt(N .* L ./ (E*1e9)) * 1000;%effective thickness in mm
148I = (b_box * 1000 * t_eff * (h_box*1000)^2/4*2);%mm^4
149F_crushing = M^2 .* L * h_box .* t_eff/1000 * b_box ./ (2 * E * 1e9 * (I * 1e-12)
.^2);%N
152t_rib_yield = F_crushing ./ (b_box .* sigma_yield * 1e6) * 1000;%yield thickness of
rib,mm
153t_rib_buckle = ( F_crushing .* h_box ^ 2 ./ (3.62 * E * 1e9 * b_box) ).^(1/3) *
1000;%buckling thickness,mm
155%find minimum rib thickness, need thickest one
156t_rib = zeros(1,length(t_rib_buckle));%mm
157for i = 1:length(t_rib)
if(t_rib_yield(i) > t_rib_buckle(i))
t_rib(i) = t_rib_yield(i);
else
t_rib(i) = t_rib_buckle(i);
end
163end
165%rib and effective thickness now known for some Farrar efficiency,
166%calculate weight of top and bottom skin panels comibned
167skinPanelWeight = t_eff/1000 .* b_box .* 2 .* spanLength .* rho;%in kg
169%calculate weight of ribs
170ribNumber = ceil(spanLength./L);%round up to ensure number of ribs are sufficient
171ribWeight = b_box .* h_box .* t_rib./1000 .* ribNumber .* rho;%kg
173%total weight
174totalWeightF_0_8 = ribWeight + skinPanelWeight;

176%plot
177figure
178hold on
179plot(L,skinPanelWeight)
180plot(L,ribWeight)
181plot(L,totalWeightF_0_8)
182legend("Skin Panel","Ribs","Total")
183xlabel("Rib Spacing (m)")
184ylabel("Mass (kg)")
185title("Wing structure mass for Farrar = 0.8")
186%%
187F = 0.85;
189t_eff = 1./F .* sqrt(N .* L ./ (E*1e9)) * 1000;%effective thickness in mm
190I = (b_box * 1000 * t_eff * (h_box*1000)^2/4*2);%mm^4
191F_crushing = M^2 .* L * h_box .* t_eff/1000 * b_box ./ (2 * E * 1e9 * (I * 1e-12)
.^2);%N
194t_rib_yield = F_crushing ./ (b_box .* sigma_yield * 1e6) * 1000;%yield thickness of
rib,mm
195t_rib_buckle = ( F_crushing .* h_box ^ 2 ./ (3.62 * E * 1e9 * b_box) ).^(1/3) *
1000;%buckling thickness,mm
197%find minimum rib thickness, need thickest one
198t_rib = zeros(1,length(t_rib_buckle));%mm
199for i = 1:length(t_rib)
if(t_rib_yield(i) > t_rib_buckle(i))
t_rib(i) = t_rib_yield(i);
else
t_rib(i) = t_rib_buckle(i);
end
205end
207%rib and effective thickness now known for some Farrar efficiency,
208%calculate weight of top and bottom skin panels comibned
209skinPanelWeight = t_eff/1000 .* b_box .* 2 .* spanLength .* rho;%in kg
211%calculate weight of ribs
212ribNumber = ceil(spanLength./L);%round up to ensure number of ribs are sufficient
213ribWeight = b_box .* h_box .* t_rib./1000 .* ribNumber .* rho;%kg
215%total weight
216totalWeightF_0_85 = ribWeight + skinPanelWeight;
218%plot
219figure
220hold on
221plot(L,skinPanelWeight)
222plot(L,ribWeight)
223plot(L,totalWeightF_0_85)
224legend("Skin Panel","Ribs","Total")
225xlabel("Rib Spacing (m)")

226ylabel("Mass (kg)")
227title("Wing structure mass for Farrar = 0.85")
228%%
229F = 0.9;
231t_eff = 1./F .* sqrt(N .* L ./ (E*1e9)) * 1000;%effective thickness in mm
232I = (b_box * 1000 * t_eff * (h_box*1000)^2/4*2);%mm^4
233F_crushing = M^2 .* L * h_box .* t_eff/1000 * b_box ./ (2 * E * 1e9 * (I * 1e-12)
.^2);%N
236t_rib_yield = F_crushing ./ (b_box .* sigma_yield * 1e6) * 1000;%yield thickness of
rib,mm
237t_rib_buckle = ( F_crushing .* h_box ^ 2 ./ (3.62 * E * 1e9 * b_box) ).^(1/3) *
1000;%buckling thickness,mm
239%find minimum rib thickness, need thickest one
240t_rib = zeros(1,length(t_rib_buckle));%mm
241for i = 1:length(t_rib)
if(t_rib_yield(i) > t_rib_buckle(i))
t_rib(i) = t_rib_yield(i);
else
t_rib(i) = t_rib_buckle(i);
end
247end
249%rib and effective thickness now known for some Farrar efficiency,
250%calculate weight of top and bottom skin panels comibned
251skinPanelWeight = t_eff/1000 .* b_box .* 2 .* spanLength .* rho;%in kg
253%calculate weight of ribs
254ribNumber = ceil(spanLength./L);%round up to ensure number of ribs are sufficient
255ribWeight = b_box .* h_box .* t_rib./1000 .* ribNumber .* rho;%kg
257%total weight
258totalWeightF_0_9 = ribWeight + skinPanelWeight;
260%plot
261figure
262hold on
263plot(L,skinPanelWeight)
264plot(L,ribWeight)
265plot(L,totalWeightF_0_9)
266legend("Skin Panel","Ribs","Total")
267xlabel("Rib Spacing (m)")
268ylabel("Mass (kg)")
269title("Wing structure mass for Farrar = 0.9")
270%%
271F = 0.95;
273t_eff = 1./F .* sqrt(N .* L ./ (E*1e9)) * 1000;%effective thickness in mm
274I = (b_box * 1000 * t_eff * (h_box*1000)^2/4*2);%mm^4
275F_crushing = M^2 .* L * h_box .* t_eff/1000 * b_box ./ (2 * E * 1e9 * (I * 1e-12)
.^2);%N

278t_rib_yield = F_crushing ./ (b_box .* sigma_yield * 1e6) * 1000;%yield thickness of
rib,mm
279t_rib_buckle = ( F_crushing .* h_box ^ 2 ./ (3.62 * E * 1e9 * b_box) ).^(1/3) *
1000;%buckling thickness,mm
281%find minimum rib thickness, need thickest one
282t_rib = zeros(1,length(t_rib_buckle));%mm
283for i = 1:length(t_rib)
if(t_rib_yield(i) > t_rib_buckle(i))
t_rib(i) = t_rib_yield(i);
else
t_rib(i) = t_rib_buckle(i);
end
289end
291%rib and effective thickness now known for some Farrar efficiency,
292%calculate weight of top and bottom skin panels comibned
293skinPanelWeight = t_eff/1000 .* b_box .* 2 .* spanLength .* rho;%in kg
295%calculate weight of ribs
296ribNumber = ceil(spanLength./L);%round up to ensure number of ribs are sufficient
297ribWeight = b_box .* h_box .* t_rib./1000 .* ribNumber .* rho;%kg
299%total weight
300totalWeightF_0_95 = ribWeight + skinPanelWeight;
302%plot
303figure
304hold on
305plot(L,skinPanelWeight, 'LineWidth ',2)
306plot(L,ribWeight, 'LineWidth ',2)
307plot(L,totalWeightF_0_95, 'm','LineWidth ',2)
308legend("Skin Panel","Ribs","Total")
309xlabel("Rib Spacing (m)")
310ylabel("Mass (kg)")
311%title("Wing structure mass for Farrar = 0.95")
312grid on
313ax = gca;
314ax.XMinorGrid = "on";
315ax.YMinorGrid = "on";
316%%
317% Plot variation of total weight with F on the z axis
319%2D plot comparing Farrar efficiency effect
320figure
321hold on
322plot(L,totalWeightF_0_7);
323plot(L,totalWeightF_0_75);
324plot(L,totalWeightF_0_8);
325plot(L,totalWeightF_0_85);
326plot(L,totalWeightF_0_9);
327plot(L,totalWeightF_0_95);

328legend("F = 0.7","F = 0.75","F = 0.8","F = 0.86","F = 0.9","F = 0.95")
