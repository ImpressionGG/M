function oo = addzpk(o1,o2)
%
% ADDZPK   Add to systems in ZPK representation
%
%             oo = addzpk(o1,o2)
%
%          Example
%           
%             o1 = zpk(corasim,[-3],[-2 -5],1);
%             o2 = zpk(corasim,[-4],[-1 -1],2);
%             oo = addzpk(o1,o2)
%
%          Other functions
%
%             oo = addzpk(o,'Demo1')   % Linear function demo
%             oo = addzpk(o,'Demo2')   % Quadratic function demo
%             oo = addzpk(o,'Demo3')   % Quadratic function demo
%             oo = addzpk(o,'Demo4')   % Newton - single roots
%             oo = addzpk(o,'Demo5')   % Newton - multiple roots
%
%          Copyright(c): Bluenetics 2020
%
%          See also: CORASIM, TRF, ZPK, ADD, PLUS
%
   if ischar(o2)
      oo = Call(o1,o2);                % call local function
      return
   end
   
   oo = o1;  % dummy
end

%==========================================================================
% Run a Local Function
%==========================================================================

function oo = Call(o,func)
   gamma = eval(['@',func]);           % get function handle
   oo = gamma(o);                      % call local fnction
end

%==========================================================================
% Demos
%==========================================================================

function o = Demo1(o)                  % Linear Demo                   
%
% DEMO1  Linear demo
%
%           p(s) = s + 1  => zeros: z = [-1]
   z = [-1];
   
   s = -1:0.01:1;
   f = Eval(o,z,s);
   df = Derivative(o,z,s);
   
   cls(o);
   plot(o,s,f,'r');
   hold on
   plot(o,s,df,'g');
   
   title('f(s) = s+1  =>  zeros: z = [-1]');
   xlabel('s');
   ylabel('f(s),  df(s)/ds');

   subplot(o);                         % subplot complete
end
function o = Demo2(o)                  % Quadratic Demo                
%
% DEMO2  Quadratic demo
%
%           p(s) = (s+1)*(s+2) = s^2+3s+2  => zeros: z = [-1,-2]
%           p'(s) = 2*s + 3
   z = [-1,-2];
   
   s = -4:0.01:1;
   f = Eval(o,z,s);
   df = Derivative(o,z,s);
   
   cls(o);
   plot(o,s,f,'r');
   hold on
   plot(o,s,df,'g');
   
      % known results: p(-1) = 0, p(0) = 2, p(1) = 6
      %                p'(-1) = 1, p'(0) = 3, p'(1) = 5
      
   plot(o,[-1 0 1],[0 2 6],'ro');
   plot(o,[-1 0 1],[1 3 5],'go');
   
   title('f(s) = s^2+3s+2  =>  zeros: z = [-1,-2]');
   xlabel('s');
   ylabel('f(s),  df(s)/ds');

   subplot(o);                         % subplot complete
end
function o = Demo3(o)                  % Quadratic Demo                
%
% DEMO3  Quadratic demo
%
%           p(s) = (s+1)*(s+1) = s^2+2s+1  => zeros: z = [-1,-1]
%           p'(s) = 2*s + 2
   z = [-1,-1];
   
   s = -2:0.01:0;
   f = Eval(o,z,s);
   df = Derivative(o,z,s);
   
   cls(o);
   PlotF(o,211);
   PlotDf(o,212);

   function PlotF(o,sub)
      subplot(o,sub);
      plot(o,s,f,'r');
      hold on

         % known results: p(-2) = 1, p(-1) = 0, p(0) = 1

      plot(o,[-2 -1 0],[1 0 1],'ro');
      title('f(s) = s^2+2s+1  =>  zeros: z = [-1,-1]');
      xlabel('s');
      ylabel('f(s)');

      subplot(o);                         % subplot complete
   end
   function PlotDf(o,sub)   
      subplot(o,sub);
      plot(o,s,df,'g');
      hold on

         % known results: p'(-2) = -2, p'(-1) = 0, p'(0) = 2

      plot(o,[-2 -1 0],[-2 0 2],'go');

      title('f''(s) = 2s+2  =>  zeros: z = [-1]');
      xlabel('s');
      ylabel('df(s)/ds');

      subplot(o);                         % subplot complete
   end
end
function o = Demo4(o)                  % Newton - Single Roots         
%
% DEMO4  Newton demo
%
%        Newton's algorithm:
%
%           s(k+1) = s(k) - f(k)/f'(k)
%
   n = 50;
   z = -[1:n];
   
   s = [-1.1, -2.1];
   
   delta = inf*ones(1,10);
   
   for (i=1:1000)
      f = Eval(o,z,s);
      df = Derivative(o,z,s);
      
      idx = find(df~=0);
      if isempty(idx)
         ds = 0;
      else
         ds = f(idx)./df(idx);
         s(idx) = s(idx) - ds;
      end
      
      corr(i) = norm(ds);
      delta = [corr(i),delta(1:end-1)];% history of corrections
      ratio(i) = delta(end)/delta(1);
      if (ratio(i) < 1.01)
         %break;
      end
      if (corr(i) ==  0)
         break;                        % no need to continue
      end
   end

   dB = 20*log10(abs(corr));           % correction in dB
   idx = find(isinf(dB));
   dB(idx) = -500*ones(size(idx));
   
   idx = find(isnan(ratio));
   ratio(idx) = 0*idx;
   
   err = norm(s-[-1 -2]);              % final error

   cls(o);
   PlotCorrection(o,211);
   PlotRatio(o,212);
   o = s;
   
      % done
   
   function PlotCorrection(o,sub)      % Plot Correction               
      subplot(o,sub);
      plot(o,1:length(dB),dB,'r');
      title(sprintf('Newton Iteration: s1 = %g, s2 = %g, err = %g',...
            s(1),s(2),err));
      xlabel('Iteration');
      ylabel('Correction [DB]');

      subplot(o);
   end
   function PlotRatio(o,sub)           % Plot Improvement Ratio        
      subplot(o,sub);
      plot(o,1:length(ratio),ratio,'r');
      title(sprintf('Newton Iteration: s1 = %g, s2 = %g, err = %g',...
            s(1),s(2),err));
      xlabel('Iteration');
      ylabel('Improvement ratio over 10 steps');

      subplot(o);
   end
