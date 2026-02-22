1%plot 3 variations of web thickness of limiting cases
2%obtain superposition of max thickness
4clear
5clc
6close all
8vals = readtable( 'Wing Design1.xlsx ','Sheet ','Spar Web Sizing ','Range ','F3:AQ148 ');
9vals = table2array(vals);
11spanStation = vals(:,1)-1.2;
12FSthickCase1 = vals(:,13);
13RSthickCase1 = vals(:,14);
14FSthickCase2 = vals(:,24);
15RSthickCase2 = vals(:,25);
16FSthickCase3 = vals(:,35);

17RSthickCase3 = vals(:,36);
20figure
21hold on
22plot(spanStation, FSthickCase1, 'g', LineWidth=2)
23plot(spanStation, FSthickCase2, 'b', LineWidth=2)
24plot(spanStation, FSthickCase3, 'r', LineWidth=2)
25for i = 1:length(spanStation)
if FSthickCase1(i) < 1
FSthickCase1(i) = 1;
end
29end
30plot(spanStation, FSthickCase1, 'k--', LineWidth=2)
32ylim([0 9])
34title("Front Spar Thickness Distribution")
35ylabel("Front Spar Thickness (mm)")
36xlabel("Distance from start of wingbox (m)")
39legend("V_D at n = 4.5", "V_A at n = -1.5", "Landing", "Actual Distribution");
40grid on
41ax = gca;
42ax.XMinorGrid = 'on';
43ax.YMinorGrid = "on";
46figure
47hold on
48plot(spanStation, RSthickCase1, 'g', LineWidth=2)
49plot(spanStation, RSthickCase2, 'b', LineWidth=2)
50plot(spanStation, RSthickCase3, 'r', LineWidth=2)
51for i = 1:length(spanStation)
if RSthickCase1(i) < 1
RSthickCase1(i) = 1;
end
55end
57RSfinal = [RSthickCase3(1:3); RSthickCase1(4:146)];
58plot(spanStation, RSfinal, 'k--', LineWidth=2)
60ylim([0 9])
62title("Rear Spar Thickness Distribution")
63ylabel("Rear Spar Thickness (mm)")
64xlabel("Distance from start of wingbox (m)")
67legend("V_D at n = 4.5", "V_A at n = -1.5", "Landing", "Actual Distribution");
68grid on
69ax = gca;
70ax.XMinorGrid = 'on';

71ax.YMinorGrid = "on";
93% for i = 1:length(spanStation)
94% if FSthickCase1(i) < 1
95% FSthickCase1(i) = 1;
96% end
97%
98% if RSthickCase1(i) < 1
99% RSthickCase1(i) = 1;
100% end
101% if FSthickCase2(i) < 1
102% FSthickCase2(i) = 1;
103% end
104% if RSthickCase2(i) < 1
105% RSthickCase2(i) = 1;
106% end
107% if FSthickCase3(i) < 1
108% FSthickCase3(i) = 1;
109% end
110% if RSthickCase3(i) < 1
111% RSthickCase3(i) = 1;
112% end
113%
114% end
