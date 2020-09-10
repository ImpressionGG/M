function [oo,idx] = basket(o)          % Basket of Selected Objects    
%
% BASKET   Get list of objects in basket, or display basket settings.
%
%    Adoption of the BASKET method for dealig with a set of transfer
%    functions assigned to a package. For each list in the basket
%    if the basket object is a package then all transfer functions
%    belonging to this package are multiplied with each other and the
%    original package object in the basket is replaced with a new transfer
%    function representing the product of the package members.
%
%    For more functionality of basket see cordoba/basket and corazon/basket.
%
%       [list,idx] = basket(o)         % list & indices of basket objects
%       basket(o)                      % print selecting options
%
%    Note that the basket can contain only objects of a class which matches
%    exactly the class of the current selected object. This is nessessay
%    to provide proper dynamic menus.
%
%    Example: plot all objects of a basket
%
%       list = basket(o);
%       for (i=1:length(list))
%          oo = list{i};
%          plot(oo);
%       end
%
%    See also: TRF, CORDOBA/BASKET, CORAZON/BASKET, INHERIT
%
   co = cast(o,'cordoba');             % casted object
   if (nargout == 0)
      basket(co);
   else
      [list,idx] = basket(co);
      for (j=1:length(list))
         oo = list{j};
         if length(list) == 1 && o.is(type(oo),'pkg')
            package = get(oo,'package');
            title = get(oo,'title');
            collection = {};
            for (i=1:length(o.data))
               oo = o.data{i};
               typ = type(oo);
               if ~isempty(package)
                  proper = o.is(typ,{'strf','ztrf','qtrf'}); 
                  if proper && o.is(get(oo,'package'),package)
                     collection{end+1} = oo;
                  end
               end
            end
            oo = trf('collection');
            oo.data = collection;
            oo = set(oo,'title',title);
            list{j} = oo;
         end
      end
      oo = list;
   end
end
