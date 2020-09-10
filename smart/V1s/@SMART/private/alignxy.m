function [x,y,nplots,match] = alignxy(x,y)
%
% ALIGNXY    Align x and y matrices for plotting. Check for compatible
%            dimensions of x and y vector (matrices) and return number of
%            plots to be made (nplots), and a flag (match) indicating
%            the special case whether x and y dimensions are matching
%
%               [x,y,nplots,match] = alignxy(x,y);   % align
%
%            Note what is working! Consider two 'high' rectangular matrices
%            x and y of dimension 10 x 2 (per default use 'high' matrices:
%
%               x = sort(rand(10,3));
%               y = sort(rand(10,3));
%
%            The following cases work:
%
%               a) plot(x,y)             % same dimensions x & y
%               b) plot(x(:,1),y)        % proper column vector x
%               c) plot(x(:,1)',y)       % proper row vector x
%               d) plot(x(:,1),y')       % proper column vector x
%               e) plot(x(:,1)',y')      % proper row vector x
%               f) plot(x,y(:,1))        % proper column vector y
%               g) plot(x,y(:,1)')       % proper row vector y
%               h) plot(x(:,1),y(:,1))   % column x, column y 
%               i) plot(x(:,1),y(:,1)')  % column x, row y
%               j) plot(x(:,1)',y(:,1))  % row x, column y
%               k) plot(x(:,1)',y(:,1)') % row x, row y
%               l) plot([],[])           % empty x, y
%             
%            And this will fail:
%
%               1) plot(x',y)            % swapped dimensions x & y
%               2) plot(x,y')            % swapped dimensions x & y
%               3) plot([],y)            % empty x
%               4) plot(x,[])            % empty y
%
   mindimx = min(size(x));          % the smaller dimension of x
   if (mindimx == 1)                % is x a vector ?
      x = x(:);                     % align x => now column vector
   end
   
   mindimy = min(size(y));          % the smaller dimension of y
   if (mindimy == 1)
      y = y(:);                     % align y => now column vector
   end
   
   x = iif(isempty(x),[],x);        % tricky: empty can be 0x0, 0x1, 1x0
   y = iif(isempty(y),[],y);        % tricky: empty can be 0x0, 0x1, 1x0
   
      % our first pre-alignment has been done. If x or y is a vector
      % then we have made sure that it is a column vector
      
   [mx,nx] = size(x);               % get dimensions of x
   [my,ny] = size(y);               % get dimensions of y
      
   match = all(size(x)==size(y));   % same dimensions?

      % since all matrices are now aligned it now easy
      % to determine the number of plots
     
   if (~match)                      % if dimensions do not match
      if (nx == 1)                  % ultimate chance for x-vectors            
         if (mx == ny)              % could x column number match y rows?
            y = y';                 % yes, works!  go with the transposed y
         end
      elseif (ny == 1)              % ultimate chance for y-vectors            
         if (my == nx)              % could y column number match x rows?
            x = x';                 % yes, works!  go with the transposed x
         end
      end
   end
   
   [mx,nx] = size(x);               % update dimensions of x
   [my,ny] = size(y);               % update dimensions of y

   if (mx ~= my)                    % final check
       error('smart::alignxy(): dimensions of x and y incompatible!');
   end

   nplots = max(nx,ny);             % take the bigger number of columns!
   
   return

%eof   