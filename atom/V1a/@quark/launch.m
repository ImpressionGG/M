function oo = launch(o,oo)
%
% LAUNCH   QUARK launch service
%
%    A proper shell is launched for an object which is currently repre-
%    sented as a bag of properties.
%
%       oo = launch(quark,o)           % launch any object's shell
%       launch(o)                      % launch a QUARK object
%       oo = launch(quark,bag)         % launch from bag
%
%    Code lines: 14
%
%    See also: QUARK
%
   if (nargin == 1)
      oo = o;                          % use arg1 for object to be launched
   end
%
% if argument oo is a bag we have to construct an object from the bag
%
   if isstruct(oo)                     % ignore empty bags
      oo = construct(gluon,oo);        % construct object
   end
%
% now launch object. In case of error try shell
%
   try
      gamma = eval(['@',oo.typ]);      % launch function handle
   catch
      %gamma = @shell;                  % use shell as last option
   end
   
   oo = gamma(oo);                     % invoke launch
end

