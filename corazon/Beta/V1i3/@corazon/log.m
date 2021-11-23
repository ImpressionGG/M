% 
% LOG   Data logging
%
%    Passing strings to the LOG method initializes a data logging object.
%    Subsequent passing of multiple scalar arguments adds values to the
%    data logging object.
%
%       oo = log(pll,'t','x','y','z',...)    % init a data log object
%       oo = log(oo,t,x,y,z,...)             % add values to trace log
%
%    Syntactic Sugar: consider that all strings are horizontally concate-
%    nated with comma separation, and all double args are vertically con-
%    catenated (must thus have same number of rows)
%
%       oo = log(pll,'t,x,y,z');
%       oo = log(pll,'t',0:100,'x,y,z',rand(3,101));
%       oo = log(pll,'t',0:100,'x,y,z',rand(m*3,101));
%       oo = log(pll,'t,x,y,z',0:100,rand(m*3,101));
%       oo = log(pll,'t,x,y,z',0:100,rand(m*3,101));
%
%       oo = log(pll,'t[s],x[µ]:r#1,y[µ]#2,th[m°]@g',rand(1+m*3,n));
%
%    Type setting and unpacking plot relevant options is performed
%    if the log object is derived from a shell object:
%
%       o = pull(pll);
%       oo = log(type(o,'mytype'),'t,x:r,y:b',1:100,sin(1:100),cos(1:100))
%
%    Example:
%
%       oo = log(o,'t','u','y');       % create empty data log object
%       T = 0.1;  a = 0.9;  y = 0;
%       for k = 0:100
%          t = k*T;                    % time stamp
%          u = randn;                  % some signal
%          y = a*y + (1-a)*u;          % filtered signal
%          oo = log(oo,t,u,y);         % add values to data log object
%       end
%       [t,u,y] = log(o)               % retrieve recorded data
%
%    See also: CORASIM, PLOT
%
