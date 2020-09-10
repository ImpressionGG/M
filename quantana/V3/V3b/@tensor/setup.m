function out = setup(obj,name,value)
%
% SETUP      Setup specials for a Hilbert space, e.g. special 
%            vectors like superposition states or entangeled 
%            states
%
%               S = space(tensor,{'a','b','c'});
%
%            1) Setup specific vectors
%
%               V = normalize(S('a')+S('b'));
%               S = setup(S,'v',V);
%
%            Now vector can be referenced symbolically
%
%               V = vector(S,'v');      % vector referenced by symbol
%               V = S('v');             % vector referenced by symbol
%               P = projector(S,'v');   % vector referenced by symbol
%

%            See also: TENSOR, SPACE, VECTOR, PROJECTOR
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
   
% otherwise setup specific vectors

   if ~property(obj,'space')
      error('space object expected!');
   end
   
   if ~ischar(name)
      name
      error('string expected for name (arg2)');
   end
   
   if ~property(value,'vector')
      error('vector object (''#VECTOR'') expected for value (arg3)!');
   end
   
   M = matrix(value);
   
   [m,n] = dim(obj);
   if ~(all(size(M) == [m,n]))
      error(sprintf('bad dimensions for value (arg2)'));
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
