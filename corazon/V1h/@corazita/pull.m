function oo = pull(o)
%
% PULL   Pull object from figure
%
%    Pull object from figure indicate by object figure handle (figure(o))
%    If object figure handle is empty use current figure instead.
%
%           oo = pull(o)               % pull CORAZITA object from figure
%           oo = pull(corazita)         % pull CORAZITA object from figure
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZITA, GCF, FIGURE, PUSH
%
   fig = figure(o);                    % first choice for fig handle
%
% the provided figure handle fig = figure(o) could be empty. In this case
% use the default fig = gcf instead. If no figure is open stop processing
%
   if isempty(fig)                     % don't do for GUI handle register
%     fig = gcf(o);                    % get current figure
      fig = gcf(corazito);             % get current figure
      if isempty(fig)
         oo = [];                      % give up - no way to continue!
         return                        % return empty object
      end
      o = figure(o,fig);               % set object's figure handle
   end
%
% pull object
%
   cob = corazito;                     % work with the CORAZITO shelf
   oo = shelf(cob,fig,'object');       % recall object from shelf
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
