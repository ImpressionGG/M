function [err,o1] = check(o,mode)
%
% CHECK   Check numeric quality. Standard check is based on double
%         arithmetics. Optional VPA arithmetics can be used
%
%            check(o)        % check zero/pole quality of a transfer system
%
%            err = check(o)  % err = [zerr,perr] contains zero/pole errors
%
%            err = check(o,'Zeros')  % err: column of zero errors
%            err = check(o,'Poles')  % err: column of pole errors
%
%         Options:
%            digits          % digits of VPA arithmetics for check
%                            % default: 0 means double arithmetics
%
%         Copyright(c): Bluenetics 2021
%
%         See also: CORASIM, SYSTEM, TRF, ZPK, TRFVAL
%
   digs = opt(o,{'digits',0})
   
      % if digits option is non-zero then we have to proceed with VPA
      % arithmetics
      
   if (digs > 0)
      old = digits(digs);              % redefine VPA digits
   end

   
   
   
   
   
   
   if (digs > 0)
      digits(old);                     % restore VPA digits
   end
