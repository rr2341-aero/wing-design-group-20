1% script to visualise wing structure
3%% Wing planform
5croot = 5.98;
6ctip = 2.03;
7taper = ctip/croot;
8sweepLE = 36.4 .* pi / 180;
9b = 31.30660302/2;
10AR = 8;
11fuselageIntersection = 1.2;
13%wing geometry
14c = @(x) croot + (croot - ctip)/-b .* x;
15LE = @(x) -x .* tan(sweepLE);
16TE = @(x) LE(x) - c(x);
18%compute front and rear spar sweep lines
19sweepFrontSpar = atan(tan(sweepLE) - 4/AR * (0.2 * (1-taper)/(1+taper)));
20sweepBackSpar = atan(tan(sweepLE) - 4/AR * (0.7 * (1-taper)/(1+taper)));
22frontSpar = @(x) -0.2*croot - x.*tan(sweepFrontSpar);
23backSpar = @(x) -0.7*croot - x.*tan(sweepBackSpar);
25%plot figures
26figure
27subplot(1,2,1)
28hold on

29fplot(frontSpar,[fuselageIntersection,b],"b-","LineWidth",1)
30fplot(backSpar,[fuselageIntersection,b],"b-","LineWidth",1)
31fplot(LE,[0,b],"k","LineWidth",2)
32fplot(TE,[0,b],"k","LineWidth",2)
33plot([b,b],[LE(b),TE(b)],"k","LineWidth",2)
35xline(fuselageIntersection,"k:", 'LineWidth ',2); %fuselage intersection
37%14 stringers, from front spar to rear spar
38stringerNum = 14;
39stringerStartX = ones(stringerNum,1) * 1.2;
40stringerStartY = linspace(frontSpar(1.2),backSpar(1.2),stringerNum+2);%discretise
sufficient poiont
41stringerStartY = stringerStartY(2:end-1);%do not want front spar or rear spar
43plot(stringerStartX,stringerStartY, 'rx')
44stringerGradient = -tan(sweepFrontSpar);
46stringerEndX = flip([b b b b b 14.8169 13.126 11.4348 9.74381 8.85408 7.16311
5.47213 2.97991 2.09018]);
47stringerEndY = flip([-12.1532 -12.3427 -12.5321 -12.7216 -12.9111 -12.5248 -11.5509
-10.5774 -9.60351 -9.18089 -8.20706 -7.23322 -5.70817 -5.28555]);
48for i = 1:stringerNum
eq = @(x) stringerGradient*(x - 1.2) - stringerStartY(i) -1.152*croot + 0.0048;
fplot(eq,[1.2 stringerEndX(i)], 'r')
disp(stringerEndX(i));
52end
53plot(stringerEndX,stringerEndY, 'rx')
56%plot the ribs
57ribGradient = 1/tan(sweepFrontSpar); %or LE sweep?
59ribLoc = linspace(1.2,b,18);
61for i = 1:length(ribLoc)-1
eq = @(x)ribGradient*(x - ribLoc(i)) + backSpar(ribLoc(i));
if i < 2
k = 0;
elseif i < length(ribLoc)/2 - 1
k = 0.035;%correction factor to correct line lengths for taper
else
k = 0.045;
end
fplot(eq,[ribLoc(i) ribLoc(i)+1.3-k*i], 'g','LineWidth ',2)
71end
72plot([ribLoc(end) ribLoc(end)],[backSpar(ribLoc(end)) frontSpar(ribLoc(end))], 'g','
LineWidth ',2)
74%%----------------plot psuedo ribs
75pseudo_rib_loc = 1.2 + linspace(0,14.45,17);
76pseudo_rib_loc = pseudo_rib_loc(:,2:end-1);
77% for i = 1:length(pseudo_rib_loc)
78% eq = @(x)ribGradient*(x - pseudo_rib_loc(i)) + frontSpar(pseudo_rib_loc(i));

79% if i < 2
80% k = 0;
81% elseif i < length(pseudo_rib_loc)/2 - 1
82% k = 0.035;%correction factor to correct line lengths for taper
83% else
84% k = 0.045;
85% end
86% fplot(eq,[pseudo_rib_loc(i) pseudo_rib_loc(i)+0.5], 'b','LineWidth ',2)
87% end
89xLoc = [2.60312 3.48352 4.36392 5.24432 6.13554 7.01731 7.89688 8.77735 ...
9.66903 10.5494 11.4298 12.3102 13.2021 14.0823 14.9634];
91yLoc = [-1.91605 -2.57039 -3.22473 -3.87907 -4.51767 -5.17003 -5.82557 ...
-6.47981 -7.11774 -7.77208 -8.42642 -9.08077 -9.71859 -10.3731 -11.0264];
94for i = 1:length(pseudo_rib_loc)
eq = @(x)ribGradient*(x - pseudo_rib_loc(i)) + frontSpar(pseudo_rib_loc(i));
xData = [pseudo_rib_loc(i) xLoc(i)];
yData = [eq(xData(1)) yLoc(i)];
plot(xData,yData, 'c-','LineWidth ',2);
99end
100grid on
101ax = gca;
102ax.XMinorGrid = 'on';
103ax.YMinorGrid = "on";
104xlabel("Distance from fuselage centreline (m)")
105ylabel("Distance along fuselage from leading edge root (m)")
106title("Wing structure top with 14 stringers")
107legend("Front Spar","Back Spar", '','','',"Fuselage","Stringer Start/End Points","
Stringer",...
'','','','','','','','','','','','','','','','','','','','','','','','',...
"Ribs", '','','','','','','','','','','','','','','','','','',...
"Psuedo-Ribs")
112%% Visualisation of Bottom
114croot = 5.98;
115ctip = 2.03;
116taper = ctip/croot;
117sweepLE = 36.4 .* pi / 180;
118b = 31.30660302/2;
119AR = 8;
120fuselageIntersection = 1.2;
122%wing geometry
123c = @(x) croot + (croot - ctip)/-b .* x;
124LE = @(x) -x .* tan(sweepLE);
125TE = @(x) LE(x) - c(x);
127%compute front and rear spar sweep lines
128sweepFrontSpar = atan(tan(sweepLE) - 4/AR * (0.2 * (1-taper)/(1+taper)));
129sweepBackSpar = atan(tan(sweepLE) - 4/AR * (0.7 * (1-taper)/(1+taper)));
131frontSpar = @(x) -0.2*croot - x.*tan(sweepFrontSpar);

132backSpar = @(x) -0.7*croot - x.*tan(sweepBackSpar);
134%plot figures
135subplot(1,2,2)
136hold on
137fplot(frontSpar,[fuselageIntersection,b],"b-","LineWidth",1)
138fplot(backSpar,[fuselageIntersection,b],"b-","LineWidth",1)
139fplot(LE,[0,b],"k","LineWidth",2)
140fplot(TE,[0,b],"k","LineWidth",2)
141plot([b,b],[LE(b),TE(b)],"k","LineWidth",2)
143xline(fuselageIntersection,"k:", 'LineWidth ',2); %fuselage intersection
145%14 stringers, from front spar to rear spar
146stringerNum = 24;
147stringerStartX = ones(stringerNum,1) * 1.2;
148stringerStartY = linspace(frontSpar(1.2),backSpar(1.2),stringerNum+2);%discretise
sufficient poiont
149stringerStartY = stringerStartY(2:end-1);%do not want front spar or rear spar
151plot(stringerStartX,stringerStartY, 'rx')
152stringerGradient = -tan(sweepFrontSpar);
154stringerEndX = flip([b b b b b b b b b 14.8167 13.9624 13.1081 12.2537 10.5981
9.74381 8.88947 8.03514 7.1808 6.32647,...
5.47209 4.61781 3.76349 2.90913 2.05487]);
156stringerEndY = flip([-12.0774 -12.1911 -12.3048 -12.4184 -12.5321 -12.6458 -12.7595
-12.8732 -12.9869 -12.525 -12.051 -11.5769,...
-11.1029 -10.0776 -9.60351 -9.12976 -8.65539 -8.18134 -7.70728 -7.23328 -6.75915
-6.28506 -5.81105 -5.33688]);
158for i = 1:stringerNum
eq = @(x) stringerGradient*(x - 1.2) - stringerStartY(i) -1.152*croot + 0.0048;
fplot(eq,[1.2 stringerEndX(i)], 'r')
disp(stringerEndX(i));
162end
163plot(stringerEndX,stringerEndY, 'rx')
166%plot the ribs
167ribGradient = 1/tan(sweepFrontSpar); %or LE sweep?
169ribLoc = linspace(1.2,b,18);
171for i = 1:length(ribLoc)-1
eq = @(x)ribGradient*(x - ribLoc(i)) + backSpar(ribLoc(i));
if i < 2
k = 0;
elseif i < length(ribLoc)/2 - 1
k = 0.035;%correction factor to correct line lengths for taper
else
k = 0.045;
end
fplot(eq,[ribLoc(i) ribLoc(i)+1.3-k*i], 'g','LineWidth ',2)
181end

182plot([ribLoc(end) ribLoc(end)],[backSpar(ribLoc(end)) frontSpar(ribLoc(end))], 'g','
LineWidth ',2)
184%%----------------plot psuedo ribs
185pseudo_rib_loc = 1.2 + linspace(0,14.45,17);
186pseudo_rib_loc = pseudo_rib_loc(:,2:end-1);
187% for i = 1:length(pseudo_rib_loc)
188% eq = @(x)ribGradient*(x - pseudo_rib_loc(i)) + frontSpar(pseudo_rib_loc(i));
189% if i < 2
190% k = 0;
191% elseif i < length(pseudo_rib_loc)/2 - 1
192% k = 0.035;%correction factor to correct line lengths for taper
193% else
194% k = 0.045;
195% end
196% fplot(eq,[pseudo_rib_loc(i) pseudo_rib_loc(i)+0.5], 'b','LineWidth ',2)
197% end
199xLoc = [2.60312 3.48352 4.36392 5.24432 6.13554 7.01731 7.89688 8.77735 ...
9.66903 10.5494 11.4298 12.3102 13.2021 14.0823 14.9634];
201yLoc = [-1.91605 -2.57039 -3.22473 -3.87907 -4.51767 -5.17003 -5.82557 ...
-6.47981 -7.11774 -7.77208 -8.42642 -9.08077 -9.71859 -10.3731 -11.0264];
204for i = 1:length(pseudo_rib_loc)
eq = @(x)ribGradient*(x - pseudo_rib_loc(i)) + frontSpar(pseudo_rib_loc(i));
xData = [pseudo_rib_loc(i) xLoc(i)];
yData = [eq(xData(1)) yLoc(i)];
plot(xData,yData, 'c-','LineWidth ',2);
209end
211for i = 1:length(pseudo_rib_loc) - 1
eq = @(x)ribGradient*(x - pseudo_rib_loc(i)) + frontSpar(pseudo_rib_loc(i));
xData = [pseudo_rib_loc(i) xLoc(i)];
yData = [eq(xData(1)) yLoc(i)];
plot(xData,yData, 'c-','LineWidth ',2);
216end
219grid on
220ax = gca;
221ax.XMinorGrid = 'on';
222ax.YMinorGrid = "on";
223xlabel("Distance from fuselage centreline (m)")
224ylabel("Distance along fuselage from leading edge root (m)")
225title("Wing structure bottom with 24 stringers")
226legend("Front Spar","Back Spar", '','','',"Fuselage","Stringer Start/End Points","
Stringer",...
'','','','','','','','','','','','','','','','','','','','','','','','',...
"Ribs", '','','','','','','','','','','','','','','','','','',...
"Psuedo-Ribs")