end
function o = Demo5(o)                  % Newton - Multiple Roots       
%
% DEMO4  Newton demo
%
%        Newton's algorithm:
%
%           s(k+1) = s(k) - f(k)/f'(k)
%
   n = 500;
   z = [(-1)*ones(1,n), (-2)*ones(1,n)];
   
   s = [-1.1, -2.1];
   
   delta = inf*ones(1,10);
   
   for (i=1:1000)
      f = Eval(o,z,s);
      df = Derivative(o,z,s);
      
      idx = find(df~=0);
      if isempty(idx)
         ds = 0;
      else
         ds = f(idx)./df(idx);
         s(idx) = s(idx) - ds;
      end
      
      corr(i) = norm(ds);
      delta = [corr(i),delta(1:end-1)];% history of corrections
      ratio(i) = delta(end)/delta(1);
      if (ratio(i) < 1.01)
         %break;
      end
      if (corr(i) ==  0)
         break;                        % no need to continue
      end
   end

   dB = 20*log10(abs(corr));           % correction in dB
   idx = find(isinf(dB));
   dB(idx) = -500*ones(size(idx));
   
   idx = find(isnan(ratio));
   ratio(idx) = 0*idx;
   
   err = norm(s-[-1 -2]);              % final error

   cls(o);
   PlotCorrection(o,211);
   PlotRatio(o,212);
   o = s;
   
      % done
   
   function PlotCorrection(o,sub)      % Plot Correction               
      subplot(o,sub);
      plot(o,1:length(dB),dB,'r');
      title(sprintf('Newton Iteration: s1 = %g, s2 = %g, err = %g',...
            s(1),s(2),err));
      xlabel('Iteration');
      ylabel('Correction [DB]');

      subplot(o);
   end
   function PlotRatio(o,sub)           % Plot Improvement Ratio        
      subplot(o,sub);
      plot(o,1:length(ratio),ratio,'r');
      title(sprintf('Newton Iteration: s1 = %g, s2 = %g, err = %g',...
            s(1),s(2),err));
      xlabel('Iteration');
      ylabel('Improvement ratio over 10 steps');

      subplot(o);
   end
end

%==========================================================================
% Helper
%==========================================================================

function f = Eval(o,z,s)               % Polynomial Evaluation         
%
% POLYVAL    Evaluate polynomial with given roots z = [z1,...,zn] at argu-
%            ment s, where s may be a row vector s = [s1,...,sm]
%
%               f = Eval(o,z,s)
%
%            Remark: Eval(o,z,z) must return all zeros
%
%            Algorithm:
%
%               f = (s-z1) * (s-z2) * ... * (s-zn) 
%
   z = z(:);  s = s(:).';
   
   Z = z*ones(1,length(s));
   S = ones(length(z),1)*s;
   F = S-Z;
   
   if (size(F,1) <= 1)
      f = F;
   else
      f = prod(F);
   end
end
function df = Derivative(o,z,s)        % Polynomial Derivative         
%
% DERIVATIVE Evaluate derivative of a polynomial with given roots 
%            z = [z1,...,zn] at argument s, where s may be a row vector 
%            s = [s1,...,sm]
%
%               df = Derivative(o,z,s)
%
%            Algorithm:
%
%               f(s) = (s-z1) * (s-z2) * (s-z3) * (s-zn)
%               df/ds = ???
%
%            Let: gi(s) := s-zi, i.e. g1(s) := s-z1, g2(s) := s-z2, ...
%                 g124(s) := g1(s)*g2(s)*g4(s) and so on ...
%                 gi'(s) = 1
%            Then
%
%               f(s) = g1234(s) = g1(s) * g2(s) * g3(s) * g4(s)
%
%               f'(s) = g1'(s)*g234(s) + g1(s)*g234'(s) =
%                       g234(s) + g1(s)*[g2'(s)*g34(s) + g2(s)*g34'(s)]
%
%            With g34'(s) = g3'(s)*g4(s) + g3(s)*g4*(s) = g4(s) + g3(s)
%
%               f'(s) = g234(s) + g1(s)*[g34(s) + g2(s)*[g4(s)+g3(s)]] = 
%                     = g234(s) + g134(s) + g124(s) + g123(s)
%
%               f'(s) = g1234(s) * [1/g1(s) + 1/g2(s) + ... + 1/g4(s)]
%
%
%                                [  1    g1(s) g1(s) g1(s) ... g1(s) ]
%                                [ g2(s)  1    g2(s) g2(s) ... g2(s) ]  
%               f'(s) = sum(prod([ g3(s) g3(s)  1    g3(s) ... g3(s) ]))
%                                [  :     :     :     :    ...  :    ]
%                                [ gn(s) gn(s) gn(s) gn(s) ...  1    ]
%
   z = z(:);  s = s(:).';
   
   Z = z*ones(1,length(s));
   S = ones(length(z),1)*s;
   G = S-Z;
   
   one = ones(size(s));
   df = 0*one;                         % init
   
   if (length(z) > 1)
      for (i=1:length(z))
         Gi = G;  Gi(i,:) = one;
         dfi = prod(Gi);
         df = df + dfi;
      end
   end
end



