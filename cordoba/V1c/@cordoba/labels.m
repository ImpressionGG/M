function labels(o)                     % Provide Labels & Titles       
%
% LABELS   Provide plots with labels & titles
%
%    Behaviour of LABELS is influenced by plot mode and style option
%
%       o = opt(o,'style',style);
%       o = opt(o,'mode.plot','Stream');
%       labels(o);
%
%    Plot mode:
%       'Stream'                       % (simple) data stream
%       'Fictive'                      % fictive data stream
%
%       'Overlay'                      % overlay mode
%       'Offset'                       % offsets (mean values of overlays)
%       'Repeatability'                % repeatability (offset eliminated)
%
%       'Ensemble'                     % ensemble mode
%       'Average'                      % average of ensemble        
%       'Spread'                       % spread of ensemble  
%       'Deviation'                    % deviation of ensemble from average
%
%       'Condensate1'                  % order 1 condensate
%       'Condensate2'                  % order 2 condensate
%       'Condensate3'                  % order 3 condensate
%
%    Analysis
%       'Path'                         % matrix path
%       'Zigzag'                       % zigzag path
%       'Arrow'                        % arrow plot
%
%    Label Style:
%       'plain'                        % plain style
%       'statistics'                   % Cpk,Cp,mean,sigma
%       'guerilla'                     % 'Guerilla' style
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CARALOG, PLOT, GRID, VARIATION, MODES
%
   plotmode = PlotMode(o);
   bias = opt(o,{'mode.bias',''});     % bias mode
   o = opt(o,'bias',bias);             % provide bias mode
%
% check for the supported plot modes! all other plot modes will be 
% ignored.
%
   title = [upper(plotmode(1)),plotmode(2:end)];
   comment = {};
   style = opt(o,{'style.labels','plain'});
   
   switch plotmode
      case 'stream'
         title = 'Data Stream @ Time';
      case 'overlay'
         title = 'Data Overlay @ Position Index';
      case {'mean','offsets'}
         title = 'Position Offsets @ Position Index'; 
         comment{end+1,1} = 'Average value at each position';
         comment{end+1,1} = ['ignored data points are not included ',...
                             'in offset calculation'];
      case 'repeatability'
         title = 'Repeatability @ Position Index';
      case {'residual1','residual2','residual3'}
         s=arg(o,1);  n = sscanf(s(end:end),'%f');
         title = sprintf('Order %g Residual @ Position Index',n);
      case 'fictive'
         title = 'Fictive Stream @ Time';
      case 'ensemble'
         title = 'Ensemble of Traces @ Repeat Index';
      case 'average'
         title = 'Average over Matrix @ Repeat Index';
      case 'spread'
         title = 'Spread @ Repeat Index';
      case 'deviation'
         title = 'Deviation @ Repeat Index';
      case {'condensate1','condensate2','condensate3'}
         s=arg(o,1);  n = sscanf(s(end:end),'%f');
         title = sprintf('Order %g Condensate @ Repeat Index',n);
         
         % analysis labeling
         
      case 'path'
         title = 'Matrix Path @ 2D';  style = 'analysis';
      case 'zigzag'
         title = 'Zig-Zag Path @ 2D';  style = 'analysis';
      case 'arrow'
         title = 'Arrow Plot @ 2D';  style = 'analysis';
         
      otherwise
         return                        % other plot modes not supported!
   end
   what(o,title,comment);
   o = what(o,title,comment);          % store also in options
   o = opt(o,'mode.cook',plotmode);
%
% now dispatch on labeling style
%
   switch style
      case 'plain'                     % plain style labeling
         LabelsPlain(o);    
      case 'statistics'                % statistics style labeling
         LabelsStatistics(o); 
      case 'analysis'
         LabelsAnalysis(o);
      otherwise
         'ignore';
   end
   return
end

