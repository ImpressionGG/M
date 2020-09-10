function rv = propagate(obj,func,path)
%
% PROPAGATE   Propagate a menu callback
%
%    Propagate a menu callback of a CORE object to the parent class.
%    Propagation depends on the value of path, which is either empty
%    (caller cannot handle callback) or non-empty (caller can handle
%    callback!).
%
%       if ~propagate(obj,func,which(func)) 
%          eval([func,'(obj);']); 
%       end
%
%    propagate() returns 1 in case of decision for propagation
%    or 0 otherwise.
%
%    See also CORE, MENU
%
   rv = 0;                  % default return value: not propagated
   if isempty(path)
      par = parent(obj);
      if isempty(par)
         error(['Cannot handle callback: ',func]); 
      end
      menu(par,func);       % let parent's method handle the call!      
      rv = 1;
   end
   return
end
