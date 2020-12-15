function varargout = cook(o,sym)
%
% COOK  Cook up data
%
%       Basic syntax
%
%          G = cook(o,'G');                 % single argument
%          [A,B,C,D] = cook(o,'A,B,C,D');   % multiple arguments
%
%       System matrices and partial matrices
%
%          [A,B,C,D] = cook(o,'A,B,C,D');   % system matrices
%
%          [A11,A12] = cook(o,'A11,A12');   % partial matrices
%          [A21,A22] = cook(o,'A21,A22');   % partial matrices
%          [B1,B2]   = cook(o,'B1,B2');     % partial matrices
%          [C1,C2]   = cook(o,'C1,C2');     % partial matrices
%
%       Modal parametes
%
%          [a0,a1] = cook(o,'a0,a1');       % modal parameters 
%          omega = cook(o,'omega');         % eigen frequencies
%          zeta = cook(o,'zeta');           % dampings
%
%       Free system transfer matrix and transfer function
%
%          G = cook(o,'G')                  % free sys transfer matrix G(s)
%          Gpsi = cook(o,'Gpsi')            % characteristic transfer fcts.
%          W = cook(o,'W')                  % weight matrix for G(s)
%
%          [G11,G12,G13] = cook(o,'G11,G12,G13')   % free system trf
%          [G21,G22,G23] = cook(o,'G21,G22,G23')   % free system trf
%          [G31,G32,G33] = cook(o,'G31,G32,G33')   % free system trf
%
%       Principal transfer functions
%
%          [P,Q] = cook(o,'P,Q')            % principal TRF's P(s),Q(s)
%          F0 = cook(o,'F0')                % normalizing TRF
%          L0 = cook(o,'L0')                % Open loop L0(s) := P(s)/Q(s)
%          K0 = cook(o,'K0')                % critical gain (mu)
%          S0 = cook(o,'S0')                % closed loop Sensitivity @ K0
%          T0 = cook(o,'T0')                % total closed loop TRF @ K0 
%          
%
%       Constrained system transfer matrix
%
%          H = cook(o,'H')                  % constrained trf matrix H(s)
%
%       Open loop transfer matrix and open loop transfer function
%
%          L = cook(o,'L')                  % open loop trf matrix L(s)
%          Lmu = cook(o,'Lmu')              % open loop trf L0(s) with mu
%
%       Closed Loop Transfer Matrices
%
%          Tf = cook(o,'Tf')                % Force transfer matrix Tf(s)
%          Ts = cook(o,'Ts')                % Elongation trf matrix Ts(s)
%          Tv = cook(o,'Tv')                % Velocity trf matrix Tv(s)
%          Ta = cook(o,'Ta')                % Acceleration trf matrix Ta(s)
%
%       Multiple output args
%
%          [Ts,Tv,Ta] = cook(o,'Ts,Tv,Ta')  % multiple output args
%
%       Copyright(c): Bluenetics 2020 
%
%       See also: SPM, CACHE
%
   if ~ischar(sym)
      error('character string expected for arg2');
   end
   
   symbols = [',',sym,','];
   idx = find(symbols == ',');
   
   for (i=1:length(idx)-1)
      sym = symbols(idx(i)+1:idx(i+1)-1);
      [o,oo] = Cook(o,sym);
      
         % inherit and unwrap options
         
      if isa(oo,'corazon')
         oo = inherit(oo,o);
         oo = with(oo,{'bode','simu','rloc','nyq'});
      end
      varargout{i} = oo;
   end
end

%==========================================================================
% Cook
%==========================================================================

function [o,oo] = Cook(o,sym)          % Cook-up Anyhing               
   if length(sym) >= 2
      i = sym(2) - '0';                % prepare row index (just in case)
   end
   if length(sym) >= 3
      j = sym(3) - '0';                % prepare col index (just in case)
   end

   switch sym
      case {'A','B','C', 'D'}
         oo = brew(o,'System');
         oo = var(oo,sym);

      case {'A11','A12','A21', 'A22','B1','B2','C1','C2'}
         oo = brew(o,'System');
         oo = var(oo,sym);

      case {'a0','a1','omega','zeta'}
         oo = brew(o,'System');
         oo = var(oo,sym);

      case 'G'
         oo = cache(o,o,'trf');        % hard refresh trf cache 
         oo = cache(oo,'trf.G');
         
      case 'Gpsi'
         oo = cache(o,'trf.Gpsi');

      case {'G11','G12','G13', 'G21','G22','G23', 'G31','G32','G33'}
         G = cache(o,'trf.G');
         oo = peek(G,i,j);
         
         % constrained transfer matrix
         
      case 'H'
         oo = cache(o,'consd.H');
         
      case {'H11','H12','H13', 'H21','H22','H23', 'H31','H32','H33'}
         H = cache(o,'consd.H');
         oo = peek(H,i,j);
         
         % open loop transfer matrix
         
      case 'L'
         oo = cache(o,o,'consd');      % hard refresh consd cache 
         oo = cache(oo,'consd.L');
         
      case {'P','Q','F0','L0','K0','S0','T0'}
         o = cache(o,o,'principal');   % cold refresh of principal segment
         oo = cache(o,['principal.',sym]);

      case 'Lmu'
         oo = cache(o,o,'loop');       % hard refresh loop cache 
         oo = cache(oo,'loop.Lmu');
         
      case {'L1','L2'}
         L = cache(o,'consd.L');
         oo = peek(L,1,i);

         % closed loop transfer matrix
         
      case {'Tf','Ts','Tv','Ta'}
         oo = cache(o,['process.',sym]);
         
      case {'Tf1','Tf2'}
         Tf = cache(o,'process.Tf');
         oo = peek(Tf,j,1);

      case {'Ts1','Ts2'}
         Ts = cache(o,'process.Ts');
         oo = peek(Ts,j,1);

      case {'Tv1','Tv2'}
         Tv = cache(o,'process.Tv');
         oo = peek(Tv,j,1);

      case {'Ta1','Ta2'}
         Ta = cache(o,'process.Ta');
         oo = peek(Ta,j,1);

      case 'W'
         oo = cache(o,'trf.W');

      otherwise
         error('unsupported symbol');
   end
end