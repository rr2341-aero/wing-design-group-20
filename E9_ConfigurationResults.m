clear
clc
close all
4
%read data from Excel file, tables have same spanstations
torqueTable = readtable('Aircraft Loads1.xlsx','Sheet','Wing Torsional Load','Range','O2:BJ160');
7
torqueTable = table2array(torqueTable);
9
%extract relevant data
spanStation = torqueTable(:,1);%span station from centreline in m
torqueVA = torqueTable(:,28);
torqueVA_NF = torqueTable(:,30);
torqueVD = torqueTable(:,33);
torqueVD_NF = torqueTable(:,35);
torqueOEI = torqueTable(:,38);
torqueOEI_NF = torqueTable(:,40);
torqueLanding = torqueTable(:,43);
torqueNegative = torqueTable(:,46);
torqueNegative_NF = torqueTable(:,48);
21
%find where wing actually starts
wingStart = 1.2;
idx = find(spanStation == wingStart);
25
26
%fix values to new coordinate system, now wing start, not fuselage
%centreline, as origin
spanStation = spanStation(idx:end);
spanStation = spanStation - wingStart;
torqueVA = torqueVA(idx:end);
torqueVA_NF = torqueVA_NF(idx:end);
torqueVD = torqueVD(idx:end);
102
torqueVD_NF = torqueVD_NF(idx:end);
torqueOEI = torqueOEI(idx:end);
torqueOEI_NF = torqueOEI_NF(idx:end);
torqueLanding = torqueLanding(idx:end);
torqueNegative = torqueNegative(idx:end);
torqueNegative_NF = torqueNegative_NF(idx:end);
40
%find where landing load exceeds n=-1.5
idx2 = 4; %(occurs at 0.3m which isthe 4th index)
envelopeX = [0 0.1 0.2 0.27];
envelopeY = [-846680 -846680 -846680 -310302];
45
%plot graphs
figure
hold on
49
plot(spanStation,-torqueVA,'g','LineWidth',1.5)
plot(spanStation,-torqueVA_NF,'-.g','LineWidth',1.5)
plot(spanStation,-torqueVD,'m','LineWidth',1.5)
plot(spanStation,-torqueVD_NF,'-.m','LineWidth',1.5)
plot(spanStation,-torqueNegative,'r','LineWidth',1.5)
plot(spanStation,-torqueNegative_NF,'-.r','LineWidth',1.5)
plot(spanStation,-torqueLanding,'b','LineWidth',1.5)
plot(spanStation,-torqueOEI, 'Color',"#D95319",'LineWidth',1.5)
plot(spanStation,-torqueOEI_NF,'-.','Color',"#D95319",'LineWidth',1.5)
59
60
plot(spanStation,-torqueVD,'--k','LineWidth',2)
plot(spanStation(idx2:end),-torqueNegative(idx2:end),'--k','LineWidth',2)
plot(envelopeX, envelopeY, '--k', 'LineWidth',2)
64
65
%title("Wing Torque Diagram")
xlabel("Distance from start of wing box (m)")
ylabel("Torque (Nm)")
69
%legend("V_A, n = 2.5","V_D, n = 3.8","V_A, n = -1.5","Landing", "OEI, n = 3.8");
legend("V_A at n = 2.5","V_A at n = 2.5 with no fuel","V_D at n = 3.8","V_D at n =3.8 with no fuel","V_A at n = -1.5","V_A at n = -1.5 with no fuel","Landing", "
OEI at n = 2.5","OEI at n = 2.5 with no fuel", "Loading Envelope","Location",'southoutside', "Orientation","horizontal",...
72
"NumColumns",2);
grid on
ax = gca;
ax.XMinorGrid = 'on';
ax.YMinorGrid = "on";
ax.FontSize = 15;
78
% % planeW = 45583*9.8;
% %
% plot(spanStation,torqueVA/planeW,'b','LineWidth',2)
% plot(spanStation,torqueVD/planeW,'g','LineWidth',2)
% plot(spanStation,torqueNegative/planeW,'r','LineWidth',2)
% plot(spanStation,torqueLanding/planeW,'m','LineWidth',2)
103
% plot(spanStation,torqueOEI/planeW,'c','LineWidth',2)
% %plot(spanStation,-torqueOEI_NF,':c','LineWidth',1)
% plot(spanStation,torqueVD/planeW,'--k','LineWidth',2)
% plot(spanStation(idx2:end),torqueNegative(idx2:end)/planeW,'--k','LineWidth',2)
% plot(envelopeX, -envelopeY/planeW, '--k', 'LineWidth',2)
90
%
% %title("Wing Torque Diagram")
% xlabel("Distance from start of wing box (m)")
% ylabel("Torque (Gm)")
% %
% legend("V_A, n = 2.5","V_D, n = 3.8","V_A, n = -1.5","Landing", "OEI, n = 3.8");
% legend("V_A at n = 2.5","V_D at n = 3.8","V_A at n = -1.5","Landing with full fuel
", "OEI at n = 3.8", "Loading Envelope");
% grid on
% ax = gca;
% ax.XMinorGrid = 'on';
% ax.YMinorGrid = "on";
