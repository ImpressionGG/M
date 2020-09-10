function oo = inherit(oo,o)
%
% INHERIT   Inherit work properties properly, or inherit configuration
%           options from shell
%
%    If control(o,'options') is true then children's options are inherited
%    from the container, otherwise they are not affected.
%
%       oo = inherit(oo,o);            % inherit work property properly
%
%    Exceptions: the following options are not transfered from the container
%    to the child object:
%
%       opt(o,'control.color')         % figure background color
%       opt(o,'control.launch')        % launch function
%
%    Furthermore the following work properties have to be inherited:
%
%       work.figure
%       work.object
%       work.event
%       work.arg
%       work.mitem
%
%     Inherit configuration options from settings: options 'config',
%     'category' and 'subplot' are inherited from shell.
%
%       o = inherit(o);            % inherit config options from settings
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORDOBA, CURRENT, BASKET
%
   if (nargin == 1)
      bag = setting(oo);
      oo = opt(oo,'config',bag.config);
      oo = opt(oo,'category',bag.category);
      oo = opt(oo,'subplot',bag.subplot);
   elseif (nargin == 2)
      co = cast(oo,'corazon');
      oo = inherit(co,o);
      oo = balance(oo);
   else
      error('1 or 2 input args expected!');
   end
end