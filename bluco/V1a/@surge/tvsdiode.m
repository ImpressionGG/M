function [o,du] = tvsdiode(o,number)
%
% TVSDIODE  Setup parameters of a particular TVS Diode
%
%              i = tvsdiode(o,u)         % i = f(u), u = g(i)
%              [u,du] = tvsdiode(o,{i})  % u = g(i), du = dg/du
%
%              o = tvsdiode(o,'1')       % 1.5SMC350CA
%              o = tvsdiode(o,'2')       % 1.5SMC400CA
%
%           See also: SURGE, SIMU, STUDY
%
    if isa(number,'double')
       tvs = o.par.tvs;
       n = 2*tvs.N+1;
    
       u = number;
       i = tvs.Ipp * (u/tvs.Uclamp).^n;
       o = i;
       return
    elseif iscell(number)
       tvs = o.par.tvs;
       n = 2*tvs.N+1;
    
       i = number{1};
       s = sign(i);

          % u = Uclamp * Ipp^(-1/n) * i^(1/n) 

       u = tvs.Uclamp * (abs(i)/tvs.Ipp).^(1/n) .* s;
       if (nargout >= 2)
          du = tvs.Uclamp * 1/n * i.^(1/n-1) / tvs.Ipp.^(1/n);
       end
       o = u;
       return
    end
    
    switch number
       case {'1','1.5SMC350CA'}
          o = Tvs1(o);
       case {'2','1.5SMC400CA'}
          o = Tvs2(o);
       case {'3','1.5SMC440CA'}
          o = TVS1500SMC440CA(o);
       case {'4','1.5SMC480CA'}
          o = Tvs4(o);
          
       case {'5','P6SMB400A'}
          o = Tvs5(o);
       case {'6','P6SMB440A'}
          o = Tvs6(o);
       case {'7','P6SMB480A'}
          o = Tvs7(o);

       case {'8','2x 1.5SMC220A'}
          o = Tvs8(o);

       case {'9','SMDJ300CA'}
          o = SMDJ300CA(o);
          
       case {'M1','DV250K3225'}
          o = DV250K3225(o);
       case {'CNR05D361','CNR-05D361K'}
          o = CNR05D361K(o);
       case {'CNR05D391','CNR-05D391K'}
          o = CNR05D391K(o);
       case {'V360ZA05P'}
          o = V360ZA05P(o);
       case {'V390ZA05P'}
          o = V390ZA05P(o);
    end
    
       % Ipp (rated at 1ms pulse) can be increased to Ipp50 for
       % 50 us pulses by the power ratio 5.5kW / 1.5kW 
       
    o.par.tvs.Ipp50 = o.par.tvs.Ipp * 5.5/1.5;
end

%==========================================================================
% TVS Setup 1500W
%==========================================================================
          
function o = Tvs1(o)
   p.name = '1.5SMC350CA';           % name of TVS diode
   p.kind = 'TVS';
   
   p.Pmax   = 1500;                  % [W] max power
   p.Vrwm   = 300;                   % [V] reverse working maximum voltage
   p.Ubmin  = 332;                   % [V] breakdown minimum voltage
   p.Ubmax  = 368;                   % [V] breakdown maximum voltage
   p.Uclamp = 482;                   % [V] max clamping voltage
   p.Ipp    = 3.2;                   % [A] peak impulse current
   p.Td0    = 1e-3;                  % [s] nominal pulse width
   p.N      = 13;                    % [1] curvature index
   p.kappa  = 0.43;                  % [1] conversion exponent
   p.derate = 0.8;                   % [1] Ipp derating at 80°C junction T
   
   o = set(o,'tvs',p);
end
function o = Tvs2(o)
   p.name = '1.5SMC400CA';           % name of TVS diode
   p.kind = 'TVS';

   p.Pmax   = 1500;                  % [W] max power
   p.Vrwm   = 342;                   % [V] reverse working maximum voltage
   p.Ubmin  = 380;                   % [V] breakdown minimum voltage
   p.Ubmax  = 420;                   % [V] breakdown maximum voltage
   p.Uclamp = 548;                   % [V] max clamping voltage
   p.Ipp    = 2.8;                   % [A] peak impulse current
   p.Td0    = 1e-3;                  % [s] nominal pulse width
   p.N      = 13;                    % [1] curvature index
   p.kappa  = 0.43;                  % [1] conversion exponent
   p.derate = 0.8;                   % [1] Ipp derating at 80°C junction T

   o = set(o,'tvs',p);
end
function o = TVS1500SMC440CA(o)
   p.name = '1.5SMC440CA';           % name of TVS diode
   p.kind = 'TVS';

   p.Pmax   = 1500;                  % [W] max power
   p.Vrwm   = 376;                   % [V] reverse working maximum voltage
   p.Ubmin  = 418;                   % [V] breakdown minimum voltage
   p.Ubmax  = 462;                   % [V] breakdown maximum voltage
   p.Uclamp = 602;                   % [V] max clamping voltage
   p.Ipp    = 2.5;                   % [A] peak impulse current
   p.Td0    = 1e-3;                  % [s] nominal pulse width
   p.N      = 13;                    % [1] curvature index
   p.kappa  = 0.43;                  % [1] conversion exponent
   p.derate = 0.8;                   % [1] Ipp derating at 80°C junction T

   o = set(o,'tvs',p);
