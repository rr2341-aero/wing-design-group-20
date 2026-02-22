%wingShearFlow calculation script
clc
clear
close all
warning off
%%
7
%read data from Excel file, tables have same spanstations
Table = readtable('Wing Design1.xlsx','Sheet','Spar Web Sizing','Range','F3:AI148');
Table = table2array(Table);
11
spanStation = Table(:,1);
chord = Table(:,2);
SF1 = Table(:,7); %case 1
T1 = Table(:,8);
SF2 = Table(:,18); %case 2
T2= Table(:,19);
SF3 = Table(:,29); %case 3
T3 = Table(:,30);
20
vals = readtable('Wing Design1.xlsx','Sheet','Dsection','Range','F3:M148');
vals = table2array(vals);
23
c2upperT = vals(:,5);
c2lowerT = vals(:,6);
% FSthick = Table(:,7);
% RSthick = Table(:,8);
28
%evaluate thicknesses using function
for i = 1:length(spanStation)
31
%[c1thick(i), buckleStress(i), tau14ext(i), ] = thicknessCalc(chord(i), SF(i), T
(i), c2upperT(i), c2lowerT(i), FSthick(i), RSthick(i));
32
[c1thick1(i), buckleStress1(i), FSthick1(i), RSthick1(i), shearFlow1(i), tauD1(i
104
), tauFS1(i), tauRS1(i), tauC2Upper1(i)] = thicknessCalc(chord(i), SF1(i), T1
(i), c2upperT(i), c2lowerT(i));
33
[c1thick2(i), buckleStress2(i), FSthick2(i), RSthick2(i), shearFlow2(i), tauD2(i
), tauFS2(i), tauRS2(i), tauC2Upper2(i)] = thicknessCalc(chord(i), SF2(i), T2
(i), c2upperT(i), c2lowerT(i));
34
[c1thick3(i), buckleStress3(i), FSthick3(i), RSthick3(i), shearFlow3(i), tauD3(i
), tauFS3(i), tauRS3(i), tauC2Upper3(i)] = thicknessCalc(chord(i), SF3(i), T3
(i), c2upperT(i), c2lowerT(i));
end
36
%determine required thickness based on max thicknesses
for i = 1:length(spanStation)
39
40
tempFS = max([FSthick1(i) FSthick2(i) FSthick3(i)]);
41
tempRS = max([RSthick1(i) RSthick3(i)]);
42
tempDsec = max([c1thick1(i) c1thick2(i) c1thick3(i)]);
43
44
if tempFS >= 1
45
FSenvelope(i) = max(tempFS);
46
else
47
FSenvelope(i) = 1;
48
end
49
50
if tempRS >= 1
51
RSenvelope(i) = max(tempRS);
52
else
53
RSenvelope(i) =1;
54
end
55
56
if tempDsec >=1
57
DsecEnvelope(i) = max(tempDsec);
58
else
59
DsecEnvelope(i) = 1;
60
end
61
%%%%%%%%%%%%%%%%%%%
63
tauFS(i) = max([tauFS1(i) tauFS2(i) tauFS3(i)]);
64
tauRS(i) = max([tauRS1(i) tauRS2(i) tauRS3(i)]);
65
tauD(i) = max([tauD1(i) tauD2(i) tauD3(i)]);
66
tauC2Upper(i) = max([tauC2Upper1(i) tauC2Upper2(i) tauC2Upper3(i)]);
67
%tauC2Lower(i) = max([tauC2Lower1(i) tauC2Lower2(i) tauC2Lower3(i)]);
68
end
70
figure
hold on
plot(spanStation-1.2, tauFS ,'g-','LineWidth',2);
plot(spanStation-1.2, tauRS ,'b-','LineWidth',2);
plot(spanStation-1.2, tauD ,'r-','LineWidth',2);
yline([431/2], 'k', LineWidth=2)
legend('Front Spar Max Shear Stress', 'Rear Spar Max Shear Stress', 'D-Section Max
Shear Stress', 'Shear Yield Stress', Location='best')
xlabel('Distance from start of wingbox (m)')
ylabel('Shear Stress (MPa)')
105
grid on
ax = gca;
ax.XMinorGrid = 'on';
ax.YMinorGrid = "on";
84
85
% figure
% hold on
% plot(spanStation-1.2, shearFlow1 ,'g-','LineWidth',2);
% plot(spanStation-1.2, shearFlow2 ,'b-','LineWidth',2);
% plot(spanStation-1.2, shearFlow3 ,'r-','LineWidth',2);
91
figure
hold on
plot(spanStation-1.2, c1thick1,'g-','LineWidth',2);
plot(spanStation-1.2, c1thick2,'r-','LineWidth',2);
plot(spanStation-1.2, c1thick3,'b-','LineWidth',2);
plot(spanStation-1.2, DsecEnvelope,'k--','LineWidth',2);
legend("V_D at n = 4.5", "V_A at n = -1.5", "Landing", "Required Thickness")
%title('D-section')
xlabel('Distance from start of wingbox (m)')
ylabel('Thickness (mm)')
grid on
ax = gca;
ax.XMinorGrid = 'on';
ax.YMinorGrid = "on";
106
% figure
% hold on
% plot(spanStation-1.2, abs(tau14ext),'b-','LineWidth',2);
% figure
% plot(spanStation, buckleStress)
% xlabel('Spanwise Distance')
% ylabel('Buckling Stress')
% %yline(290)
% grid on
% ax = gca;
% ax.XMinorGrid = 'on';
% ax.YMinorGrid = "on";
119
120
figure
hold on
plot(spanStation-1.2, RSthick1,'g-','LineWidth',2);
plot(spanStation-1.2, RSthick2,'r-','LineWidth',2);
plot(spanStation-1.2, RSthick3,'b-','LineWidth',2);
plot(spanStation-1.2, RSenvelope,'k--','LineWidth',2);
legend("V_D at n = 4.5", "V_A at n = -1.5", "Landing", "Required Thickness")
%title('Rear Spar')
xlabel('Distance from start of wingbox (m)')
ylabel('Thickness (mm)')
ylim([0 6])
grid on
ax = gca;
106
ax.XMinorGrid = 'on';
ax.YMinorGrid = "on";
136
figure
hold on
plot(spanStation-1.2, FSthick1,'g-','LineWidth',2);
plot(spanStation-1.2, FSthick2,'r-','LineWidth',2);
plot(spanStation-1.2, FSthick3,'b-','LineWidth',2);
plot(spanStation-1.2, FSenvelope,'k--','LineWidth',2);
legend("V_D at n = 4.5", "V_A at n = -1.5", "Landing", "Required Thickness")
%title('Front Spar')
xlabel('Distance from start of wingbox (m)')
ylabel('Thickness (mm)')
%yline(290)
grid on
ax = gca;%
ax.XMinorGrid = 'on';
ax.YMinorGrid = "on";
152
153
154
%function [c1thick, buckleStress, tau14ext] = thicknessCalc(chord, SF, T, c2upperT,
c2lowerT, FSthick, RSthick)
function [c1thick, buckleStress, FSthick, RSthick, testShearFlows, tauD, tauFS,tauRS, tauC2Lower] = thicknessCalc(chord, SF, T, c2upperT, c2lowerT)
%set some variables
chord = chord*1000; %chord in mm
SF = -SF; %(N)
T = T*1000; %(Nmm)
sparH = 0.12*chord; %(height in mm)
G = 28.7*10^3; %MPa
E = 73.85*1000; %MPa
164
165
%set intial values
c1thick = 3;
RSthick = 5;
FSthick = 8;
tReq=0;
tReq2=0;
tReq3=0;
173
while (abs(tReq - c1thick) > 0.0001) && (abs(tReq2 - FSthick) >0.0001) && (abs(tReq3
- RSthick) > 0.0001)
%while (abs(tReq - c1thick) > 0.0001)
176
177
pgonThick = c1thick/chord;
178
179
%read airfoil data
180
airfoil = readmatrix("airfoil.txt");
181
182
%create and plot airfoil idealisation
183
xCoord = airfoil(:,1);
184
yCoord = airfoil(:,2);
107
185
186
%%
187
%obtain structural idealisation coords
188
189
%top half
190
radius=109/300;
%radius of the arc
191
radiusUpper = 109/300 + pgonThick/2;
192
radiusLower = 109/300 - pgonThick/2;
193
theta = 33.4; %angle of arc in degrees
194
thetaUpper = acos((radiusUpper-(0.06+pgonThick/2))/radiusUpper);
195
thetaLower = acos((radiusLower-(0.06-pgonThick/2))/radiusLower);
196
angini=90;
%initial angle of the arc in degrees
197
angfin=90+theta;
%final angle of the arc in degrees
198
rangini=deg2rad(angini);
%initial angle of the arc in radians
199
rangfin=deg2rad(angfin);
%final angle of the arc in radians
200
centre=[0.2;(0.08-109/300)]; %centre of the arc
201
202
teta = linspace(rangini,rangfin);
203
xco = centre(1)+radius*cos(teta);
%x coordinates
204
yco = centre(2)+radius*sin(teta); %y coordinates
205
206
%creating polygon points for D section
207
tetaUpper = linspace(pi/2, pi/2+thetaUpper);
208
tetaLower = linspace(pi/2, pi/2+thetaLower);
209
xcoUpperTop = centre(1)+radiusUpper*cos(tetaUpper);
210
ycoUpperTop = centre(2)+radiusUpper*sin(tetaUpper);
211
212
xcoLowerTop = centre(1)+radiusLower*cos(tetaLower);
213
ycoLowerTop = centre(2)+radiusLower*sin(tetaLower);
214
215
%bottom half
216
angini=270-theta;
%initial angle of the arc in degrees
217
angfin=270;
%final angle of the arc in degrees
218
rangini2=deg2rad(angini);
%initial angle of the arc in radians
219
rangfin2=deg2rad(angfin);
%final angle of the arc in radians
220
centre=[0.2;(-0.04+109/300)]; %centre of the arc
221
222
teta = linspace(rangini2,rangfin2);
223
xco2 = centre(1)+radius*cos(teta);
%x coordinates
224
yco2 = centre(2)+radius*sin(teta); %y coordinates
225
226
%creating polygon points for D section
227
tetaUpper = linspace(3*pi/2-thetaUpper, 3*pi/2);
228
tetaLower = linspace(3*pi/2-thetaLower, 3*pi/2);
229
xcoUpperBot = centre(1)+radiusUpper*cos(tetaUpper);
230
ycoUpperBot = centre(2)+radiusUpper*sin(tetaUpper);
231
232
xcoLowerBot = centre(1)+radiusLower*cos(tetaLower);
233
ycoLowerBot = centre(2)+radiusLower*sin(tetaLower);
234
235
xD = [xcoUpperTop(1:99) xcoUpperBot fliplr(xcoLowerBot(2:100)) fliplr(xcoLowerTop)];
236
yD = [ycoUpperTop(1:99) ycoUpperBot fliplr(ycoLowerBot(2:100)) fliplr(ycoLowerTop)];
108
237
238
pgon = polyshape(xD, yD);
239
240
%%
241
%plotting..
242
% close
243
% hold on
244
% plot(xCoord,yCoord,'k');
245
% % plot(pgon);
246
% plot(xco,yco,'b', 'LineWidth',2)
247
% plot(xco2,yco2,'b', 'LineWidth',2)
248
% %plot(pgon,'LineWidth',2,'EdgeColor','b', 'FaceAlpha',0);
249
% rectangle('Position',[0.2 -0.04 0.5 0.12], 'EdgeColor','b', LineWidth=2)
250
% legend('Airfoil', 'Structural Idealisation')
251
% xlabel('x/c')
252
% ylabel('y/c')
253
% axis equal
254
% grid on
255
% ax = gca;
256
% ax.XMinorGrid = 'on';
257
% ax.YMinorGrid = "on";
258
259
%%
260
%determine cell 1 area and perimeter
261
%perimeter is arc length of 2theta
262
%area is area of segmenta of 2theta
263
radius = radius*chord; %convert to absolute value
264
265
c1peri = 2*(theta*pi/180)*radius;
266
c1area = (2*theta/360 * pi * radius^2) - 0.5 * radius^2 * sin(2*theta * pi/180);
267
268
%cell 2 area and width
269
c2area = 0.12*chord*0.5*chord;
270
c2width = chord*0.5;
271
272
%%
273
%equation to solve: Ax=B
274
%where A is a 3x3 matrix
275
%x is a vector of shear flow in qn, qw & qr
276
%B is a vector
277
278
A = [2*c1area 2*c2area 0;
279
-sparH sparH sparH;
280
c1peri/(2*c1area*G*c1thick) -1/(2*c2area*G)*(c2width/c2upperT+c2width/
c2lowerT+sparH/RSthick) (sparH/FSthick)*(1/(2*c1area*G) + 1/(2*c2area*G))
];
281
282
B = [T;
283
SF;
284
0];
285
286
shearFlows = A\B;
287
testShearFlows = shearFlows(2);
288
109
289
tauD = shearFlows(1)/c1thick;
290
tauRS = shearFlows(2)/RSthick;
291
tauC2Lower = shearFlows(2)/c2lowerT;
292
tauC2Upper = shearFlows(2)/c2upperT;
293
tauFS = shearFlows(3)/FSthick;
294
295
%%
296
% plot graph of K vs b/root(Rt)
297
298
load('data2.mat')
299
% figure
300
% plot(data(:,1),data(:,2))
301
% xlabel('b/root(Rt)')
302
% ylabel('K')
303
% title('ESDU Datasheet for Buckling Coefficient of Curved Panel')
304
% grid on
305
% ax = gca;
306
% ax.XMinorGrid = 'on';
307
% ax.YMinorGrid = "on";
308
309
%extract K values
310
b = c1peri/2;
311
xPoint = b/sqrt(radius*c1thick);
312
K = interp1(data(:,1),data(:,2), xPoint);
313
Kspar = 8.1;
314
315
%determine thickness required to buckle @ shear stress
316
%using Excel method
317
tReq = (b^2*abs(shearFlows(1))/(K*E))^(1/3);
318
c1thick = tReq;
319
buckleStress = K*E*(c1thick/b)^2;
320
321
%spar
322
tReq2 = (sparH^2*abs(shearFlows(3))/(Kspar*E))^(1/3);
323
FSthick = tReq2;
324
325
tReq3 = (sparH^2*abs(shearFlows(2))/(Kspar*E))^(1/3);
326
RSthick = tReq3;
327
328
end
330
end
