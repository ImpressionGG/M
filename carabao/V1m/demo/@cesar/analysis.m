function oo = analysis(o,varargin)     % Cesar Data Analysis           
%
% ANALYSIS  Cesar Data Analysis
%
%           analysis(o,'Setup')        % setup Analysis menu
%
   [gamma,oo] = manage(o,varargin,@Setup,...
                   @DataAnalysis,@GradientAnalysis,@LevelAnalysis,...
                   @PositionRepeatability);
   oo = gamma(oo);
end

%==========================================================================
% Menu Setup
%==========================================================================

function oo = Setup(o)                 % Menu Setup                    
   oo = mhead(o,'Analysis');           % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = mhead(oo,'Position Repeatability',{@PositionRepeatability});
   ooo = mhead(oo,'Data Analysis',{@DataAnalysis});
   ooo = mitem(oo,'-');
   ooo = mhead(oo,'Level Analysis',{@LevelAnalysis});
   ooo = mhead(oo,'Gradient Analysis',{@GradientAnalysis});
   ooo = mitem(oo,'-');
end

%==========================================================================
% Local Plot Functions
%==========================================================================

function o = PositionRepeatability(o)  % Pos. Repeatability Analysis   
   refresh(o,o);
   
   o = opt(o,'basket.collect','*');    % all objects in container   
   o = opt(o,'basket.type','image');   % which are of type image
   list = basket(o);
   if isempty(list)
      message(o,'No image objekts in basket!');
      return
   end
   
   oo = list{1};
   n = config(oo,inf);
   for (i=1:n)
      [sym,sub,col,cat] = config(oo,i);
      symbols{i} = sym;
      colors{i} = col;
      subplots(i) = sub;
   end
   
   
   P1 = [];  P2 = [];                  % position
   Sym = {};
   for k = 1:length(list)
      oo = extract(list{k});
      for (i=1:config(oo,inf))
         [sym,sub,col,cat] = config(oo,i);
         if ~isequal(sym,symbols{i})
            error('bad symbol!');
         end
         if ~isequal(col,colors{i})
            error('bad color!');
         end
         if ~isequal(sub,subplots(i))
            error('bad suplot number!');
         end
         x = cook(oo,':','offsets');  x = x(1,:);
         y = cook(oo,sym,'offsets');

         [dy,idx] = Derivative(y);
         [px,py] = Position(o,x,y,idx);
         
         P1(i,k) = px(1);  P2(i,k) = px(2);
      end
   end
   
   oo = pick(list{1},'Fiducial');      % take as a basis
   m = size(P1,2);
   oo.data = [];
   oo.data.t = 1:m;
   for i=1:n
      oo.data.(symbols{i}) = P1(i,:);
%     oo.data.(symbols{i}) = P1(1,:) + P1(2,:);
   end
   oo.par.sizes = [1 m 1];
   oo = cast(oo,'caramel');
   plot(oo,'Stream');
   xlabel(get(oo,{'xlabel',''}));
end
function o = DataAnalysis(o)           % Data Analysis                 
   color = @o.color;                   % short hand
   
   refresh(o,o);
   oo = current(o);
   oo = extract(oo);
 
   cls(o);
   for (i=1:config(oo,inf))
      [sym,sub,col,cat] = config(oo,i);
      x = cook(oo,':','offsets');  x = x(1,:);
      y = cook(oo,sym,'offsets');
      
      subplot(oo,sub);
      hdl = plot(x,y);  hold on;
      color(hdl,col);
      
      [dy,idx] = Derivative(y);
      
      plot(x(idx(1,:)),y(idx(1,:)),'ko');
      plot(x(idx(2,:)),y(idx(2,:)),'ko');

      [X,Y] = Position(o,x,y,idx);
      xlim = get(gca,'xlim');  
      ylim = get(gca,'ylim');
      plot(X(1)*[1 1],ylim,'k-',  X(1),Y,'bo');
      plot(X(2)*[1 1],ylim,'k-',  X(2),Y,'bo');
      plot(xlim,Y*[1 1],'k:');
      
      if (i==1)
         title(get(oo,'title'));
      end
      xlabel(sprintf('position:  %g/%g',o.rd(X(1),3),o.rd(X(2),3)));
   end
end
function o = LevelAnalysis(o)          % Level Analysis                
   color = @o.color;                   % short hand
   
   refresh(o,o);
   oo = current(o);
   oo = extract(oo);
 
   cls(o);
   for (i=1:config(oo,inf))
      [sym,sub,col,cat] = config(oo,i);
      x = cook(oo,':','offsets');  x = x(1,:);
      y = cook(oo,sym,'offsets');
      
      subplot(oo,sub);
      hdl = plot(x,y);  hold on;
      color(hdl,col);
      
      [l,u,sigl,sigu,idx] = Levels(y);
      xlim = get(gca,'xlim');
      plot(xlim,l*[1 1],'k',  xlim,(l+3*sigl)*[1 1],'k:');
      plot(xlim,u*[1 1],'k',  xlim,(u-3*sigu)*[1 1],'k:');
      
      plot(x(idx),y(idx),'ko');
   end
end
function o = GradientAnalysis(o)       % Gradient Analysis             
   color = @o.color;                   % short hand
   bullets = opt(o,{'style.bullets',0});
   
   refresh(o,o);
   oo = current(o);
   oo = extract(oo);
 
   cls(o);
   for (i=1:config(oo,inf))
      [sym,sub,col,cat] = config(oo,i);
      x = cook(oo,':','offsets');  x = x(1,:);
      y = cook(oo,sym,'offsets');
      dy = [0,diff(y)];      
      subplot(oo,sub);
      hdl = plot(x,dy);  hold on;
      color(hdl,col);

      if (bullets < 0)
         hdl = plot(x,dy,'k.');
      elseif (bullets > 0)
         hdl = plot(x,dy,[col,'.']);
      end
      
      
      [sdy,idx] = sort(dy);
      idx1 = idx(1:3);  idx2 = idx(end-2:end);
      plot(x(idx1),dy(idx1),'ko')
      plot(x(idx2),dy(idx2),'ko')
      
      
      if (i==1)
         title(get(oo,'title'));
      end
   end
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function [l,u,sigl,sigu,idx] = Levels(f)   % Extract Levels of a Fct.  
  mini = min(f);  maxi = max(f);
  delta = maxi - mini;
  udx = find(f >= maxi - 1/3*delta);
  ldx = find(f <= mini + 1/3*delta);
  
  l = mean(f(ldx));  u = mean(f(udx));
  sigu = std(f(udx));
  sigl = std(f(ldx));
  idx = find((f >= (l+3*sigl)) & (f <= (u-3*sigu)));
end
function [y,idx] = Derivative(x)       % Build Derivative              
   d = diff(x);
   d1 = [d(1) d];
   d2 = [d d(end)];
   y = (d1+d2)/2;

   idx = find(y==max(y));
   idx1 = idx(1) + [-1 0 1];
   idx = find(y==min(y));
   idx2 = idx(1) + [-1 0 1];
   
   idx = [idx1;idx2];
end
function [X,Y] = Position(o,x,y,idx)   % Position Calculation          
   x1 = x(idx(1,:));  y1 = y(idx(1,:));
   x2 = x(idx(2,:));  y2 = y(idx(2,:));
   
   Y = 80;  

   C1 = map(o,y1,x1,1);
   X1 = map(o,C1,Y);
   
   C2 = map(o,y2,x2,1);
   X2 = map(o,C2,Y);
   
   X = [X1;X2];
end
