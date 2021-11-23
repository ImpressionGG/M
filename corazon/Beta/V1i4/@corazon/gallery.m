%
% GALLERY   Manage Gallery
%
%    1) Add a gallery entry: for two input arguments options, title and 
%    comment are chosen from arg2. With one input arg options are chosen
%    from arg1 while a dialog for title and comments is opened.
%
%       gallery(pull(o))               % add to gallery - open dialog
%       o = gallery(o,oo)              % add to gallery - no dialog
%
%    2) Get i-th gallery entry or number of gallery entries
%
%       gallery(o,i);                  % launch gallery entry of i-th index
%       entry = gallery(o,i);          % get entry of i-th index
%       n = gallery(o,inf);            % get number of gallery entries
%
%    3) Clear all gallery entries
%
%       gallery(o,[]);
%
%    4) Special functions
%
%       gallery(o,'Display')           % display gallery entry
%       gallery(o,'Edit')              % edit gallery entry
%       gallery(o,'Up')                % move gallery entry up
%       gallery(o,'Down')              % move gallery entry down
%       gallery(o,'Delete')            % delete gallery entry
%
%    5) Get/set gallery parameters
%
%       [list,cur] = gallery(o)        % get gallery list & current index
%       gallery(o,list,cur)            % set gallery parameters
%
%    Example 1: Add to gallery with dialog
%       gallery(o);
%
%    Example 2: refresh according to i-th gallery entry
%       oo = gallery(o,i);             % fetch i-th gallery entry
%       if is(oo)
%          refresh(oo);                % refresh object
%       end
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZON, MENU
%
