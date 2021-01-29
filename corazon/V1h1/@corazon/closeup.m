function oo = closeup(o,varargin)
%
% CLOSEUP Add a closeup panel with a zoom slider and a shift slider to
%         investigate a figure's closeup
%
%            closeup(o)                % setup closeup sliders
%            closeup(o,'Setup')        % same as above
%
%         Setup with customized callbacks:
%
%            closeup(o,{mfilename,'Zoom'},{mfilename,'Shift'})
%
%         Invoke standard Zoom and Shift callback:
%
%            o = closeup(o,'Zoom')     % closeup zoom callback
%            o = closeup(o,'Shift')    % closeup shift callback
%
%         Pick index range (requires proper setting of var(o,'zoom') and
%         var(o,'shift'), as it is done by o = closeup(o,'Zoom') or o =
%         closeup(o,'Shift').
%
%            oo = closeup(o,'Range',[1 10000])
%            range = var(oo,'range');
%
%         Remark closeup() changes the xlimits of all subplots with either
%         empty or enabled shelf settings 'closeup'. To prevent a subplot 
%         from being controlled by the closeup sliders invoke
%
%            shelf(o,gca,'closeup',false);   % prevents closeup control
%
%         Copyright(c) Bluenetics 2020
%
%         See also: CORAZON
%
   [gamma,o] = manage(o,varargin,@Setup,@Zoom,@Shift,@Range);
   oo = gamma(o);                      % invoke local function
end

function o = Setup(o)                  % Setup Closeup Sliders         
   fig = figure(o);
   if isempty(fig)
      fig = gcf;
   end
   
      % find all axes
      
   hax = [];  left = inf;  right = -inf;  xlim = [];
   kids = get(fig,'Children');
   for (i=1:length(kids))
      kid = kids(i);
      if isequal(get(kid,'type'),'axes')
         enable = o.either(shelf(o,kid,'closeup'),1);
         if (enable)
            hax(end+1) = kid;
            xlim(end+1,1:2) = get(kid,'xlim');
         end
         pos = get(kid,'position');  xl = pos(1);  xr = xl+pos(3);
         left = min(left,xl);  right = max(right,xr);
      end
   end
   
      % get figure width and height
      
   fpos = get(fig,'OuterPosition');  
   fwidth = fpos(3);  fheight = fpos(4);

      % draw panel
      
   pheight = 0.03;                     % panel height
   pwidth = 0.99*(right-left)/2;       % panel width
   hpix = fheight*pheight;             % panel pixel height
   
   ud.zhdl = SliderZoom(o);            % zoom slider
   ud.shdl = SliderShift(o);           % shift slider
   
   ud.hax = hax;                       % store axis handles
   ud.xlim = xlim;                     % store x-limits
   ud.zoom = 1;                        % zoom factor
   ud.shift = 0.5;                     % shift factor
   
   set(ud.zhdl,'UserData',ud);
   set(ud.shdl,'UserData',ud);
   
   Refresh(o,ud);                      % refresh closeup
      
   function hdl = SliderZoom(o)
      wpix = fwidth*pwidth;            % panel pixel width

      phdl = uipanel(gcf,'Position',[left 0.02 pwidth pheight]);

      col = opt(o,{'control.color',0.9*[1 1 1]});
      %set(h,'Background',col);

      hdl = uicontrol(phdl,'Style','slider');
      set(hdl,'OuterPosition',[0 -2 wpix hpix]);
      set(hdl,'Background',col,'Foreground',col);
      
         % now setup Callback
 
      cblist = {mfilename 'Zoom'};
      if isequal(arg(o,inf),2) && iscell(arg(o,1)) && iscell(arg(o,2))
         cblist = arg(o,1);
      end
      callback = call(o,class(o),cblist);   % construct callback
      set(hdl,'Callback',callback);
   end
   function hdl = SliderShift(o)
      wpix = fwidth*pwidth;            % panel pixel width

      phdl = uipanel(gcf,'Position',[right-pwidth 0.02 pwidth pheight]);

      col = opt(o,{'control.color',0.9*[1 1 1]});
      %set(h,'Background',col);

      hdl = uicontrol(phdl,'Style','slider');
      set(hdl,'OuterPosition',[0 -2 wpix hpix]);
      set(hdl,'Background',col,'Foreground',col);

         % now setup Callback
      
      cblist = {mfilename 'Shift'};
      if isequal(arg(o,inf),2) && iscell(arg(o,1)) && iscell(arg(o,2))
         cblist = arg(o,2);
      end
      callback = call(o,class(o),cblist);   % construct callback
      set(hdl,'Callback',callback);
   end
end

%==========================================================================
% Callbacks
%==========================================================================

function oo = Zoom(o)                  % Zoom Slider Callback          
   hdl = o.work.object;
   ud = get(hdl,'UserData');
   ud.zoom = get(hdl,'Value');
   oo = Refresh(o,ud);
end
function oo = Shift(o)                 % Shift Slider Callback         
   hdl = o.work.object;
   ud = get(hdl,'UserData');
   
   ud.shift = get(hdl,'Value');
   oo = Refresh(o,ud);
end

%==========================================================================
% Refresh Closeup
%==========================================================================

function oo = Refresh(o,ud)            % refresh sliders and xlimits   
   ud.zoom = max(0,min(1,ud.zoom));
   if (ud.zoom == 1)
      ud.shift = 0.5;                  % overwrite in case of 100% zoom
   end
   
   
   shift = max(0,min(1,ud.shift));
   ud.shift = shift;
   
   minz = 0.0001;
   logz = log10(minz)*(1-ud.zoom);
   zoom = 10^logz;
   
   fac = 3*10^(-0.2*logz/log10(0.5)) + 1000*exp(50*logz);
   
   set(ud.zhdl,'Value',ud.zoom);
   set(ud.shdl,'Value',ud.shift);
   
   set(ud.zhdl,'SliderStep',[0.001 0.02]);
   set(ud.shdl,'SliderStep',[ud.zoom/10000 max(0.01,fac*zoom)]);
   
   set(ud.zhdl,'UserData',ud);
   set(ud.shdl,'UserData',ud);
   
   [m,n] = size(ud.xlim);
   for (i=1:m)
      xlim = Limit(o,ud.xlim(i,:),zoom,shift);
      %ud.xlim  
      %Tlim=xlim
      set(ud.hax(i),'Xlim',xlim);
   end
   
      % set zoom and shift value
      
   oo = o;
   oo = var(oo,'zoom',zoom);
   oo = var(oo,'shift',shift);
end

%==========================================================================
% Index Range
%==========================================================================

function oo = Range(o)                 % Calculate New Range           
   limit = arg(o,1);
   zoom = var(o,'zoom');
   shift = var(o,'shift');
   
   if ~isempty(zoom) && ~isempty(shift)
      range = Limit(o,limit,zoom,shift);
      range = [ceil(range(1)),floor(range(2))];
      
      %limit_range = [limit;range]       
      %t = shelf(o,gca,'t');
      %if ~isempty(t)
      %   tlim = [t(1) t(end); t(range(1)), t(range(2))]
      %end
   else
      range = [];
   end
   oo = var(o,'range',range);
end

%==========================================================================
% Helper
%==========================================================================

function limit = Limit(o,lim,zoom,shift)
   xd = zoom*diff(lim);
   x0 = lim(1) + diff(lim)*shift;
   limit = x0 + [-xd +xd]/2;
   limit = [max(limit(1),lim(1)), min(limit(2),lim(2))];
end

