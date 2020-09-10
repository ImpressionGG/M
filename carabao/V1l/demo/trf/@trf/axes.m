function oo = axes(o,varargin)
%
% AXES   Draw time axes or bode axes
%
%    Synopsis
%
%       axes(o,'Bode');                % draw default bode axes
%       axes(o,'Bode',om_lo,om_hi,mg_lo,mg_hi,ph_lo,ph_hi)
%
%       axes(o,'Time');                % draw default time axes
%       axes(o,'Time',low,high);       
%
%    This method is to setup the scaling parameters for bode axes or
%    time axes. As a general rule: providing a NaN argument causes to
%    use the existing scaling parameter. In contrast leaving an argument
%    missing or providing an empty argument causes to use the correspon-
%    ding option for the scaling parameter (and if the option is empty
%    then refering back to the existing scaling parameter).
%
%    Those options are for bode axes:
%
%       opt(o,'omega.low')             % lower frequency limit
%       opt(o,'omega.high')            % upper frequency limit
%       opt(o,'magnitude.low')         % lower magnitude limit
%       opt(o,'magnitude.high')        % upper magnitude limit
%       opt(o,'phase.low')             % lower phase limit
%       opt(o,'phase.high')            % upper phase limit
%
%    Those options are for time axes:
%
%       opt(o,'time.low')              % lower time limit
%       opt(o,'time.high')             % upper time limit
%
%    Setting up Bode Axes Scaling
%
%       axes(o,'Bode',om_lo,om_hi);
%
%       axes(o,'Frequency',om_lo,om_hi);
%       axes(o,'Frequency',om_lo,NaN);   % use existing upper frequency
%       axes(o,'Frequency',NaN,om_hi);   % use existing lower frequency
%       axes(o,'Frequency',NaN,NaN);     % use existing frequency scaling
%       axes(o,'Frequency',[],[]);       % use frequency scaling options 
%       axes(o,'Frequency');             % same as above 
%
%       axes(o,'Magnitude',mg_lo,mg_hi);
%       axes(o,'Magnitude',mg_lo,NaN);   % use existing upper magnitude
%       axes(o,'Magnitude',NaN,mg_hi);   % use existing lower magnitude
%       axes(o,'Magnitude',NaN,NaN);     % use existing magnitude scaling
%       axes(o,'Magnitude',[],[]);       % use magnitude scaling options 
%       axes(o,'Magnitude');             % same as above 
%
%       axes(o,'Phase',ph_lo,ph_hi);
%       axes(o,'Phase',ph_lo,NaN);       % use existing upper phase
%       axes(o,'Phase',NaN,ph_hi);       % use existing lower phase
%       axes(o,'Phase',NaN,NaN);         % use existing phase scaling
%       axes(o,'Phase',[],[]);           % use phase scaling options 
%       axes(o,'Phase');                 % same as above 
%
%    Setting up Time Axes Scaling
%
%       axes(o,'Time',low,high);
%
%    See also: TRF, STEP, BODE
%
   [gamma,oo] = manage(o,varargin,@Error,@Bode,@Time,@Frequency,...
                       @Magnitude,@Phase);
   oo = gamma(oo);
end

%==========================================================================
% Local Plot Functions
%==========================================================================

function oo = Error(o)                 % report an error               
   error('no axes mode provided!');
end

function oo = Bode(o)
%
% BODE   Setup bode axes scaling
%
%           axes(o,'Bode',om_lo,om_hi,mg_lo,mg_hi,ph_lo,ph_hi)
% 
%        Any empty or missing argument defaults to the corresponding 
%        option setting. Any NaN argument leaves the scaling parameter
%        as it is (or uses the initial default for new axes)
%
   om_lo = arg(o,1);
   om_hi = arg(o,2);
   mg_lo = arg(o,3);
   mg_hi = arg(o,4);
   ph_lo = arg(o,5);
   ph_hi = arg(o,6);

   om_lo = o.either(om_lo,opt(o,{'omega.low',NaN}));
   om_hi = o.either(om_hi,opt(o,{'omega.high',NaN}));
   mg_lo = o.either(mg_lo,opt(o,{'magnitude.low',NaN}));
   mg_hi = o.either(mg_hi,opt(o,{'magnitude.high',NaN}));
   ph_lo = o.either(ph_lo,opt(o,{'phase.low',NaN}));
   ph_hi = o.either(ph_hi,opt(o,{'phase.high',NaN}));
   
   hdl = bodeaxes(om_lo,om_hi,mg_lo,mg_hi,ph_lo,ph_hi);
   BodeCanvas(o);                      % set proper canvas color
   oo = work(o,'hdl',hdl);
