function display(o)
%
% DISPLAY   Display a TRF object
%
%              display(o)
%
%           See also: TRF
%
   if container(o) || isstruct(o.data) || isempty(o.data)
      Display(o);
   else
      dsp(o);
   end
end

function Display(o)
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
%
% Optional info for menu items
%
   hdl = work(o,'mitem');
   if ~isempty(hdl)
      fprintf('MITEM Details\n');
      mitem(o);
   end
end
