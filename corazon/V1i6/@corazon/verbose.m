%
% TALK   Setup verbose talking control. 
%
%    1) Setup proper boolean variable set for decision of verbose talking
%    based on current 'verbose' option setting. Take care about speed of
%    the setup!
%
%       [o,talk] = verbose(o)                           % use defaults
%       [o,talk] = verbose(o,'bit',1,'some',2,'lot',3)  % same as above
%       [o,talk] = verbose(o,'L1',1,'L2',2,'L3',3,...)  % customized
%
%    This statement sets up a structure talk with boolean values
%    depending on the actual value of option 'verbose'.
%
%       talk.bit   = (control(o,'verbose') >= 1)        % default
%       talk.some  = (control(o,'verbose') >= 2)        % default
%       talk.lot   = (control(o,'verbose') >= 3)        % default
%
%    while talk is additionally stored in an object variable according to
%
%       o = var(o,'verbose',talk);
%
%    Embedding an integer value in a list means that this value will me
%    directly used. This fur instance helpful if a modulus value needs to
%    be defined.
%
%    Example 1: define 3 verbose levels
%
%       o = verbose(o,'bit',1,'some',2,'lot',3);   % same as o = verbose(o)
%         :
%       verbose = var(o,'verbose');
%       if verbose.bit
%          fprintf('talking a bit about ...\n');
%       end
%
%    means
%
%       o = var(o,'verbose',talk)
%
%    with fast access possibilities on lower subroutine levels
%
%       talk = var(o,'verbose')                     % [30 �s !!!]
%
%
%    Example 2: define one verbose level and a modulus
%
%       [o,talk] = verbose(o,'summary',1,'modulus',{20})
%           :
%       if talk.summary && rem(count,talk.modulus) == 0
%          fprintf('Intermediate summary ...\n');
%       end
%
%    See also: CORAZON, CONTROL
%    Copyright (c): Bluenetics 2020 
%
