1function [K] = BucklingCoeff(d_h_ratio,td_ts_ratio,ts_t_ratio,h_b_ratio)
2%BUCKLINGCOEFF Interpolate buckling coefficient from ESDU dataset
3% Refer to ESDU 71014 for notation and explanation
4% cannot pass arrays through, must use loops

6%figure out which figure to refer to
7if(d_h_ratio == 0.3)
if(td_ts_ratio == 1)
figNum = "1";
elseif(td_ts_ratio == 2)
figNum = "2";
end
13elseif(d_h_ratio == 0.4)
if(td_ts_ratio == 1)
figNum = "3";
elseif(td_ts_ratio == 2)
figNum = "4";
end
19elseif(d_h_ratio == 0.5)
if(td_ts_ratio == 1)
figNum = "5";
elseif(td_ts_ratio == 2)
figNum = "6";
end
25end
27%figure out which dataset in figure to refer to
28switch ts_t_ratio
case 0.5
dataNum = "0_5";
case 0.6
dataNum = "0_6";
case 0.7
dataNum = "0_7";
case 0.8
dataNum = "0_8";
case 0.9
dataNum = "0_9";
case 1
dataNum = "1_0";
case 1.25
dataNum = "1_25";
case 1.5
dataNum = "1_5";
case 2
dataNum = "2_0";
47end
49%parse string and extract data
50fileName = "ESDU71014\ESDUfig" + figNum + "data" + dataNum + ".mat";
52data = struct2array(load(fileName));
54%interpolate data
55K = interp1(data(:,1),data(:,2),h_b_ratio);
56end
