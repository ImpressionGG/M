%
% CLOSEUP Add a closeup panel with a zoom slider and a shift slider to
%         investigate a figure's closeup
%
%            closeup(o)                % setup closeup sliders
%            closeup(o,'Setup')        % same as above
%
%         Setup with customized callbacks:
%
%            closeup(o,{mfilename,'Zoom'},{mfilename,'Shift'})
%
%         Invoke standard Zoom and Shift callback:
%
%            o = closeup(o,'Zoom')     % closeup zoom callback
%            o = closeup(o,'Shift')    % closeup shift callback
%
%         Pick index range (requires proper setting of var(o,'zoom') and
%         var(o,'shift'), as it is done by o = closeup(o,'Zoom') or o =
%         closeup(o,'Shift').
%
%            oo = closeup(o,'Range',[1 10000])
%            range = var(oo,'range');
%
%         Remark closeup() changes the xlimits of all subplots with either
%         empty or enabled shelf settings 'closeup'. To prevent a subplot 
%         from being controlled by the closeup sliders invoke
%
%            shelf(o,gca,'closeup',false);   % prevents closeup control
%
%         Copyright(c) Bluenetics 2020
%
%         See also: CORAZON
%
