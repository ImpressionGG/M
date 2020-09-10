function oo = plot(o,varargin)         % CESAR Plot Method             
%
% PLOT   Cesar plot method
%
%           plot(o,'Image')            % plot full image
%           plot(o);                   % short hand for plot(o,'Image')
%           plot(o,'Fiducial')         % plot fiducial area of image
%           plot(o,'Data')             % plot data of fiducial area
%
   if container(o)
      oo = Basket(o);                  % plot all objects of Basket
   else
      [gamma,oo] = manage(o,varargin,@Image,@Area,@Fiducial,...
                      @Stream,@Overlay,@Offsets,@Data);
      oo = gamma(oo);
   end
end

%==========================================================================
% Plot Objects of Basket
%==========================================================================

function oo = Basket(o)                % Plot Basket                   
   oo = cast(o,'carabao');  
   args = arg(o,0);
   oo = plot(oo,'Basket',args);        % plot all objects in container
end

%==========================================================================
% Local Plot Functions
%==========================================================================

function oo = Image(o)                 % Plot Full Image               
   oo = cast(o,'caravel');
   plot(oo,'Image');
end
function oo = Area(o)                  % Plot Fiducial Area of Image   
   oo = pick(o,'Area');
   plot(oo,'Image');
   title(get(oo,{'title',''}));
   xlabel(get(oo,{'xlabel',''}));
end
function oo = Fiducial(o)              % Plot Selected Fiducial        
   oo = pick(o,'Fiducial');
   plot(oo,'Image');
   title(get(oo,{'title',''}));
   xlabel(get(oo,{'xlabel',''}));
end
function oo = Stream(o)                % Plot Stream of Fiducial Data  
   oo = extract(o);
   plot(oo,'Stream');
   xlabel(get(oo,{'xlabel',''}));
end
function oo = Overlay(o)               % Plot Overlay of Fiducial Data 
   oo = extract(o);
   plot(oo,'Overlay');
   xlabel(get(oo,{'xlabel',''}));
end
function oo = Offsets(o)               % Plot Offsets of Fiducial Data 
   oo = extract(o);
   plot(oo,'Offsets');
   xlabel(get(oo,{'xlabel',''}));
end

function oo = Data(o)                  % Plot Data of Fiducial Area    
   oo = extract(o);
   plot(oo);
end
