function o = provide(o,tag,value)
%
% PROVIDE   Provide a property
%
%    Provide a property value if current property value is empty.
%    Otherwise the object is not affected.
%
%       o = provide(o,tag,value)            % provide property
%       o = provide(o,'type','shell');      % provide type
%       o = provide(o,'par.title','Hi!');   % provide parameter
%       o = provide(o,'data.x',1:5);        % provide data
%       o = provide(o,'work.var.a',pi);     % provide work variable
%
%    See also: QUARK, SET, GET, DATA, WORK, OPT, VAR
%
   if isempty(prop(o,tag))
      o = prop(o,tag,value);
   end
end
