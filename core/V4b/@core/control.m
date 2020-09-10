function loop = control(obj)
%
% CONTROL    Loop control which serves two functions
%
%               1) returns a loop termination request to the caller
%                  if terminate has been invoked by a caller
%
%               2) syncronizes UPDATE sequence
%
%            Example:
%          
%               [t,dt] = timer(smart,0.1);
%               while (control(smart))
%                  update(smart,plot(0:dt:t));
%                  [t,dt] = wait(smart)
%               end
%
%            See also: SMART, GAO, STOP, WAIT, TIMER
%
   loop = ~stop(obj);
   update(obj);
   return
   
%eof   