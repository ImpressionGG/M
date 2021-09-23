function icheck(o,data,msg)
%
% CHECK   Check matrix elements for range
%
   if all(data == 0)
      return                 % ok
   end
 
   absdata = abs(data);
   if (any(absdata >= 2^31))
      if ~isempty(msg)
         msg = [' (',msg,')'];
      end
      if isempty(o.name)
         fprintf('*** IMAT overflow%s!\n',msg);
      else
         fprintf('*** %s: IMAT overflow%s!\n',o.name,msg);
      end
      beep;
   end
   
   if (any(absdata < 1))
      if ~isempty(msg)
         msg = [' (',msg,')'];
      end
      if isempty(o.name)
         fprintf('*** IMAT underflow%s!\n',msg);
      else
         fprintf('*** %s: IMAT underflow%s!\n',o.name,msg);
      end
      beep;
   end
end