function LabelsPlain(o)                % Plain Style Labels            
%
   plotmode = PlotMode(o);
   
   imax = subplot(o,inf);
   jmax = config(o,inf);
   [specs,limits,units] = category(o);
   
   for (i=1:imax)                      % for all subplots
      subplot(o,i);                    % select configured subplot
      xlab = '';  ylab = '';           % init x- and y-label
      comma = '';                      % init comma separator
      labels = {};                     % legend labels                    
      
      tokens = config(o,{i});
      for (j=1:length(tokens))         % for all streams
         [sym,sub,col,cat] = config(o,tokens{j});
         if ~(sub == i && cat > 0 || isempty(col)) 
            continue                   % proceed only for matching subplot
         end

         if length(units) < cat
            unit = '1';
         else
            unit = units{cat};         % get unit
         end
         
         ylab = [ylab,comma,sym,' [',unit,']'];
         labels{end+1} = [sym,' [',unit,']'];
         comma = ', ';                 % comma seperator for next time
      end
      
      if (i == 1)                      % only for 1st subplot
         tit = Title(o);
         if o.is(tit)
            title(tit);
         end
      end
   
      switch plotmode
         case 'overlay'
            Xlabel(o,'Position Index of Overlay');
         case 'offsets'
            Xlabel(o,'Position Index of Offsets');
         case 'repeatability'
            Xlabel(o,'Position Index of Repeatability');
         case {'residual1','residual2','residual3'}
            Xlabel(o,['Position Index of Residual ',plotmode(end)]);

         case 'ensemble'
            xlabel('Iteration Index of Ensemble');
         case 'average'
            xlabel('Iteration Index of Average');
         case 'spread'
            xlabel('Iteration Index of 3*Sigma');
         case 'deviation'
            xlabel('Iteration Index of Deviation');
         case {'condensate1','condensate2','condensate3'}
            s=arg(o,1);  n = sscanf(s(end:end),'%f');
            xlabel(sprintf('Iteration Index of Condensate %g',n));
         otherwise
            xlabel(sprintf('time [%s]',TimeUnit(o)));
      end
      
      if ~isempty(ylab)
         ylabel(ylab);
         if opt(o,{'style.legend',0})
            hdl = legend(labels);      % add legend if activated
            set(hdl,'Location','Best');
         end
      end
   end
   return
end
function LabelsStatistics(o)           % Statistics Style Labels       
%
   digits = opt(o,{'style.digits',2});
   rd = @o.rd;                         % need some util
   is = @o.is;                         % need some util
   %ignore = opt(o,{'select.ignore',0});    % nmb. of data points to ignore
   
   t = cook(o,':','stream');                % get time
   if isempty(t)
      return
   end
   
   T = [t(end)-t(1)]/length(t);             % average cycle time
   uph = sprintf('%g UPH',rd(3600/T,-1));   % units per hour
