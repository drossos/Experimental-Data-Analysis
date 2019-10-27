theta_init = 79.610746;
A = 13900;
B = 1.689;
Ro = 1.1;
To = 20 + 273.14;
alphao =  4.5e-3;

%%Getting Wein Values
ex_1_table = readtable("bb_data/ex_2_data.csv");

n = @(theta) sqrt(((2./sqrt(3))*sind(theta) + 1./2).^2 + 3./4);
lambda = @(n) sqrt(A./abs(n-B));
T = @(V,I) To + ((V./I)/Ro - 1 )./alphao;

n_vals = zeros(length(ex_1_table.Trial),1);
lambda_vals = zeros(length(ex_1_table.Trial),1);
T_vals = zeros(length(ex_1_table.Trial),1);

n_vals = n(theta_init - ex_1_table.PeakAngle);
lambda_vals = lambda(n_vals);
T_vals = T(ex_1_table.Voltage , ex_1_table.Current);

wien = T_vals .* (lambda_vals .* 10^(-9));


%% Calculating deviation and mean and plotting

wien_mean = mean(wien);
std_dev = std(wien);

errorbar(wien',std_dev.*ones(size(ex_1_table.Trial)))
hold on
plot(wien_mean.*ones(length(ex_1_table.Trial)) , 'g')


%% Calculating the Boltzman's Distrivution
sb_const = 5.670367e-8;
E = 1;


for i = 1:3:size(ex_1_table.Trial)
    curr_trials = ex_1_table(i:i+2, :);
    curr_T = T_vals(i:i+2, :);
    area = curr_trials.Area .* (100 ./ curr_trials.Tare);
    
    curr_T = curr_T .^ 4 .* sb_const * E;
    
    plot(curr_T, area);
    hold on
    
end