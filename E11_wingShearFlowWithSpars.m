1%dsection plot
3clear
4clc
5close all
7spanStation = 0:0.1:14.4;
8spanStation = [spanStation 14.45];

9chord = 5.68-0.25.*spanStation;
10radius = 109/300*chord;
11theta = 33.4;
12b = (theta*pi/360)*2*radius;
13c1area = (2*theta/360 * pi * radius.^2) - 0.5 * radius.^2 * sin(2*theta * pi/180);
15%%
17%pseudorib location to satisfy a/b=1
18% a1 = round(b,1);
19% xpRib = [0];
20% idx1=1;
21% for i = 1:18
22% xpRib(i+1) = xpRib(i) + a1(idx1(i));
23% idx1(i+1) = find(abs(spanStation - xpRib(i+1)) < 0.001);
24% end
25%
26% xRib = 0:14.45/18:14.45;
27% xRib = round(xRib,1);
28load( 'DsectionAR1.mat ')
29% yRib(1) = DsecEnvelope(1);
30% ypRib(1) = DsecEnvelope(1);
31% for i = 1:18
32% %yRib(i+1) = c1thick(1+i*8);
33% ypRib(i+1) = DsecEnvelope(idx1(i+1));
34% end
35xpRib = linspace(0,14.45,17);
36ypRib = interp1(spanStation, DsecEnvelope,xpRib);
38figure
39hold on
40plot(spanStation, DsecEnvelope, '-b','LineWidth ',2)
41plot([0 6.3], [4 4], 'r', LineWidth=2)
42plot(xpRib(2:16), ypRib(2:16), 'xk','LineWidth ',2)
44plot([6.3 6.3], [4 3], 'r', LineWidth=2)
45plot([6.3 10.8], [3 3], 'r', LineWidth=2)
46plot([10.8 10.8], [3 2], 'r', LineWidth=2)
47plot([10.8 13.5], [2 2], 'r', LineWidth=2)
48plot([13.5 13.5], [2 1], 'r', LineWidth=2)
49plot([13.5 14.45], [1 1], 'r', LineWidth=2)
50legend( 'Required Thickness Distribution ','Actual Thickness Distribution ','Pseudo
Rib Location ')
51grid on
52ax = gca;
53ax.XMinorGrid = 'on';
54ax.YMinorGrid = "on";
56%title( 'Dsection AR=1 ')
57xlabel( 'Distance from start of wingbox (m) ')
58ylabel( 'D-Section Thickness (mm) ')
59ylim([0 5])
61%%

62% repeat for a/b=2
63% a2=b*2;
64% a2 = round(a2,1);
65% xpRib2 = [0];
66% idx2=1;
67% for i = 1:9
68% xpRib2(i+1) = xpRib2(i) + a2(idx2(i));
69% idx2(i+1) = find(abs(spanStation - xpRib2(i+1)) < 0.001);
70% end
72load( 'DsectionAR2.mat ')
73% yRib(1) = c1thick(1);
74% for i = 1:18
75% yRib(i+1) = c1thick(1+i*8);
76% end
78% ypRib2(1) = DsecEnvelope(1);
79% for i = 1:9
80% ypRib2(i+1) = DsecEnvelope(idx2(i+1));
81% end
83xpRib2 = linspace(0,14.45,12);
84ypRib2 = interp1(spanStation, DsecEnvelope,xpRib2);
86figure
87hold on
88plot(spanStation, DsecEnvelope, '-b', LineWidth=2)
89% plot(xRib, yRib, 'xr')
90plot([0 2.6], [5 5], 'r', LineWidth=2)
91plot(xpRib2(2:11), ypRib2(2:11), 'xk', LineWidth=2)
94plot([2.6 2.6], [5 4], 'r', LineWidth=2)
95plot([2.6 7.9], [4 4], 'r', LineWidth=2)
96plot([7.9 7.9], [4 3], 'r', LineWidth=2)
97plot([7.9 11.8], [3 3], 'r', LineWidth=2)
98plot([11.8 11.8], [3 2], 'r', LineWidth=2)
99plot([11.8 14.45], [2 2], 'r', LineWidth=2)
100plot([14.45 14.45], [2 1], 'r', LineWidth=2)
101legend( 'Required Thickness Distribution ','Actual Thickness Distribution ','Pseudo
Rib Location ')
102title( 'D section AR=2 ')
103grid on
104ylim([0 5])
105ax = gca;
106ax.XMinorGrid = 'on';
107ax.YMinorGrid = "on";
109%%
110% % repeat for a/b=3
111% a3=b*3;
112% a3 = round(a3,1);
113% xpRib3 = [0];
114% idx3=1;

115% for i = 1:5
116% xpRib3(i+1) = xpRib3(i) + a3(idx3(i));
117% idx3(i+1) = find(abs(spanStation - xpRib3(i+1)) < 0.001);
118% end
120load( 'DsectionAR3.mat ')
121% yRib(1) = c1thick(1);
122% for i = 1:18
123% yRib(i+1) = c1thick(1+i*8);
124% end
126% ypRib3(1) = DsecEnvelope(1);
127% for i = 1:5
128% ypRib3(i+1) = DsecEnvelope(idx3(i+1));
129% end
130xpRib3 = linspace(0,14.45,7);
131ypRib3 = interp1(spanStation, DsecEnvelope,xpRib3);
132figure
133hold on
134plot(spanStation, DsecEnvelope, '-b', LineWidth=2)
135plot([0 4.8], [5 5], 'r', LineWidth=2)
136plot(xpRib3(2:6), ypRib3(2:6), 'xk', LineWidth=2)
138%plot(13.5, 1, 'xk', LineWidth=2)
140plot([4.8 4.8], [5 4], 'r', LineWidth=2)
141plot([4.8 9.6], [4 4], 'r', LineWidth=2)
142plot([9.6 9.6], [4 3], 'r', LineWidth=2)
143plot([9.6 12], [3 3], 'r', LineWidth=2)
144plot([12 12], [3 2], 'r', LineWidth=2)
145plot([12 14.45], [2 2], 'r', LineWidth=2)
146plot([14.45 14.45], [2 1], 'r', LineWidth=2)
147legend( 'Required Thickness Distribution ','Actual Thickness Distribution ','Pseudo
Rib Location ')
149title( 'D section AR=3 ')
150ylim([0 5])
151grid on
152ax = gca;
153ax.XMinorGrid = 'on';
154ax.YMinorGrid = "on";
156%%
157%plot with all 3 aspect ratios
159figure
160hold on
161grid on
162ax = gca;
163ax.XMinorGrid = 'on';
164ax.YMinorGrid = "on";
166load( 'DsectionAR1.mat ')
167plot(spanStation, DsecEnvelope, '-r','LineWidth ',1.5)

168load( 'DsectionAR2.mat ')
169plot(spanStation, DsecEnvelope, '-b','LineWidth ',1.5)
170load( 'DsectionAR3.mat ')
171plot(spanStation, DsecEnvelope, '-g','LineWidth ',1.5)
172plot(xpRib(2:16), ypRib(2:16), 'xk','LineWidth ',1.5)
173plot(xpRib2(2:11), ypRib2(2:11), 'xk','LineWidth ',1.5)
174plot(xpRib3(2:6), ypRib3(2:6), 'xk','LineWidth ',1.5)
175legend( 'Required Thickness for 15 ribs ','Required Thickness for 10 ribs ','Required
Thickness for 5 ribs ','Pseuo Rib Location ')
176xlabel( 'Distance from start of wingbox (m) ')
177ylabel( 'D-section Thickness (mm) ')
178ylim([0 5])
181%%
182% determine how mass changes with varying AR
183%mass = vol*density
184tRib = 0.007;
187%AR=1
188vol=0;
189for i = 1:146
if i <=63
vol = vol + 0.1*b(i)*0.004;
elseif i<=108
vol = vol + 0.1*b(i)*0.003;
elseif i<=135
vol = vol + 0.1*b(i)*0.002;
elseif i<=145
vol = vol + 0.1*b(i)*0.001;
else
vol = vol + 0.05*b(i)*0.001;
end
201end
202vol = vol*2;
203xpRib = round(xpRib,1)*10;
204for i = 2:16
vol = vol + c1area(xpRib(i))*tRib
206end
208%AR=2
209vol2=0;
210for i = 1:146
if i <=26
vol2 = vol2 + 0.1*b(i)*0.005;
elseif i<=79
vol2 = vol2 + 0.1*b(i)*0.004;
elseif i<=118
vol2 = vol2 + 0.1*b(i)*0.003;
elseif i<=145
vol2 = vol2 + 0.1*b(i)*0.002;
else
vol2 = vol2 + 0.05*b(i)*0.002;

end
222end
223vol2 = vol2*2;
224xpRib2 = round(xpRib2,1)*10;
225for i = 2:11
vol2 = vol2 + c1area(xpRib2(i))*tRib
227end
229%AR=3
230vol3=0;
231for i = 1:146
if i <=48
vol3 = vol3 + 0.1*b(i)*0.005;
elseif i<=96
vol3 = vol3 + 0.1*b(i)*0.004;
elseif i<=130
vol3 = vol3 + 0.1*b(i)*0.003;
elseif i<=145
vol3 = vol3 + 0.1*b(i)*0.002;
else
vol3 = vol3 + 0.05*b(i)*0.002;
end
243end
244vol3 = vol3*2;
245xpRib3 = round(xpRib3,1)*10;
246for i = 2:6
vol3 = vol3 + c1area(xpRib3(i))*tRib
248end
251rho = 2765;
253mass1 = vol*rho
254mass2 = vol2*rho
255mass3 = vol3*rho
