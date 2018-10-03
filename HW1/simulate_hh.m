clear all

%% Configure input current

% Basic step input at t=100
Iapp = @(t) (t>100)*16;
% 
% % Two pulses spaced t_sep ms apart
% t_sep = 3;
% Iapp = @(t) (t>10 & t < 12)*10 + (t>10+t_sep & t < 12+t_sep)*10;
% 
% % Step up from 0 to 6.3 microA at t=100
% Iapp = @(t) (t>0 & t < 100)*0 + 6.3*(t>100);
% 
% % Step up from 0 to 8 microA at t=100
% Iapp = @(t) (t>0 & t < 100)*0 + 8*(t>100);
% 
% % Step down from 10 to 8 microA at t=100
% Iapp = @(t) (t>0 & t < 100)*10 + 8*(t>100);
% 
% % Step down from 10 to 0 microA at t=100
% Iapp = @(t) (t>0 & t < 100)*10;
% 
% % Sinusoid plus constant amplitude 
% I0 = 7;
% I1 = 7;
% hz = 50;
% omega = hz/1000*2*pi;
% Iapp  = @(t) I0 + I1*sin(omega*t);

%% Simulate HH dynamics
use_euler = false;

theta0 = [0.0003    0.0529    0.3177    0.5961]; % Initial state
Tfinal = 200; % Duration of simulation in ms
dt = .01;
if use_euler
    [t,theta] = euler_solver(@(t,x) hh_deriv(t,x,Iapp), [0 Tfinal], theta0, dt);
else
    [t,theta] = ode45(@(t,x) hh_deriv(t,x,Iapp), [0 Tfinal], theta0);
end

% Zoom in on one section
zoom = false;
if zoom
    theta = theta(t > 104 & t < 120, :);
    t = t(t > 104 & t < 120);
end

% Plot results
plot_ax(1) = subplot(311);
plot(t,Iapp(t),'linewidth',2)
ylabel('Input current (\mu A)')

plot_ax(2) = subplot(312);
plot(t,theta(:,1),'linewidth',2)
ylabel('Membrane potential (mV)')
xlabel('Time (ms)')

linkaxes(plot_ax,'x')

% Estimate firing rate
vthresh = 20; % Consider a spike to have occured when voltage crosses this threshold (mV)
t_thresh = 100; % Only compute firing rate using spikes occuring after this time (in ms)
v = theta(:,1);
tspike = t(v(1:end-1) <= vthresh & v(2:end) > vthresh);
tspike(tspike < t_thresh) = []; % Throw away spikes occuring before t_thresh ms
if isempty(tspike) % Handle zero firing rate
   tspike = [0 inf]; 
end
for ts = tspike
    vline(ts) 
end

fr = 1000/median(diff(tspike));
text(10,[.1 .9]*get(gca,'YLim')',sprintf('Firing rate: %g Hz', fr))

% Plot gating variables
plot_ax(3) = subplot(313);
plot(t,theta(:,2:end))
ylabel('Gating variable')
legend('m','n','h')
xlabel('Time (ms)')

linkaxes(plot_ax,'x')

%% varying current
var_range = 0:0.5:15;
Iapp_curve = cell(length(var_range),1);
for iCurrent = 1:length(var_range)
    Iapp_curve{iCurrent} = @(t) (t>100)*var_range(iCurrent);
end

%% varying omega
I0 = 0;
I1 = 7;
var_range = 5:5:100;
Iapp_curve = cell(length(var_range),1);

for iHz = 1:length(var_range)
    hz = var_range(iHz);
    omega = hz/1000*2*pi;
    Iapp_curve{iHz}  = @(t) I0 + I1*sin(omega*t);
end

%% varying I0
hz = 50;
omega = hz/1000*2*pi;
I1 = 7;
var_range = 0:0.5:10;
Iapp_curve = cell(length(var_range),1);

for iI0 = 1:length(var_range)
    I0 = var_range(iI0);
    Iapp_curve{iI0}  = @(t) I0 + I1*sin(omega*t);
end
    
%% Plot firing rate vs current
theta0 = [0.0003    0.0529    0.3177    0.5961]; % Initial state
Tfinal = 200; % Duration of simulation in ms

vthresh = 20; % Consider a spike to have occured when voltage crosses this threshold (mV)
t_thresh = 100; % Only compute firing rate using spikes occuring after this time (in ms)
firing_rates = zeros(1, length(Iapp_curve));

for iCurrent = 1:length(Iapp_curve)
    Iapp = Iapp_curve{iCurrent};
    [t,theta] = ode45(@(t,x) hh_deriv(t,x,Iapp), [0 Tfinal], theta0);
    v = theta(:,1);

    tspike = t(v(1:end-1) <= vthresh & v(2:end) > vthresh);
    tspike(tspike < t_thresh) = []; % Throw away spikes occuring before t_thresh ms
    % CHANGED LINE! switch back?
    if length(tspike) < 2 % Handle zero firing rate
        tspike = [0 inf]; 
    end
    fr = 1000/median(diff(tspike));
    firing_rates(iCurrent) = fr;
end

scatter(var_range, firing_rates, 'filled')
ylabel('Firing rate (Hz)')

%%
title('Firing rate vs. input current')
xlabel('Input current (\mu A)')

%% 
title('Firing rate vs. omega')
xlabel('omega')

%% 
title('Firing rate vs. I0')
ylim([0 inf])
xlabel('I0 (\mu A)')