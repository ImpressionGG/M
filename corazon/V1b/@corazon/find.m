function idx = find(o,arg1,arg2)
%
% FIND   Find first occurence of a match
%
%    Find first occurence of a substring within a string, or find first
%    occurrence in a logical vector. The function always return an integer,
%    which simplifies subsequent processing.
%
%       idx = find(o,'cde','abcdefgh')               % idx = 3
%       idx = find(o,'ghi','abcdefgh')               % idx = 0
%       idx = find(o,'','abcdefgh')                  % idx = 0
%
%       idx = find(o,[0 0 1 1 0])                    % idx = 3
%       idx = find(o,[0 0 0 0 0])                    % idx = 0
%       idx = find(o,[])                             % idx = 0
%
%       idx = find(o,[5 6 7]==[7 6 7])               % idx = 2
%       idx = find(o,[5 6 7]==[7 8 9])               % idx = 0
%       idx = find(o,[5 6 7]==7)                     % idx = 3
%
%       idx = find(o,'bc',{'abc','ab','bc'})         % idx = 3
%       idx = find(o,'bc',{'bc0','bc','bc'})         % idx = 2
%       idx = find(o,'bc',{'abc','ab','de'})         % idx = 0
%       idx = find(o,'bc',{})                        % idx = 0
%
%    Note: the function needs less than 20 micro seconds
%
%       Copyright(c): Bluenetics 2020 
%
%    See also: CORAZON, STRFIND
%
   if (nargin == 2)
      idx = min(find(arg1));
   elseif iscell(arg2)
      for (idx = 1:length(arg2))
         if strcmp(arg1,arg2{idx})
            return                      % found first match in list
         end
      end
      idx = 0;
      return                            % otherwise return 0 (not found)
   else
      idx = min(strfind(arg2,arg1));
   end

      % empty matrix will concerted to a zero
      
   if isempty(idx)
      idx = 0;
   end
end