end
function oo = Frequency(o)
   om_lo = arg(o,1);
   om_hi = arg(o,2);

   om_lo = o.either(om_lo,opt(o,{'omega.low',NaN}));
   om_hi = o.either(om_hi,opt(o,{'omega.high',NaN}));
   
   hdl = bodeaxes(om_lo,om_hi);
   BodeCanvas(o);                      % set proper canvas color
   oo = work(o,'hdl',hdl);
end
function oo = Magnitude(o)
   mg_lo = arg(o,1);
   mg_hi = arg(o,2);

   mg_lo = o.either(mg_lo,opt(o,{'magnitude.low',NaN}));
   mg_hi = o.either(mg_hi,opt(o,{'magnitude.high',NaN}));
   
   hdl = bodeaxes('magnitude',mg_lo,mg_hi);
   BodeCanvas(o);                      % set proper canvas color
   oo = work(o,'hdl',hdl);
end
function oo = Phase(o)
   ph_lo = arg(o,1);
   ph_hi = arg(o,2);

   ph_lo = o.either(ph_lo,opt(o,{'phase.low',NaN}));
   ph_hi = o.either(ph_hi,opt(o,{'phase.high',NaN}));
   
   hdl = bodeaxes('phase',ph_lo,ph_hi);
   BodeCanvas(o);                      % set proper canvas color
   oo = work(o,'hdl',hdl);
end

function oo = Time(o)
   t_lo = arg(o,1);
   t_hi = arg(o,2);
   y_lo = arg(o,3);
   y_hi = arg(o,4);

   t_lo = o.either(t_lo,opt(o,{'time.low',NaN}));
   t_hi = o.either(t_hi,opt(o,{'time.high',NaN}));
   y_lo = o.either(y_lo,opt(o,{'amplitude.low',NaN}));
   y_hi = o.either(y_hi,opt(o,{'amplitude.high',NaN}));

   hdl = timeaxes(t_lo,t_hi,y_lo,y_hi);
   TimeCanvas(o);                      % set proper canvas color
   oo = work(o,'hdl',hdl);
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function o = BodeCanvas(o)             % Set Proper Bode Canvas Color  
   fig = o.either(figure(o),gcf);
   hax = get(fig,'CurrentAxes');
   canvas = opt(o,{'style.canvas','color'}); % canvas color 
   switch canvas
      case 'white'
         set(hax,'color',o.color('w'));
         %set(hax,'xcolor',0.5*[1 1 1],'ycolor',0.5*[1 1 1]);
      case 'black'
         set(hax,'color',o.color('k'));
         set(hax,'xcolor',0.5*[1 1 1],'ycolor',0.5*[1 1 1]);
      case 'color'
         set(hax,'color',[0.3 0.3 0]);
   end
end
function o = TimeCanvas(o)             % Set Proper Time Canvas Color  
   fig = o.either(figure(o),gcf);
   hax = get(fig,'CurrentAxes');
   canvas = opt(o,{'style.canvas','color'}); % canvas color 
   switch canvas
      case 'white'
         set(hax,'color',o.color('w'));
         %set(hax,'xcolor',0.5*[1 1 1],'ycolor',0.5*[1 1 1]);
      case 'black'
         set(hax,'color',o.color('k'));
         set(hax,'xcolor',0.5*[1 1 1],'ycolor',0.5*[1 1 1]);
      case 'color'
         set(hax,'color',[0.3 0.35 0]);
   end
end
