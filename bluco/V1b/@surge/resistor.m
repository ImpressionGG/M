function o = resistor(o,name)
%
% RESISTOR  Setup parameters of a particular serial resistor
%
%              o = resistor(o,name)
%
%              o = resistor(o,'1')               % AS08J1000ET
%              o = resistor(o,'AS08J1000ET')     % AS08J1000ET
%
%           See also: SURGE, TVSDIODE, SIMU, STUDY
%
    switch name
       case {'1','AS08J1000ET'}
          o = AS08J1000ET(o);
       case {'2','AS12J1000ET'}
          o = AS12J1000ET(o);
       case {'3','AS25J1000ET'}
          o = AS25J1000ET(o);
          
       case {'AS25J1000ETx2'}
          o = AS25J1000ETx2(o);
       case {'AS25J1000ETx3'}
          o = AS25J1000ETx3(o);
       case {'AS25J15R0ETx2'}
          o = AS25J15R0ETx2(o);
       case {'AS25J22R0ETx2'}
          o = AS25J22R0ETx2(o);
       case {'AS25J10R0ETx2'}
          o = AS25J10R0ETx2(o);
          
       case {'4','AS08J22R0ET'}
          o = AS08J22R0ET(o);
       case {'5','AS12J22R0ET'}
          o = AS12J22R0ET(o);
       case {'6','AS25J22R0ET'}
          o = AS25J22R0ET(o);
       case {'7','AS25J15R0ET'}
          o = AS25J15R0ET(o);
       case {'8','AS25J10R0ET'}
          o = AS25J10R0ET(o);
          
       case {'R1Ohm'}
          o = R1Ohm(o);
       case {'R22Ohm'}
          o = R22Ohm(o);
       case {'R27Ohm'}
          o = R27Ohm(o);
       case {'R33Ohm'}
          o = R33Ohm(o);
       case {'R47Ohm'}
          o = R47Ohm(o);
       case {'R56Ohm'}
          o = R56Ohm(o);
       case {'R68Ohm'}
          o = R68Ohm(o);
       case {'R82Ohm'}
          o = R82Ohm(o);
       case {'R100Ohm'}
          o = R100Ohm(o);
    end
end

%==========================================================================
% TVS Setup 1500W
%==========================================================================
          
function o = AS08J1000ET(o)          % 100 Ohm
   p.name = 'AS08J1000ET';           % name of resistor
   
   p.Pmax   = 150;                   % [W] max power
   p.Rp     = 100;                   % [R] resistance
   p.Td0    = 50e-6;                 % [s] nominal pulse width
   p.kappa  = 0.4;                   % [1] conversion exponent
   p.derate = 0.9;                   % [1] Ipp derating at 80°C junction T

   o = set(o,'resistor',p);
end
function o = AS12J1000ET(o)          % 100 Ohm
   p.name = 'AS12J1000ET';           % name of resistor
   
   p.Pmax   = 400;                   % [W] max power
   p.Rp     = 100;                   % [R] resistance
   p.Td0    = 50e-6;                 % [s] nominal pulse width
   p.kappa  = 0.4;                   % [1] conversion exponent
   p.derate = 0.9;                   % [1] Ipp derating at 80°C junction T

   o = set(o,'resistor',p);
end
function o = AS25J1000ET(o)          % 100 Ohm
   p.name = 'AS25J1000ET';           % name of resistor
   
   p.Pmax   = 4000;                  % [W] max power
   p.Rp     = 100;                   % [R] resistance
   p.Td0    = 20e-6;                 % [s] nominal pulse width
   p.kappa  = 0.0;                   % [1] conversion exponent
   p.derate = 0.9;                   % [1] Ipp derating at 80°C junction T

   o = set(o,'resistor',p);
end

function o = AS25J1000ETx2(o)        % 50 Ohm
   p.name = '2x||AS25J1000ET';       % name of resistor
   
   p.Pmax   = 8000;                  % [W] max power
   p.Rp     = 50;                    % [R] resistance
   p.Td0    = 20e-6;                 % [s] nominal pulse width
   p.kappa  = 0.0;                   % [1] conversion exponent
   p.derate = 0.9;                   % [1] Ipp derating at 80°C junction T

   o = set(o,'resistor',p);
