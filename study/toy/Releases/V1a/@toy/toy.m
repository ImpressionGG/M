function out = toy(varargin)
% 
% TOY   Construct a TOY object.
%
%    1) Construct an empty generic TOY object
%
%       T = toy                      % generic empty toy
%       toy                          % opens the TOY demo menu
%
%       T = type(toy,'#SPACE')       % generic '#SPACE'
%       T = type(toy,'#PROJECTOR')   % generic '#PROJECTOR'
%       T = type(toy,'#VECTOR')      % generic '#VECTOR'
%       T = type(toy,'#OPERATOR')    % generic '#OPERATOR'
%       T = type(toy,'#SPLIT')       % generic '#SPLIT'
%
%    2) Construct a TOY object with parameters and data
%
%       T = toy('#SPACE',par,dat)    % generic '#SPACE'
%       T = toy('#VECTOR',par,dat)   % generic '#VECTOR'
%
%    3) Special Toys are created by providing 1 or 2 input args. These
%       calls are delegate to method space (see also: SPACE)
%
%       H = toy('spin');             % create 2D spin space
%       H = toy('alpha');            % create alpha decay toy model
%
%       H = toy(1:5)                 % create 5-dim Hilbert space
%       H = toy({'a','b','c'})       % create 3-dim Hilbert space
%
%       O = toy(1:5,'>>')            % create shift operator
%       O = toy({'a','b','c'},0)     % create null operator
%       O = toy({'-1','0','1'},1)    % create identity operator
%
%    Methods
%       basis         retrieve basis or basis vector
%       born          Born rule
%       cast          cast operator type
%       chain         chain operator
%       com           operators commuting?
%       eq            toy equality
%       eye           identity operator
%       family        support of a consistent family of histories
%       display       display short form
%       history       define history or history space
%       info          get toy info
%       invoke        overloaded invoke method to invoke a callback
%       labels        get or set toy labels
%       matrix        retrieve toy matrix
%       minus         minus operator
%       mtimes        normal product of operators
%       mpower        power operator
%       norm          norm of a toy object
%       normalize     normalize a vector
%       plus          plus operator
%       probability   probability demo menu
%       projector     construct a (hermitian) projector
%       setup         setup specials for Hilbert space
%       space         construct a hilbert space
%       symbols       get symbol list
%       toy           constructor
%       times         toy product of operators
%       title         menu item dependent title setting
%       toy           toy model demo menu
%       transition    symbolic transition chain
%       uminus        unary minus operation
%       unit          normalize vector to unit length
%       uplus         unary plus operation
%       vector        vector object
% 
%    See also CORE, SPACE, DISP, DISPLAY, GET, SET
%

% Start with special toy creation (1 or 2 input args)

   if (nargin == 1)
      arg = varargin{1};
      
      hashkey = 0;
      if ischar(arg)
         arg = [arg,'#'];               % need to make arg(1) sure!
         hashkey = (arg(1) == '#');     % '#SPACE','#VECTOR',...
      end
      
      if (~hashkey)                     % exclude '#SPACE','#VECTOR',...
         out = space(toy,varargin{1});
         return
      end
   elseif (nargin == 2)
      H = space(toy,varargin{1});
      out = operator(H,varargin{2});
      return
   end
         
% All syntax check has been done. From here no more short hand treatment

   typ = '#???'; par = [];  dat = [];
   
   ilist = varargin;
   n = length(ilist);
   
   done = 0;
   
% First case: empty varargin list

   if (~done && n==0)
      typ = '#GENERIC';
      done = 1;      % everything already done
   end

% Second case: one argument and this argument is a string
% This generates a generic toy with specified type
   
   if (~done && n <= 3)
      typ = ilist{1};
      if (n >= 2) 
         par = ilist{2};
      end
      if (n >= 3)
         dat = ilist{3};
      end
      
      if ischar(typ)
         switch typ
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
               typ = '???';  dat = [];  par = [];
         end
      end
   end
   
% Third case: one argument and this argument is a list
% This generates a toy space
   
   if (~done && n >= 1)
      error('do not like to come here!');
      
      list = ilist{1};
      if iscell(list)
         list = list(:);
         for (i=1:length(list))
            dat.size(i,1:2) = size(list{i});
         end
         
         if (n == 1)
            typ = '#SPACE';
            done = 1;
         elseif (n == size(dat.size,1)+1)
            typ = '#LIST';
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
            error('number of indices (arg2,arg3,...) does not match dimension of toy space (arg1)!');            
         end
      end
   end
   
% Fourth case: one argument but argument is not a list
% This generates an empty toy with specified dimensions
         
   if (~done)
      error('do not like to come here!');
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

% Finally we have to create the toy object
      
   [obj,cob] = derive(core(typ,par,dat),mfilename);
   obj = class(obj,obj.tag,cob);     
   
      % assert integrity of toy object
      
   assert(obj);
   
      % Finish
      
   if (nargout==0)
      demo(obj);
   else
      out = obj;
   end
   return           
end
