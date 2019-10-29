theta_init = 79.610746;
A = 13900;
B = 1.689;
Ro = 1.1;
To = 20 + 273.14;
alphao =  4.5e-3;

%%Getting Wein Values
data = readtable("bb_data/ex_2_data.csv");

theta_p_meas_uncert = ones(size(data.Trial)).*.00001;
curr_meas_uncert = ones(size(data.Trial)).*.001;
area_meas_uncert = ones(size(data.Trial)).*.001;
theta_init_uncert = ones(size(data.Trial)).* .113;

n = @(theta) sqrt(((2./sqrt(3))*sind(theta) + 1./2).^2 + 3./4);
lambda = @(n) sqrt(A./abs(n-B));
T = @(V,I) To + ((V./I)/Ro - 1 )./alphao;
unitless_param = @(V,I) (V./I)/Ro;

n_uncert = @(ns,thetas,t_uncerts) 2 .* ns .* ((cotd(thetas) .* t_uncerts .* ns) ./ ((2./sqrt(3))*sind(thetas) + 1./2));
lambda_uncert = @(lambdas,ns,n_uncerts) .5 .* (n_uncerts ./ ns) .* lambdas;
T_uncert = @(int_param,vs,is,v_uncert,I_uncert) int_param .* sqrt((v_uncert ./ vs).^2 + (I_uncert ./ is).^2);

n_vals = zeros(length(data.Trial),1);
lambda_vals = zeros(length(data.Trial),1);
T_vals = zeros(length(data.Trial),1);
unitls_params = zeros(length(data.Trial),1);

n_u = zeros(length(data.Trial),1);
lambda_u = zeros(length(data.Trial),1);
T_u = zeros(length(data.Trial),1);

%getting vals
n_vals = n(theta_init - data.PeakAngle);
lambda_vals = lambda(n_vals);
T_vals = T(data.Voltage , data.Current);
unitls_params = unitless_param(data.Voltage,data.Current);

%getting uncerts
n_u = n_uncert(n_vals, theta_init - data.PeakAngle, sqrt(theta_p_meas_uncert.^2 + theta_init_uncert.^2));
lambda_u = lambda_uncert(lambda_vals,n_vals, n_u);
T_u = T_uncert(unitls_params,data.Voltage,data.Current,0,curr_meas_uncert);

wien = T_vals .* (lambda_vals .* 10^(-9));



%% Calculating deviation and mean and plotting

wien_mean = mean(wien);
std_dev = std(wien);

errorbar(wien',std_dev.*ones(size(data.Trial)))
hold on
plot(wien_mean.*ones(length(data.Trial)) , 'g')
title("Wien Constants over Trials");
xlabel("Trial Number");
ylabel("Wien Value (\lambda * T)");

saveas(gcf,"bb_data/wein_vals.png");

%% Calculating the Boltzman's Distrivution
sb_const = 5.670367e-8;
E = 1;

area = data.Area ./ data.Tare;
area_uncert = area_meas_uncert ./ data.Tare;

T4 = T_vals .^ 4;
t4_uncerts = (T_u ./ T_vals) .* T4;

writematrix(T4, "bb_data/x_dat.csv");
writematrix(area, "bb_data/y_dat.csv");

writematrix(t4_uncerts, "bb_data/x_uncert.csv");
writematrix(area_uncert, "bb_data/y_uncert.csv");
    
