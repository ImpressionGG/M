function varargout = cook(o,sym)
%
% COOK  Cook up data
%
%          G = cook(o,'G')                  % SPM transfer matrix G(s)
%          H = cook(o,'H')                  % constrained trf matrix H(s)
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
      varargout{i} = Cook(o,sym);
   end
end

%==========================================================================
% Cook
%==========================================================================

function oo = Cook(o,sym)
   if length(sym) >= 2
      i = sym(2) - '0';                % prepare row index (just in case)
   end
   if length(sym) >= 3
      j = sym(3) - '0';                % prepare col index (just in case)
   end

   switch sym
      case 'G'
         oo = cache(o,'trfd.G');
         
      case {'G11','G12','G13', 'G21','G22','G23', 'G31','G32','G33'}
         G = cache(o,'trfd.G');
         oo = peek(G,i,j);
         
      case 'H'
         oo = cache(o,'consd.H');
         
      case {'H11','H12','H13', 'H21','H22','H23', 'H31','H32','H33'}
         H = cache(o,'consd.H');
         oo = peek(H,i,j);
         
         % Closed Loop Transfer Matrix
         
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

      otherwise
         error('unsupported symbol');
   end
end