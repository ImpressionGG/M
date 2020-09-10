function o = register(o,varargin)
%
% REGISTER Register an item
%
%          Registering changes only the shell settings, but usually
%          not the menu of a shell in order to achieve a fast
%          initializing process.
%
%          1) Configuration
%          ================
%
%             register(o,'Config',cblist)   % register type specific config
%
%          The configuration according to the  object type is registered.
%          Example:
%
%             oo = type(o,active(o));  % object which has active type
%             oo = Config(arg(o,{'XandY'}));
%             register(oo,'Config',{@study,'Config','XandY'});   
%
%          2) Type
%          =======
%
%             register(o,'Type')     % register type specific config
%
%          The configuration according to the  object type is registered.
%          Example:
%
%             oo = type(o,active(o));  % object which has active type
%             oo = Config(arg(o,{'XandY'}));
%             register(oo,'Config');   % register configuration
%
%          Copyright(c): Bluenetics 2020 
%
%          See also: CORDOBA 
%
   [gamma,oo] = manage(o,varargin,@Config);
   oo = gamma(oo);
end

%==========================================================================
% Work Horses
%==========================================================================

function o = Config(o)
   cblist = arg(o,1);
   list = active(o,o.type);         % get registered list
   if isempty(list)                 % only if nothing registered
      config(o,{o});                % conditional registering of config
      active(o,{o.type},cblist);    % conditional registration
   end
end
