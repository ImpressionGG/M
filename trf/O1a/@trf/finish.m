function oo = finish(o,oo,title,comment,color)
%
%  FINISH   Finish the creation process of a transfer function
%    
%                title = 'PT1 System';
%                comment = {'PT1(s) = 1/(1+s*T)'};
%                color = 'r'
%                oo = trf([1],[T 1]);    
%                oo = finish(o,oo,title,comment,color)
%    
%             See also: TRF
%    
   if (nargin < 5)
      color = 'c';                     % cyan color by default
   end
   
   [func,mfile] = caller(o,1);
   kind = get(o,'kind');
   
   oo = set(oo,'kind',func);
   gamma = eval(['@',mfile]);
   oo = set(oo,'update',{gamma,func});

   oo = update(oo,title,comment);

      % we have to add property entry for the color
      
   list = get(oo,{'edit',{}});
   list{end+1} = {'Color','color'};
   oo = set(oo,'edit',list);
   
      % in case of a virgin object paste transfer function, otherwise
      % merge data and new parameters into old object
      
   virgin = ~isequal(kind,func);       % do we have a virgin object?
   if (virgin)
      oo = set(oo,'color',color);
      oo = edit(oo);
      if ~isempty(oo)
         paste(o,{oo});                % paste transfer function
      end
   else
      oo = Merge(o,oo);                % merge data and parameters
      title = get(o,{'title',''});     % actual title
      oo = set(oo,'title',title);      % restore actual title
   end
   return
   
   function o  = Merge(o,oo)           % Merge Data and Parameters     
   %
   % MERGE   Merge new data and parameters of new object oo into old
   %         object o.
   %
   %            oo = Merge(o,oo)
   %
      tags = fields(oo.par);
      for (i=1:length(tags))
         tag = tags{i};
         o = set(o,tag,get(oo,tag));
      end
      o.data = oo.data;
   end
end
