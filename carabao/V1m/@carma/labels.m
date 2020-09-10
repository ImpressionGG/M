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
%    See also: CARALOG, PLOT, GRID, VARIATION
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
      case {'mean','offset'}
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
      case 'guerilla'                  % GUERILLA style labeling
         LabelsGuerilla(o); 
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
   units = opt(o,'category.units');
   
   for (i=1:imax)                      % for all subplots
      subplot(o,i);                    % select configured subplot
      xlab = '';  ylab = '';           % init x- and y-label
      comma = '';                      % init comma separator
      
      for (j=1:jmax)
         [sym,sub,~,cat] = config(o,j);
         if ~(sub == i && cat > 0) 
            continue                   % proceed only for matching subplot
         end
         
         unit = units{cat};            % get unit
         ylab = [ylab,comma,sym,' [',unit,']'];
         comma = ', ';                 % comma seperator for next time
      end
      
      if (i == 1)                      % only for 1st subplot
         tit = get(o,'title');
         if o.is(tit)
            title(underscore(o,tit));
         end
      end
   
      switch plotmode
         case 'ensemble'
            xlabel('Ensemble @ Iteration Number');
         case 'average'
            xlabel('Average @ Iteration Number');
         case 'spread'
            xlabel('3*Sigma @ Iteration Number');
         case 'deviation'
            xlabel('Deviation @ Iteration Number');
         case {'residual1','residual2','residual3'}
            s=arg(o,1);  n = sscanf(s(end:end),'%f');
            xlabel(sprintf('Residual %g @ Position Index',n));
         case {'condensate1','condensate2','condensate3'}
            s=arg(o,1);  n = sscanf(s(end:end),'%f');
            xlabel(sprintf('Condensate %g @ Iteration Number',n));
         otherwise
            xlabel(sprintf('time'));
      end
      ylabel(ylab);
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
   T = [t(end)-t(1)]/length(t);             % average cycle time
   uph = sprintf('%g UPH',rd(3600/T,-1));   % units per hour
%
% now loop for all supported traces
%
   imax = subplot(o,inf);
   jmax = config(o,inf);
   units = opt(o,'category.units');
   specs = opt(o,'category.specs');

   for (i=1:imax)                      % for all subplots
      ylab = '';                       % init y-label
      comma = '';                      % init comma separator
      for (j=1:jmax)                   % for all streams
         [sym,sub,~,cat] = config(o,j);
         if (cat == 0 || sub ~= i) 
            continue                   % proceed only for matching subplot
         end
         unit = units{cat};            % get unit
         ylab = [ylab,comma,sym,' [',unit,']'];
         comma = ', ';                 % comma seperator for next time
      end
      subplot(o,i);
      ylabel(ylab);
   end
   
   
   xlab = '';                          % init x-label
   mtxt = '';  stxt = '';              % init mean & sigma text
   ltxt = '';  ctxt = '';              % init label text & class txt
   cptxt = ''; cpktxt = '';            % init cp and cpk text
   utxt = '';                          % init unit text
   comma = '';                         % initially empty comma separator
   slash = '';                         % initially empty slash separator

   for (j=1:jmax)
      [sym,sub,~,cat] = config(o,j);
      if (sub == 0) 
         continue                      % proceed only for matching subplot
      end

      unit = units{cat};               % get unit
      spec = specs(cat,:);             % get spec
      class = diff(spec)/2;            % spec class
      
      if all(spec==0)
         %continue                      % ignore if spec = [0 0]
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
      
      slash = '/';                     % slash seperator for next time
      comma = ', ';                    % comma seperator for next time
   end

   tit = underscore(o,get(o,'title'));
   leader = [ltxt,' @ ',ctxt,':  '];
   trailer = ['  @ ',ltxt,' [',ctxt,']'];
   cpklab = ['Cpk = ',cpktxt];
   cplab = ['Cp = ',cptxt];
   mstxt = ['mean = ',mtxt,',  sigma = ',stxt,' @ ',ltxt,' [',utxt,']'];
   
   plotmode = PlotMode(o);
   
   switch imax                         % number of subplots?
      case 1
         subplot(o,1);
         title([tit,':  ',mstxt]);
         if is(cpktxt) && is(cptxt) && any(spec)
            xlabel([cpklab,',  ',cplab,trailer]);
         end
         
      case 2
         subplot(o,1);
         title([tit,'  (',plotmode,')']);
         xlabel(mstxt);                % mean and sigma text
         subplot(o,2);
         if is(cpktxt) && is(cptxt) && any(spec)
            title([cpklab,',  ',cplab,trailer]);
         end
         xlabel(sprintf('time    (%s)',uph));

      case 3
         subplot(o,1);
         title(tit);
         subplot(o,2);
         title(mstxt);                 % mean and sigma text
         subplot(o,3);
         if any(spec)
            title([cpklab,',  ',cplab,trailer]);
         end
         xlabel(sprintf('time    (%s)',uph));
   end
   return
