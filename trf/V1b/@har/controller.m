function oo = controller(o,varargin)   % Har Controller Method
%
% CONTROLLER   Create a new controller pbject
%
%           controller(o,'R1')         % create R1 controller
%           controller(o,'R2')         % create R2 controller
%
   [gamma,oo] = manage(o,varargin,@Controller,@R1,@R2);
   oo = gamma(oo);
end

%==========================================================================
% Menu Setup
%==========================================================================

function oo = Controller(o)            % Controller Menu Setup
   co = cast(o,'trf');                 % cast to TRF object
   oo = controller(co);                % add New/Controller menu
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'R1 Controller',{@R1});
   ooo = mitem(oo,'R2 Controller',{@R2});
end

%==========================================================================
% Actual Controller Creation
%==========================================================================

function oo = R1(o)                    % New R1 Controller         
%
% R1   Create a lead type controller with transfer function 
%
%                       1 + s/(om/sqrt(N))    
%          R1(s) = V * --------------------   % V = 1, om = 1, N = 10
%                       1 + s/(om*sqrt(N))
%
   if o.is(type(o),'R1')
      oo = o;
      [V,om,N] = get(oo,'V','om','N');
   else
      V = 1;                           % gain factor
      om = 1;                          % design frequency
      N = 10;                          % working range

      oo = trf(V*[1/(om/sqrt(N)) 1],[1/(om*sqrt(N)) 1]);
      oo = set(oo,'init','R1');
      oo = set(oo,'V',V,'om',om,'N',N);
   end
   
   head = 'R1(s) = V * [1 + s/(om/sqrt(N))] / [1 + s/(om*sqrt(N))]';
   params = sprintf('V = %g, om = %g, N = %g',V,om,N);

   oo = update(oo,'R1 Controller',{head,params});
   paste(o,{oo});                      % paste transfer function
end

function oo = R2(o)                    % New R2 Controller         
%
% R2   Create a lag type controller with transfer function
%
%                       1 + s/(om*sqrt(N))    
%          R2(s) = V * --------------------   % V = 1, om = 1, N = 10
%                       1 + s/(om/sqrt(N))
%
   if o.is(type(o),'R2')
      oo = o;
      [V,om,N] = get(oo,'V','om','N');
   else
      V = 1;                           % gain factor
      om = 1;                          % design frequency
      N = 10;                          % working range

      oo = trf(V*[1/(om*sqrt(N)) 1],[1/(om/sqrt(N)) 1]);
      oo = set(oo,'init','R2');
      oo = set(oo,'V',V,'om',om,'N',N);
   end
   
   head = 'R2(s) = V * [1 + s/(om*sqrt(N))] / [1 + s/(om/sqrt(N))]';
   params = sprintf('V = %g, om = %g, N = %g',V,om,N);

   oo = update(oo,'R2 Controller',{head,params});
   paste(o,{oo});                      % paste transfer function
end
