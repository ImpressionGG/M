function obj = cleanup(obj)
% 
% CLEANUP   Cleanup a CORE object, e.g. for preventing to save unnecessary
%           bulk data to file. CLEANUP is implicitely called in SAVE.
%      
%             obj = cleanup(obj);
%
%        See also: CORE SAVE
%
   return   % nothing specifically to do for non derived CORE objects
end
