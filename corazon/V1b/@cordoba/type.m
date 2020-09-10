function oo = type(o,typ)              % Get/Set Type                  
% 
% TYPE   Get/set type of a CORDOBA object. This method is compatible to
%        the caracow/type method with the extra syntax typ = type(o,o),
%        which is used to retrieve the 'actual type' for config, category
%        and subplot methods.
%      
%           typ = type(o);             % get type
%           o = type(o,'mytype');      % set type
%
%        Enhanced syntax to retrieve actual type for configurations,
%        categories, subplots, signals:
%
%           typ = type(o,o);           % get actual type
%
%        To see all object type specific config, category and subplot settings
%        options/settings use
%
%           type(sho)    % list type specific settings
%           type(o)      % list all type specific options
%
%        Copyright(c): Bluenetics 2020 
%
%        See also: CORDOBA, CONFIG, CATEGORY, SUBPLOT, SIGNAL
%
   if (nargin == 1) && nargout > 0
      oo = o.type;                     % get object's type
   elseif (nargin == 1) && nargout == 0
      Show(o);                         % show type specific options
   elseif ischar(typ)
      o.type = typ;                    % set object's type
      oo = o;                          % copy to out arg
   else
      oo = o.type;
      return
      
      oo = o;                          % init out arg 2
      if container(o)
         curidx = control(o,'current');
         if (curidx ~= 0)
            oo = data(o,curidx);       % overwrite out arg 2
         end
      end
      typ = oo.type;                   % get actual type
      o = typ;                         % set out arg 1
      return

      atype = active(o);
      if ~isempty(atype)
         typ = atype;
      else
         typ = oo.type;
      end
   end
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function Show(o)                       % Show Type Specific Options    
   fprintf('      object type: ''%s''\n',o.type);
   subplot(o,NaN);                     % show specific subplot options
   category(o,NaN);                    % show specific category options
   config(o,NaN);                      % show specific configuration
end