function o = prop(o,tag,value,varargin)
%
% PROP   Get/set a CORAZITA object's property
%
%    Syntax:
%       bag = prop(o)                  % same as bag = struct(o)
%       value = prop(o,tag);           % get an object property
%       o = prop(o,tag,value);         % set an object property
%
%    Multiple Get
%
%       list = prop(o,{'par.system'},'A,B,C')      % direct get
%       list = prop(o,{'par.system'},{'A,B',A,B})  % conditional get
%
%    Multiple Set
%
%       o = prop(o,{'par.system'},'A,B,C',A,B,C)   % direct set 
%       o = prop(o,{'par.system'},'A,B,C',{A,B,C}) % direct set 
%
%       o = prop(o,{'par.system'},{'A,B'},A,B)     % conditional set 
%       o = prop(o,{'par.system'},{'A,B'},{A,B})   % conditional set 
%
%    Examples:
%       data = prop(o,'data');         % get object's data
%       o = prop(o,'data',data);       % set object's data
%
%       x = prop(o,'data.x');          % get object's data.x
%       o = prop(o,'data.x',x);        % set object's data.x
%
%       ti = prop(o,'par.title');      % get an object parameter
%       o = prop(o,'par.title',ti);    % set an object parameter
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZITA, GET, SET, VAR, OPT, WORK, TYPE
%

      % by default arg2 (tag) is a character, which results in optimal
      % performance of the method. 
      
   if ischar(tag)
      if (nargin == 1)
         o = struct('tag',o.tag,'type',o.type,'par',o.par,...
                    'data',[],'work',o.work);
      elseif (nargin == 2)
         o = eval(['o.',tag],'[]');
      elseif (nargin == 3)
         eval(['o.',tag,' = value;']);
      else
         error('1, 2 or 3 input args expected!')
      end
      return
   end
   
      % if arg2 is a cell array we have to deal with comma separated tags
      % and optional defaults, thus we compromise performance with the
      % method's additional functionalities caused by dispatching overhead
      
   if ~iscell(tag)
      error('arg2 must be char or cell array!');
   end
      
   prefix = tag{1};
   tags = value;

      % see if defaults are provided
      
   if iscell(tags)
      defaults = tags(2:end);
      tags = tags{1};
   else                                % multiple set or set with defaults
      defaults = [];
   end
   
   if ~ischar(tags)
      error('arg3 must be a string with comma separated tags!');
   end
   
   idx = find(tags==',');
   n = length(idx) + 1;                % number of comma separated args
   idx = [0,idx,length(tags)+1];
   bag = eval(['o.',prefix],'[]');

      % dispatch between multiple get or multiple set
      
   if (nargin == 3)                    % multiple get
      for (i=1:n)                      % no defaults provided
          tag = tags(idx(i)+1:idx(i+1)-1);
          if isfield(bag,tag)
             list{i} = bag.(tag);
          else
             list{i} = [];
          end
          
             % replace empty list item with default (if provided)
             
          if (isempty(list{i}) && length(defaults) >= i)
             list{i}  = defaults{i};
          end
      end
      o = list;
   else                                % multiple set
      
         % under special conditions arglist may be passed as
         % embedded list, which we will unembed ...
         
      if (ischar(tags) && ~isempty(find(tags==',')))
         if (length(varargin)==1 && n > 1)
            varargin = varargin{1};
         end
      end
      
         % now varargin is an unembedded list 
         
      if (n ~= length(varargin))
         error('number of comma separated tags must match number of data args!');
      end
      
      for (i=1:n)
          tag = tags(idx(i)+1:idx(i+1)-1);
          if (iscell(defaults))
             if isfield(bag,tag)
                value = bag.(tag);
             else
                value = [];
             end
             
             if isempty(value)
                bag.(tag) = varargin{i};
             end
          else
             bag.(tag) = varargin{i};
          end
      end
      eval(['o.',prefix,'=bag;'],'[]');
   end
end
