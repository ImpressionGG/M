function handle = bodeaxes(om_lo,om_hi,mg_lo,mg_hi,ph_lo,ph_hi)
%
% BODEAXES Draw or select semilogarithmic scaled axes for bode plots.
%          The standard call is
%
%             handle = bodeaxes(om_lo,om_hi,mg_lo,mg_hi,ph_lo,ph_hi)
%
%             handle = bodeaxes('magnitude',mg_lo,mg_hi)
%             handle = bodeaxes('m',mg_lo,mg_hi)
%             handle = bodeaxes('phase',ph_lo,ph_hi)
%             handle = bodeaxes('p',ph_lo,ph_hi)
%
%             handle = bodeaxes     % select current bode axes object
%                                   % (create default if not exists)
%
%          An axes object tagged 'Bode Axes' is selected (created) and 
%          axes are scaled in the specified ranges. If an argument is
%	   missing or an argument is NaN the current values (or default
%          value on creation time) will be used.
%
%          Search/creation process: Beginning with the current axes ob- 
%          ject the current figure will be searched for a 'Bode Axes'
%          tagged axes object. If no such axes object exists a new one
%          will be created and tagged 'Bode Axes' in its userdata.
%
%          Examples:
%
%             h = bodeaxes(0.1,1000,-60,60)     
%
%	   See also TIMEAXES, TFFBODE, TFFPHASE, TFFMAGNI
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   if ( isempty(trf.gao('owner')) )
      trf.gao('owner','none');
   end

   owner = trf.gao('owner');
   if ( strcmp(owner,'bode') == 0)
      o = carabao;
      o = o.either(pull(o),o);
      cls(o);
      hdl = semilogx([0.01 1000],[0 0]);
      delete(hdl);
      grid on;
      trf.gao('owner','bode');            % set axis ownership
   
      hax = gca;
      set(hax,'xlim',[0.01 1000]);
      set(hax,'ylim',[-80  80]);
      set(hax,'zlim',[-270 90]);
      set(hax,'ytick',-80:20:80); 
      set(hax,'Xscale','log');
      set(hax,'Color',[0.3 0.3 0]);
      %set(hax,'userdata','Bode Axes');
      %set(hax,'ButtonDownFcn','timeaxcb(1)');
      set(hax,'nextplot','replace');
hold on
      grid on;
      %tffmencb(0);   % setup menu
   end      

%
% from here we have 'hax' as a valid handle to bode plot axes
%
   hax = gca;
   axes(hax);    % make 'hax' current axes

   if ( nargout >= 1 ) handle = hax; end

%
% Modify scaling attributes of axes object
%

   xlim = get(hax,'Xlim');
   ylim = get(hax,'Ylim');
   zlim = get(hax,'Zlim');

   mode = 0;
   if ( nargin > 0 )
     if ( isstr(om_lo)  ) mode = om_lo; end
   end

   if ( mode )
      if ( nargin < 2 ) arg_lo = NaN; else arg_lo = om_hi; end
      if ( nargin < 3 ) arg_hi = NaN; else arg_hi = mg_lo; end
      om_lo = NaN;  om_hi = NaN;
      mg_lo = NaN;  mg_hi = NaN;
      ph_lo = NaN;  ph_hi = NaN;

      if ( strcmp(mode,'magnitude') | strcmp(mode,'m') )
         mg_lo = arg_lo;  mg_hi = arg_hi;
      elseif ( strcmp(mode,'phase') | strcmp(mode,'p') )
         ph_lo = arg_lo;  ph_hi = arg_hi;
      else
         error(['bad mode: ',mode]);
      end
   else
      if (nargin < 1) om_lo = NaN; end
      if (nargin < 2) om_hi = NaN; end
      if (nargin < 3) mg_lo = NaN; end
      if (nargin < 4) mg_hi = NaN; end
      if (nargin < 5) ph_lo = NaN; end
      if (nargin < 6) ph_hi = NaN; end
   end

   if ( isnan(om_lo) ) om_lo = xlim(1); else xlim(1) = om_lo; end
   if ( isnan(om_hi) ) om_hi = xlim(2); else xlim(2) = om_hi; end
   if ( isnan(mg_lo) ) mg_lo = ylim(1); else ylim(1) = mg_lo; end
   if ( isnan(mg_hi) ) mg_hi = ylim(2); else ylim(2) = mg_hi; end
   if ( isnan(ph_lo) ) ph_lo = zlim(1); else zlim(1) = ph_lo; end
   if ( isnan(ph_hi) ) ph_hi = zlim(2); else zlim(2) = ph_hi; end

   set(hax,'xlim',[om_lo, om_hi]);
   set(hax,'ylim',[mg_lo, mg_hi]);
   set(hax,'zlim',[ph_lo, ph_hi]);
   set(hax,'ytick',mg_lo:20:mg_hi); 

%
% remove current phase ticks
%

   children = get(hax,'children');
   while ( ~isempty(children) )
      child = children(1);  children(1) = [];
      if ( strcmp(get(child,'userdata'),'Bode Axes') )
         delete(child);
      end
   end


%
% update phase ticks
%

   ytick = get(hax,'ytick');
   
   dy = ylim(2)-ylim(1);  y0 = ylim(1);
   dz = zlim(2)-zlim(1);  z0 = zlim(1);
   
   for (i=1:length(ytick))
      y = ytick(i);
      z = z0 + (y-y0) * dz/dy;
      label = sprintf('   %g',z);
      h = text(xlim(2),y,label);
      set(h,'userdata','Bode Axes');
   end

   % hold on

% eof
