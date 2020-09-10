function [oo,idx] = basket(o)          % Basket of Selected Objects    
%
% BASKET   Get list of objects in basket, or display basket settings.
%
%    The objects in the basket list inherit work properties from the 
%    container object in a proper way (see INHERIT method).
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
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORDOBA, INHERIT
%
   o.profiler('Basket',1);             % begin profiling
   
   collect = opt(o,{'basket.collect','selected'});
   groups = opt(o,{'basket.groups','*'});
%
% No out args and 1 input arg: show info about option settings
% a) basket(o)                         % print selecting options
%
   while nargin == 1 && nargout == 0   % print selecting options       
      Info(o);
      o.profiler('Basket',0);          % end profiling
      return
   end
%
% One out arg and 1 input arg: return list of selected objects
% a) [list,idx] = basket(o) % list & indices of basket objects
%
   while nargin == 1 && nargout >= 1   % list of selected objects  
      switch collect
         case 'selected'
            [oo,idx] = current(o);
            if container(oo)
               list = oo.data;  idx = 1:length(list);
            else
               list = {oo};
            end
            [list,idx] = Types(o,list,idx);
            [list,idx] = Kinds(o,list,idx);
            
         case '*'                      % all objects
            [oo,idx] = current(o);
            if container(o)
               list = o.data;
               idx = 1:length(list);
            else
               list = {o};
            end
            [list,idx] = Types(o,list,idx);
            [list,idx] = Kinds(o,list,idx);
            
         case 'marked'                 % marked groups
            list = {};  idx = [];
            
         case 'unmarked'               % unmarked groups
            list = {};  idx = [];
      end
      
         % for each list element inherit work property properly
         
      [list,idx] = Classes(oo,list,idx);% only classes matching class(oo)
      for (i=1:length(list))
         list{i} = inherit(list{i},o); % inherit work property properly
      end
      oo = list;
      o.profiler('Basket',0);          % end profiling
      return
   end
%
% if we reach here something with the calling syntax is wrong
%
   error('bad calling syntax (1 in arg an 0 or 1 out args expected)!');
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function [list,idx] = Classes(o,ilist,index)  % Filter Proper Class    
   name = class(o);
   list = {};  idx = [];
   for (i=1:length(ilist))
      oo = ilist{i};
      if isequal(class(oo),name)
         list{end+1} = oo;  idx(end+1) = index(i);
      end
   end
end

function [list,idx] = Types(o,ilist,index)    % Filter Selected Types  
   type = opt(o,{'basket.type','*'});
   list = ilist;  idx = index;
   if ~isequal(type,'*')
      list = {};  idx = [];
      for (i=1:length(ilist))
         oo = ilist{i};
         if o.is(oo.type,type)
            list{end+1} = oo;  idx(end+1) = index(i);
         end
      end
   end
end

function [list,idx] = Kinds(o,ilist,index)    % Filter Selected Kinds
   kind = opt(o,{'basket.kind','*'});
   list = ilist;  idx = index;
   if ~isequal(kind,'*')
      list = {};  idx = [];
      for (i=1:length(ilist))
         oo = ilist{i};
         if isequal(kind,get(oo,{'kind',''}))
            list{end+1} = oo;  idx(end+1) = index(i);
         end
      end
   end
end

function Info(o)                       % Show selecting option settings
%
% INFO   Display selection info
%
   o = pull(o);                        % refresh options
   
   [oo,idx] = current(o);              % get index of current object
   
   collect = opt(o,{'basket.collect',''''''});
   groups = opt(o,{'basket.groups',''''''});
   classname = class(oo);
   type = opt(o,{'basket.type','*'});
   kind = opt(o,{'basket.kind','*'});

   fprintf('  Current Selection\n');
   if (idx == 0)
      fprintf('    all objects of shell\n');
   else
      title = get(oo,{'title',''});
      fprintf('    object #%g: %s\n',idx,title);
   end
   
   if (idx == 0)
      influence = '(no influence)';
   else
      influence = '';
   end
   
   fprintf('  Basket class\n');
   fprintf('    class:  %s\n',classname);
   fprintf('  Basket options %s\n',influence);
   fprintf('    collect: %s\n',collect);
   %fprintf('     groups:  %s\n',groups);
   fprintf('    type:   %s\n',type);
   fprintf('    kind:   %s\n',kind);
   fprintf('  Objects in basket\n');
   
   [list,idx] = basket(o);
   for (i = 1:length(list))
      title = get(list{i},{'title',''''''});
      fprintf('    object #%g: %s\n',idx(i),title);
   end
end

