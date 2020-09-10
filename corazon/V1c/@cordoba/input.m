function varargout = input(o,title,prompts,values,sizes)
%
% INPUT   Input dialog for multiple input values
%
%    Input 1 or more values by dialog box. The type is examined from the
%    input values. The same type is returned as output args. Output args
%    are either returned by a list of values or a out arg list.
%
%    Arg5 specifies the sizes of the edit field. Default is 1 row by 50
%    columns ([1 50]).  Sizes (arg5) may also be a matrix with row numbers 
%    matching the number of prompts and each ror specifying row and column
%    numbers of the input field.
%
%       sizes = [1 50; 10 50];                       % 1x50 and 10x50 field
%       values = input(o,title,prompts,values,sizes)   
%       values = input(o,title,prompts,values)       % sizes = [1 50]
%
%       values = input(o,title,prompts)              % empty default values
%       values = input(o,title,prompts,{'',...,'')   % empty default values
%
%       [v1,v2,...] = input(o,title,prompts);
%
%       [v1,v2,...] = input(o,title,{'',...,''});    % empty prompts
%       [v1,v2,...] = input(o,title);                % same as above
%
%       [v1,v2,...] = input(o);                      % no title
%       [v1,v2,...] = input(o,'',{'',...,''});       % same as above
%
%    Examples
%
%       prompt = {'Number 1:','Number 2:'};
%       values = input(o,'Input two numbers',prompt,{0,0})
%
%       prompt = {'First Name:','Last Name:'};
%       [first,last] = input(o,'Your Name',prompt,{'Jonny','Walker'})
%
%       [first,last] = input(o,'Your Name',prompt,{'',''}) % empty defaults
%       [first,last] = input(o,'Your Name',prompt)         % empty defaults
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORDOBA, MENU
%
   if (nargin < 2)   
      title = 'Input';    % default title
   end
   
   if ~ischar(title')
      error('title (arg2) must be string!');
   end
   
% provide proper prompts
      
   if (nargin < 3)
      prompts = {''};      %  default prompt
      for (i=1:nargout)
         prompts{i} = '';
      end
   end
   
   if ~iscell(prompts)
      error('prompts (arg3) must be a list!');
   end

   if (nargout > 1) && (length(prompts) ~= nargout)
      error('number of out args must match length of prompts!');
   end
   
   for (i=1:length(prompts))
      if (~ischar(prompts{i}))
         error('all elements of prompts list (arg3) must be string!');
      end
   end

% provide proper values
      
   if (nargin < 4)
      values = {''};      %  default value
      for (i=1:nargout)
         prompts{i} = '';
      end
   end
   
   if ~iscell(values)
      error('default values (arg4) must be a list!');
   end
   
   if (length(values) ~= length(prompts))
      error('number of prompts must match length of default values!');
   end

% examine the classes of default values and cast them to string

   for (i=1:length(values))
      classes{i} = class(values{i});
      switch classes{i}
         case 'double'
            val = values{i};
            values{i} = sprintf('%g',val(1));
         case 'char'
            'char OK!';
         otherwise
            error('can only deal with double and char default values!');
      end
   end

% default for sizes

   if (nargin < 5)
      sizes = [1 50];
   end
   
   if ~isa(sizes,'double')
      error('sizes (arg5) must have positive double values!');
   end

   %sizes = sizes(:)';

   if size(sizes,1) == 1
      if length(sizes) ~= 2
         error('1x2 row vector expected for sizes (arg5)!');
      end
      sizes = ones(length(prompts),1)*sizes;
   elseif size(sizes,2) == 1
      if length(sizes) ~= length(prompts)
         error('length of sizes (arg5) must match number of prompts!');
      end
      sizes = [sizes, ones(length(sizes),1)*50];
   end
   
   if size(sizes,1) ~= length(prompts)
      error('sizes (arg5) is incompatible with number of prompts!')
   end
   
% open the input dialog. Return immediately if dialog has been terminated
% with CANCEL

   prompt1 = prompts{1};
   %prompt1(25) = '.';        % make a bit longer => this stretches the box!
   prompts{1} = prompt1;

   answers = inputdlg(prompts,title,sizes,values);

   if isempty(answers)
      for (i=1:length(prompts))
         varargout{i} = {};   % all out args are empty
      end
      return
   end
   
% copy answers to the out arg list while casting the type

   if (nargout == 1 && length(answers) > 1)
      varargout{1} = answers;
   elseif (nargout == length(answers) || nargout == 0)
      for (i=1:length(answers))
         switch classes{i}
            case 'char'
               value = answers{i};
            case 'double'
               value = sscanf(answers{i},'%f');
            otherwise
               value = answers{i};
         end
         varargout{i} = value;
      end
   else
      error('either 1 out arg or same number as prompts expected!');
   end
end
