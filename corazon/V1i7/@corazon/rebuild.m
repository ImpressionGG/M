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
