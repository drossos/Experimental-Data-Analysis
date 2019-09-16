close all;
clc;
clear all;

folder = "/option_2";
curr_dir = pwd + folder;
cd(curr_dir);

volt_uncert = csvread('y_uncert.csv');
curr_uncert = csvread('x_uncert.csv');
currents = csvread('x_dat.csv');
voltages = csvread('y_dat.csv');

xlab = "Current (mA)";
ylab = "Voltage (V)";
g_title = "Voltage against Current - Option 2";

data_analysis(currents, voltages, curr_uncert, volt_uncert, xlab, ylab, g_title)

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

%obtain chi values
[chi_sqr, red_chi_sqr] = chi_sqr_test_gof(x,y,lin_regress, 2)

str = [sprintf("m = %f +- %f",m,sm), sprintf("b = %f +- %f",b,sb), sprintf("r^2 = %f",r2),  sprintf('\\chi^2 = %f',chi_sqr) ,  sprintf('\\chi^2_v = %f',red_chi_sqr)]
annotation('textbox',[.55 .55 .35 .35],'String',str,'FitBoxToText','on');

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
    plot(x, y-reggress_vals, '-o')
    z = refline([0 0] );
    z.LineStyle = "--";
    title("Residual Plot")
    
    
end

function [chi_sqr, red_chi_sqr] = chi_sqr_test_gof(x,y,regress, deg_freedom)
    chi_sqr_raw = sum(((y - regress).^2)/regress);
    chi_sqr = 1-chi2cdf(chi_sqr_raw,length(x) - deg_freedom)
    red_chi_sqr = chi_sqr / (length(x) - deg_freedom)
end 