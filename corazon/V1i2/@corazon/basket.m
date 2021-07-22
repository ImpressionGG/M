%
% BASKET   Get list of objects in basket, or display basket settings.
%
%    The objects in the basket list inherit work properties from the 
%    container object in a proper way (see INHERIT method).
%
%       [list,idx] = basket(o)         % list & indices of basket objects
%       basket(o)                      % print selecting options
%
%    Are some objects in basket with type from given type list?
%
%       ok = basket(o,{'shell','weird','cube'})
%
%    Perform operation gamma on all objects of the basket list
%
%       oo = basket(o,gamma)           % perform gamma on basket list
%
%    Note that the basket can contain only objects of a class which matches
%    exactly the class of the current selected object. This is nessessay
%    to provide proper dynamic menus.
%
%    Example 1: plot all objects of a basket
%
%       list = basket(o);
%       for (i=1:length(list))
%          oo = list{i};
%          plot(oo);
%       end
%
%    Example 2: a typical Basket() function to perform a basket operation 
%
%       function o = Basket(o)         % perform basket operation                   
%          refresh(o,o);               % use this callback for refresh
%          cls(o);                     % clear screen
%          gamma = eval(['@',mfilename]);
%          oo = basket(o,gamma);       % perform operation gamma on basket   
%          if ~isempty(oo)             % irregulars happened?
%             message(oo);             % report irregular
%          end
%       end
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZON, INHERIT
%
