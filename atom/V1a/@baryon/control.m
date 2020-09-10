function oo = control(o,tag,value)
%
% CONTROL   Deal with shell control settings
%
%    Shell control settings determine the behavior of the shell. Mind that
%    method CONTROL does either manipulate object options (if output arg
%    is assigned to an object) or it directly manipulates the control set-
%    tings (if no out args are provided and more than 1 input arg).
%
%       control(o)                     % display all control settings
%       bag = control(o)               % get bag of control options
%       o = control(o,bag)             % init control options
%
%       value = control(o,tag)         % get a control option
%       control(o,tag,value)           % set a control setting
%       o = control(o,tag,value)       % set a control option
%
%    Conditional setting or providing default values
%
%       value = control(o,{tag,default}) % get a control option
%       control(o,{tag},value)           % provide a control setting
%       o = control(o,{tag},value)       % provide a control option
%
%    Example:
%       control(o,'refresh',cblist)    % set refresh callback
%       control(o,'current',2)         % set current object index
%       control(o,'dynamic',true)      % enable dynamic shell
%       control(o,'launch',func)       % set launch function
%
%    Note: to set a control option unconditionally first clear the option
%    and then set it.
%
%       o = control(o,'launch','');    % clear launch function
%       o = control(o,'launch',func);  % set launch function
%
%    See also: BARYON
%
   prefix = 'control.';                     % control setting prefix
   
   if (nargin == 1)
      bag = opt(o,prefix(1:end-1));
      if (nargout == 0)
         disp(bag);                         % display control settings
      else
         oo = bag;                          % return control settings
      end
   elseif (nargin == 2)
      if iscell(tag)
         value = tag{2};  tag = tag{1};
         oo = opt(o,[prefix,tag]);
         if isempty(oo)
            oo = value;
         end
      elseif isstruct(tag)
         if (nargout == 0)
            setting(o,'control',tag);
         else
            oo = opt(o,tag);
         end
      else
         oo = opt(o,[prefix,tag]);          % get value of control setting
      end
   elseif (nargin == 3) && (nargout == 0)
      if iscell(tag)
         tag = tag{1};
         if isempty(setting(o,[prefix,tag]))   
            setting(o,[prefix,tag],value);  % set value of control setting
         end
      else
         setting(o,[prefix,tag],value);     % set value of control setting
      end
      oo = o;                               % copy to out arg
   elseif (nargin == 3) && (nargout == 1)
      if iscell(tag)
         tag = tag{1};
         if isempty(opt(o,[prefix,tag]))   
            oo = opt(o,[prefix,tag],value); % set value of control setting
         else
            oo = o;                         % go with current options
         end
      else
         oo = opt(o,[prefix,tag],value);    % set value of control setting
      end
   else
      error('bad calling syntax!');
   end
end

