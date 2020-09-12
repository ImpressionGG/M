function o = base(o,number)            % Set Basis of CORINTH Object   
%
% BASE    Set basis of a rational object. Also transfer verbose control
%         option to global verbose control variable 
%
%            o = base(corinth);        % set default basis 1e6
%
%            o = base(corinth,10);     % set basis 10          
%            o = base(corinth,1000);   % set basis 1000          
%            o = base(corinth,1e6);    % set basis 1e6          
%
%         Remark: the following statement sets up verbose level 3 for all
%         corinthian methods:
%
%            o = base(opt(o,'control.verbose',3),1e6)
%
%         Alternatiely we can transfer verbose setting from any shell
%
%            o = base(inherit(corinth,sho),1e6)
%
%         To convert shell object into a base object
%         See also: CORINTH, TRIM, NEW
%
   global CorinthVerbose
   CorinthVerbose = opt(o,{'control.verbose',0});

   if (nargin < 2)
      if container(o)
         number = get(o,{'base',1e6});
         o.type = 'number';
         
         o.data = [];                  % clear container list
         o.data.expo = 0;
         o.data.num = 0;
         o.data.den = 1;         
      elseif isfield(o.data,'base')
         number = o.data.base;
      else
         number = 1e6;
      end
   end
   
   o.data.base = number;
end
