function obj = provide(obj,varargin)
%
% PROVIDE   Provide parameter setting(s) for SHELL object for all those
%           parameters which have empty settings.
%
%               obj = provide(obj,'title','My Title')
%               obj = provide(obj,'title','My Title','menu',{'file'})
%
%           Genmeral syntax is:
%
%               obj = provide(obj,varargin)
%
%           See also: SHELL SET GET
%
   n = length(varargin) / 2;
   for (i = 1:n)
      attrib = varargin{i*2-1};
      if isempty(get(obj,attrib))
         value = varargin{i*2};
         obj = set(obj,attrib,value);
      end
   end
   
   return
   
%eof
