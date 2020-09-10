function out = subsref(obj,args)
% 
% SUBSREF  Indexing method
%
%
%          1) Display labels
%
%             H = space(toy,magic(3));
%             H(:)                         % display labels
%
%          2) Retrieve special vectors
%
%             H = space(toy,{'a','b','c'})
%             H = setup(H,'w',normalize(S('a')+S('b')))
%             Va = H('a');
%             Vb = H('b');
%             W  = H('w');
%             V1 = H(1);
%
%          3) Indexing a projector of a split
%
%             H = space(toy,{'a','b','c'})
%             S = split(H,{'a',{'b','c'}});
%             P = S('a');       % fetch projector labeled by 'a'
%             P = S('[a]');     % same as above
%             P = S('b,c');     % fetch projector labeled by 'b,c'
%             P = S('[b,c]');   % same as above
%
%          4) Creating a split from a space or operator
%
%             H = space(toy,{'a','b','c'});
%             T = operator(H,'>>');
%             S = H({'a',{'b','c'}});
%             S = T({'a',{'b','c'}});
%          
%          4) Indexing a split of a universe
%
%             H = space(toy,1:8);
%             S = split(H,labels(H));
%             T = operator(H,'>>');
%             U = T*S^5;
%
%             T  = U(0);    % get transition operator
%             S1 = U(1);    % 1st split
%             S2 = U(2)     % 2nd split
%
%    See also: TOY
%
   subs = args.subs;
   
   switch args.type
      case '()'
         arg = subs{1};
         if iscell(arg)
            
            switch type(obj)
               case '#SPACE'
                   out = split(obj,arg);
               case '#OPERATOR'
                   out = split(space(obj),arg);
            end
            return
            
         elseif (ischar(arg) || isa(arg,'double'))
            switch arg
               case ':'
                  DisplayLabels(obj);
                  return
                  
               otherwise
                  switch type(obj)
                     case '#SPACE'
                        out = VectorBySymbol(obj,arg);
                        if isempty(out)
                           error(['unsupported label for indexing: ',arg]);
                        end

                     case '#SPLIT'
                        list = property(obj,'list');
                        labs = labels(obj);
                        
                        if isa(arg,'double')
                           if (arg < 1 || arg > length(list(:)))
                              error('index out of range!');
                           end
                           out = list{arg};
                        elseif ischar(arg)
                           idx = match(['[',arg,']'],labs(:));
                           if isempty(idx)
                              idx = match(arg,labs(:));
                           end
                           if isempty(idx)
                              error( ['unsupported symbolic index:',arg]);
                           end
                           out = list{idx};
                        else
                           error('bug!');
                        end
                        
                     case '#UNIVERSE'
                        if ~isa(arg,'double')
                           error('double index (arg2) expected!');
                        end
                        out = universe(obj,arg);

                     case '#HISTORY'
                        if ~isa(arg,'double')
                           error('double index (arg2) expected!');
                        end
                        if (arg == 0)
                           out = history(obj,arg);
                        else
                           out = projector(obj,arg);
                        end
                        
                     otherwise
                        error(['unsupported type: ',type(obj)]);
                  end
            end
            return
         end
      otherwise
         error(['indexing type not supported: ',type]);
   end
   
   error('reference by () not implemented!');
   return
end

%==========================================================================
% Display Labels
%==========================================================================

function DisplayLabels(obj)
%
% DISPLAY-LABELS  Display indexing labels for a Hilbert space
%
   labels = property(obj,'labels');
   if (nargout == 0)
      fprintf('\n');
      disp(labels)
   else
      out = labels;
   end
   return
end

%==========================================================================
% Get Vector by Symbol
%==========================================================================

function V = VectorBySymbol(obj,sym)
%
% VECTOR-BY-SYMBOL    Get vector by symbol. Return empty matrix if
%                     not successful
%
   try
      V = vector(obj,sym);
   catch
      V = [];
   end
   return
end
