function out = textbox(varargin)
%
% function textbox(varargin)
%
% draws a textbox in a figure; if no figure handle is given as first
% argument, then the current figure is used
%
% EXAMPLE:
%   textbox('string1', 'string2', 'string3');
%   textbox(figHandle, 'string1', 'string2', 'string3');
%
% hari, 04_12_14

if nargin == 0
    return;
end

if ischar(varargin{1})
    figHandle = gcf;
    startIx = 1;
else
    figHandle = varargin{1};
    startIx = 2;
end

if ischar(varargin{end})
    caText = varargin(startIx:end);
else
    % the last input parameter is a positional argument
    caText = varargin(startIx:end-1);
end

% TODO implement positional argument

ax = get(figHandle, 'CurrentAxes');

if isempty(ax)
    %no axes in the figure
    axPos = [0 0 1 1];
else
    axPos = get(ax,'Position');
end

gap = 0.01;     % small gap between axes and textbox
at = annotation(figHandle, ...
                'textbox',[axPos(1) + gap 0.5 0.25 0.25],...
                'String', caText, ...
                'FitBoxToText', 'on', ...
                'Visible', 'off', ...
                'BackgroundColor', [0.99 0.99 0.99], ...
                'Tag', 'textbox');

pause(0.01);   % needed, otherwise strange timing problem

% reduce axes size by width of textbox (so figure size does not change)
posTxt = get(at, 'Position');

if posTxt(3) > axPos(3)
   ME = MException('textbox:outOfRange','Textbox width too large'); 
   throw(ME);
end

if posTxt(4) > axPos(4)
   ME = MException('textbox:outOfRange','Textbox height too large'); 
   throw(ME);
end

axPos(3) = axPos(3) - posTxt(3);
set(ax, 'Position', axPos);

if isempty(ax)
    posTxt(1) = 0.25;
else
    posTxt(1) = axPos(1) + axPos(3) + gap;
end

posTxt(2) = axPos(2) + (axPos(4) - posTxt(4))/2;

set(at, 'Position', posTxt);
set(at, 'Visible', 'on');
set(ax, 'UserData', at);

out = at;

return