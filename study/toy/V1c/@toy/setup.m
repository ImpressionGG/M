function out = setup(obj,name,value)
%
% SETUP      Setup specials for a Hilbert space, e.g. special 
%            vectors like superposition states or entangeled 
%            states
%
%               H = space(toy,{'a','b','c'});
%
%            A) Three input args: setup specific vectors
%
%               V = unit(H('a')+H('b'));
%               H = setup(H,'v',V);
%
%            Now vector can be referenced symbolically
%
%               V = vector(H,'v');      % vector referenced by symbol
%               V = H('v');             % vector referenced by symbol
%               P = projector(H,'v');   % vector referenced by symbol
%
%            B) One input arg: retrieve setup list
%
%               list = setup(H);
%
%            C) Two input args: setup various kinds of toys
%
%               H = setup(toy,'spin');        % 2D spin space
%               H = setup(toy,'twin');        % 2 entangled spins
%               H = setup(toy,'triple');      % 3 entangled spins
%
%               H = setup(toy,'coin');        % quantum coin space
%               H = setup(toy,'die');         % quantum die space
%               H = setup(toy,'game');        % quantum game space
%                                             % composite coin°die space
%
%               H = setup(toy,'alpha');       % alpha decay toy model
%               H = setup(toy,'detector');    % simple detector toy model
%
%            See also: TOY, SPACE, VECTOR, PROJECTOR
%
   if (nargin == 1)
      spec = data(obj,'space.spec');
      if (nargout == 0)
         if isempty(spec)
            fprintf('\n   []\n\n');
         else
            disp(spec);
         end
      else
         out = spec;
      end
      return
   end
   
% For two input args create a quantum toy

   if (nargin == 2)
      out = QuantumToy(obj,name);
      return
   end
   
% otherwise setup specific vectors or operators

   if (nargin ~= 3)
      error('1, 2 or 3 input args expected!');
   end

   if ~property(obj,'space?')
      error('space object expected!');
   end
   
   if ~ischar(name)
      name
      error('string expected for name (arg2)');
   end
   
   if property(value,'vector?')
      M = matrix(value);

      [m,n] = dim(obj);
      if ~(all(size(M) == [m,n]))
         error(sprintf('bad dimensions for value (arg2)'));
      end
   elseif property(value,'operator?')
      M = matrix(value);

      n = dim(obj);
      if ~(all(size(M) == [n,n]))
         error(sprintf('bad dimensions for value (arg2)'));
      end
      M = {M}; % need to pack matrix into a cell (distinguish from vector)
   else
      error('vector object (''#VECTOR'') expected for value (arg3)!');
   end

   spec = either(data(obj,'space.spec'),{});
   
% check if entry already exists

   found = 0;                      % by default
   for (i=1:length(spec))
      pair = spec{i};
      if strcmp(pair{1},name)
         pair{2} = M;              % update value
         spec{i} = pair;
         found = 1;
         break;
      end
   end
   
   if ~found
      spec{end+1} = {name,M};       % add an entry
   end
   
   out = data(obj,'space.spec',spec);
   return
end

%==========================================================================
% Create quantum toys, like pre-configured spaces & configurations
%==========================================================================

