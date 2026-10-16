clear; clc; close all
format short


%% -------------------------------  INPUTS  -------------------------------  

% Stiffness Props
Vf  = 0.675;
rho =  0.06;        %lbf/in^3
t   = 0.006;        %in

EL  =  25e6;        %psi
ET  = 1.4e6;        %psi
GLT = 0.6e6;        %psi
vLT =  0.23;        
vTL = ET/EL*vLT;

% Strength Props
XT =  490e3;        %psi
XC =  -91e3;        %psi
YT =  6.4e3;        %psi
YC = -6.4e3;        %psi
S  =  6.2e3;        %psi

% Allowable Strengths
FoS = 1.5;
XTallow = XT/FoS;
XCallow = XC/FoS;
YTallow = YT/FoS;
YCallow = YC/FoS;
Sallow  = S/FoS;

% Ext Loads
Nx  = 1000;     %lbf/in
Ny  =  500;     %lbf/in
Nxy = -500;     %lbf/in
Mx  =  -20;     %lbf-in/in
My  =   30;     %lbf-in/in
Mxy =  -25;     %lbf-in/in

N = [Nx Ny Nxy]';
M = [Mx My Mxy]';

%% ------------------------------  Analysis  ------------------------------  

% Q
vTL = ET/EL*vLT;
Q11 = EL/(1-vLT*vTL);
Q22 = ET/(1-vLT*vTL);
Q12 = vLT*ET/(1-vLT*vTL);
Q66 = GLT;

Q = [Q11  Q12   0 ;
     Q12  Q22   0 ;
      0    0   Q66];    %psi

% Qbar
th = 0;
c = cosd(th);
s = sind(th);
T = [   c^2  s^2    2*s*c;
        s^2  c^2   -2*s*c;
       -s*c  s*c  c^2-s^2];
