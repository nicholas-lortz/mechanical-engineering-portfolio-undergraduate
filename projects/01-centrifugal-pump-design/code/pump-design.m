%% Centrifugal Pump Design: Impeller, Blade Profile, Diffuser, and Volute
% Design point: 1500 gpm at 2500 rpm, 500 ft discharge head
% Fluid: water at sea level, STP. Units: U.S. customary (ft, in, gpm, rpm, psi).
%
% Sections
%   1. Design conditions and inputs
%   2. Specific speed and shaft power
%   3. Inlet configuration
%   4. Outlet configuration
%   5. Blade profile
%   6. Design checks (outlet angle, solidity, diffusion factor)
%   7. Diffuser and volute
%   8. Summary and plot

clear; clc; close all;

%% 1. DESIGN CONDITIONS AND INPUTS
% Required operating point
Q_gpm = 1500;            % flow rate [gpm]
N_rpm = 2500;            % rotating speed [rpm]
H_ft  = 500;             % discharge head [ft]

% Design choices
sigma_s_psi  = 10000;    % allowable shaft shear stress [psi]
r_1_in       = 3.2;      % impeller inlet radius [in]
beta_b1_deg  = 17;       % blade angle at inlet [deg]
beta_b2_deg  = 22.5;     % blade angle at outlet [deg]
D_s          = 8.2;      % specific diameter from Cordier diagram [-]
Z_override   = 9;        % blade count (0 = use computed value)
n_steps      = 10;       % radial increments for blade profile
t_blade_in   = 0.25;     % blade thickness [in]
K_3          = 0.46;     % volute throat velocity ratio (Fig. 4.24) [-]
diff_ratio   = 0.08;     % (D_3 - D_2) / D_2 (Fig. 4.24) [-]
C_vol        = 0.95;     % volute angular momentum coefficient [-]
phi_trap_deg = 30;       % included angle of trapezoidal volute section [deg]
make_plots   = true;

% Constants and assumptions
g          = 32.2;       % gravitational acceleration [ft/s^2]
gamma_w    = 62.4;       % specific weight of water [lbf/ft^3]
n_oa       = 0.78;       % overall efficiency [-]
phi_e      = 0.27;       % eye flow coefficient [-]
V1_ratio   = 1.1;        % inlet velocity / eye velocity [-]
in2_per_ft2 = 144;       % unit conversion

%% 2. SPECIFIC SPEED AND SHAFT POWER
Q_fts = Q_gpm * 231 / (60 * 12^3);        % flow rate [ft^3/s]
omega = 2*pi*N_rpm / 60;                  % angular speed [rad/s]

N_s     = N_rpm * sqrt(Q_gpm) / H_ft^(3/4);              % specific speed (U.S.)
omega_s = omega * sqrt(Q_fts) / (g * H_ft)^(3/4);        % dimensionless specific speed

P_s_ftlbfs = Q_fts * (gamma_w * H_ft) / n_oa;            % shaft power [ft*lbf/s]
P_s_hp     = P_s_ftlbfs / 550;                           % shaft power [hp]
tau        = P_s_ftlbfs / omega;                         % shaft torque [ft*lbf]

%% 3. INLET CONFIGURATION
% Shaft diameter from torsion
D_sh_ft = (16 * tau / (pi * sigma_s_psi * in2_per_ft2))^(1/3);
D_sh_in = D_sh_ft * 12;

% Eye geometry
r_e_ft = (Q_fts / (pi * phi_e * omega))^(1/3);
d_e_ft = 2 * r_e_ft;
d_e_in = 12 * d_e_ft;

V_e_fts = Q_fts / (pi * d_e_ft^2 / 4);    % eye velocity [ft/s]
V_1_fts = V1_ratio * V_e_fts;             % blade inlet velocity [ft/s]

% Blade inlet
r_1_ft  = r_1_in / 12;
A_1_ft2 = Q_fts / V_1_fts;
b_1_in  = 12 * A_1_ft2 / (2 * pi * r_1_ft);   % inlet blade width [in]

U_1_fts      = omega * r_1_ft;                         % blade speed [ft/s]
beta_f1_deg  = atand(V_1_fts / U_1_fts);               % relative flow angle [deg]
W_1_fts      = hypot(U_1_fts, V_1_fts);                % relative velocity [ft/s]

%% 4. OUTLET CONFIGURATION
d_2_ft = D_s * sqrt(Q_fts) / (g * H_ft)^(1/4);
d_2_in = 12 * d_2_ft;
r_2_ft = d_2_ft / 2;
r_2_in = d_2_in / 2;
U_2_fts = omega * r_2_ft;

% Blade count (computed, unless overridden)
nu  = (2 * r_1_ft) / d_2_ft;                                           % diameter ratio d_1/d_2
Z_b = 6.5 * ((1 + nu) / (1 - nu)) * sind((beta_b1_deg + beta_b2_deg) / 2);
if Z_override ~= 0
    Z = Z_override;
else
    Z = round(Z_b);
end

% Hydraulic efficiency, slip factor, and outlet velocities
n_h  = 1 - 0.80 / Q_gpm^(1/4);
mu_s = 1 - pi * sind(beta_b2_deg) / Z;                       % slip factor

V_u2_fts = g * H_ft / (n_h * U_2_fts);                       % tangential velocity [ft/s]
V_r2_fts = (U_2_fts - V_u2_fts / mu_s) * tand(beta_b2_deg);  % radial velocity [ft/s]
W_2_fts  = hypot(V_r2_fts, U_2_fts - V_u2_fts);              % relative velocity [ft/s]

