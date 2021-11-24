function txt = heading(o,txt)
%
% HEADING   Overloaded heading method for SPM objects
%
%              heading(o)          % plot heading (auto adds object id)
%              heading(o,txt)      % plot heading with custom text 
%
%              txt = headng(o)     % get heading text without plotting
%
%           Copyright(c): Bluenetics 2020
%
%            See also: SPM
%
   if (nargin == 1)
      tit = get(o,{'title',''});
      txt = o.either(tit,'SPM Object');

      oid = id(o);
      if ~isempty(oid);
         txt = [txt,' (',oid,')'];
      end
   end

      % incorporate package title into heading
      
   pattern = 'state_space_matrix format=dense';
   idx = strfind(txt,pattern);

   if ~isempty(idx)
      po = pkg(o);
      if ~isempty(po) && ~isempty(get(po,'title'))
         idx = idx(1)-1;
         name = get(po,'title');
         ndx = strfind(name,'.SPM ');
%        txt = [txt(1:idx), name(ndx(1)+5:end), txt(idx+length(pattern):end)];
         txt = [name(ndx(1)+5:end), txt(idx+1+length(pattern):end)];
      end
   end
    
      % plot heading if nargout==0   
   
   if (nargout == 0)   
      if (nargin == 1 || nargin == 2)
         heading(corazon(o),txt);
      else
         error('1 or 2 input args expected');
      end
   end
end
