close all
clear all
clc

%% Coronavirus ~Toy~ Simulation
% Philip Mocz (2020)
% Pinceton University
% http://pmocz.github.io/

% Free to use -- please give credit!

% Simulates a population of interacting particles
% Parameters:
% N = population size in the box (the box size is fixed at 1)
% p_inf         = probability of infection upon contact per unit time interval
% r_inf         = infection radius of individual
% t_inf         = time individual stays infectious
% p_death       = probability of death during infection period
% isolation_fun = isolation function of time (= 1 means regular interaction level; = 0 means no interaction)

% To Try: try out the effect of the different isolation functions!
% uncomment the isolation functions you would like to use!

%isolation_fun = @(t) ones(size(t)); % constant function
%isolation_fun = @(t) exp(-0.1*t); % social distancing
isolation_fun = @(t) (cos(2*t)+1)/2; % sinusoidal distancing


%% Parameters
N = 2e3;
p_inf = 1;
r_inf = 0.02;
t_inf = 1;
p_death = 0.02;

t = 0;
dt = 0.1;
Tfinal = 20; % end of simulation




%% Initial Conditions
rng(42); % random number seed

x = rand(N,1);
y = rand(N,1);

vx = randn(size(x))*0.1;
vy = randn(size(x))*0.1;

infected = false(size(x));
infected_t_counter = zeros(size(x));
infected(1) = true;

immune = false(size(x));


%% Simulation
fh = figure('position',[0 0 400 900]);

while t < Tfinal
    
    
    %% get distance between particle pairs
    r = sqrt((x-x').^2+(y-y').^2);
    contactMtx = r < r_inf & r > 0;
    
    %% compute infections
    
    num_inf_contacts = contactMtx * double(infected);
    cut = (~infected & ~immune);
    infected(cut) = num_inf_contacts(cut) & (rand(size(infected(cut))) < p_inf * dt * num_inf_contacts(cut));
    
    
    %% move particles (applying the isolation function)
    x = mod(x + dt*isolation_fun(t)*vx,1);
    y = mod(y + dt*isolation_fun(t)*vy,1);
    
    
    %% apply infected time counter, and cures
    infected_t_counter(infected) = infected_t_counter(infected) + dt;
    recovered = infected_t_counter > t_inf;
    infected(recovered) = false;
    infected_t_counter(recovered) = 0;
    immune(recovered) = true;
    
    %% apply death / remove particles
    death = infected & (rand(size(infected)) < p_death * dt/t_inf);
    
    x = x(~death);
    y = y(~death);
    vx = vx(~death);
    vy = vy(~death);
    infected = infected(~death);
    infected_t_counter = infected_t_counter(~death);
    immune = immune(~death);
    
    
    %% advance time
    t = t + dt;
    
    
    %% plot
    subplot(3,1,1)
    plot(x(~infected),y(~infected),'o','color',[0 0 1],'markerfacecolor',[0 0 1],'markersize',1)
    hold on
    plot(x(immune),y(immune),'o','color',[0 0.6 0],'markerfacecolor',[0 0.4 1],'markersize',1)
    plot(x(infected & ~immune),y(infected & ~immune),'o','color',[1 0 0],'markerfacecolor',[1 0 0],'markersize',1)
    hold off
    axis([0 1 0 1])
    axis square
    xticks([]);
    yticks([]);
    
    subplot(3,1,2)
    plot(0:dt:Tfinal,isolation_fun((0:dt:Tfinal)),'b')
    xlabel('time');
    ylabel('Interaction level');
    axis([0 Tfinal 0 1.2])
    
    subplot(3,1,3)
    semilogy(t,sum(infected),'ro') % number infected
    hold on
    semilogy(t,sum(immune),'o','color',[0 0.8 0]) % number immmune
    semilogy(t,N-numel(x),'ko') % deaths
    if t == dt
        text(0.75*Tfinal,10.^((log10(N))*0.15),'# immune','color',[0 0.6 0]);
        text(0.75*Tfinal,10.^((log10(N))*0.1),'# infected','color','r');
        text(0.75*Tfinal,10.^((log10(N))*0.05),'# deaths');
        xlabel('time');
        ylabel('N');
        axis([0 Tfinal 1 N])
    end
    
    pause(0.0001);
    
    
end


