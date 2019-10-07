close all;
clc;
clear all;

all_dat = readtable("raw_data.csv");

%Declaring Varriables for each reading
current = all_dat.I;
voltage = all_dat.V;
current = all_dat.I;
LS = all_dat.LS;
RS = all_dat.RS;

%Getting radius values
r = abs(LS + RS)*1.2 ./ 2;

I_uncert = .001;
R_uncert = .05;
V_uncert = .1;

%1.2 to correct for parralax
root_volt_curv = sqrt(voltage) ./ r;

%propogating the errors for y axis and x axis
n = .5;
V_uncert = n*voltage.^(n-1).*R_uncert;
y_uncert = root_volt_curv .* sqrt((V_uncert./voltage).^2+(R_uncert./r).^2);
x_uncert = ones(length(current),1) .* I_uncert;

%multiplot("individ_currents",[current voltage r])

%creting uncert vectors (TODO IMPILMENT REAL UNCERTS ONCE WE KNOW HOW)


%exporting data to processed version
path = "em_data/";
csvwrite(path + "x_dat.csv",current');
csvwrite(path + "y_dat.csv",root_volt_curv');
csvwrite(path + "x_uncert.csv",x_uncert');
csvwrite(path + "y_uncert.csv",y_uncert');

function f = multiplot(dir,dat)
pre_entry = dat(1);

currents = dat(:,1);
xdat = [];
ydat = [];
xuncert =  zeros(length(currents),1);
yuncert =  zeros(length(currents),1);

for i = 1:length(currents)
    if (currents(i) ~= pre_entry)
        mkdir (dir+"/"+pre_entry+"_current/");
        path = dir+"/"+pre_entry+"_current/";
        csvwrite(path + "x_dat.csv",xdat');
        csvwrite(path + "y_dat.csv",ydat');
        
        xuncert =  zeros(length(xdat),1);
        yuncert =  zeros(length(xdat),1);
        csvwrite(path + "x_uncert.csv",xuncert');
        csvwrite(path + "y_uncert.csv",yuncert');
        
        %driver(path);
        
        xdat = [];
        ydat = [];
        %xuncert = [];
        %yuncert = [];
        
        
    end
       
    xdat = [xdat 1./sqrt(dat(i,2))];
    ydat = [ydat 1./dat(i,3)];
    
    pre_entry = currents(i);
    
    
end 
end 