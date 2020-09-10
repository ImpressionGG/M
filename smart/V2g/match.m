function out = match(arg1,arg2)
%
% MATCH   Get match index of a label string
%         Return 0 if not found!
%
%         Slow lookup: (search needs 8 ms for list length of 30)
%
%            idx = match('vA1',list)    % e.g. list = {'uM1','uM2','pU','vA1','vA2'}
%
%         Quick lookup:  (search needs 0.9 ms for list length of 30)
%
%            table = match(list)        % calculate match table from list
%            idx = match('vA1',table)   % e.g. table=['uM1';'uM2';'pU ';'vA1';'vA2']
%            idx = match('vA2',table)
%

   if (nargin == 1) % then calculate match table
      list = arg1;
      [m,n] = size(list);
      
      if (m == 1) list = list'; m = n; end
         
      table = '';
      for(i=1:m)  % for all rows
         lab = list{i,1};
         l = length(lab);
         table(i,1:l) = lab;
      end
      out = table;      
      
   else % calculate match index
      str = arg1;     % string to match
      table = arg2;   % match table
      
      if iscell(table)
         table = match(table);  % convert match table from match list
      end
      [m,n] = size(table);
      
      if length(str) > n
         idx = [];   % not found
      else
         search = 0*table(1,:);
         l = length(str);
         search(1:length(str)) = str;
         strtab = setstr(ones(m,1)*search);
         diff = table - strtab;
         if size(diff,2) == 1
            idx  = find(abs(diff)==0);
         else
            idx = find(~sum(abs(diff)'));
         end
      end
      out = idx;
   end
   
% eof      
   
