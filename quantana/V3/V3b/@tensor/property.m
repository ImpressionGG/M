function prop = property(obj,propname)
% 
% PROPERTY Get a property of a TENSOR object
%      
%             obj = tensor                   % create TENSOR object
%             p = property(obj,'simple')     % get property value 'simple'
%
%          Supported TENSOR properties:
%
%             bra        indication if vector or history is a bra
%             dimension  dimension of space
%             eye        object representing an identity operator?
%             history    object representing a history?
%             identity   object representing an identity operator?
%             index      index list/vector of basis vectors
%             ket        indication if vector or history is a ket
%             labels     get labels of a Hilbert space
%             list       get list of objects
%             null       object representing a null operator?
%             number     number of projectors of a split or history
%             symbol     get vector or operator symbol
%             symbols    get symbols of a Hilbert space (labels + specs)
%             operator   object representing an operator (incl. projector)?
%             projector  object representing a projector
%             simple     object representing simple space? 
%             size       size argument of tensor space
%             space      object representing a (simple or compound) space?
%             split      object representing a split?
%             transition get transition operator of a universe
%             unitary    unitary operator?
%             universe   object representing a universe?
%             vector     object representing a vector?
%
%          Supported SHELL properties:
%
%             none
%
%          See also STREAMS SHELL/PROPERTY

   general = {'bra','dimension','eye','history','identity','index','ket',...
              'labels','list','null','number',...
              'operator','projector','simple','size',...
              'space','split','symbol','symbols','transition',...
              'vector','unitary','universe'};
   special = {};
      
   switch propname
      case general    % general properties handeled here!
      case special    % special properties be delegated to special handler 
         try
            prop = delegate(obj,propname);
            return
         catch
         end
      otherwise       % not listed properties propagate to SHELL methods
         prop = property(obj.SHELL,propname);
         return
   end

      % any general properties, and specific properties which are
      % catched by the exception handler are processed below

         
   fmt = format(obj);      % format
   prop = [];              % default return value
   
   switch propname
      case 'bra'
         prop = 0;
         switch fmt
            case '#VECTOR'
               prop = either(data(obj,'vector.bra'),0);
            case '#HISTORY'
               prop = either(data(obj,'history.bra'),0);
         end
         
      case 'dimension'
         sz = data(obj,'space.size');
         prop = prod(prod(sz));

      case {'eye','identity'}
         prop = 0;
         if strcmp(fmt,'#OPERATOR')
            prop = property(obj-eye(obj),'null');
         end
         
      case 'history'
         prop = strcmp(fmt,'#HISTORY');
         
      case 'index'
         switch fmt
            case '#PROJECTOR'
               prop = data(obj,'proj.index');
         end
         return
         
      case 'ket'
         prop = 0;
         switch fmt
            case '#VECTOR'
               prop = ~either(data(obj,'vector.bra'),0);
            case '#HISTORY'
               prop = ~either(data(obj,'history.bra'),0);
         end
         
      case 'labels'
         prop = data(obj,'space.labels');

      case 'list'
         switch fmt
            case '#SPLIT'
               prop = data(obj,'split.list');
            case '#UNIVERSE'
               prop = data(obj,'uni.list');
            case '#HISTORY'
               prop = data(obj,'history.list');
         end
         return
         
      case 'null'
         prop =  (norm(matrix(obj)+0) <= 30*eps);

      case 'number'
         switch fmt
            case {'#SPLIT','#UNIVERSE','#HISTORY'}
               list = property(obj,'list');
               prop = prod(size(list));
         end
         
      case 'symbol'
         prop = '';               % by default
         switch fmt
            case '#VECTOR'
               prop = setstr(data(obj,'vector.symbol'));
            case '#OPERATOR'
               prop = setstr(data(obj,'oper.symbol'));
         end
         
      case 'symbols'
         prop = data(obj,'space.labels');
         spec = data(obj,'space.spec');
         for (i=1:length(spec))
            pair = spec{i};
            prop{end+1} = pair{1};
         end

      case 'operator'                          % operator type tensor?
         prop1 = strcmp(fmt,'#PROJECTOR');
         prop2 = strcmp(fmt,'#OPERATOR');
         prop = (prop1 || prop2);

      case 'projector'                         % projector type tensor?
         prop = strcmp(fmt,'#PROJECTOR');
         
      case 'simple'
         fmt = format(obj);
         prop = strcmp(fmt,'#SPACE') && isempty(data(obj,'space.list'));
         
      case 'size'
         prop = data(obj,'space.size');
         
      case 'space'                             % space type tensor?
         prop = strcmp(fmt,'#SPACE');

      case 'split'                             % space type tensor?
         prop = strcmp(fmt,'#SPLIT');

      case 'projector'                         % projector type tensor?
         prop = strcmp(fmt,'#PROJECTOR');
         
      case 'operator'                          % operator type split?
         prop = strcmp(fmt,'#SPLIT');

      case 'transition'
         if strcmp(fmt,'#UNIVERSE')
            dat.space = data(obj,'space');
            dat.oper = data(obj,'oper');
            obj = format(obj,'#OPERATOR');
            prop = data(obj,dat);
         end
         
      case 'vector'                            % vector type tensor?
         prop = strcmp(fmt,'#VECTOR');
         
      case 'unitary'
         prop = 0;
         if strcmp(fmt,'#OPERATOR')
            M = matrix(obj'*obj-eye(obj));
            prop = all(all(abs(M) < 9e-15)) + 0;
         end
         
      case 'universe'                          % universe type tensor?
         prop = strcmp(fmt,'#UNIVERSE');
         
      otherwise
         try
            prop = property(obj.SHELL,propname);
         catch
            error(['cannot handle general property: ',propname]);
         end
   end
   return   
end
