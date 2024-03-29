function display(o,oo)                 % Display Corazon Object        
%
% DISPLAY   Display a CORAZON object
%
%              display(o)              % display a corazon object
%              display(corazon,oo)     % display other class object
%
%           Copyright(c): Bluenetics 2020 
%
%           See also: CORAZON
%
   if (nargin == 2) && isa(oo,'corazon')
      o = oo;
   end
   
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
      fprintf('\n');
      if isfield(bag,'figure')
         fig = bag.figure;
         fprintf('    figure: %g\n',double(fig));
         bag = rmfield(bag,'figure');
      end
      disp(bag);
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
