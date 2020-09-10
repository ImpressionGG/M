function o = with(o,tag)
%
% WITH   Translation of options
%
%    Translates a current option setting to a required option setting.
%
%      oo = with(o,'style')                     % unpack 'style' options
%      oo = with(o,{'style','view','select'});  % unpack multiple options
% 
%    See also: CARABAO, OPT
%
   if (nargin ~= 2)
      error('2 input args expected!');
   end

   if isa(tag,'char')
      o = With(o,tag);
   elseif isa(tag,'cell')
      list = tag;                               % arg2 is a list
      for (i=1:length(list))
         o = With(o,list{i});
      end
   else
      error('char or list expected for arg2!');
   end
end

%==========================================================================
% Actual With Routine
%==========================================================================

function o = With(o,tag)
   if ~isa(tag,'char')
      error('char expected for tag!');
   end
   
   value = opt(o,tag);
   if isempty(value)
      return;
   end

   flds = fields(value);
   for (i=1:length(flds))
      dtag = flds{i};            % destination tag
      stag = [tag,'.',dtag];     % source tag
      value = opt(o,stag);
      o = opt(o,dtag,value);     % copy value
   end
end