Qb0 = inv(T)*Q*inv((T'));

th = 10;
c = cosd(th);
s = sind(th);
T = [   c^2  s^2    2*s*c;
        s^2  c^2   -2*s*c;
       -s*c  s*c  c^2-s^2];
Qb10 = inv(T)*Q*inv((T'));

th = 20;
c = cosd(th);
s = sind(th);
T = [   c^2  s^2    2*s*c;
        s^2  c^2   -2*s*c;
       -s*c  s*c  c^2-s^2];
Qb20 = inv(T)*Q*inv((T'));

th = 40;
c = cosd(th);
s = sind(th);
T = [   c^2  s^2    2*s*c;
        s^2  c^2   -2*s*c;
       -s*c  s*c  c^2-s^2];
Qb40 = inv(T)*Q*inv((T'));

th = 60;
c = cosd(th);
s = sind(th);
T = [   c^2  s^2    2*s*c;
        s^2  c^2   -2*s*c;
       -s*c  s*c  c^2-s^2];
Qb60 = inv(T)*Q*inv((T'));

th = 80;
c = cosd(th);
s = sind(th);
T = [   c^2  s^2    2*s*c;
        s^2  c^2   -2*s*c;
       -s*c  s*c  c^2-s^2];
Qb80 = inv(T)*Q*inv((T'));

th = 90;
c = cosd(th);
s = sind(th);
T = [   c^2  s^2    2*s*c;
        s^2  c^2   -2*s*c;
       -s*c  s*c  c^2-s^2];
Qb90 = inv(T)*Q*inv((T'));

Qb = [Qb0,Qb10,Qb20,Qb40,Qb60,Qb80,Qb90 Qb90,Qb80,Qb60,Qb40,Qb20,Qb10,Qb0];

n    = 14;
zmax = t*n/2;
z    = -zmax:t:zmax;

% A,B,D
A = zeros(3);	%3x3 matrix
B = zeros(3);	%3x3 matrix
D = zeros(3);	%3x3 matrix

for k = 1:n
    from = (k-1)*3+1;
    to   = k*3;
    A = A + (z(k+1) - z(k))*Qb(:,from:to);
    B = B + 1/2*(z(k+1)^2 - z(k)^2)*Qb(:,from:to);
    D = D + 1/3*(z(k+1)^3 - z(k)^3)*Qb(:,from:to);
end

% Strains & Stresses
Compl   = inv([A,B;B,D]);

StrCurv = Compl*[N;M];
eps0    = StrCurv(1:3);
k0      = StrCurv(4:6);

theta = [0 10 20 40 60 80 90 90 80 60 40 20 10 0];
epsXY = zeros(3,n+1);
strainXY = zeros(3,2*n);
stressXY = zeros(3,2*n);
stressLT = zeros(3,2*n);

iz = 1;
is = 1;
for z=z
    epsXY(:,iz) = eps0+z*k0;
        
    if iz >= 2
        from = (iz-2)*3+1;
        to   = (iz-1)*3;
        Qbar = Qb(:,from:to);
        stressXY(:,is) = Qbar*epsXY(:,iz);
        strainXY(:,is) = epsXY(:,iz);
        
        th = theta(iz-1);
        c  = cosd(th);
        s  = sind(th);
        Tg = [c^2  s^2    2*s*c;
              s^2  c^2   -2*s*c;
             -s*c  s*c  c^2-s^2];
        stressLT(:,is) = Tg*stressXY(:,is);

        is = is+1;
    end
    
    if iz <= n
        from = (iz-1)*3+1;
        to   = iz*3;
        Qbar = Qb(:,from:to);
        
        stressXY(:,is) = Qbar*epsXY(:,iz);
        strainXY(:,is) = epsXY(:,iz);
        
        th = theta(iz);
        c  = cosd(th);
        s  = sind(th);
        Tg = [c^2  s^2    2*s*c;
              s^2  c^2   -2*s*c;
             -s*c  s*c  c^2-s^2];
        stressLT(:,is) = Tg*stressXY(:,is);
        
        is = is+1;
    end
    iz = iz+1;
end


%% -------------------------------  Plots  -------------------------------  
% Strains
figure(1)
hold on
for i=1:n
    plot(strainXY(1,(i-1)*2+1:i*2),(i:i+1)*t-zmax-t,'r','LineWidth',2.5)
end
grid on
xlabel('\epsilon_{xx}   [in/in]')
ylabel('Thickness: t   [in]')
title('Normal Strain \epsilon_{xx} through Thickness')
view(0,-90)

figure(2)
hold on
for i=1:n
    plot(strainXY(2,(i-1)*2+1:i*2),(i:i+1)*t-zmax-t,'b','LineWidth',2.5)
end
grid on
xlabel('\epsilon_{yy}   [in/in]')
ylabel('Thickness: t   [in]')
title('Normal Strain \epsilon_{yy} through Thickness')
view(0,-90)

figure(3)
hold on
for i=1:n
    plot(strainXY(3,(i-1)*2+1:i*2),(i:i+1)*t-zmax-t,'m','LineWidth',2.5)
end
grid on
xlabel('\gamma_{xy}   [in/in]')
ylabel('Thickness: t   [in]')
title('Shear Strain \gamma_{xy} through Thickness')
view(0,-90)

% Stresses
figure(4)
hold on
for i=1:n
    plot(stressXY(1,(i-1)*2+1:i*2),(i:i+1)*t-zmax-t,'r','LineWidth',2.5)
    if i>=1 && i<n
        plot([stressXY(1,i*2), stressXY(1,i*2+1)],[i+1 i+1]*t-zmax-t,'r','LineWidth',2.5)
    end
end
grid on
xlabel('\sigma_{xx}   [psi]')
ylabel('Thickness: t   [in]')
title('Normal Stress \sigma_{xx} through Thickness')
axis([-6e4 9.5e4 -zmax zmax]); axis square
view(0,-90)

figure(5)
hold on
for i=1:n
    plot(stressXY(2,(i-1)*2+1:i*2),(i:i+1)*t-zmax-t,'b','LineWidth',2.5)
    if i>=1 && i<n
        plot([stressXY(2,i*2), stressXY(2,i*2+1)],[i+1 i+1]*t-zmax-t,'b','LineWidth',2.5)
    end
end
grid on
xlabel('\sigma_{yy}   [psi]')
ylabel('Thickness: t   [in]')
title('Normal Stress \sigma_{yy} through Thickness')
axis([-7e4 10e4 -zmax zmax]); axis square
view(0,-90)

figure(6)
hold on
for i=1:n
    plot(stressXY(3,(i-1)*2+1:i*2),(i:i+1)*t-zmax-t,'m','LineWidth',2.5)
    if i>=1 && i<n
        plot([stressXY(3,i*2), stressXY(3,i*2+1)],[i+1 i+1]*t-zmax-t,'m','LineWidth',2.5)
    end
end
grid on
xlabel('\tau_{xy}   [psi]')
ylabel('Thickness: t   [in]')
title('Shear Stress \tau_{xy} through Thickness')
axis([-5e4 3e4 -zmax zmax]); axis square
view(0,-90)

%% -----------------------  Margins of Safety: MoS  -----------------------
% FoS = 1.5;
% XTallow = XT/FoS;
% XCallow = XC/FoS;
% YTallow = YT/FoS;
% YCallow = YC/FoS;
% Sallow  = S/FoS;

for is=1:2*n
    for it=1:3
        switch it
            case 1
                Sapplied = stressLT(it,is);
                if Sapplied>=0
                    % XTallow
                    MoS(it,is) = XTallow/Sapplied - 1;
                else
                    % XCallow
                    MoS(it,is) = XCallow/Sapplied - 1;
                end
            case 2
                Sapplied = stressLT(it,is);
                if Sapplied>=0
                    % YTallow
                    MoS(it,is) = YTallow/Sapplied - 1;
                else
                    % YCallow
                    MoS(it,is) = YCallow/Sapplied - 1;
                end
            case 3
                % Sallow
                Sapplied = stressLT(it,is);
                MoS(it,is) = Sallow/abs(Sapplied) - 1;
        end
    end
end
    
minMoS = min(MoS,[],'all')

% Safe Design
NMsafe = (1+minMoS)*[N;M]