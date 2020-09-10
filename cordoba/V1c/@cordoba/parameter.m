function [tag,value] = parameter(o,line)    % Extract Parameter        
%
% PARAMETER   Extract parameter from Line
%
%    Syntax
%
%       ok = parameter(o,line)              % is this a parameter line?
%       [tag,value] = parameter(o,line);    % parse parameter
%
%    Parameter expressions:
%
%       [tag,value] = parameter(o,'$format=tpx1')
%       [tag,value] = parameter(o,'$title=My Title')
%       [tag,value] = parameter(o,'$comment=Test run #1')
%       [tag,value] = parameter(o,'$comment=without golden eye search')
%
%       [tag,value] = parameter(o,'$date=03-Jun-2016')
%       [tag,value] = parameter(o,'$time=12:24:00')
%       [tag,value] = parameter(o,'$pi=3.15159')
%       [tag,value] = parameter(o,'$array=[5.5 6.6 7.7]')
%       [tag,value] = parameter(o,'$list={67,56,[6 7 8]}')
%
%    Example 1
%       line = fgetl(fid);
%       while parameter(o,line)
%          [tag,value] = parameter(o,line);
%          o = set(o,tag,value);       % set parameter
%          line = fgetl(fid);          % next line
%       end
%
%    Example 2
%       line = fgetl(fid);
%       while parameter(o,line)
%          [tag,value] = parameter(o,line);
%          par.(tag) = value;          % set parameter
%          line = fgetl(fid);          % next line
%       end
%       o.par = par;
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORDOBA, READ
%                   
   if (nargout <= 1)
      tag = '';
      if (~isempty(line) && line(1) == '$')
         tag = sscanf(line,'$%[^=]');
      end
      return
   end
   
   tag = sscanf(line,'$%[^=]');
   format = ['$',tag,'=%[^\n]'];
   value = sscanf(line,format);

      % special treatment in case of comments
      
   if isequal(tag,'comment')         % special treatment for comments
      comment = get(o,{'comment',{}}); % get current comment
      if ~iscell(comment)
         comment = {comment};          % ensure a list!
      end
      comment{end+1} = value;          % add to comment list
      value = comment;                 % return accumulated comment list
      return
   end
   
      % get first character of value
      
   c = ' ';
   if (length(value) >= 1)
      c = value(1);
      switch tag
         case {'title'}
            c = ' ';                   % continue with default
         case 'date'
            vec = sscanf(value,'%f/%f/%f/%f/%f/%f/%f')';
            if ~isempty(vec)
               value = datestr(vec(1:6));
               tag = 'datetime';
               return
            end
      end
   end
   
      % other value treatment
      
   if (length(value) >= 2 && c == '''' && value(end) == '''')
      value(1) = '';  value(end) = '';
   elseif ('0' <= c && c <= '9') || c == '[' || c == '{'
      value = eval(value,[]);
   end
end
