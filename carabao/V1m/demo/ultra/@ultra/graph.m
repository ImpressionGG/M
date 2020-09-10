function oo = graph(o,varargin)   % Plot Graph of a Trace Object           
%
% GRAPH  Plot graph of an ULTRA trace object (or derived). At the same
%        time put object into clipboard for pasting into object list.
%        GRAPH calls method PLOT.
%
%           graph(o,'Scatter')         % scatter analysis of final error
%
%    See also: ULTRA, CONFIG, PLOT, STUDY
%
   [gamma,oo] = manage(o,varargin,@Scatter);
   oo = gamma(oo);
end

%==========================================================================
% Local Functions to be Dispatched
%==========================================================================

function oo = Scatter(o)               % Scatter Plot                   
   oo = Graph(o,'Scatter');
end

%==========================================================================
% Plot and Put Into Clip Board
%==========================================================================

function oo = Graph(o,mode)            % plot & put into clip board    
   atype = active(o);
   if ~isequal(atype,o.type)
      active(o,o.type);
      event(pull(o),'signal');
      change(o,'signal');              % update Signal menu
   end
   
   if (nargin == 1)
      mode = setting(o,{'mode.plot','Stream'});
   end

      % the next lines are needed to make the refresh after a new
      % object selection working properly!
   
   about = caller(o,'Activate');
   about = about || caller(o,'PasteCb');
   
   if (about)                          % better to show 'About' screen?
      menu(current(o),'About');
      oo = o;
      return
   end   
   
   o = opt(o,setting(o));
   clip(o,o);
   
   switch mode
      case 'Scatter'
         oo = o;                       % don't cast
      otherwise
         oo = cast(o,'caramel');
   end
   
   oo = with(oo,'style');              % unpack 'style' options
   oo = with(oo,'view');               % unpack 'view' options
   oo = with(oo,'select');             % unpack 'select' options

   oo = SubplotMap(oo);
   plot(oo,mode);
end

function o = SubplotMap(o)
%
% SUBPLOTMAP Map 1 column subplot indizes into left column index of
%            two-column subplot.
%
%               1 -> 1
%               2 -> 3
%               3 -> 5      in general: sub -> 2*sub - 1
%               4 -> 7
%               5 -> 9
   for (i=1:config(o,inf))
       [sym,sub,col,cat] = config(o,i);
       if ~isnan(sub) && (sub > 0)
          sub = 2*sub - 1;             % perform mapping
          o = config(o,sym,sub);
       end
   end
end
