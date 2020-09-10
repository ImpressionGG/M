function oo = plot(o,varargin)         % Espresso Plot Method
%
% PLOT   Espresso plot method
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

function o = Plot1(o)                  % Scatter Plot                  
   refresh(o,{'plot','Plot1'});        % update refresh callback
   oo = current(o);                    % get current object
   cls(o);                             % clear screen
   if ~container(oo)
      scatterplot(oo.data.x,oo.data.y,oo.par);  
   end
end

function o = Plot2(o)                  % Stream Plot For X-Data        
   refresh(o,{'plot','Plot2'});        % update refresh callback
   oo = current(o);                    % get current object
   cls(o);                             % clear screen
   if ~container(oo)
      streamplot(oo.data.x,'x','r',oo.par);  
   end
end

function o = Plot3(o)                  % Stream Plot For Y-Data        
   refresh(o,{'plot','Plot3'});        % update refresh callback
   oo = current(o);                    % get current object
   cls(o);                             % clear screen
   if ~container(oo)
      streamplot(oo.data.y,'y','b',oo.par);  
   end
end

function o = Show(o)                   % Show Object                   
   oo = cast(o,'carabao');             % cast to a carabao object
   plot(oo,'Show');                    % delegate to plot@carabao
end

function oo = Animation(o)             % Animation Callback            
   oo = cast(o,'carabao');             % cast to a carabao object
   plot(oo,'Animation');               % delegate to plot@carabao
end