% Outlet blade width with blade blockage
A_2_in2   = 144 * Q_fts / V_r2_fts;
epsilon_2 = 1 - Z * t_blade_in / (pi * d_2_in * sind(beta_b2_deg));
b_2_in    = A_2_in2 / (2 * epsilon_2 * pi * r_2_in);

%% 5. BLADE PROFILE
% Blade angle varies linearly with radius; wrap angle and length are
% accumulated from inlet to outlet.
dr_in = (r_2_in - r_1_in) / n_steps;
r_in  = linspace(r_1_in, r_2_in, n_steps + 1);
beta_b_deg = beta_b1_deg + (beta_b2_deg - beta_b1_deg) * (r_in - r_1_in) / (r_2_in - r_1_in);

dtheta_deg = rad2deg(dr_in ./ (r_in .* tand(beta_b_deg)));         % wrap increment [deg]
dL_in      = sqrt((r_in .* deg2rad(dtheta_deg)).^2 + dr_in^2);     % length increment [in]

theta_deg = [0, cumsum(dtheta_deg(1:end-1))];                      % wrap angle [deg]
L_in      = [0, cumsum(dL_in(1:end-1))];                           % blade length [in]

%% 6. DESIGN CHECKS
sigma_solidity  = Z * L_in(end) / (pi * d_2_in);
diffusion_ratio = W_2_fts / W_1_fts;

check_range('Outlet blade angle [deg]', beta_b2_deg,    22.5, 27.5, 'adjust beta_b2');
check_range('Solidity',                 sigma_solidity,  2.5,  3.0, 'adjust beta_b2 and/or blade count');
check_range('Diffusion factor',         diffusion_ratio, 0.7,  1.0, 'select a new specific diameter from the Cordier diagram');

%% 7. DIFFUSER AND VOLUTE
angMom_in2s = r_2_ft * V_u2_fts * in2_per_ft2;       % angular momentum [in^2/s]

V_t_fts  = K_3 * sqrt(2 * g * H_ft);                 % throat velocity [ft/s]
A_t_in2  = in2_per_ft2 * Q_fts / V_t_fts;            % throat area [in^2]

d_3_in = (1 + diff_ratio) * d_2_in;                  % diffuser outlet diameter [in]
r_3_in = d_3_in / 2;

b_vol_in = 1.8 * b_2_in;                             % volute section base width [in]
Q_in3s   = Q_fts * 12^3;                             % flow rate [in^3/s]
theta_rad = deg2rad(theta_deg(end));

% Iterate: section area -> centroid radius -> tangential velocity
V_theta_ins = 12 * V_t_fts;                          % initial guess [in/s]
tol = 0.01;
max_iter = 100;
for iter = 1:max_iter
    A_theta_in2 = Q_in3s * theta_rad / (2 * pi * V_theta_ins);
    a_in = sqrt(4 * tand(phi_trap_deg/2) * A_theta_in2 + b_vol_in^2);   % section outer width [in]
    h_in = 2 * A_theta_in2 / (a_in + b_vol_in);                         % section height [in]
    x_c_in = h_in * (2*a_in + b_vol_in) / (3 * (a_in + b_vol_in));      % centroid offset [in]
    r_c_in = r_3_in + x_c_in;                                           % centroid radius [in]

    V_new = C_vol * angMom_in2s / r_c_in;
    converged = abs(V_new - V_theta_ins) / V_new < tol;
    V_theta_ins = V_new;
    if converged, break; end
end

%% 8. SUMMARY
fprintf('\n=== DESIGN SUMMARY ===\n');
fprintf('Specific speed N_s            %8.1f\n',    N_s);
fprintf('Shaft power                   %8.1f hp\n', P_s_hp);
fprintf('Shaft diameter                %8.2f in\n', D_sh_in);
fprintf('Eye diameter                  %8.2f in\n', d_e_in);
fprintf('Inlet blade width             %8.2f in\n', b_1_in);
fprintf('Impeller outer diameter       %8.2f in\n', d_2_in);
fprintf('Outlet blade width            %8.2f in\n', b_2_in);
fprintf('Blade count (computed / used) %5.2f / %d\n', Z_b, Z);
fprintf('Solidity                      %8.2f\n',    sigma_solidity);
fprintf('Diffusion factor              %8.3f\n',    diffusion_ratio);
fprintf('Diffuser outlet diameter      %8.2f in\n', d_3_in);
fprintf('Volute section (a x h)        %5.2f x %5.2f in\n', a_in, h_in);
fprintf('Volute centroid radius        %8.2f in\n', r_c_in);
fprintf('Volute iterations             %8d\n',      iter);

if make_plots
    figure; hold on; axis equal; grid on;
    t = linspace(0, 2*pi, 200);
    for k = 0:Z-1
        ang = theta_deg + k * 360 / Z;
        plot(r_in .* cosd(ang), r_in .* sind(ang), 'b', 'LineWidth', 1.5);
    end
    plot(r_1_in * cos(t), r_1_in * sin(t), 'k--');
    plot(r_2_in * cos(t), r_2_in * sin(t), 'k-');
    plot(r_3_in * cos(t), r_3_in * sin(t), 'k:');
    xlabel('x [in]'); ylabel('y [in]');
    title(sprintf('Impeller blade profile (%d blades)', Z));
end

%% LOCAL FUNCTIONS
function check_range(name, value, lo, hi, hint)
    if value >= lo && value <= hi
        fprintf('%-26s %8.3f   OK (%.2f to %.2f)\n', name, value, lo, hi);
    else
        fprintf('%-26s %8.3f   OUT OF RANGE (%.2f to %.2f): %s\n', name, value, lo, hi, hint);
    end
end