end

function LabelsGuerilla(o)             % Guerilla Style Labels         
%
   t = cook(o,0,'stream');                  % get time
   T = t(end)/length(t);                    % average cycle time
   uph = sprintf('%g UPH',rd(3600/T,-1));   % units per hour
%
% now loop for all supported traces
%
   imax = subplot(o,inf);
   jmax = config(o,inf);
   units = opt(o,'category.units');
   specs = opt(o,'category.specs');
   
   for (i=1:imax)                      % for all subplots
      subplot(o,i);                    % select configured subplot
      xlab = '';  ylab = '';           % init x- and y-label
      mtxt = '';  stxt = '';           % init mean & sigma text
      ltxt = '';  ctxt = '';           % init label text & class txt
      cptxt = ''; cpktxt = '';         % init cp and cpk text
      comma = '';                      % initially empty comma separator
      slash = '';                      % initially empty slash separator
      class = 0;
      
      for (j=1:jmax)
         [sym,sub,~,cat] = config(o,j);
         if ~(sub == i && cat > 0) 
            continue                   % proceed only for matching subplot
         end
         
         unit = units{cat};            % get unit
         spec = specs(cat,:);          % get spec
         
         if all(spec==0)
            continue                   % cannot calculate Cp & Cpk values
         end
         
         ylab = [ylab,comma,sym,' [',unit,']'];
         
         d = cook(o,sym);
         [Cpk,Cp,sig,avg,mini,maxi] = capa(o,d(:)',spec);
          
         mtxt = [mtxt,slash,sprintf('%g',rd(avg)),unit];   % mean text
         stxt = [stxt,slash,sprintf('%g',rd(sig)),unit];   % sigma text
         ltxt = [ltxt,slash,sym];                          % label text
         cptxt = [cptxt,slash,sprintf('%g',rd(Cp))];       % Cp text
         cpktxt = [cpktxt,slash,sprintf('%g',rd(Cpk))];    % Cpk text

         if isempty(ctxt)
            class = diff(spec)/2;                          % spec class
            ctxt = sprintf('%g%s',class,unit);
         elseif (diff(spec)/2 ~= class)
            class = diff(spec)/2;
            ctxt = [ctxt,slash,sprintf('%g%s',class,unit)];
            class = inf;
         end
         
         slash = '/';                  % slash seperator for next time
         comma = ', ';                 % comma seperator for next time
      end
      
      tit = underscore(o,get(o,'title'));
      title([tit,': mean(',ltxt,'): ',mtxt,',  sigma(',ltxt,'): ',stxt]);
      xlabel([ctxt,'@Cpk: ',cpktxt,',  ',ctxt,'@Cp: ',cptxt,',  ',uph]);
      ylabel(ylab);
   end
   return
end

function LabelsAnalysis(o)             % Analysis Style Labels         
%
   pair = plotinfo(o);                 % fetch plot info
   tit = underscore(o,[get(o,'title'),' (',pair{1},')']);
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

function [mode,order] = PlotMode(o)            % Extract Plot Mode             
   mode = lower(opt(o,{'mode.plot','Stream'}));
end