function H = QuantumToy(obj,arg)
%
% QUANTUM-TOY   Create special kinds of quantum toys
%
%    Syntax
%
%       H = QuantumToy(obj,'spin')        % spin space
%
   assert(ischar(arg));
   switch arg
      case 'spin'                         % create a spin space
         H = space(toy,{'u';'d'});
         H = setup(H,'r',[ket(H,'u')+ket(H,'d')]/sqrt(2));
         H = setup(H,'l',[ket(H,'u')-ket(H,'d')]/sqrt(2));
         H = setup(H,'i',[ket(H,'u')+sqrt(-1)*ket(H,'d')]/sqrt(2));
         H = setup(H,'o',[ket(H,'u')-sqrt(-1)*ket(H,'d')]/sqrt(2));
         
         [u,d,l,r,i,o] = vector(H,'u','d','l','r','i','o');
         
         H = setup(H,'Sz',u*u'-d*d');
         H = setup(H,'Sx',r*r'-l*l');
         H = setup(H,'Sy',i*i'-o*o');

      case 'coin'
         H = space(toy,{'H';'T'});
         [h,t] = vector(H,'H','T');
         
      case 'die'
         H = space(toy,1:6);

      case 'game'
         H1 = space(toy,'coin');
         H2 = space(toy,'die');
         H = H1.*H2;                      % composite coin°die space
         
      case 'detector'                     % create simple detector space
         D = space(toy,[0;1]);            % detector space
         L = space(toy,-1:5);             % location space
         H = space(L,D);                  % tensor product space H = L°D
         
            % define a forward shift operator on L
         
         SL = operator(L,'>>');           % forward shift operator on L
         S = SL.*eye(D);                  % forward shift operator on LD
         
            % define a detector toggle operator on L
         
         R = eye(H);                      % start with identity matrix
         R = matrix(R,{'2°0','2°0'},0);   % no transition 2°0 -> 2°0
         R = matrix(R,{'2°1','2°1'},0);   % no transition 2°1 -> 2°1
         R = matrix(R,{'2°1','2°0'},1);   % transition 2°0 -> 2°1
         R = matrix(R,{'2°0','2°1'},1);   % transition 2°1 -> 2°0

            % Total Transition Chain
         
         T = S*R;                         % total transition operator
         
         s0 = ket(L,'-1') .* ket(D,'0');  % initial state
         s1 = transition(T,s0,7);         % transition chain');

         H = setup(H,'s0',s0);            % initial state for detector = 0
         H = setup(H,'s1',s1);            % initial state for detector = 1
         H = setup(H,'R',R);              % detector transition operator
         H = setup(H,'S',S);              % shift operator for location
         H = setup(H,'T',T);              % total transition operator
         
         %transition(T,s0,7)
         %transition(T,s1,7)              %% transition chain');
         
            % setup position coordinates
            
         x = -3:3;
         H = set(H,'position.L',[x;0*x;0*x]);
         H = set(H,'position.D',[0 0; 1 2; 0 0]);
         
      case {'twin2121','twin'}            % entangeled spins
         Hs = space(toy,'spin');          % spin space A (column)
         H = SetupTwin(Hs,Hs);

      case {'twin2112'}                   % entangeled spins
         Hs = space(toy,'spin');          % spin space A (column)
         H = SetupTwin(Hs,Hs');

      case {'twin1221'}                   % entangeled spins
         Hs = space(toy,'spin');          % spin space A (column)
         H = SetupTwin(Hs',Hs);

      case {'twin1212'}                   % entangeled spins
         Hs = space(toy,'spin');          % spin space A (column)
         H = SetupTwin(Hs',Hs');

            % triple space
            
      case {'triple212121','triple'}      % entangeled spins
         Hs = space(toy,'spin');          % spin space A (column)
         H = SetupTriple(Hs,Hs,Hs);

      case {'triple212112'}               % entangeled spins
         Hs = space(toy,'spin');          % spin space A (column)
         H = SetupTriple(Hs,Hs,Hs');
         
      case {'triple211221'}               % entangeled spins
         Hs = space(toy,'spin');          % spin space A (column)
         H = SetupTriple(Hs,Hs',Hs);

      case {'triple211212'}               % entangeled spins
         Hs = space(toy,'spin');          % spin space A (column)
         H = SetupTriple(Hs,Hs',Hs');

         
      case {'triple122121'}               % entangeled spins
         Hs = space(toy,'spin');          % spin space A (column)
         H = SetupTriple(Hs',Hs,Hs);

      case {'triple122112'}               % entangeled spins
         Hs = space(toy,'spin');          % spin space A (column)
         H = SetupTriple(Hs',Hs,Hs');
         
      case {'triple121221'}               % entangeled spins
         Hs = space(toy,'spin');          % spin space A (column)
         H = SetupTriple(Hs',Hs',Hs);

      case {'triple121212'}               % entangeled spins
         Hs = space(toy,'spin');          % spin space A (column)
         H = SetupTriple(Hs',Hs',Hs');

      otherwise
         error(['bad name for quantum toy: ''',arg,'''!']);
   end
   return
end

%==========================================================================
% Setup Twin Space
%==========================================================================

function H = SetupTwin(Ha,Hb)
%
% SETUP-TWIN  Setup a twin tensor product space based on two spin
%             spaces Ha and Hb.
%
   H = Ha.*Hb;                  % tensor product space

      % setting up up-down basis

   [ua,da] = ket(Ha,'u','d');
   [ub,db] = ket(Hb,'u','d');

   uu = ua.*ub;
   ud = ua.*db;
   du = da.*ub;
   dd = da.*db;

   H = setup(H,'uu',uu);            % basis state |u°u>
   H = setup(H,'ud',ud);            % basis state |u°d>
   H = setup(H,'du',du);            % basis state |d°u>
   H = setup(H,'dd',dd);            % basis state |d°d>

   sing = unit(ud-du);              % singlet state
   trip1 = unit(ud+du);             % 1st triplet state
   trip2 = unit(uu+dd);             % 2nd triplet state
   trip3 = unit(uu-dd);             % 3rd triplet state

   H = setup(H,'sing',sing);        % singlet state
   H = setup(H,'trip1',trip1);      % 1st triplet state
   H = setup(H,'trip2',trip2);      % 2nd triplet state
   H = setup(H,'trip3',trip3);      % 3rd triplet state

      % setting up right-left basis

   [ra,la] = ket(Ha,'r','l');
   [rb,lb] = ket(Hb,'r','l');

   rr = ra.*rb;
   rl = ra.*lb;
   lr = la.*rb;
   ll = la.*lb;

   H = setup(H,'rr',rr);            % basis state |r°r>
   H = setup(H,'rl',rl);            % basis state |r°l>
   H = setup(H,'lr',lr);            % basis state |l°r>
   H = setup(H,'ll',ll);            % basis state |l°l>

      % setting up in-out basis

   [ia,oa] = ket(Ha,'i','o');
   [ib,ob] = ket(Hb,'i','o');

   ii = ia.*ib;
   io = ia.*ob;
   oi = oa.*ib;
   oo = oa.*ob;

   H = setup(H,'ii',ii);            % basis state |i°i>
   H = setup(H,'io',io);            % basis state |i°o>
   H = setup(H,'oi',oi);            % basis state |o°i>
   H = setup(H,'oo',oo);            % basis state |o°o>

      % operator setup

   [Sax,Say,Saz] = operator(Ha,'Sx','Sy','Sz');
   [Sbx,Sby,Sbz] = operator(Hb,'Sx','Sy','Sz');

   Ax = Sax.*eye(Hb);
   Ay = Say.*eye(Hb);
   Az = Saz.*eye(Hb);

   Bx = eye(Ha).*Sbx;
   By = eye(Ha).*Sby;
   Bz = eye(Ha).*Sbz;

   H = setup(H,'Ax',Ax);            % compound spin operator Ax
   H = setup(H,'Ay',Ay);            % compound spin operator Ay
   H = setup(H,'Az',Az);            % compound spin operator Az

   H = setup(H,'Bx',Bx);            % compound spin operator Bx
   H = setup(H,'By',By);            % compound spin operator By
   H = setup(H,'Bz',Bz);            % compound spin operator Bz
         
   return
end

%==========================================================================
% Setup Triple Space
%==========================================================================

function H = SetupTriple(Ha,Hb,Hc)
%
% SETUP-TRIPLE  Setup a twin tensor product space based on two spin
%                spaces Ha, Hb and Hc.
%
   H = Ha.*Hb.*Hc;                % tensor product space

      % setting up up-down basis

   [ua,da] = ket(Ha,'u','d');
   [ub,db] = ket(Hb,'u','d');
   [uc,dc] = ket(Hc,'u','d');

   uuu = ua.*ub.*uc;
   uud = ua.*ub.*dc;
   udu = ua.*db.*uc;
   udd = ua.*db.*dc;
   duu = da.*ub.*uc;
   dud = da.*ub.*dc;
   ddu = da.*db.*uc;
   ddd = da.*db.*dc;

   H = setup(H,'uuu',uuu);          % basis state |u°u°u>
   H = setup(H,'uud',uud);          % basis state |u°u°d>
   H = setup(H,'udu',udu);          % basis state |u°d°u>
   H = setup(H,'udd',udd);          % basis state |u°d°d>
   H = setup(H,'duu',duu);          % basis state |d°u°u>
   H = setup(H,'dud',dud);          % basis state |d°u°d>
   H = setup(H,'ddu',ddu);          % basis state |d°d°u>
   H = setup(H,'ddd',ddd);          % basis state |d°d°d>

      % setting up right-left basis

   [ra,la] = ket(Ha,'r','l');
   [rb,lb] = ket(Hb,'r','l');
   [rc,lc] = ket(Hc,'r','l');

   rrr = ra.*rb.*rc;
   rrl = ra.*rb.*lc;
   rlr = ra.*lb.*rc;
   rll = ra.*lb.*lc;
   lrr = la.*rb.*rc;
   lrl = la.*rb.*lc;
   llr = la.*lb.*rc;
   lll = la.*lb.*lc;

   H = setup(H,'rrr',rrr);          % basis state |r°r°r>
   H = setup(H,'rrl',rrl);          % basis state |r°r°l>
   H = setup(H,'rlr',rlr);          % basis state |r°l°r>
   H = setup(H,'rll',rll);          % basis state |r°l°l>
   H = setup(H,'lrr',lrr);          % basis state |l°r°r>
   H = setup(H,'lrl',lrl);          % basis state |l°r°l>
   H = setup(H,'llr',llr);          % basis state |l°l°r>
   H = setup(H,'lll',lll);          % basis state |l°l°l>

      % setting up in-out basis

   [ia,oa] = ket(Ha,'i','o');
   [ib,ob] = ket(Hb,'i','o');
   [ic,oc] = ket(Hc,'i','o');

   iii = ia.*ib.*ic;
   iio = ia.*ib.*oc;
   ioi = ia.*ob.*ic;
   ioo = ia.*ob.*oc;
   oii = oa.*ib.*ic;
   oio = oa.*ib.*oc;
   ooi = oa.*ob.*ic;
   ooo = oa.*ob.*oc;

   H = setup(H,'iii',iii);          % basis state |i°i°i>
   H = setup(H,'iio',iio);          % basis state |i°i°o>
   H = setup(H,'ioi',ioi);          % basis state |i°o°i>
   H = setup(H,'ioo',ioo);          % basis state |i°o°o>
   H = setup(H,'oii',oii);          % basis state |o°i°i>
   H = setup(H,'oio',oio);          % basis state |o°i°o>
   H = setup(H,'ooi',ooi);          % basis state |o°o°i>
   H = setup(H,'ooo',ooo);          % basis state |o°o°o>

      % operator setup

   [Sax,Say,Saz] = operator(Ha,'Sx','Sy','Sz');
   [Sbx,Sby,Sbz] = operator(Hb,'Sx','Sy','Sz');
   [Scx,Scy,Scz] = operator(Hc,'Sx','Sy','Sz');

   Ax = Sax.*eye(Hb).*eye(Hc);
   Ay = Say.*eye(Hb).*eye(Hc);
   Az = Saz.*eye(Hb).*eye(Hc);

   Bx = eye(Ha).*Sbx.*eye(Hc);
   By = eye(Ha).*Sby.*eye(Hc);
   Bz = eye(Ha).*Sbz.*eye(Hc);

   Cx = eye(Ha).*eye(Hb).*Scx;
   Cy = eye(Ha).*eye(Hb).*Scy;
   Cz = eye(Ha).*eye(Hb).*Scz;
   
   H = setup(H,'Ax',Ax);            % compound spin operator Ax
   H = setup(H,'Ay',Ay);            % compound spin operator Ay
   H = setup(H,'Az',Az);            % compound spin operator Az

   H = setup(H,'Bx',Bx);            % compound spin operator Bx
   H = setup(H,'By',By);            % compound spin operator By
   H = setup(H,'Bz',Bz);            % compound spin operator Bz
         
   H = setup(H,'Cx',Cx);            % compound spin operator Cx
   H = setup(H,'Cy',Cy);            % compound spin operator Cy
   H = setup(H,'Cz',Cz);            % compound spin operator Cz
         
   return
end