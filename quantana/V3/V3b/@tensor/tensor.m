function out = tensor(varargin)
% 
% TENSOR   Construct a tensor object.
%
%          1) Construct an empty generic tensor
%
%             T = tensor                      % generic empty tensor
%             T = tensor('#SPACE')            % generic '#SPACE'
%             T = tensor('#PROJECTOR')        % generic '#PROJECTOR'
%             T = tensor('#VECTOR')           % generic '#VECTOR'
%             T = tensor('#OPERATOR')         % generic '#OPERATOR'
%             T = tensor('#SPLIT')            % generic '#SPLIT'
%
%             T = tensor('#SPACE',par,dat)    % generic '#SPACE'
%             T = tensor('#VECTOR',par,dat)   % generic '#VECTOR'
%
%          Short hands:
%
%             H = tensor(1:5)                 % create 5-dim Hilbert space
%             H = tensor({'a','b','c'})       % create 3-dim Hilbert space
%
%             O = tensor(1:5,'>>')            % create shift operator
%             O = tensor({'a','b','c'},0)     % create null operator
%             O = tensor({'-1','0','1'},1)    % create identity operator
%
%          Methods
%             basis         retrieve basis or basis vector
%             born          Born rule
%             cast          cast operator type
%             chain         chain operator
%             com           operators commuting?
%             eq            tensor equality
%             eye           identity operator
%             family        support of a consistent family of histories
%             display       display short form
%             history       define history or history space
%             info          get tensor info
%             labels        get or set tensor labels
%             matrix        retrieve tensor matrix
%             minus         minus operator
%             mtimes        normal product of operators
%             mpower        power operator
%             norm          norm of a tensor object
%             normalize     normalize a vector
%             plus          plus operator
%             probability   probability demo menu
%             projector     construct a (hermitian) projector
%             setup         setup specials for Hilbert space
%             space         construct a hilbert space
%             symbols       get symbol list
%             tensor        constructor
%             times         tensor product of operators
%             toy           toy model demo menu
%             transition    symbolic transition chain
%             uminus        unary minus operation
%             uplus         unary plus operation
%             vector        vector object
%
%          See also QUANTANA, PROBABILITY, TOY
%

% Start with short hand functions: the following syntax enjoys special
% treatment
%
%    H = tensor(1:5)                 % create 5-dim Hilbert space
%    H = tensor({'a','b','c'})       % create 3-dim Hilbert space
%    O = tensor(1:5,'>>')            % create shift operator
%    O = tensor({'a','b','c'},0)     % create null operator
%    O = tensor({'-1','0','1'},1)    % create identity operator

   v = varargin;
   if (nargin == 1)
      if isa(v{1},'double') || isa(v{1},'cell')
         out = space(tensor,v{1});
         return
      end
   elseif (nargin == 2)
      if (isa(v{1},'double') || isa(v{1},'cell')) && ...
          (ischar(v{2}) || isa(v{2},'double'))
         H = space(tensor,v{1});
         out = operator(H,v{2});
         return
      end
   end
         
% All syntax check has been done. From here no more short hand treatment

   fmt = '#???'; par = [];  dat = [];
   
   ilist = varargin;
   n = length(ilist);
   
   done = 0;
   
% First case: empty varargin list

   if (~done && n==0)
      fmt = '#GENERIC';
      done = 1;      % everything already done
   end

% Second case: one argument and this argument is a string
% This generates a generic tensor with specified format
   
   if (~done && n <= 3)
      fmt = ilist{1};
      if (n >= 2) 
         par = ilist{2};
      end
      if (n >= 3)
         dat = ilist{3};
      end
      
      if ischar(fmt)
         switch fmt
            case '#SPACE'
               if (n < 3)
                  dat.space.list = {};      % list of Hilbert spaces 
                  dat.space.size = [0 0];
                  dat.space.basis = [];
                  dat.space.labels = [];
                  dat.space.spec = [];
               end
               done = 1;
               
            case '#PROJECTOR'
               if (n < 3)
                  dat.proj.type = '???';
                  dat.proj.index = [];
               end
               done = 1;

            case '#VECTOR'
               if (n < 3)
                  dat.vector.bra = 0;     % no bra vector
                  dat.vector.matrix = [];   
               end
               done = 1;
               
            case '#OPERATOR'
               if (n < 3)
                  dat.oper.matrix = [];   
               end
               done = 1;

            case '#SPLIT'
               if (n < 3)
                  dat.split.list = {};   
               end
               done = 1;

            case '#UNIVERSE'
               if (n < 3)
                  dat.uni.list = {};   
               end
               done = 1;

            case '#HISTORY'
               if (n < 3)
                  dat.history.bra = 0;
                  dat.history.list = {};   
               end
               done = 1;
               
            otherwise
               fmt = '???';  dat = [];  par = [];
         end
      end
   end
   
% Third case: one argument and this argument is a list
% This generates a tensor space
   
   if (~done && n >= 1)
      list = ilist{1};
      if iscell(list)
         list = list(:);
         for (i=1:length(list))
            dat.size(i,1:2) = size(list{i});
         end
         
         if (n == 1)
            fmt = '#SPACE';
            done = 1;
         elseif (n == size(dat.size,1)+1)
            fmt = '#LIST';
            nlist = {};         % new ilist
            for (i=1:n-1)
               sz = dat.size(i,:);               
               V = zeros(sz);
               idx = ilist{i+1};
               V(idx) = 1;
               nlist{i} = V;
            end
            ilist = nlist;   % overwrite arg list with new args
         else
            error('number of indices (arg2,arg3,...) does not match dimension of tensor space (arg1)!');            
         end
      end
   end
   
% Fourth case: one argument but argument is not a list
% This generates an empty tensor with specified dimensions
         
   if (~done)
      n = length(ilist);   % length of ilist could have changed
      for (i=1:n)
         v = ilist{i};
         if (~isa(v,'double'))
            error('arguments must be double vectors!')
         end
         dat.size(i,1:2) = size(v);
         dat.matrix = v;
      end
      dat.list = ilist;
      %dat.matrix = matrix(ilist);
   end

% Finally we have to create the tensor object
      
   [obj,she] = derive(quantana(fmt,par,dat),mfilename);
   obj = class(obj,obj.tag,she);     
   
      % assert integrity of tensor object
      
   assert(obj);
   
      % Finish
      
   if (nargout==0)
      demo(obj);
   else
      out = obj;
   end
   return           
end
