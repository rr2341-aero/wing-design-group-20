clear
clc
close all
4
5
%read data from Excel file, tables have same spanstations
flangeTable = readtable('Wing Design1.xlsx','Sheet','Spar Flange Sizing','Range','G2
117:O147');
flangeTable = table2array(flangeTable);
9
10
spanStation = flangeTable(:,1)-1.2;%span station from start of wingbox
chord = flangeTable(:,2);
D = flangeTable(:,3);
maxBM = flangeTable(:,6);
% t2FS = flangeTable(:,8);
% t2RS = flangeTable(:,9);
% t2RS(1) = 7.5983;
% t2RS(2) = 7.5928;
% t2RS(3) = 7.5872;
load('RSfinal.mat');
load('FSfinal.mat');
t2FS = FSenvelope;
t2RS = RSenvelope;
24
25
for i=1:146
27
[t1FS(i), bFS(i), buckleStressFS(i), IxxFinalFS(i)] = SparFlangeDims(t2FS(i), D(i), maxBM(i), chord(i));
28
[t1RS(i), bRS(i), buckleStressRS(i), IxxFinalRS(i)] = SparFlangeDims(t2RS(i), D(i), maxBM(i), chord(i));
29
30
sigmaFS(i) = maxBM(i)*D(i)/(4*IxxFinalFS(i));
31
sigmaRS(i) = maxBM(i)*D(i)/(4*IxxFinalRS(i));
32
close all
end
34
for i = 1:146
36
if t1FS(i)<1
37
t1FS(i)=1;
38
end
39
if t1RS(i)<1
40
t1RS(i)=1;
41
end
42
if bFS(i)<1
43
bFS(i)=1;
44
end
45
if bRS(i)<1
46
bRS(i)=1;
47
end
end
%%
%subplot graphs of flange thickness and breadth distribution
%plot front spar
figure
hold on
%plot(spanStation,t1FS,'-r',LineWidth=2);
plot(spanStation, t1FS, '-k', 'LineWidth',2);
56
%title("Front Spar Flange Thickness")
xlabel("Distance from start of wing box (m)")
118
ylabel("Thickness (mm)")
%legend('Optimal Thickness Distribution', 'Actual Thickness Distribution')
61
grid on
ax = gca;
ax.XMinorGrid = 'on';
ax.YMinorGrid = "on";
ax.FontSize = 15;
67
figure
hold on
%plot(spanStation,bFS, '-r', LineWidth=2);
plot(spanStation,bFS, '-k', LineWidth=2);
%title("Front Spar Flange Breadth")
xlabel("Distance from start of wing box (m)")
ylabel("Breadth (mm)")
%legend('Optimal Thickness Distribution', 'Actual Thickness Distribution')
76
grid on
ax = gca;
ax.XMinorGrid = 'on';
ax.YMinorGrid = "on";
ax.FontSize = 15;
82
%plot rear spar
figure
hold on
%plot(spanStation,t1RS, '-r',LineWidth=2);
plot(spanStation,t1RS, '-k',LineWidth=2);
title("Rear Spar Flange Thickness")
xlabel("Distance from start of wing box (m)")
ylabel("Size (mm)")
legend('Optimal Thickness Distribution', 'Actual Thickness Distribution')
92
grid on
ax = gca;
ax.XMinorGrid = 'on';
ax.YMinorGrid = "on";
ax.FontSize = 15;
98
figure
hold on
plot(spanStation,bRS, 'k',LineWidth=2);
%plot(spanStation,bRS, '--k',LineWidth=2);
title("Rear Spar Flange Breadth")
xlabel("Distance from start of wing box (m)")
ylabel("Size (mm)")
legend('Optimal Thickness Distribution', 'Actual Thickness Distribution')
107
grid on
ax = gca;
ax.XMinorGrid = 'on';
ax.YMinorGrid = "on";
ax.FontSize = 15;
119
113
114
%plot buckling stresses
figure
hold on
plot(spanStation,buckleStressFS, '-b', LineWidth=2);
plot(spanStation, sigmaFS, '-r', LineWidth=2);
yline(431,'-k', 'LineWidth',1.5)
%title("Front Spar Buckling Stress")
ylim([380 480])
xlabel("Distance from start of wing box (m)")
ylabel("Stress (MPa)")
legend('Buckling Stress', 'Applied Stress', 'Yield Stress', Location='best')
126
grid on
ax = gca;
ax.XMinorGrid = 'on';
ax.YMinorGrid = "on";
ax.FontSize = 15;
132
figure
hold on
plot(spanStation,buckleStressRS, LineWidth=2);
plot(spanStation, sigmaFS, '-r', LineWidth=2);
yline(431, 'k','LineWidth',1.5)
ylim([380 480])
title("Rear Spar Buckling Stress")
xlabel("Distance from start of wing box (m)")
ylabel("Stress (MPa)")
legend('Buckling Stress', 'Yield Stress', 'Applied Stress', Location='best')
grid on
ax = gca;
ax.XMinorGrid = 'on';
ax.YMinorGrid = "on";
ax.FontSize = 15;
148
149
150
151
%%
function [t1Final, bFinal, buckleStress, IxxFinal] = SparFlangeDims(t2,D,maxBM,chord
)
154
155
%constants
yieldStress = 431; %stress in MPa
E = 73.85*1000; %Youngs Modulus in MPa
159
%variables
IxxReq = maxBM*D/(yieldStress*4);
162
163
%determine possible thickness and breadth array
% t1 = 0:1:ceil(0.01*chord*1000);
120
% b = 0:1:ceil(0.09*chord*1000);
t1 = 0:0.1:30;
b = 0:0.1:400;
169
% for i = 1:length(b)
% if b(i) > 500
% b(i) = 0;
% end
% end
%
% for i = 1:length(t1)
% if t1(i) > 35
% t1(i) = 0;
% end
% end
181
182
%meshgrid t1 and b for use in surf function
[T1,B] = meshgrid(t1,b);
185
186
187
%determine Ixx for use in surf function
Ixx = 1/6.*B.*T1.^3 + 1/2.*B.*T1.*(D-T1).^2 + 1/12.*t2.*(D-2.*T1).^3;
190
%flat surface of Ixx_min
IxxLIM = IxxReq*ones(length(b),length(t1));
193
%plotting...
% s=surf(T1,B,Ixx);
% hold on
% s.EdgeColor = 'none';
% %s.FaceColor = 'g'
% xlabel("Flange Thickness (mm)")
% ylabel('Flange Breadth (mm)')
% zlabel('I_{xx} (mm^4)')
% t=surf(T1,B,IxxLIM);
% t.EdgeColor = 'none';
% t.FaceColor = [0.7 0.7 0.7];
% colormap winter
% ax = gca;
% ax.FontSize=15;
208
209
210
211
212
%determine coordinates of intesection between Ixx_min and surface
for i = 1:length(b)
215
for j = 1:length(t1)
216
if Ixx(i,j) - IxxReq > 0
217
t1Intersect(i,j) = T1(i,j);
218
bIntersect(i,j) = B(i,j);
219
121
220
%filter out all possibilities that result in buckling stress before yield
221
if 0.385*E*(t1Intersect(i,j))^2/(bIntersect(i,j)/2)^2 < yieldStress
222
t1Intersect(i,j) = 0;
223
bIntersect(i,j) = 0;
224
end
225
226
227
end
228
end
end
230
231
232
%design for a buckling stress above
233
234
235
%determine b and t1 and minumum area (minimum mass)
236
area = 2*t1Intersect.*bIntersect;
237
minArea = min(area(area>0));
238
[index1,index2] = find(area==minArea);
239
t1Final = t1Intersect(index1(1),index2(1));
240
bFinal = bIntersect(index1(1),index2(1));
241
buckleStress = 0.385*E*(t1Final)^2/(bFinal/2)^2;
242
IxxFinal = Ixx(index1(1),index2(1));
243
244
245
end