end
function o = Tvs4(o)
   p.name = '1.5SMC480CA';           % name of TVS diode
   p.kind = 'TVS';
   
   p.Pmax   = 1500;                  % [W] max power
   p.Vrwm   = 408;                   % [V] reverse working maximum voltage
   p.Ubmin  = 456;                   % [V] breakdown minimum voltage
   p.Ubmax  = 504;                   % [V] breakdown maximum voltage
   p.Uclamp = 658;                   % [V] max clamping voltage
   p.Ipp    = 2.3;                   % [A] peak impulse current
   p.Td0    = 1e-3;                  % [s] nominal pulse width
   p.N      = 13;                    % [1] curvature index
   p.kappa  = 0.43;                  % [1] conversion exponent
   p.derate = 0.8;                   % [1] Ipp derating at 80°C junction T

   o = set(o,'tvs',p);
end

%==========================================================================
% TVS Setup 600W
%==========================================================================
          
function o = Tvs5(o)
   p.name = 'P6SMB400A';             % name of TVS diode
   p.kind = 'TVS';
   
   p.Pmax   = 600;                   % [W] max power
   p.Vrwm   = 342;                   % [V] reverse working maximum voltage
   p.Ubmin  = 380;                   % [V] breakdown minimum voltage
   p.Ubmax  = 420;                   % [V] breakdown maximum voltage
   p.Uclamp = 548;                   % [V] max clamping voltage
   p.Ipp    = 1.1;                   % [A] peak impulse current
   p.Td0    = 1e-3;                  % [s] nominal pulse width
   p.N      = 13;                    % [1] curvature index
   p.kappa  = 0.46;                  % [1] conversion exponent
   p.derate = 0.8;                   % [1] Ipp derating at 80°C junction T

   o = set(o,'tvs',p);
end
function o = Tvs6(o)
   p.name = 'P6SMB440A';             % name of TVS diode
   p.kind = 'TVS';
   
   p.Pmax   = 600;                   % [W] max power
   p.Vrwm   = 376;                   % [V] reverse working maximum voltage
   p.Ubmin  = 418;                   % [V] breakdown minimum voltage
   p.Ubmax  = 462;                   % [V] breakdown maximum voltage
   p.Uclamp = 602;                   % [V] max clamping voltage
   p.Ipp    = 1.0;                   % [A] peak impulse current
   p.Td0    = 1e-3;                  % [s] nominal pulse width
   p.N      = 13;                    % [1] curvature index
   p.kappa  = 0.46;                  % [1] conversion exponent
   p.derate = 0.8;                   % [1] Ipp derating at 80°C junction T

   o = set(o,'tvs',p);
end
function o = Tvs7(o)
   p.name = 'P6SMB480A';             % name of TVS diode
   p.kind = 'TVS';
   
   p.Pmax   = 600;                   % [W] max power
   p.Vrwm   = 408;                   % [V] reverse working maximum voltage
   p.Ubmin  = 456;                   % [V] breakdown minimum voltage
   p.Ubmax  = 504;                   % [V] breakdown maximum voltage
   p.Uclamp = 658;                   % [V] max clamping voltage
   p.Ipp    = 0.9;                   % [A] peak impulse current
   p.Td0    = 1e-3;                  % [s] nominal pulse width
   p.N      = 13;                    % [1] curvature index
   p.kappa  = 0.46;                  % [1] conversion exponent
   p.derate = 0.8;                   % [1] Ipp derating at 80°C junction T

   o = set(o,'tvs',p);
end

%==========================================================================
% 2x TVS Setup 1500W
%==========================================================================
          
function o = Tvs8(o)
   p.name = '2x 1.5SMC220CA';        % name of TVS diode
   p.kind = 'TVS';

   p.Pmax   = 3000;                  % [W] max power
   p.Vrwm   = 2*185;                 % [V] reverse working maximum voltage
   p.Ubmin  = 2*209;                 % [V] breakdown minimum voltage
   p.Ubmax  = 2*231;                 % [V] breakdown maximum voltage
   p.Uclamp = 2*328;                 % [V] max clamping voltage
   p.Ipp    = 4.6;                   % [A] peak impulse current
   p.Td0    = 1e-3;                  % [s] nominal pulse width
   p.N      = 13;                    % [1] curvature index
   p.kappa  = 0.43;                  % [1] conversion exponent
   p.derate = 0.8;                   % [1] Ipp derating at 80°C junction T

   o = set(o,'tvs',p);
end

%==========================================================================
% TVS Setup 3000W
%==========================================================================
          
