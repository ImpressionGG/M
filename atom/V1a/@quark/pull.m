function oo = pull(o)
%
% PULL   Pull object from figure
%
%    Pull object from figure indicate by object figure handle (figure(o))
%    If object figure handle is empty use current figure instead.
%
%           oo = pull(o)               % pull QUARK object from figure
%           oo = pull(lepton)          % pull QUARK object from figure
%
%    Code lines: 16
%
%    See also: QUARK, GLUON, GCF, FIGURE, PUSH
%
   fig = figure(o);                    % first choice for fig handle
%
% the provided figure handle fig = figure(o) could be empty. In this case
% use the default fig = gcf instead. If no figure is open stop processing
%
   if isempty(fig)                     % don't do for GUI handle register
      fig = gcf(gluon);                % get current figure
      if isempty(fig)
         oo = [];                      % give up - no way to continue!
         return                        % return empty object
      end
      o = figure(o,fig);               % set object's figure handle
   end
%
% pull object
%
   gob = gluon;                        % work with the GLUON shelf
   oo = shelf(gob,fig,'object');       % recall object from shelf
   if isempty(oo)
      return                           % give up - no way to continue!
   end
%
% overwrite options with settings
%
   settings = setting(oo);
   oo = work(oo,'opt',settings);
%
% set another times the figure handle
%
   oo = figure(oo,fig);                % set object's figure handle
end