end
function o = AS25J1000ETx3(o)        % 33 Ohm
   p.name = '3x||AS25J1000ET';       % name of resistor
   
   p.Pmax   = 12000;                 % [W] max power
   p.Rp     = 33.3;                  % [R] resistance
   p.Td0    = 20e-6;                 % [s] nominal pulse width
   p.kappa  = 0.0;                   % [1] conversion exponent
   p.derate = 0.9;                   % [1] Ipp derating at 80°C junction T

   o = set(o,'resistor',p);
end
function o = AS25J15R0ETx2(o)        % 30 Ohm
   p.name = '2xAS25J15R0ET';         % name of resistor
   
   p.Pmax   = 8000;                  % [W] max power
   p.Rp     = 30;                    % [R] resistance
   p.Td0    = 20e-6;                 % [s] nominal pulse width
   p.kappa  = 0.0;                   % [1] conversion exponent
   p.derate = 0.9;                   % [1] Ipp derating at 80°C junction T

   o = set(o,'resistor',p);
end

function o = AS08J22R0ET(o)          % 22 Ohm
   p.name = 'AS08J22R0ET';           % name of resistor
   
   p.Pmax   = 150;                   % [W] max power
   p.Rp     = 22;                    % [R] resistance
   p.Td0    = 50e-6;                 % [s] nominal pulse width
   p.kappa  = 0.4;                   % [1] conversion exponent
   p.derate = 0.9;                   % [1] Ipp derating at 80°C junction T

   o = set(o,'resistor',p);
end
function o = AS12J22R0ET(o)          % 22 Ohm
   p.name = 'AS12J22R0ET';           % name of resistor
   
   p.Pmax   = 400;                   % [W] max power
   p.Rp     = 22;                    % [R] resistance
   p.Td0    = 50e-6;                 % [s] nominal pulse width
   p.kappa  = 0.4;                   % [1] conversion exponent
   p.derate = 0.9;                   % [1] Ipp derating at 80°C junction T

   o = set(o,'resistor',p);
end
function o = AS25J22R0ET(o)          % 22 Ohm
   p.name = 'AS25J22R0ET';           % name of resistor
   
   p.Pmax   = 4000;                  % [W] max power
   p.Rp     = 22;                    % [R] resistance
   p.Td0    = 20e-6;                 % [s] nominal pulse width
   p.kappa  = 0;                     % [1] conversion exponent
   p.derate = 0.9;                   % [1] Ipp derating at 80°C junction T

   o = set(o,'resistor',p);
end
function o = AS25J22R0ETx2(o)        % 22 Ohm
   p.name = 'AS25J22R0ETx2';         % name of resistor
   
   p.Pmax   = 8000;                  % [W] max power
   p.Rp     = 44;                    % [R] resistance
   p.Td0    = 20e-6;                 % [s] nominal pulse width
   p.kappa  = 0;                     % [1] conversion exponent
   p.derate = 0.9;                   % [1] Ipp derating at 80°C junction T

   o = set(o,'resistor',p);
end

function o = AS25J15R0ET(o)          % 15 Ohm
   p.name = 'AS25J15R0ET';           % name of resistor
   
   p.Pmax   = 4000;                  % [W] max power
   p.Rp     = 15;                    % [R] resistance
   p.Td0    = 20e-6;                 % [s] nominal pulse width
   p.kappa  = 0;                     % [1] conversion exponent
   p.derate = 0.9;                   % [1] Ipp derating at 80°C junction T

   o = set(o,'resistor',p);
end
function o = AS25J10R0ET(o)          % 10 Ohm
   p.name = 'AS25J10R0ET';           % name of resistor
   
   p.Pmax   = 4000;                  % [W] max power
   p.Rp     = 10;                    % [R] resistance
   p.Td0    = 20e-6;                 % [s] nominal pulse width
   p.kappa  = 0;                     % [1] conversion exponent
   p.derate = 0.9;                   % [1] Ipp derating at 80°C junction T

   o = set(o,'resistor',p);