%
% now loop for all supported traces
%
   imax = subplot(o,inf);
   jmax = config(o,inf);
   [specs,limits,units] = category(o);

   for (i=1:imax)                      % for all subplots
      labels = {};                     % legend labels                    
      ylab = '';                       % init y-label
      comma = '';                      % init comma separator
      tokens = config(o,{i});
      for (j=1:length(tokens))         % for all streams
         [sym,sub,col,cat] = config(o,tokens{j});
         if (cat == 0 || sub ~= i  || isempty(col)) 
            continue                   % proceed only for matching subplot
         end
         if ~isempty(units) && cat <= length(units)
            unit = units{cat};         % get unit
         else
            unit = '';
         end
         ylab = [ylab,comma,sym,' [',unit,']'];
         labels{end+1} = [sym,' [',unit,']'];
         comma = ', ';                 % comma seperator for next time
      end
      
      subplot(o,i);
      if ~isempty(ylab)
         ylabel(ylab);
         if opt(o,{'style.legend',0})
            hdl = legend(labels);      % add legend if activated
            set(hdl,'Location','Best');
         end
      end
   end
   
   
   xlab = '';                          % init x-label
   mtxt = '';  stxt = '';              % init mean & sigma text
   ltxt = '';  ctxt = '';              % init label text & class txt
   cptxt = ''; cpktxt = '';            % init cp and cpk text
   utxt = '';                          % init unit text
   comma = '';                         % initially empty comma separator
   slash = '';                         % initially empty slash separator

   count = 0;
   for (i=1:imax)                      % for all subplots
      tokens = config(o,{i});
      for (j=1:length(tokens))         % for all streams
         count = count+1;
         [sym,sub,col,cat] = config(o,tokens{j});
         if (sub == 0 || isempty(col)) 
            continue                   % proceed only for matching subplot
         end

         if ~isempty(units) && cat <= length(units) && cat > 0
            unit = units{cat};         % get unit
         else
            unit = '';
         end
         if ~isempty(specs) && cat <= size(specs,1) && cat > 0
            spec = specs(cat,:);       % get spec
         else
            spec = [0 0];
         end
         class = diff(spec)/2;         % spec class

         if all(spec==0)
            %continue                  % ignore if spec = [0 0]
         end

         d = cook(o,sym);
         d = d(:)';

         %   % ignore some data points for statistical calculation

         %d = d(ignore+1:length(d));

         [Cpk,Cp,sig,avg,mini,maxi] = capa(with(o,'select'),d(:)',spec);

         mtxt = [mtxt,slash,sprintf('%g',rd(avg,digits))]; % mean text
         stxt = [stxt,slash,sprintf('%g',rd(sig,digits))]; % sigma text
         ltxt = [ltxt,slash,sym,];                         % label text
         cptxt = [cptxt,slash,sprintf('%g',rd(Cp))];       % Cp text
         cpktxt = [cpktxt,slash,sprintf('%g',rd(Cpk))];    % Cpk text

         ctxt = [ctxt,slash,sprintf('%g%s',class,unit)];
         utxt = [utxt,slash,unit];

         slash = '/';                  % slash seperator for next time
         comma = ', ';                 % comma seperator for next time
      end
   end
   
   tit = Title(o);
   leader = [ltxt,' @ ',ctxt,':  '];
   if count <= 1
      trailer = ['  @ ',ctxt];
   else
      trailer = ['  @ ',ltxt,' [',ctxt,']'];
   end
   cpklab = ['Cpk = ',cpktxt];
   cplab = ['Cp = ',cptxt];
   mstxt = ['mean = ',mtxt,',  sigma = ',stxt,' @ ',ltxt,' [',utxt,']'];
   
   plotmode = PlotMode(o);
   
   switch imax                         % number of subplots?
      case 1
         subplot(o,1);
         title([tit,'  [',plotmode,']',':  ',mstxt]);
         if is(cpktxt) && is(cptxt) && any(spec)
            xlabel([cpklab,',  ',cplab,trailer]);
         end
         
      case 2
         subplot(o,1);
         title([tit,'  [',plotmode,']']);
         xlabel(mstxt);                % mean and sigma text
         subplot(o,2);
         if is(cpktxt) && is(cptxt) && any(spec)
            title([cpklab,',  ',cplab,trailer]);
         end
         
         switch lower(arg(o,1))
            case {'ensemble','average','spread','deviation'}
               xlabel(sprintf('matrix [#]  (%s)',uph));
            case {'overlay','offsets','repeatability',...
                  'residual1','residual2','residual3'}
               xlabel(sprintf('position [#]  (%s)',uph));
            otherwise
               xlabel(sprintf('time [%s]  (%s)',TimeUnit(o),uph));
         end

      case 3
         subplot(o,1);
         title([tit,'  [',plotmode,']']);
         subplot(o,2);
         title(mstxt);                 % mean and sigma text
         subplot(o,3);
         if any(spec)
            title([cpklab,',  ',cplab,trailer]);
         end
         xlabel(sprintf('time [%s]  (%s)',TimeUnit(o),uph));
   end
   return
end
function LabelsAnalysis(o)             % Analysis Style Labels         
%
   pair = what(o);                     % fetch plot info
   tit = Title(o);
   tit = [tit,' [',pair{1},']'];
   title(tit);
%
% dispatch on plot mode
%
   plotmode = PlotMode(o);
   switch plotmode  
      case {'path','zigzag'}
         ylabel('magenta: system 1, green: system2');
      case 'arrow'
         ylabel('green: 1.33x in spec, yellow: in spec, red: out of spec');
   end
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function [mode,order] = PlotMode(o)    % Extract Plot Mode             
   mode = lower(opt(o,{'mode.plot','Stream'}));
end
function title = Title(o)              % Get Proper Title Text         
   title = get(o,'title');
   if ~isempty(title)
      title = o.underscore(title);
      style = opt(o,{'style.title','original'});
      if isequal(style,'package')
         package = get(o,'package');
         if ~isempty(package)
            title = [title,' (',package,'.',upper(o.type),')'];
         end
      end
   end
end
function unit = TimeUnit(o)            % Get Time Unit                 
   xscale = opt(o,{'scale.xscale',0});
   switch xscale
      case 1e9
         unit = 'ns';
      case 1e6
         unit = 'µs';
      case 1000
         unit = 'ms';
      case 1
         unit = 's';
      case 1/60
         unit = 'min';
      case 1/3600
         unit = 'h';
      otherwise
         unit = '?';
   end
end
function Xlabel(o,xtext)               % Set X-Label                   
   overlays = opt(o,'overlays');
   if isequal(overlays,'index')
      xlabel(xtext);
   elseif isequal(overlays,'time')
      xlabel(sprintf('time [%s]',TimeUnit(o)));
   else
      error('bad overlays mode!');
   end
end
   
