function out = bion(qob1,qob2,arg3,arg4,type)
% 
% BION     Bi-Quon Object
%          Create a bi-quon object as a derived QUANTANA object.
%
%             bob = bion;                  % quick & dirty constructor, using defaults
%             bob = bion(qob1,qob2,M);     % construct by mode matrix
%             bob = bion(qob1,qob2,i,j);   % construct by mode indices
%
%          M is the mode matrix. Based on the properties of the mode
%          Matrix the bion has the type:
%
%             boson:             symmetric M (M = M')
%             fermion:           antisymmetric M (M = -M')
%             general:           general M (distinguishable particles)
%
%          Examples:
%
%             eob = envi(quantana,'box');   % particles in a box
%             qob1 = quon(eob);
%             qob2 = quon(eob);
%
%             bob = bion(qob1,qob2,[1 0 0; 0 1 0; 0 0 1]);    % boson 
%             bob = bion(qob1,qob2,[0 1 0; -1 0 1; 0 -1 0]);  % fermion 
%             bob = bion(qob1,qob2,[1 1 0; 1 1 0; 0 0 0]);    % general 
%
%          See also QUANTANA, BION, ENVI
%   
   if (nargin == 0)
      eob = envi(quantana,'box');   % particles in a box
      qob1 = quon(eob);  qob2 = qob1;
      M = [0 1 0; -1 0 1; 0 -1 0];  % fermion
   end

   if (nargin< 5)
      type = 0;
   end
   
   if (~isa(qob1,'quon') | ~isa(qob2,'quon'))
      error('quon objects expected for arg1 & arg2');
   end

   
   if (nargin == 3)
      M = arg3;
      [m,n] = size(M);
      if (m ~= n)
         error('quadratic mode matrix expected! (arg3)!');
      end
   elseif (nargin >= 4)
      i = arg3;  j = arg4;
      if (length(i) ~= length(j))
         error('arg3 and arg4 must have same lengths!');
      end
      m = max([i(:);j(:)]);  n = m;  M = zeros(m,n);
      for (k=1:length(i))
         M(i(k),j(k)) = 1;
      end
      M = M + type * M';
   else
      error('0,3 or 4 args expected!');
   end

   if (all(M == M'))
      kind = 'boson';
   elseif (all(M == -M'))
      kind = 'fermion';
   else
      kind = 'dist';
   end
   
      % set argument defaults

   fmt = '';  dat.kind = kind;  par = [];
   
   za = zspace(qob1);  zb = zspace(qob2);
   
   psi = 0;
   for (i = 1:m)
      for (j = 1:n)
         [psiai,Eai] = eig(qob1,i);
         [psibj,Eaj] = eig(qob2,j);
         psi_ij = psiai * conj(psibj');
         basis{i,j} = psi_ij;
         psi = psi + M(i,j) * psi_ij;
         energy(i,j) = Eai + Eaj;
      end
   end
   
   
   hbar1 = data(qob1,'hbar');     % reduced Planck constant
   hbar2 = data(qob2,'hbar');     % reduced Planck constant

   if (hbar1 ~= hbar2)
      error('Planck constant mismatch!');
   end
   
   dat.qob1 = qob1;
   dat.qob2 = qob2;
   
   dat.hbar = hbar1;
   dat.m1 = data(qob1,'m');       % mass of particles
   dat.m2 = data(qob2,'m');       % mass of particles
   
   dat.xspace = zspace(qob1);  
   dat.yspace = zspace(qob2);  
   
   dat.psi = psi;         % actual psi function
   dat.energy = energy;   % energy values 
   dat.basis = basis;     % eigen function basis 
   dat.eco = M;           % actual expansion coefficients
   
      % object creation
      
   [obj,she] = derive(quantana(fmt,par,dat),mfilename);
   obj = class(obj,obj.tag,she);     

      % Finish
      
   obj = set(obj,'title',kind);
   
   if (nargout==0)
      %demo(obj);
   else
      out = obj;
   end
   return           
   
% eof   