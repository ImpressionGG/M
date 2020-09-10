function n = name(obj)
% 
% NAME   Get name of a DPROC object
%      
%             obj = dproc           % create DPROC object
%             n = name(obj)         % name
%
%          See also   DISCO, DPROC

   n = obj.data.name;               % object's name
   
% end
