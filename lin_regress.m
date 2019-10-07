close all;
clc;
clear all;



%itterater()
main()

function f = itterater()
d = dir("individ_currents");
isub = [d(:).isdir];
subFolders = {d(isub).name}';

for i = 3:length(subFolders)
  curr = "/individ_currents/" + string(subFolders(i));
  driver("/individ_currents/" + string(subFolders(i)),string(subFolders(i)));
  cd ../..
  close all
end
end 

function f = main()
driver("/em_data/");
end

function driver = driver(dir,title)
folder = dir;
curr_dir = pwd + folder;
cd(curr_dir);


%change these varriable names based 
y_uncert = csvread('y_uncert.csv');
x_uncert = csvread('x_uncert.csv');
x_dat = csvread('x_dat.csv');
y_dat = csvread('y_dat.csv');

% xlab = "1/sqrt(Volatge) (1/V)";
% ylab = "Curvature (1/cm)";
% g_title = "1/sqrt(Volatge) against curvature at " + title + "A";

ylab = "sqrt(Volatge)*curvature (V/cm)";
xlab = "Current (A)";
g_title = "sqrt(Volatge)*curvature against Current";

data_analysis(x_dat, y_dat, x_uncert, y_uncert, xlab, ylab, g_title)

end 
function f = data_analysis(x,y,x_uncert,y_uncert, xlab, ylab, g_title)

y_uncerts = zeros(length(y),1)' + y_uncert;
x_uncerts = zeros(length(x),1)' + x_uncert;


errorbar(x, y, y_uncerts,y_uncerts,x_uncerts,x_uncerts, 'o');
xlabel(xlab);
ylabel(ylab);
title(g_title);
hold on

[m,b] = linear_regres(x, y);

lin_regress = m*x + b;
[sm, sb] = regress_uncert(x,y,lin_regress,m,b);

plot(x , lin_regress);
r2 = r_sqrd_val(y,lin_regress);

DOF = 2;
%obtain chi values
[chi_sqr, red_chi_sqr] = chi_sqr_test_gof(x,y,lin_regress, DOF)

x0=10;
y0=10;
width=800;
height=450
set(gcf,'position',[x0,y0,width,height])

digit = 3

%str = [sprintf("m = %g 1/V*cm +- %g 1/V*cm",round(m,digit,'significant'),round(sm,digit,'significant')), sprintf("b = %g 1/cm +- %g 1/cm",round(b,digit,'significant'),round(sb,digit,'significant')), sprintf("r^2 = %g",round(r2,digit,'significant')),  sprintf('\\chi^2 = %g',round(chi_sqr,digit,'significant')) ,  sprintf('\\chi^2_v = %g',round(red_chi_sqr,digit,'significant'))]
str = [sprintf("m = %g V/(cm*A) +- %g V/(cm*A)",round(m,digit,'significant'),round(sm,digit,'significant')), sprintf("b = %g 1/V*cm +- %g 1/V*cm",round(b,digit,'significant'),round(sb,digit,'significant')), sprintf("r^2 = %g",round(r2,digit,'significant')),  sprintf('\\chi^2 = %g',round(chi_sqr,digit,'significant')) ,  sprintf('\\chi^2_v = %g',round(red_chi_sqr,digit,'significant'))]

annotation('textbox',[.15 .55 .35 .35],'String',str,'FitBoxToText','on');

%Saves plot in curr direct
saveas(gcf, "Linear Regression.png")

%plot residual graph
residuals(x,y,lin_regress)

saveas(gcf, "Residuals Plot.png")

end


%Linear Regression Given two varriables
%Returns intercept as well as slope for y=mx+b
function [m,b] = linear_regres(x,y)
x=x';
y=y';


x = [ones(length(x),1)  x];

vals = x\y;

b = vals(1);
m = vals(2);

end 

function [sm, sb] = regress_uncert(x,y,lin_regress,m,b)
N = length(x);
delta = N*sum(x.^2) - sum(x).^2;

%Varriance of y(x)
syx_sqr = 1/(N-2)* sum((y-(lin_regress)).^2);

sm = sqrt(N*syx_sqr/delta);
sb = sqrt(syx_sqr * sum(x.^2) / delta);

end


function r2 = r_sqrd_val(y,reggress_vals)
r2 = 1 - sum((y - reggress_vals).^2)/sum((y - mean(y)).^2)
end

function f = residuals(x,y,reggress_vals)
    figure(2)
    plot(x, y-reggress_vals, 'o','MarkerFaceColor','b')
    z = refline([0 0] );
    z.LineStyle = "--";
    title("Residual Plot");
    xlabel("Fitted Value");
    ylabel("Residuals");
    
    
    
end

function [chi_sqr, red_chi_sqr] = chi_sqr_test_gof(x,y,regress, deg_freedom)
     deg_freedom = length(x) - 2;
     chi_sqr_raw = sum((y-regress).^2 ./ regress);
     chi_sqr = chi2inv(chi_sqr_raw, deg_freedom)
     red_chi_sqr = chi_sqr / (deg_freedom)

end 

