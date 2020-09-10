function closeup(o,varargin)
%
% CLOSEUP Add a closeup panel with a zoom slider and a shift slider to
%         investigate a figure's closeup
%
%            closeup(o)                % setup closeup sliders
%            closeup(o,'Setup')        % same as above
%
%            closeup(o,'Zoom')         % closeup zoom callback
%            closeup(o,'Shift')        % closeup shift callback
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
   [gamma,o] = manage(o,varargin,@Setup,@Zoom,@Shift);
   oo = gamma(o);                   % invoke local function
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
 
      callback = call(o,class(o),{mfilename 'Zoom'}); % construct callback
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
      
      callback = call(o,class(o),{mfilename 'Shift'}); % construct callback
      set(hdl,'Callback',callback);
   end
end

%==========================================================================
% Callbacks
%==========================================================================

function o = Zoom(o)                   % Zoom Slider Callback          
   hdl = o.work.object;
   ud = get(hdl,'UserData');
   ud.zoom = get(hdl,'Value');
   Refresh(o,ud);
end
function o = Shift(o)                  % Shift Slider Callback         
   hdl = o.work.object;
   ud = get(hdl,'UserData');
   
   ud.shift = get(hdl,'Value');
   Refresh(o,ud);
end

%==========================================================================
% Refresh Closeup
%==========================================================================

function o = Refresh(o,ud)             % refresh sliders and xlimits
   ud.zoom = max(0,min(1,ud.zoom));
   if (ud.zoom == 1)
      ud.shift = 0.5;                  % overwrite in case of 100% zoom
   end
   
   ud.shift = max(0,min(1,ud.shift));
  
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
      xlim = ud.xlim(i,:);
      xd = zoom*diff(xlim);
      x0 = xlim(1) + diff(xlim)*ud.shift;
      xlim = x0 + [-xd +xd]/2;
      set(ud.hax(i),'Xlim',xlim);
   end
   
%  fprintf('zoom: %g (%g%%), shift: %g%%\n',...
%          o.rd(zoom,3),o.rd(ud.zoom*100,1),o.rd(ud.shift*100,1));
end