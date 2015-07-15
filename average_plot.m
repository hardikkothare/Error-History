h = gcf;
axesObjs = get(h,'Children')
dataObjs = get(axesObjs,'Children')
objTypes = get(dataObjs,'Type');
xdata = get(dataObjs,'XDATA')
ydata = get(dataObjs,'YDATA')
xdata = flipud(xdata);
ydata = flipud(ydata);
xdata =cell2mat(xdata)
ydata=cell2mat(ydata)
xdata = xdata'
ydata = ydata'
for i=1:270
indices = find(xdata ==i);
mean_value(1,i) = mean(ydata(indices));
end
figure 
for i = 1:270
plot(i,mean_value(1,i),'b*')
hold on
end
vline(30,'k');
vline(60,'k');
vline(130,'k');
vline(190,'k');
vline(240,'k');
phase_mean(1,1) = mean(mean_value(1,1:15));
phase_mean(1,2) = mean(mean_value(1,16:30));
phase_mean(1,3) = mean(mean_value(1,31:45));
phase_mean(1,4) = mean(mean_value(1,46:60));
phase_mean(1,5) = mean(mean_value(1,61:75));
phase_mean(1,6) = mean(mean_value(1,76:90));
phase_mean(1,7) = mean(mean_value(1,116:130));
phase_mean(1,8) = mean(mean_value(1,131:145));
phase_mean(1,9) = mean(mean_value(1,146:160));
phase_mean(1,10) = mean(mean_value(1,176:190));
phase_mean(1,11) = mean(mean_value(1,191:205));
phase_mean(1,12) = mean(mean_value(1,206:220));
phase_mean(1,13) = mean(mean_value(1,226:240));
phase_mean(1,14) = mean(mean_value(1,241:255));
phase_mean(1,15) = mean(mean_value(1,256:270));
standard_error(1,1) = std(mean_value(1,1:15))/sqrt(15);
standard_error(1,2) = std(mean_value(1,16:30))/sqrt(15);
standard_error(1,3) = std(mean_value(1,31:45))/sqrt(15);
standard_error(1,4) = std(mean_value(1,46:60))/sqrt(15);
standard_error(1,5) = std(mean_value(1,61:75))/sqrt(15);
standard_error(1,6) = std(mean_value(1,76:90))/sqrt(15);
standard_error(1,7) = std(mean_value(1,116:130))/sqrt(15);
standard_error(1,8) = std(mean_value(1,131:145))/sqrt(15);
standard_error(1,9) = std(mean_value(1,146:160))/sqrt(15);
standard_error(1,10) = std(mean_value(1,176:190))/sqrt(15);
standard_error(1,11) = std(mean_value(1,191:205))/sqrt(15);
standard_error(1,12) = std(mean_value(1,206:220))/sqrt(15);
standard_error(1,13) = std(mean_value(1,226:240))/sqrt(15);
standard_error(1,14) = std(mean_value(1,241:255))/sqrt(15);
standard_error(1,15) = std(mean_value(1,256:270))/sqrt(15);
figure
plot(8,phase_mean(1,1),'*k');
hold on
errorbar(8,phase_mean(1,1),standard_error(1,1),'*k');
hold on
plot(23,phase_mean(1,2),'*k');
hold on
errorbar(23,phase_mean(1,2),standard_error(1,2),'*k');
hold on
plot(38,phase_mean(1,3),'*k');
hold on
errorbar(38,phase_mean(1,3),standard_error(1,3),'*k');
hold on
plot(53,phase_mean(1,4),'*k');
hold on
errorbar(53,phase_mean(1,4),standard_error(1,4),'*k');
hold on
plot(68,phase_mean(1,5),'*k');
hold on
errorbar(68,phase_mean(1,5),standard_error(1,5),'*k');
hold on
plot(83,phase_mean(1,6),'*k');
hold on
errorbar(83,phase_mean(1,6),standard_error(1,6),'*k');
hold on
plot(123,phase_mean(1,7),'*k');
hold on
errorbar(123,phase_mean(1,7),standard_error(1,7),'*k');
hold on
plot(138,phase_mean(1,8),'*k');
hold on
errorbar(138,phase_mean(1,8),standard_error(1,8),'*k');
hold on
plot(153,phase_mean(1,9),'*k');
hold on
errorbar(153,phase_mean(1,9),standard_error(1,9),'*k');
hold on
plot(183,phase_mean(1,10),'*k');
hold on
errorbar(183,phase_mean(1,10),standard_error(1,10),'*k');
hold on
plot(198,phase_mean(1,11),'*k');
hold on
errorbar(198,phase_mean(1,11),standard_error(1,11),'*k');
hold on
plot(213,phase_mean(1,12),'*k');
hold on
errorbar(213,phase_mean(1,12),standard_error(1,12),'*k');
hold on
plot(233,phase_mean(1,13),'*k');
hold on
errorbar(233,phase_mean(1,13),standard_error(1,13),'*k');
hold on
plot(248,phase_mean(1,14),'*k');
hold on
errorbar(248,phase_mean(1,14),standard_error(1,14),'*k');
hold on
plot(263,phase_mean(1,15),'*k');
hold on
errorbar(263,phase_mean(1,15),standard_error(1,15),'*k');
hold on
vline(30,'k');
vline(60,'k');
vline(130,'k');
vline(190,'k');
vline(240,'k');