function o = SMDJ300CA(o)
   p.name = 'SMDJ300CA';             % name of TVS diode
   p.kind = 'TVS';

   p.Pmax   = 14900;                 % [W] max power
   p.Vrwm   = 300;                   % [V] reverse working maximum voltage
   p.Ubmin  = 335;                   % [V] breakdown minimum voltage
   p.Ubmax  = 371;                   % [V] breakdown maximum voltage
   p.Uclamp = 628;                   % [V] max clamping voltage
   p.Ipp    = 31;                    % [A] peak impulse current
   p.Td0    = 20e-6;                 % [s] nominal pulse width
   p.N      = 9;                     % [1] curvature index
   p.kappa  = 0.41;                  % [1] conversion exponent
   p.derate = 0.75;                  % [1] Ipp derating at 80°C junction T

   o = set(o,'tvs',p);
end

%==========================================================================
% MOV Setup
%==========================================================================
          
function o = DV250K3225(o)
   p.name = 'DV250K3225';             % name of MOV
   p.kind = 'MOV';

   p.Pmax   = 260000;                % [W] max power
   p.Wmax   = 11;                    % [J] max thermal energy
   p.Vrwm   = 360;                   % [V] reverse working maximum voltage
   p.Ubmin  = 390;                   % [V] breakdown minimum voltage
   p.Ubmax  = 390;                   % [V] breakdown maximum voltage
   p.Uclamp = 650;                   % [V] max clamping voltage
   p.Ipp    = 400;                   % [A] peak impulse current
   p.Td0    = 20e-6;                 % [s] nominal pulse width
   p.N      = 12;                    % [1] curvature index
   p.kappa  = 0.41;                  % [1] conversion exponent
   p.derate = 1.0;                   % [1] Ipp derating at 80°C junction T

   o = set(o,'tvs',p);
end

function o = CNR05D361K(o)
   p.name = 'CNR-05D361K';           % name of MOV
   p.kind = 'MOV';

   p.Pmax   = 248000;                % [W] max power
   p.Wmax   = 10;                    % [J] max thermal energy
   p.Vrwm   = 360;                   % [V] reverse working maximum voltage
   p.Ubmin  = 324;                   % [V] breakdown minimum voltage
   p.Ubmax  = 396;                   % [V] breakdown maximum voltage
   p.Uclamp = 620;                   % [V] max clamping voltage
   p.Ipp    = 400;                   % [A] peak impulse current
   p.Td0    = 20e-6;                 % [s] nominal pulse width
   p.N      = 12;                    % [1] curvature index
   p.kappa  = 0.41;                  % [1] conversion exponent
   p.derate = 1.0;                   % [1] Ipp derating at 80°C junction T

   o = set(o,'tvs',p);
end

function o = CNR05D391K(o)
   p.name = 'CNR-05D391K';           % name of MOV
   p.kind = 'MOV';

   p.Pmax   = 270000;                % [W] max power
   p.Wmax   = 12;                    % [J] max thermal energy
   p.Vrwm   = 360;                   % [V] reverse working maximum voltage
   p.Ubmin  = 351;                   % [V] breakdown minimum voltage
   p.Ubmax  = 429;                   % [V] breakdown maximum voltage
   p.Uclamp = 675;                   % [V] max clamping voltage
   p.Ipp    = 400;                   % [A] peak impulse current
   p.Td0    = 20e-6;                 % [s] nominal pulse width
   p.N      = 12;                    % [1] curvature index
   p.kappa  = 0.41;                  % [1] conversion exponent
   p.derate = 1.0;                   % [1] Ipp derating at 80°C junction T

   o = set(o,'tvs',p);
end

function o = V360ZA05P(o)            % Littlefuse
   p.name = 'V360ZA05P';             % name of MOV
   p.kind = 'MOV';

   p.Pmax   = 238000;                % [W] max power
   p.Wmax   = 9.5;                   % [J] max thermal energy
   p.Vrwm   = 360;                   % [V] reverse working maximum voltage
   p.Ubmin  = 324;                   % [V] breakdown minimum voltage
   p.Ubmax  = 396;                   % [V] breakdown maximum voltage
   p.Uclamp = 595;                   % [V] max clamping voltage
   p.Ipp    = 400;                   % [A] peak impulse current
   p.Td0    = 20e-6;                 % [s] nominal pulse width
   p.N      = 12;                    % [1] curvature index
   p.kappa  = 0.41;                  % [1] conversion exponent
   p.derate = 1.0;                   % [1] Ipp derating at 80°C junction T

   o = set(o,'tvs',p);
end

function o = V390ZA05P(o)            % Littlefuse
   p.name = 'V390ZA05P';             % name of MOV
   p.kind = 'MOV';

   p.Pmax   = 238000;                % [W] max power
   p.Wmax   = 10;                    % [J] max thermal energy
   p.Vrwm   = 360;                   % [V] reverse working maximum voltage
   p.Ubmin  = 351;                   % [V] breakdown minimum voltage
   p.Ubmax  = 429;                   % [V] breakdown maximum voltage
   p.Uclamp = 650;                   % [V] max clamping voltage
   p.Ipp    = 400;                   % [A] peak impulse current
   p.Td0    = 20e-6;                 % [s] nominal pulse width
   p.N      = 12;                    % [1] curvature index
   p.kappa  = 0.41;                  % [1] conversion exponent
   p.derate = 1.0;                   % [1] Ipp derating at 80°C junction T

   o = set(o,'tvs',p);
end
