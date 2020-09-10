function [txt,txt1] = info(obj)
%
% INFO     Get info of a tensor object
%
%               S = space(tensor,{'u','d'},[1 1;-1 1]/sqrt(2));
%               P = projector(S,'u');
%
%               txt = info(S);
%               txt = info(P);
%
%            See also: TENSOR, DISPLAY
%
   spc = iif(either(option(obj,'space'),0),' ','');
   
   txt1 = '';
   fmt = format(obj);
   switch fmt
      case '#GENERIC'
         txt = 'generic tensor';
         txt1 = iif(isempty(txt1),txt,txt1);
         
      case '#SPACE'
         sizes = data(obj,'space.size');
      
         if isempty(sizes)
            txt = '[]';
         elseif size(sizes,1) == 1
            txt = sprintf('[%gx%g]',sizes(1,1),sizes(1,2));
         else
            txt = '';
            for (i=1:length(sizes)-1)
               txt = [txt,sprintf('[%gx%g]°',sizes(i,1),sizes(i,2))];
            end
            txt = [txt,sprintf('[%gx%g]',sizes(end,1),sizes(end,2))];
         end
         txt1 = iif(isempty(txt1),txt,txt1);
         return
         
      case '#PROJECTOR'
         symbols = property(obj,'symbols'); 
         index = data(obj,'proj.index');
         symbols = symbols(index);
         
         txt = '[';
         for i=1:length(symbols)
            txt = [txt,sprintf([symbols{i}])];
            if (i<length(symbols))
               txt = [txt,','];
            end
         end
         txt = [txt,']'];
         txt1 = iif(isempty(txt1),txt,txt1);
         return

      case '#VECTOR'
         mat = matrix(obj);
         labels = property(obj,'labels');
         [idx,jdx,s] = find(mat);
         [mo,no] = size(labels);

         if property(obj,'ket')
            head = '|';  tail = '>';
         else
            head = '<';  tail = '|';
         end
         
         sym = Special(obj);

         if ~isempty(sym)
            txt = sprintf([head,sym,tail]);
            txt1 = txt;
         elseif isempty(idx)
            txt = sprintf([head,'%gx%g null',tail],mo,no);
            txt1 = sprintf([head,'null',tail]);
         else
            Txt = '';
            for (i=1:length(idx))
               sym = labels{idx(i),jdx(i)};
               rtxt = iif(real(s(i)),sprintf(['%g'],real(s(i))),'');
               
               k = (jdx(i)-1)*mo + idx(i);
               if abs(s(i)-1) < 30*eps
                  txt = sprintf([head,sym,tail]);
               elseif abs(s(i)+1) < 30*eps
                  txt = sprintf(['-',head,sym,tail]);
               elseif abs(s(i)-sqrt(-1)) < 30*eps
                  txt = sprintf(['+','i',head,sym,tail]);
               elseif s(i) == -sqrt(-1)
                  txt = sprintf(['-','i',head,sym,tail]);
               elseif imag(s(i)) == 0
                  txt = sprintf(['%g*',head,sym,tail],s(i));
               elseif imag(s(i)) > 0
                  txt = sprintf([rtxt,'+%gi*',head,sym,tail],abs(imag(s(i))));
               else
                  txt = sprintf([rtxt,'-%gi*',head,sym,tail],abs(imag(s(i))));
               end
               
               if ~isempty(Txt)
                  txt = iif(txt(1)=='+'||txt(1)=='-',[spc,txt],[spc,'+',spc,txt]);
               end
               Txt = [Txt,txt];
            end
            txt = Txt;
         end
         
         txt1 = iif(isempty(txt1),txt,txt1);
         return

      case '#OPERATOR'
         sym = property(obj,'symbol');
         
         if ~isempty(sym)
            txt = ['[',sym,']'];
            txt1 = txt;
         else
            mat = matrix(obj);
            labels = property(obj,'labels');
            [idx,jdx,s] = find(mat);
            [mo,no] = size(labels);

            txt = sprintf('<operator %gx%g>',mo,no);
            txt1 = sprintf('<#%g|#%g>',mo,no);
         end

      case '#SPLIT'
         [m,n] = dim(obj);
         txt = '';
         list = data(obj,'split.list');
         for (i=1:length(list(:)))
            P = list{i};
            txt = [txt,info(P)];
         end
         txt1 = sprintf(['<split %gx%g ',txt,'>'],m,n);
         
      case '#HISTORY'
         list = property(obj,'list');
         n = length(list);
         txt = '';
         for (i=1:n)
            sym = list{i};
            if ~ischar(sym)
               sym = '?';
            end
            if (i > 1)
               txt = [txt,'°'];
            end
            txt = [txt,'[',sym,']'];
         end
         
         if property(obj,'ket')
            txt1 = sprintf(['|',txt,'>']);
         else
            txt1 = sprintf(['<',txt,'|']);
         end
         
      otherwise
         error(['matrix method does not support format ''',fmt,'''!']);
   end

   %list = data(obj,'list');   % what we had earlier
   %M = matrix(list);          % now obsolete

   return
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function M = CalculateMatrix(varargin)
%
% MATRIX   Calculate product matrix
%
%               M = matrix(magic(3),ones(2,2));
%               T = matrix([5;7;9],[2 3],ones(2,2));
%
   list = varargin;
   if length(list) == 1
      if iscell(list{1})
         list = list{1};
      end
   end
   
   N = length(list);
   if (N == 0)
      M = [];
   elseif (N==1)
      M = list{1};
   elseif (N==2)
      A = list{1};
      B = list{2};
      [m,n] = size(A);
      M = [];
      for (i=1:m)
         N = [];
         for (j=1:n)
            N = [N,A(i,j)*B];
         end
         M = [M;N];
      end
   else
      tail = matrix(list(end-1:end));
      list = list(1:end-1);
      list{end} = tail;       % overwrite
      M = matrix(list);
   end
   return
end

%==========================================================================
% Special Vector Symbol
%==========================================================================

function sym = Special(obj)
%
% SPECIAL   Special vector symbol. Return empty string if not applicable
%
   n = dim(obj);
   symbols = property(obj,'symbols');

   M = matrix(obj);
   S = space(obj);
   
   for (i=n+1:length(symbols))
      sym = symbols{i};
      Mi = matrix(vector(S,sym));
      
      if (norm(M-Mi+0) < 9e-15)
         return                         % found the symbol
      end
   end
   
   sym = '';                            % special vector not found
   return
end