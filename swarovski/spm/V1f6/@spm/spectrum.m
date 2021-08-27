function [lambda0,lambda180] = spectrum(o)
%
% SPECTRUM   Ultra fast calculation of spectrum and critical quantities
%
%               [lambda0,lambda180] = spectrum(o)
%
%               [K0,f0] = var(lambda0,'K0,f0');
%               [K180,f180] = var(lambda180,'K180,f180');
% 
%            Timing:
%               
%               system construction:      18.0 ms
%               psion calculation:         4.0 ms
%               omega construction:        0.4 ms
%               out arg construction:      0.3 ms
%
%            Copyright(c): Bluenetics 2021
%
%            See also: SPM, SYSTEM, LAMBDA
%
   om = Omega(o);                      % omega construction

      % system construction
      
   sys0 = System(o,+1);                % forward system construction
   
      % psion calculation
      
   [psiW31,psiW33] = Psion(o,sys0);
      
      % lambda calculation
      
   lambda0jw = lambda(o,psiW31,psiW33,om);
   lambda180jw = -lambda0jw;
   
      % construct out args
    
   K0 = 1;  f0 = 1000;  K180 = 0.5;  f180 = 4000;
   lambda0 = OutArg(o,om,lambda0jw,'0','ryyyyy',K0,f0);
   lambda180 = OutArg(o,om,lambda180jw,'180','ryy',K180,f180);
end

%==========================================================================
% System Construction
%==========================================================================

function sys = System(o,cutting)
   if (cutting >= 0)
      sys = system(o);
   else
      phi = opt(o,'process.phi');
      o = opt(o,'process.phi',phi+180);
      sys = system(o);
   end
end

%==========================================================================
% Psion Calculation
%==========================================================================

function [psiW31,psiW33] = Psion(o,sys)
   A = var(sys,'A');
   B_1 = var(sys,'B_1');
   B_3 = var(sys,'B_3');
   C_3 = var(sys,'C_3');
   T0 = var(sys,'T0');
   
   psiW31 = psion(o,A,B_1,C_3,T0);     % to calculate G31(jw)
   psiW33 = psion(o,A,B_3,C_3,T0);     % to calculate G33(jw)
end

%==========================================================================
% Omega Construction
%==========================================================================

function om = Omega(o)
   oml = opt(o,'spectrum.omega.low');
   omh = opt(o,'spectrum.omega.high');
   points = opt(o,'spectrum.omega.points');
   
   om = logspace(log10(oml),log10(omh),points);
end

%==========================================================================
% Out Arg Construction
%==========================================================================

function L = OutArg(o,om,Ljw,tag,col,K,f)
   for (i=1:size(Ljw,1))
      matrix{i,1} = Ljw(i,:);
   end
   L = fqr(corasim,om,matrix);
   L = set(L,'name',['lambda',tag],'color',col);
   
      % set critical gain and frequency
      
   L = var(L,['K',tag],K);
   L = var(L,['f',tag],f);
end