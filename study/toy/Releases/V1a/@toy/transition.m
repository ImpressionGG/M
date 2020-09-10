function [out,chain] = transition(op,vec,n)
%
% TRANSITION Symbolic transition sequence
%
%               S = space(toy,1:5);
%               O = operator(S,'>>');
%
%               [V,seq] = transition(O,S(1),2);
%
%                  => V = |3>                    % state of last transition
%                  => seq = '|1> -> |2> -> |3>'  % 2 transitions
%
%               seq = transition(O,S(1),1);
%               seq = transition(O,S(1));       % same as above
%
%                  => seq = '|1> -> |2>'
%
%               transition(O,S(1))   % display transition sequence
%
%            Instead of the vector the vector index or symbol might be used
%
%               seq = transition(O,S(1),n);
%               seq = transition(O,1,n);    % same as above (numeric idx)
%
%               seq = transition(O,S('3'),n);
%               seq = transition(O,'3',n);  % same as above (symbolic idx)
%
%            See also: TOY, OPERATOR, VECTOR, CHAIN
%
   if (nargin < 3)
      n = 1;
   end

   if ~property(op,'operator?')
      error('operator expected for arg1!');
   end

% convert numeric index or label to vector

   if ischar(vec) || isa(vec,'double')
      H = space(op);
      arg = vec;               % index or label, to address vector in space
      vec = vector(H,arg);
   end
   
   if ~property(vec,'vector?')
      error('vector expected for arg2!');
   end
   
   [mo,no] = size(labels(op));
   [mv,nv] = size(labels(vec));
   
   if any([mo,no] ~= [mv,nv])
      error('operator (arg1) and vector (arg2) not compatible!');
   end
   
   chain = info(vec);
   
   for (i=1:n)
      vec = op*vec;
      chain = [chain,' -> ',info(vec)];
   end
   
   if nargout >= 1
      out = vec;
   else
      disp(['   ',chain]);
   end
   return
end
