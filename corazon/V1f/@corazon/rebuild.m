function oo = rebuild(o,tag,cblist)     % Rebuild Entire Menu
%
% REBUILD  Rebuild entire menu structure
%
%             rebuild(o)                            % rebuild entire menu
%             rebuild(o,'$Col$',{@menu,'Colors'});  % rebuild tagged menu
%
%          A menu can be tagged by providing a tag in the user data
%          of the menu header, e.g.
%
%             function oo = Colors(o)  % Colors Menu
%                oo = mhead(o,'Colors',{},'$Col$')
%                charm(mitem('Line Color',{},'linecolor'))
%                charm(mitem('Fill Color',{},'fillcolor'))
%             end
%
%          A typical call to rebuild this sub menu is
%
%             rebuild(o,'$Col$',{mfilename,'Colors'})
%
%          Copyright (c): Bluenetics 2020 
%
%          See also: CORAZON, MENU, GALLERY, REFRESH
%
   if (nargin == 1)
      o = pull(o);                     % refetch object from figure
      if ~isempty(o)                   % if a current figure is available
         oo = arg(o,{});               % clear arg list
         oo = work(oo,'rebuild',true); % indicate a rebuilt shell
         launch(oo);                   % launch object

         oo = current(o);
         title = get(oo,{'title',get(o,{'title','Shell'})});
         set(figure(o),'name',title);  % update figure bar
      end
   elseif (nargin == 3)
      [~,po] = mseek(o,tag);
      call(po,cblist);                 % rebuild menu
   else
      error('bad calling syntax!');
   end
end
