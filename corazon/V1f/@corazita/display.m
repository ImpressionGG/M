function display(o)
%
% DISPLAY   Display a CORAZITA object
%
%              display(o)
%
%           Copyright(c): Bluenetics 2020 
%
%           See also: CORAZITA
%
   fprintf('%s object\n',upper(class(o)));
   tags = {'tag','type','par','data'};
   fprintf(' MASTER Properties:\n');
   for (i=1:length(tags))
      tag = tags{i};
      value = prop(o,tag);

      fprintf('  %s: ',tag);
      if isstruct(value)
         fprintf('\n');  disp(value);
      elseif ~isempty(value)
          disp(value); 
      elseif isa(value,'cell')
          fprintf('{}\n');
      elseif isa(value,'char')
          fprintf('''''\n');
      else
          fprintf('[]\n');
      end
   end
%
% Now print the work properties
%
   fprintf(' WORK Property:');
   bag = work(o);
   if isstruct(bag)
      fprintf('\n');  disp(bag);
   elseif ~isempty(bag)
       disp(bag); 
   else
       fprintf('\n  []\n');
   end
end
