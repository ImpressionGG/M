function oo = plant(o,varargin)      % Har Plant Method
%
% PLANT   Create a new plant pbject
%
%           plant(o,'IPT1')            % create I-PT1 plant model
%           plant(o,'AXIS')            % create simple axis model
%           plant(o,'GANTRY')          % create gantry model 
%
   [gamma,oo] = manage(o,varargin,@Plant,@IPT1,@AXIS,@GANTRY);
   oo = gamma(oo);
end

%==========================================================================
% Menu Setup
%==========================================================================

function oo = Plant(o)                 % Plant Menu Setup              
   oo = mitem(o,'Plant');
   ooo = mitem(oo,'I-PT1 Plant',{@IPT1});
   ooo = mitem(oo,'Axis on Base',{@AXIS});
   ooo = mitem(oo,'Gantry on Base',{@GANTRY});
end

%==========================================================================
% Actual Plant Model Creation
%==========================================================================

function oo = IPT1(o)                  % New I-PT1 Plant Model         
%
% IPT1   Create an I-PT1 plant model with transfer function 
%                         V    
%          G(s) = -----------------    % V = 1, T = 1
%                   s * (1 + s*T)
%
   if o.is(type(o),'IPT1')
      oo = o;
      [V,T] = get(oo,'V','T');
   else
      V = 1;                           % gain factor
      T = 1;                           % dominant time constant

      oo = trf(V,[T 1 0]);             % transfer function
      oo = set(oo,'init','IPT1');
      oo = set(oo,'V',V,'T',T);
   end
   
   head = 'IPT1(s) = V / [s * (s*T + 1)]';
   params = sprintf('V = %g, T = %g',V,T);

   oo = update(oo,'I-PT1 Plant',{head,params});
   paste(o,{oo});                      % paste transfer function
end
function oo = AXIS(o)                  % New Axis on Base Plant Model  
%
% AXIS   Create a system with transfer function 
%                      V
%          G(s) = -----------          % V = 1, T = 5
%                   1 + s*T
%
   if o.is(type(o),'PT1')
      oo = o;
      [V,T] = get(oo,'V','T');
   else
      V = 1;                           % gain
      T = 5;                           % time constant

      oo = trf(1,[T 1]);               % transfer function
      oo = set(oo,'init','PT1');
      oo = set(oo,'V',V,'T',T);
   end

   head = 'PT1(s) = V / (1 + s*T)';
   params = sprintf('V = %g, T = %g',V,T);

   oo = update(oo,'PT1 System',{head,params});
   paste(o,{oo});                      % paste transfer function
end
function oo = GANTRY(o)                % New Gantry on Base Plant Model
%
% PT2   Create a system with transfer function 
%                            V
%          G(s) = -------------------------    % V = 1, T = 5, D = 0.7 
%                   1 + 2*D*(s*T) + (s*T)^2
%
   if o.is(type(o),'PT2')
      oo = o;
      [V,T,D] = get(oo,'V','T','D');
   else
      V = 1;                           % gain
      T = 5;                           % time constant
      D = 0.7;                         % damping

      oo = trf(V,{},{[1/T,D]});        % transfer function
      oo = set(oo,'init','PT2');
      oo = set(oo,'V',V,'T',T,'D',D);
   end
   
   head = 'PT2(s) = V / (1 + 2*D*(s*T) + (s*T)^2)';
   params = sprintf('V = %g, T = %g, D = %g',V,T,D);

   oo = update(oo,'PT2 System',{head,params});
   paste(o,{oo});                      % paste transfer function
end
