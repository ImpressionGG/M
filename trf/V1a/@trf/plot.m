function oo = plot(o,varargin)         % Trf Plot Method
%
% PLOT   Trf plot method
%
%           plot(o,'Plot1')            % user defined plot function #1
%           plot(o,'Plot2')            % user defined plot function #2
%           plot(o,'Plot3')            % user defined plot function #3
%           plot(o,'Show')             % show object
%           plot(o,'Animation')        % animation of object
%
   [gamma,oo] = manage(o,varargin,@Plot1,@Plot2,@Plot3,...
                                  @Show,@Animation);
   oo = gamma(oo);
end

%==========================================================================
% Local Plot Functions
%==========================================================================

function o = Plot1(o)                  % User Defined Plot Function #1 
   message(o,'Modify trf.plot>Plot1 function!');
end
function o = Plot2(o)                  % User Defined Plot Function #2 
   message(o,'Modify trf.plot>Plot2 function!');
end
function o = Plot3(o)                  % User Defined Plot Function #3 
   message(o,'Modify trf.plot>Plot3 function!');
end
function o = Show(o)                   % Show Object                   
   oo = cast(o,'carabao');             % cast to a carabao object
   plot(oo,'Show');                    % delegate to plot@carabao
end
function oo = Animation(o)             % Animation Callback            
   oo = cast(o,'carabao');             % cast to a carabao object
   plot(oo,'Animation');               % delegate to plot@carabao
end
