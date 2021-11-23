%
% INHERIT   Inherit work properties properly
%
%    If control(o,'options') is true then children's options are inherited
%    from the container, otherwise they are not affected.
%
%       oo = inherit(oo,o);            % inherit work property properly
%
%    oo is a child object, and o is the donor object (usually the container
%    object), and options are transfered from o to oo.
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
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZON, CURRENT, BASKET
%
