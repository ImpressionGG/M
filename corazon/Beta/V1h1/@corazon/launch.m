function out = launch(o,oo)
%
% LAUNCH   Corazita launch service
%
%    A proper shell is launched for an object which is currently repre-
%    sented as a bag of properties.
%
%       oo = launch(corazita,o)         % launch any object's shell
%       launch(o)                      % launch a CORAZITA object
%       oo = launch(corazita,bag)       % launch from bag
%
%       func = launch(o);              % get launch function name
%       o = launch(o,func);            % set launch function name
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZITA
%
   if (nargin == 1)
      if (nargout == 0)
         oo = o;                       % use arg1 for object to be launched
      else
         func = control(o,{'launch',o.type});
         out = func;                   % return launch function name
         return
      end
   end
%
% if argument oo is a bag we have to construct an object from the bag
%
   if ischar(oo)
      out = control(o,'launch',oo);    % set launch function
      return
   elseif isstruct(oo)                 % ignore empty bags
      bag = oo;
      construct = eval(['@',bag.tag]); % function handle of constructor
      oo = construct(bag);             % construct object
   end
%
% now launch object. In case of error try shell
%
   try
      func = launch(oo);
      gamma = eval(['@',func]);        % launch function handle
   catch
      func = 'shell';
      gamma = @shell;                  % use shell as last option
   end
   
   oo = launch(oo,func);               % set launch function
   oo = gamma(oo);                     % invoke launch
end

