function prop = property(obj,propname)
% 
% PROPERTY Get a property of a TOY object
%      
%    Syntax
%       obj = toy                      % create TOY object
%       p = property(obj,'simple')     % get property value 'simple'
%
%    Supported toy properties:
%
%       bra?          indication if vector or history is a bra
%       basis         get basis of a compund space
%       column        get label column of a Hilbert space
%       cspace?       object representing compound space?
%       dimension     dimension of space
%       eye?          object representing an identity operator?
%       history?      object representing a history?
%       identity?     object representing an identity operator?
%       index         index list/vector of basis vectors
%       itab          index table of a cspace object
%       ket?          indication if vector or history is a ket
%       labels        get labels of a Hilbert space
%       list          get list of objects
%       null?         object representing a null operator?
%       number        number of projectors of a split or history
%       symbol        get vector or operator symbol
%       symbols       get symbols of a Hilbert space (labels + specs)
%       operator      object representing an operator (incl. projector)?
%       projector?    object representing a projector?
%       simple?       object representing simple space? 
%       size          size argument of toy space
%       space?        object representing a (simple or compound) space?
%       split?        object representing a split?
%       transition    get transition operator of a universe
%       unitary?      unitary operator?
%       universe?     object representing a universe?
%       vector?       object representing a vector?
%
%          Supported CORE properties:
%
%             none
%
%          See also TOY, CORE/PROPERTY

   general = {'basis','bra?','column','cspace?','dimension','eye?','history?',...
              'identity?','index','itab','ket?','labels','list','null?',...
              'number','operator?','projector?','simple?','size',...
              'space?','split?','symbol','symbols','transition',...
              'unitary?','universe?','vector?'};
   special = {};
      
   switch propname
      case {'bra','eye','history','identity','ket','null','projector',...
            'space','split','unitary','universe','vector'};
         error(['replace property name by "',propname,'?']);
         
      case general    % general properties handeled here!
      case special    % special properties be delegated to special handler 
         try
            prop = delegate(obj,propname);
            return
         catch
         end
      otherwise       % not listed properties propagate to SHELL methods
         prop = property(obj.core,propname);
         return
   end

      % any general properties, and specific properties which are
      % catched by the exception handler are processed below

         
   typ = type(obj);        % get object type into a variable
   prop = [];              % default return value
   
   switch propname      
      case 'basis'
         switch typ
            case '#CSPACE'
               prop = data(obj,'cspace.basis');
         end

      case 'bra?'
         prop = 0;
         switch typ
            case '#VECTOR'
               prop = either(data(obj,'vector.bra'),0);
            case '#HISTORY'
               prop = either(data(obj,'history.bra'),0);
         end
         
      case 'column'
         prop = data(obj,'space.column');

      case 'cspace?'                             % space type toy?
         prop = strcmp(typ,'#CSPACE');

      case 'dimension'
         sz = data(obj,'space.size');
         prop = prod(prod(sz));

      case {'eye?','identity?'}
         prop = 0;
         if strcmp(typ,'#OPERATOR')
            prop = property(obj-eye(obj),'null?');
         end
         
      case 'history?'
         prop = strcmp(typ,'#HISTORY');
         
      case 'index'
         switch typ
            case {'#SPACE','#VECTOR'}
               prop = data(obj,'space.index');
            case '#PROJECTOR'
               prop = data(obj,'proj.index');
            case '#CSPACE'
               prop = data(obj,'cspace.index');
         end
         return
         
      case 'itab'
         switch typ
            case '#CSPACE'
               prop = data(obj,'cspace.itab');
         end
         return

      case 'ket?'
         prop = 0;
         switch typ
            case '#VECTOR'
               prop = ~either(data(obj,'vector.bra'),0);
            case '#HISTORY'
               prop = ~either(data(obj,'history.bra'),0);
         end
         
      case 'labels'
         prop = data(obj,'space.labels');

      case 'list'
         switch typ
            case '#SPACE'
               prop = data(obj,'space.list');
            case '#SPLIT'
               prop = data(obj,'split.list');
            case '#UNIVERSE'
               prop = data(obj,'uni.list');
            case '#HISTORY'
               prop = data(obj,'history.list');
            case '#CSPACE'
               prop = data(obj,'cspace.list');
         end
         return
         
      case 'null?'
         prop =  (norm(matrix(obj)+0) <= 30*eps);

      case 'number'
         switch typ
            case {'#SPLIT','#UNIVERSE','#HISTORY'}
               list = property(obj,'list');
               prop = prod(size(list));
         end
         
      case 'symbol'
         prop = '';               % by default
         switch typ
            case '#VECTOR'
               prop = setstr(data(obj,'vector.symbol'));
            case {'#OPERATOR','#PROJECTOR'}
               prop = setstr(data(obj,'oper.symbol'));
         end
         
      case 'symbols'
         prop = data(obj,'space.labels');
         switch typ
            case '#SPLIT'
               list = data(obj,'split.list');
               for (i=1:length(list))
                  sym = property(list{i},'symbol');
                  if (~isempty(sym))
                     prop{end+1} = sym;
                  end
               end
               
            otherwise
               spec = data(obj,'space.spec');
               for (i=1:length(spec))
                  pair = spec{i};
                  prop{end+1} = pair{1};
               end
         end
         prop = prop(:)';

      case 'operator?'                          % operator type toy?
         prop1 = strcmp(typ,'#PROJECTOR');
         prop2 = strcmp(typ,'#OPERATOR');
         prop = (prop1 || prop2);

      case 'projector?'                         % projector type toy?
         prop = strcmp(typ,'#PROJECTOR');
         
      case 'simple?'
         typ = type(obj);
         prop = strcmp(typ,'#SPACE') && isempty(data(obj,'space.list'));
         
      case 'size'
         prop = data(obj,'space.size');
         
      case 'space?'                             % space type toy?
         prop = strcmp(typ,'#SPACE');

      case 'split?'                             % space type toy?
         prop = strcmp(typ,'#SPLIT');

      case 'projector?'                         % projector type toy?
         prop = strcmp(typ,'#PROJECTOR');
         
      case 'transition'
         if strcmp(typ,'#UNIVERSE')
            dat.space = data(obj,'space');
            dat.oper = data(obj,'oper');
            obj = type(obj,'#OPERATOR');
            prop = data(obj,dat);
         end
         
      case 'unitary?'
         prop = 0;
         if strcmp(typ,'#OPERATOR')
            M = matrix(obj'*obj-eye(obj));
            prop = all(all(abs(M) < 9e-15)) + 0;
         end
         
      case 'universe?'                          % universe type toy?
         prop = strcmp(typ,'#UNIVERSE');
         
      case 'vector?'                            % vector type toy?
         prop = strcmp(typ,'#VECTOR');
         
      otherwise
         try
            prop = property(obj.CORE,propname);
         catch
            error(['cannot handle general property: ',propname]);
         end
   end
   return   
end
