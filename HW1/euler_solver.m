function [t, y] = euler_solver(odefun, tspan, y0, dt)
% Solve differential equation y' = f(t,y), from time tspan = [t0 t_final], 
% with initial condition y0. Here odefun must be a function with signature 
% odefun(t,y), which for a scalar t and a vector y returns a column vector 
% corresponding to f(t,y). The solver uses the integration timestep dt. 
% Each row in the solution array y corresponds to a time returned in the 
% column vector t.

% make array of all times between time spans, incremented by dt
%                                                
t = (tspan(1):dt:tspan(2));

y = zeros(length(t), length(y0));
y(1,:) = y0;

for tind = 2:length(t)
    tcurrent = t(tind);
    dy = odefun(tcurrent, y(tind-1,:))';
    y(tind,:) = y(tind-1,:) + dt * dy;
end