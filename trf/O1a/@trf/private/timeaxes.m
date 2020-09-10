function handle = timeaxes(t_lo,t_hi,y_lo,y_hi)
%
% TIMEAXES Draw or select linear scaled axes for time plots. The stan-
%          dard call is
%
%             handle = timeaxes(t_low,t_high,y_low,y_high)
%
%          An axes object tagged 'Time Axes' is selected (created) and 
%          axes are scaled in the specified ranges. If an argument is
%	   missing or an argument is NaN the current values (or default
%          value on creation time) will be used.
%
%	   The value INF may be used to specify semiautomatic axes li-
%          mits.
%
%          Search/creation process: Beginning with the current axes ob- 
%          ject the current figure will be searched for a 'Time Axes'
%          tagged axes object. If no such axes object exists a new one
%          will be created and tagged 'Time Axes' in its userdata.
%
%          Examples:
%
%             h = timeaxes(0,10,-1,1)     time domain 0..10, y-range -1..1
%             h = timeaxes(0,10,0,inf)    semiautomatic y-range 0..?
%             h = timeaxes(nan,nan,0)     defaults for t_low, t_high, y_high
%             h = timeaxes;               select current time axes object
%                                         (create default if not exists)
%
%	   See also BODEAXES, TFFSTEP
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   if ( isempty(trf.gao('owner')) )
      trf.gao('owner','none');
   end

   owner = trf.gao('owner');
   if ( strcmp(owner,'time') == 0)
      o = pull(carabao);
      cls(o);
      hdl = plot([0.01 1000],[0 0]);
      delete(hdl);
      grid on;
      trf.gao('owner','time');            % set axis ownership
   
      hax = gca;
      set(hax,'xlim',[0 inf]);
      set(hax,'ylim',[-inf inf]);
      set(hax,'Color',[0.3 0.35 0]);
set(hax,'nextplot','replace');
      grid on;
   end      

%
% from here we have 'hax' as a valid handle to time plot axes
%
   hax = gca;
   axes(hax);    % make 'hax' current axes

   if ( nargout >= 1 ) handle = hax; end

%
% Modify scaling attributes of axes object
%

   xlim = get(hax,'Xlim');
   ylim = get(hax,'Ylim');

   if (nargin < 1) t_lo = NaN; end
   if (nargin < 2) t_hi = NaN; end
   if (nargin < 3) y_lo = NaN; end
   if (nargin < 4) y_hi = NaN; end

   if ( isnan(t_lo) ) t_lo = xlim(1); else xlim(1) = t_lo; end
   if ( isnan(t_hi) ) t_hi = xlim(2); else xlim(2) = t_hi; end
   if ( isnan(y_lo) ) y_lo = ylim(1); else ylim(1) = y_lo; end
   if ( isnan(y_hi) ) y_hi = ylim(2); else ylim(2) = y_hi; end

   set(hax,'xlim',[t_lo, t_hi]);
   set(hax,'ylim',[y_lo, y_hi]);
   % hold on

% eof
