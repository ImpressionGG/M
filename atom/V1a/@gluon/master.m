function oo = master(obj,evt,tag,cblist)  % Master Callback            
%
% MASTER   Master callback
%
%    Serves as first callback (supporting MATLAB callback interface)
%    and forwards to QARK style callback.
%
%           oo = master(obj,evt,arg1,arg2,...)
%
%        See also: GLUON
%
   bo = construct(gluon,tag);          % base object for pull method
   o = pull(bo);                       % pull object from shell
   
%    if container(o) && ~isequal(class(o),'tag')
%       o = cast(o,tag);               % cast shell object
%       o.tag = class(bo);             % counter balancing!
%    end
   
   o.wrk.object = obj;                 % set object handle
   o.wrk.event = evt;                  % set calling event
   
      % retrieve user data and append to cblist
      
   cblist{end+1} = get(gcbo,'userdata');
   
      % call callback
      
   busy(o);                            % change mouse pointer -> busy
   oo = call(o,cblist,bo,tag);         % invoke master callback
   ready(o);                           % change mouse pointer -> ready
end