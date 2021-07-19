function [oo,idx] = basket(o,arg2)     % Basket of Selected Objects    
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
   o.profiler('Basket',1);             % begin profiling
   [either,iif] = util(o,'either','iif');   % need some utility
   
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
% b) [list,idx] = basket(o) % list & indices of basket objects
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
            
         case '*'                      % all objects
            [oo,idx] = current(o);
            list = iif(container(o),o.data,{o});
            idx = iif(container(o),1:length(list),idx);
            [list,idx] = Types(o,list,idx);
            
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
% Two input args: type found in basket?
% c) ok = basket(o,{'cube','ball'})    % type found in basket?
%
   while nargin == 2 && iscell(arg2)   % type supporting?              
      types = arg2;                    % arg2 is a list of types
      for (i=1:length(types))
         if ~ischar(types{i})
            error('type list (arg2) must contain character strings!');
         end
      end
      
      list = basket(o);      
      for (i=1:length(list))
         if o.is(type(list{i}),types)
            oo = true;                 % found a type from type list
            o.profiler('Basket',0);    % end profiling
            return
         end
      end
      
      oo = false;                      % no type from type list found
      o.profiler('Basket',0);          % end profiling
      return
   end
%
% Two input args: perform operation gamma on basket
% d) ok = basket(o,gamma)              % type found in basket?
%
   while nargin == 2 && isa(arg2,'function_handle') % perform operation
      oo = Perform(o,arg2);            % perform operation on basket
      o.profiler('Basket',0);          % end profiling
      return
   end
%
% if we reach here something with the calling syntax is wrong
%
   error('bad calling syntax (1 in arg an 0 or 1 out args expected)!');
end

%==========================================================================
% Helper Functions
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
function Info(o)                       % Show selecting option settings
%
% INFO   Display selection info
%
   o = pull(o);                        % refresh options
   either = util(o,'either');          % need some utility
   
   [oo,idx] = current(o);              % get index of current object
   
   collect = opt(o,{'basket.collect',''''''});
   groups = opt(o,{'basket.groups',''''''});
   classname = class(oo);
   type = opt(o,{'basket.type','*'});

   fprintf('  Current Selection\n');
   if (idx == 0)
      fprintf('    all objects of shell\n');
   else
      title = get(oo,{'title',''});
      fprintf('    object #%g: %s\n',idx,title);
   end
   influence = corazon.iif(idx==0,'(no influence)','');
   fprintf('  Basket class\n');
   fprintf('    class:  %s\n',classname);
   fprintf('  Basket options %s\n',influence);
   fprintf('    collect: %s\n',collect);
   %fprintf('   groups:  %s\n',groups);
   fprintf('    type:   %s\n',type);
   fprintf('  Objects in basket\n');
   
   [list,idx] = basket(o);
   for (i = 1:length(list))
      title = get(list{i},{'title',''''''});
      fprintf('    object #%g: %s\n',idx(i),title);
   end
   return
end
function oo = Perform(o,gamma)         % Perform Operation on Basket   
%
% PERFORM   Perform operation on the basket. If regulars happen then
%           return non-empty object with a short description of irregular
%           in title and comment. Calling routine may decide to report
%           irregular situation by calling message()
%
   list = basket(o);

   if isempty(list)
      oo = set(o,'title','No objects!');
      oo = set(oo,'comment',{'(import object or create a new one)'});
      return                        % irregular happened
   else
      dirty = 0;
      for (i=1:length(list))
         oo = list{i};
         if container(oo)
            return;                 % irregular happened
         else
            oo = opt(oo,'hold',1,'index',i);
            ooo = gamma(oo);           % forward to sample/Plot method
            hold on;                   % saves work for plot helpers

            dirty = dirty + ~isempty(ooo);
         end
      end

      if ~dirty
         oo = current(o);           % irregular happened
         return
      end
   end

   oo = [];                         % no irregulars happened
end
