function oo = new(o,varargin)          % CORATIO New Method              
%
% NEW   New CORINTH object
%
%           oo = new(o,'Menu')         % menu setup
%
%           o = new(corinth,'Base10')    % some base 10 ratio 
%           o = new(corinth,'Base100')   % some base 100 ratio
%           o = new(corinth,'Pi')        % pi as a base 1e6 ratio
%
%       See also: CORINTH, TRIM, ADD, SUB, MUL, DIV, COMP
%
   [gamma,oo] = manage(o,varargin,@Base10,@Base100,@Pi,@Menu);
   oo = gamma(oo);
end

%==========================================================================
% Menu Setup
%==========================================================================

function oo = Menu(o)                  % Setup Menu
   oo = mitem(o,'Base 10 Ratio',{@Callback,'Base10'},[]);
   oo = mitem(o,'Base 100 Ratio',{@Callback,'Base100'},[]);
   oo = mitem(o,'Pi @ Base 1e6 Ratio',{@Callback,'Pi'},[]);
end
function oo = Callback(o)
   mode = arg(o,1);
   oo = new(o,mode);
   paste(o,oo);                        % paste object into shell
end

%==========================================================================
% New Objects
%==========================================================================

function o = Base10(o)                 % New Base 10 Ratio             
   o = base(corinth,10);
   o.data.num = [7 3 8 5];             % numerator
   o.data.den = [8 9];                 % denominator
end
function o = Base100(o)                % New Base 100 Ratio             
   o = base(corinth,100);
   o.data.num = [41 32 76 78];         % numerator
   o.data.den = [58 67];               % denominator
end
function o = Pi(o)                     % Pi As Base 1e6 Ratio             
   o = corinth(pi);
end

