%% Residential Water Piping System: Flow Rate by Iterative Solution
% Three-section supply line (steel main, two drawn-copper branches)
% discharging to atmosphere through a showerhead. The extended Bernoulli
% equation (major and minor losses) is written in terms of the section 1
% velocity and solved by fixed-point iteration.
% Fluid: water at 20 C. Units: SI (m, s, Pa, kg).
%
% Sections
%   1. Inputs
%   2. Segment geometry
%   3. Iterative solution for inlet velocity
%   4. Summary
%
% Local function (end of file): haaland_friction_factor
% Note: local functions in scripts require MATLAB R2016b or later.

clear; clc;

%% 1. INPUTS
% Fluid properties (water, 20 C)
rho = 998.2;             % density [kg/m^3]
nu  = 1.004e-6;          % kinematic viscosity [m^2/s]
g   = 9.81;              % gravitational acceleration [m/s^2]

% Boundary conditions (absolute pressures)
P_in  = 550e3;           % supply pressure [Pa]
P_out = 101325;          % discharge pressure, atmosphere [Pa]
z_in  = 0;               % inlet elevation [m]
z_out = 7;               % outlet elevation [m]

% Pipe geometry, listed as [section 1, section 2, section 3]
d = [2.54e-2, 1.27e-2, 0.95e-2];      % inside diameter [m]
L = [10, 8, 1];                       % length [m]
roughness = [0.045e-3, 0.0015e-3, 0.0015e-3];  % steel, drawn copper, drawn copper [m]

% Minor loss coefficients [-]
K_elbow    = 1.5;        % short-radius 90 deg elbow
K_tee      = 0.9;        % tee, inline flow
K_globe    = 10;         % globe valve, fully open
K_shower   = 1.5;        % showerhead
K_contr_12 = 0.41;       % abrupt contraction, section 1 to 2
K_contr_23 = 0.22;       % abrupt contraction, section 2 to 3

% Solver settings
U1_guess = 10;           % initial guess for section 1 velocity [m/s]
tol_pct  = 0.01;         % convergence tolerance on change in U1 [%]
max_iter = 100;          % iteration limit

%% 2. SEGMENT GEOMETRY
A = pi * d.^2 / 4;               % flow area of each section [m^2]
area_ratio = A(1) ./ A;          % A1/Ai, so that Ui = area_ratio(i) * U1 [-]

% Total minor loss coefficient in each section [-]
% (section 1 has none; section 2 has 2 elbows, 2 tees, globe valve,
% and the contraction into it; section 3 has the contraction and showerhead)
K_minor = [0, ...
           2*K_elbow + 2*K_tee + K_globe + K_contr_12, ...
           K_shower + K_contr_23];

%% 3. ITERATIVE SOLUTION FOR INLET VELOCITY
% Every term is divided by U1^2 so the equation can be solved for U1:
%   (P_in - P_out)/rho + g*(z_in - z_out)
%       = U1^2 * [ KE change + sum(f*L/d/2 * (A1/Ai)^2) + sum(K/2 * (A1/Ai)^2) ]
dP_term = (P_in - P_out)/rho + g*(z_in - z_out);       % [m^2/s^2]
KE_term = 0.5*area_ratio(3)^2 - 0.5;                   % outlet minus inlet kinetic energy [-]

U1_prev   = U1_guess;
U_history = U1_guess;
error_pct = inf;
iter      = 0;

while error_pct > tol_pct && iter < max_iter
    iter = iter + 1;

    % Velocity, Reynolds number, and friction factor in each section
    U  = area_ratio * U1_prev;           % [m/s]
    Re = U .* d / nu;                    % [-]
    f  = zeros(1, 3);
    for i = 1:3
        f(i) = haaland_friction_factor(Re(i), roughness(i) / d(i));
    end

    % Loss terms per unit U1^2 [-]
    major_loss = sum(f .* (L ./ d) * 0.5 .* area_ratio.^2);
    minor_loss = sum(K_minor * 0.5 .* area_ratio.^2);

    % Solve for the new section 1 velocity
    U1 = sqrt(dP_term / (KE_term + major_loss + minor_loss));

    error_pct = abs(U1_prev - U1) / U1 * 100;
    U1_prev   = U1;
    U_history(end+1) = U1; %#ok<SAGROW>
end

if error_pct > tol_pct
    warning('Did not converge within %d iterations.', max_iter);
end

% Final velocities and flow rate
U      = area_ratio * U1;                % [m/s]
Q_m3s  = U1 * A(1);                      % [m^3/s]
Q_Lmin = Q_m3s * 1e3 * 60;               % [L/min]

%% 4. SUMMARY
fprintf('\nResidential Water Piping System\n');
fprintf('-------------------------------\n');
fprintf('Iterations:        %d\n', iter);
fprintf('Final change:      %.6f %%\n\n', error_pct);
for i = 1:3
    fprintf('Section %d:  U = %7.4f m/s,  f = %.4f\n', i, U(i), f(i));
end
fprintf('\nVolume flow rate:  %.3f L/min\n\n', Q_Lmin);

figure;
plot(0:iter, U_history, '-o', 'LineWidth', 1.5);
grid on;
xlabel('Iteration');
ylabel('Section 1 velocity, U_1 [m/s]');
title('Convergence of Inlet Velocity');

%% LOCAL FUNCTIONS
function f = haaland_friction_factor(Re, rel_roughness)
% Friction factor from the Haaland correlation.
%   Re            Reynolds number [-]
%   rel_roughness roughness / diameter [-]
    theta_1 = (-2.457 * log((7 / Re)^0.9 + 0.27 * rel_roughness))^16;
    theta_2 = (37530 / Re)^16;
    f = 8 * ((8 / Re)^12 + 1 / (theta_1 + theta_2)^1.5)^(1/12);
end