end
function o = AS25J10R0ETx2(o)        % 20 Ohm
   p.name = 'AS25J10R0ETx2';         % name of resistor
   
   p.Pmax   = 8000;                  % [W] max power
   p.Rp     = 20;                    % [R] resistance
   p.Td0    = 20e-6;                 % [s] nominal pulse width
   p.kappa  = 0;                     % [1] conversion exponent
   p.derate = 0.9;                   % [1] Ipp derating at 80°C junction T

   o = set(o,'resistor',p);
end

%==========================================================================
% Fictive Resistors
%==========================================================================

function o = R1Ohm(o)
   p.name = 'R1Ohm';                 % name of resistor
   
   p.Pmax   = 1000;                  % [W] max power
   p.Rp     = 1;                     % [R] resistance
   p.Td0    = 50e-6;                 % [s] nominal pulse width
   p.kappa  = 0.43;                  % [1] conversion exponent
   p.derate = 0.8;                   % [1] Ipp derating at 80°C junction T
   
   o = set(o,'resistor',p);
end
function o = R22Ohm(o)
   p.name = 'R22Ohm';                % name of resistor
   
   p.Pmax   = 1000;                  % [W] max power
   p.Rp     = 22;                    % [R] resistance
   p.Td0    = 50e-6;                 % [s] nominal pulse width
   p.kappa  = 1;                     % [1] conversion exponent
   p.derate = 0.8;                   % [1] Ipp derating at 80°C junction T
   
   o = set(o,'resistor',p);
end
function o = R33Ohm(o)
   p.name = 'R33Ohm';                % name of resistor
   
   p.Pmax   = 4000;                  % [W] max power
   p.Rp     = 33;                    % [R] resistance
   p.Td0    = 50e-6;                 % [s] nominal pulse width
   p.kappa  = 0.2;                   % [1] conversion exponent
   p.derate = 0.8;                   % [1] Ipp derating at 80°C junction T
   
   o = set(o,'resistor',p);
end
function o = R47Ohm(o)
   p.name = 'R47Ohm';                % name of resistor
   
   p.Pmax   = 4000;                  % [W] max power
   p.Rp     = 47;                    % [R] resistance
   p.Td0    = 50e-6;                 % [s] nominal pulse width
   p.kappa  = 0.2;                     % [1] conversion exponent
   p.derate = 0.8;                   % [1] Ipp derating at 80°C junction T
   
   o = set(o,'resistor',p);
end
function o = R56Ohm(o)
   p.name = 'R56Ohm';                % name of resistor
   
   p.Pmax   = 4000;                  % [W] max power
   p.Rp     = 56;                    % [R] resistance
   p.Td0    = 50e-6;                 % [s] nominal pulse width
   p.kappa  = 0.2;                     % [1] conversion exponent
   p.derate = 0.8;                   % [1] Ipp derating at 80°C junction T
   
   o = set(o,'resistor',p);
end
function o = R68Ohm(o)
   p.name = 'R68Ohm';                % name of resistor
   
   p.Pmax   = 4000;                  % [W] max power
   p.Rp     = 68;                    % [R] resistance
   p.Td0    = 50e-6;                 % [s] nominal pulse width
   p.kappa  = 0.2;                   % [1] conversion exponent
   p.derate = 0.8;                   % [1] Ipp derating at 80°C junction T
   
   o = set(o,'resistor',p);
end
function o = R82Ohm(o)
   p.name = 'R82Ohm';                % name of resistor
   
   p.Pmax   = 4000;                  % [W] max power
   p.Rp     = 82;                    % [R] resistance
   p.Td0    = 50e-6;                 % [s] nominal pulse width
   p.kappa  = 0.2;                   % [1] conversion exponent
   p.derate = 0.8;                   % [1] Ipp derating at 80°C junction T
   
   o = set(o,'resistor',p);
end
function o = R100Ohm(o)
   p.name = 'R100Ohm';               % name of resistor
   
   p.Pmax   = 4000;                  % [W] max power
   p.Rp     = 100;                   % [R] resistance
   p.Td0    = 50e-6;                 % [s] nominal pulse width
   p.kappa  = 0.2;                   % [1] conversion exponent
   p.derate = 0.8;                   % [1] Ipp derating at 80°C junction T
   
   o = set(o,'resistor',p);
end
