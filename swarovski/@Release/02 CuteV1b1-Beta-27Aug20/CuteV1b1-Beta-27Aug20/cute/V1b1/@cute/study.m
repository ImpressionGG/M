function oo = study(o,varargin)        % Do Some Studies               
%
% STUDY   Several studies
%
%       oo = study(o,'Menu')     % setup study menu
%
%       oo = study(o,'Study1')   % raw signal
%       oo = study(o,'Study2')   % raw & filtered signal
%       oo = study(o,'Study3')   % filtered
%       oo = study(o,'Study4')   % signal noise
%
%    See also: CUTE, PLOT, ANALYSIS
%
   [gamma,o] = manage(o,varargin,@Error,@Menu,@WithCuo,...
                        @ObjectTree,...
                        @GenericFilter,@ClusterFilter,...
                        @Cluster,@Relevant,@ClusterSigma,...
                        @CachePolar,@CacheBrew);
   oo = gamma(o);                   % invoke local function
end

%==========================================================================
% Menu Setup & Common Menu Callback
%==========================================================================

function oo = Menu(o)                  % Setup Study Menu              
   if ~setting(o,{'study.menu',1})
      visible(o,0);
      oo = o; return
   end
 
   oo = mitem(o,'Select');
   ooo = mitem(oo,'Print Object Tree',{@study,'ObjectTree'},[]);

   oo = mitem(o,'Filter');
   ooo = mitem(oo,'Generic Filter Study',{@WithCuo,'GenericFilter'},[]);
   ooo = mitem(oo,'Cluster Filter Study',{@WithCuo,'ClusterFilter'},[]);
   
   oo = mitem(o,'-');
   oo = mitem(o,'Cluster');
   ooo = mitem(oo,'Cluster',{@WithCuo,'Cluster'},[]);
   ooo = mitem(oo,'Relevant',{@WithCuo,'Relevant'},[]);
   ooo = mitem(oo,'Sigma Step',{@WithCuo,'ClusterSigma'},[]);

      % Caching
      
   oo = mitem(o,'-');
   oo = mitem(o,'Cache');
   ooo = mitem(oo,'Polar Example',{@WithCuo,'CachePolar'},[]);
   ooo = mitem(oo,'Polar Brewing',{@WithCuo,'CacheBrew'},[]);
end

%=========================================================================
% General Callback and Acting on Basket
%=========================================================================

function oo = WithCuo(o)               % General Callback              
%
% WITHCUO    A general callback with refresh function redefinition, screen
%            clearing, current object pulling and forwarding to executing
%            local function, reporting of irregularities, dark mode support
%
   refresh(o,o);                       % remember to refresh here
   cls(o);                             % clear screen
 
   oo = current(o);                    % get current object
   gamma = eval(['@',mfilename]);
   oo = gamma(oo);                     % forward to executing method

   if isempty(oo)                      % irregulars happened?
      oo = set(o,'comment',...
                 {'No idea how to plot object!',get(o,{'title',''})});
      message(oo);                     % report irregular
   end
   dark(o);                            % do dark mode actions
end
function o = Basket(o)                 % Acting on the Basket          
%
% BASKET  Plot basket, or perform actions on the basket, screen clearing, 
%         current object pulling and forwarding to executing local func-
%         tion, reporting of irregularities and dark mode support
%
   refresh(o,o);                       % use this callback for refresh
   cls(o);                             % clear screen

   gamma = eval(['@',mfilename]);
   oo = basket(o,gamma);               % perform operation gamma on basket
 
   if ~isempty(oo)                     % irregulars happened?
      message(oo);                     % report irregular
   end
   dark(o);                            % do dark mode actions
end

%==========================================================================
% Select Studies
%==========================================================================

function o = ObjectTree(o)             % Print Object Tree             
   refresh(o,o);                       % remember to refresh here

   tree = select(o);
   for (i=1:length(tree))
      list = tree{i};                  % package list
      fprintf('package %s\n',get(list{1},{'title','?'}));
      for (j=2:length(list))
         oo = list{j};                 % package object
         fprintf('   object %s\n',get(oo,{'title','?'}));
      end
   end
   message(o,'object tree printed to console!');
end

%==========================================================================
% Filter Studies
%==========================================================================

function o = GenericFilter(o)          % Generic Filter Study          
   if exist('@trf/trf') == 0
      comment = {'Study only possible with installed TRF toolbox!'};
      message(o,'Cannot do study!',comment);
      return
   end
   
   o = arg(o,{});                      % clear args
   oo = filter(with(o,'cfilter'));
      
      % setup a TRF transfer function
      
   om = opt(oo,'bandwidth')*2*pi;
   zeta = opt(oo,'zeta');
   Fs = trf(1,{},{[om zeta]});
   
   type = opt(oo,'type');
   if o.is(type,'LowPass4')
      Fs = Fs*Fs; 
   end
   Fs = inherit(Fs,oo);
   
      % define time vector and input signal
      
   t = 0:0.01:100;
   u = sign(sin(0.1*pi*t));  u(1) = 0;
   
      % calculate filter response and plot
      
   epilog = sprintf('(%s, bandwidth:%g, zeta:%g)',type,om/2/pi,zeta);
   
   ya = FilterResponse(oo,u,t,[3 1 1],epilog);   
   yb = TrfResponse(Fs,u,t,[3 1 2],epilog); 
   DeviationResponse(o,ya-yb,t,[3 1 3]);   
   closeup(o);                         % add closeup sliders
   
   comment = {'filter outputs must match!','deviation must be small'};
   what(o,'Check Matching Responses!',comment); 
   return
      
   function y = FilterResponse(o,u,t,sub,epilog)                       
      subplot(sub(1),sub(2),sub(3));
      y = filter(o,u,t);
      
      is = @isequal;                   % short hand
      mode = opt(o,'mode');
      if (is(mode,'raw') || is(mode,'both'))
         plot(corazon(o),t,u,'r');
      end
      if (is(mode,'filter') || is(mode,'both'))
         hold on
         plot(corazon(o),t,y,'c');
      end
      
      title(['Facette Filter Response ',epilog]);
      grid(o);
   end
   function y = TrfResponse(o,u,t,sub,epilog)                          
      subplot(sub(1),sub(2),sub(3));
      
      method = opt(o,{'method',0});
      switch method
         case 0
            y = rsp(o,u,t)';
         case 1
            y1 = u(1) + rsp(o,u-u(1),t);
            v = u(end:-1:1);              % reversed u
            y2 = v(1) + rsp(o,v-v(1),t);
            y = [y1 + y2(end:-1:1)]' / 2; % average fore/back responses
         case 2
            y1 = u(1) + rsp(o,u-u(1),t);
            v = u(end:-1:1);              % reversed u
            y2 = v(1) + rsp(o,v-v(1),t);
            y = [y1 + y2(end:-1:1)]' / 2; % average fore/back responses
      end

      is = @isequal;                   % short hand
      mode = opt(o,'mode');
      if (is(mode,'raw') || is(mode,'both'))
         plot(corazon(o),t,u,'r');
      end
      if (is(mode,'filter') || is(mode,'both'))
         hold on
         plot(corazon(o),t,y,'c');
      end
      
      title(['TRF Filter Response ',epilog]);
      grid(o);
   end
   function DeviationResponse(o,dy,t,sub)                              
      subplot(sub(1),sub(2),sub(3));
      
      plot(corazon(o),t,dy,'m');

      title(['Deviation of Responses (Facette Filter - TRF)']);
      ylabel('y(Filter) - y(TRF)');
      set(gca,'ylim',[-0.1 0.1]);
      grid(o);
   end
end
function o = ClusterFilter(o)          % Cluster Filter Study          
   if exist('@trf/trf') == 0
      comment = {'Study only possible with installed TRF toolbox!'};
      message(o,'Cannot do study!',comment);
      return
   end
   
   o = arg(o,{});                      % clear args
   oo = filter(with(o,'cfilter'));
      
      % setup a TRF transfer function
      
   om = opt(oo,'bandwidth')*2*pi;
   zeta = opt(oo,'zeta');
   Fs = trf(1,{},{[om zeta]});
   
   type = opt(oo,'type');
   if o.is(type,'LowPass4')
      Fs = Fs*Fs; 
   end
   Fs = inherit(Fs,oo);
   
      % define time vector and input signal
      
   t = cook(o,':');
   u = cook(o,'ar#');
   
      % calculate filter response and plot
      
   epilog = sprintf('(%s, bandwidth:%g, zeta:%g)',type,om/2/pi,zeta);
   
   ya = FilterResponse(oo,u,t,[3 1 1],epilog);   
   yb = TrfResponse(Fs,u,t,[3 1 2],epilog); 
   DeviationResponse(o,ya-yb,t,[3 1 3]);
   closeup(o);                         % add closeup sliders
   
   comment = {'filter outputs must match!','deviation must be small'};
   what(o,'Check Matching Responses!',comment); 
   return
      
   function y = FilterResponse(o,u,t,sub,epilog)                       
      subplot(sub(1),sub(2),sub(3));
      y = filter(o,u,t);

      is = @isequal;                   % short hand
      mode = opt(o,'mode');
      if (is(mode,'raw') || is(mode,'both'))
         plot(corazon(o),t,u,'r');
      end
      if (is(mode,'filter') || is(mode,'both'))
         hold on
         col = o.iif(opt(o,'style.bullets'),'c.','c');
         plot(corazon(o),t,y,col);
      end
      
      title(['Cluster Filter Response ',epilog]);
      grid(o);
   end
   function y = TrfResponse(o,u,t,sub,epilog)                          
      subplot(sub(1),sub(2),sub(3));
      
      method = opt(o,{'method',0});
      switch method
         case 0
            y = rsp(o,u,t)';
         case 1
            y1 = u(1) + rsp(o,u-u(1),t);
            v = u(end:-1:1);              % reversed u
            y2 = v(1) + rsp(o,v-v(1),t);
            y = [y1 + y2(end:-1:1)]' / 2; % average fore/back responses
         case 2
            y1 = u(1) + rsp(o,u-u(1),t);
            v = u(end:-1:1);              % reversed u
            y2 = v(1) + rsp(o,v-v(1),t);
            y = [y1 + y2(end:-1:1)]' / 2; % average fore/back responses
      end

      is = @isequal;                   % short hand
      mode = opt(o,'mode');
      if (is(mode,'raw') || is(mode,'both'))
         plot(corazon(o),t,u,'r');
      end
      if (is(mode,'filter') || is(mode,'both'))
         hold on
         col = o.iif(opt(o,'style.bullets'),'c.','c');
         plot(corazon(o),t,y,col);
      end

      title(['TRF Filter Response ',epilog]);
      grid(o);
   end
   function DeviationResponse(o,dy,t,sub)                              
      subplot(sub(1),sub(2),sub(3));
      plot(corazon(o),t,dy,'m');
      title(['Deviation of Responses (Facette Filter - TRF)']);
      ylabel('y(Filter) - y(TRF)');
      set(gca,'ylim',[-0.1 0.1]);
      grid(o);
   end
end

%==========================================================================
% Clustering
%==========================================================================

function o = Cluster(o)                %                               
   oo = current(o);
   t = cook(oo,':');
   ax = cook(oo,'ax');
   
   plot(corazon(o),t,ax,'y');
   hold on
   
   N = 40;                             % 10 Cluster
   Cp = 2.0;
   
   idx = Cluster2(ax,N,Cp);
   plot(t(idx),ax(idx),'r');
end   
function [idx,cl1,cl2] = Cluster1(f,N) %                               
   n = length(f);
   m = round(n/N);                  % interval length

   for (i=1:N)
      idx = Index(i,m,n);
      s(i) = sum(abs(f(idx)));
   end

   cl1 = [];  center1 = min(s);    % init cluster indices 1
   cl2 = [];  center2 = max(s);    % init cluster indices 2

   for (i=1:length(s))
      d1 = abs(s(i)-center1);
      d2 = abs(s(i)-center2);
      if (d1 < d2)
         cl1(end+1) = i;
         center1 = mean(s(cl1));
      else
         cl2(end+1) = i;
         center2 = mean(s(cl2));
      end
   end

      % determine index range of cluster 2

   lim = [inf,-inf];                % init index limits
   for (j=1:length(cl2))
      idx = Index(cl2(j),m,n);
      lim(1) = min(lim(1),idx(1));
      lim(2) = max(lim(2),idx(end));
   end
   idx = lim(1):lim(2);

   function idx = Index(i,m,n)
      idx = 1+(i-1)*m:min(i*m,n);
   end
end   
function idx = Cluster2(f,N,Cp)        %                               
   f = f.*f;
   n = length(f);
   m = round(n/N);                  % interval length

   for (i=1:N)
      idx = Index(i,m,n);
      sigma(i) = std(f(idx));
   end
   
   sig0 = min(sigma);
   jdx = find(sigma > 3*Cp*sig0);
   
   j1 = min(jdx);  j1 = max(1,j1-1);   % add 1 interval to the left
   j2 = max(jdx);  j2 = min(N,j2+1);   % add 1 interval to the right
   
   i1 = min(Index(j1,m,n));
   i2 = max(Index(j2,m,n));

   lim = [i1,i2];
   idx = lim(1):lim(2);
   
   function idx = Index(i,m,n)
      idx = 1+(i-1)*m:min(i*m,n);
   end
end

function o = ClusterSigma(o)           % Sigma Cluster Algorithm       
   [t,ax,ay,az] = data(o,'t,ax,ay,az');
   a = sqrt(ax.*ax + ay.*ay + az.*az); % radial acceleration
   
   subplot(211);
   plot(corazon(o),t,a,'r');
   
   subplot(212);
   ns = 200;                           % number of segments
   for (i=1:ns)
      idx = Segment(o,ns,i);
      sig(i) = std(a(idx));
      hold on
   end
   
   [sorted,kdx] = sort(sig);
   k = ceil(0.1*ns);
   sigk = sorted(k);
   
   for (i=1:ns)
      col = o.iif(sig(i) <= 10*sigk,'bo','ro');
      idx = Segment(o,ns,i);
      plot(t(idx),sig(i)*ones(size(idx)),col);
      hold on
   end
   
   function idx = Segment(o,ns,i)
      N = length(o.data.t);
      w = ceil(N/ns);
      
      i1 = min(N,(i-1)*w+1);
      i2 = min(N,(i-0)*w);

      idx = i1:i2;
   end
end

%==========================================================================
% Relevant
%==========================================================================

function o = Relevant(o)               % Relevant Data Points          
   oo = current(o);
   t = cook(oo,':');
   ax = cook(oo,'ax');
   
   plot(corazon(o),t,ax,'y');
   
   p = ax.*ax;
   idx = find(p >= 0.01*max(p));
   hold on
   plot(corazon(o),t(idx),ax(idx),'r');
end

%==========================================================================
% Caching
%==========================================================================

function o = CachePolar(o)             % Polar Cache Example           
   refresh(o,{@menu,'About'});         % avoid to refresh here
   
   oo = new(corazon,'Txy');            % create new 'txy' typed corazon
   oo = cute(oo);                      % cast to a cute object
   
      % pimp data
      
   oo.data.x(1) = 1/sqrt(2);           % to get r = 1
   oo.data.y(1) = 1/sqrt(2);           % and phi = pi/4 = 45°
   
      % paste into shell & provide polar setting
      % provide polar setting, fetch current object and plot
      
   paste(oo);
   
      % change polar setting to degrees, fetch current object,
      % refresh and conditionally store back to current object
     
   setting(o,'polar.deg',1);           % provide polar setting
   
   oo = current(o);
   oo = cache(oo,'polar');             % refresh & store back to cuo

   r = cache(oo,'polar.r');            % access cache variable r
   p = cache(oo,'polar.p');            % access cache variable p
   assert(p(1)==45);                   % p(1) must equal 45° 
   
      % change polar setting to radians, fetch current object,
      % refresh and conditionally store back to current object
     
   setting(o,'polar.deg',0);           % provide polar setting
   
   oo = current(o);
   oo = cache(oo,'polar');             % refresh & store back to cuo

   r = cache(oo,'polar.r');            % access cache variable r
   p = cache(oo,'polar.p');            % access cache variable p
   assert(p(1)==pi/4);                 % p(1) must equal pi/4

      % show status
      
   comment = {'Try the following command seqence:',...
              '1) cache(cuo) -> cache should be up-to-date!',...
              '2) setting(sho,''polar.deg'',1)',...
              '3) cache(cuo) -> cache should be dirty now!',...
              '4) cache(cuo,''polar'') -> refreshes cache',...
              '5) cache(cuo) -> cache again up to date :-)'};
   message(o,'Polar cache test passed :-)',comment); 
   
   %plot(corazon(oo),'Show');
   %dark(o);
end
function o = CacheBrew(o)              % Polar Brew Benchmark          
   refresh(o,{@menu,'About'});         % avoid to refresh here
   
   oo = new(corazon,'Txy');            % create new 'txy' typed corazon
   oo = cute(oo);                      % cast to a cute object
   
      % pimp data and paste into shell
      
   oo.data.x(1) = 1/sqrt(2);           % to get r = 1
   oo.data.y(1) = 1/sqrt(2);           % and phi = pi/4 = 45°
   paste(oo);                          % paste object into shell
   
      % 1st benchmark
      
   n = 500; tic
   for (i=1:n)
      oo = opt(oo,'polar.deg',1);      % change polar option
      p = cache(oo,'polar.p');         % access cache variable p
 
      oo = opt(oo,'polar.deg',0);      % change polar option
      p = cache(oo,'polar.p');         % access cache variable p
   end
   elapse = toc;
   ms1 = elapse/n/2 * 1e3;
   
      % show status
      
   message(o,'Polar cache test with brewing',...
             {sprintf('%g ms per access',o.rd(ms1,2))}); 
   shg; pause(0.01);
   
      % 2nd benchmark
          
   setting(oo,'polar.deg',1);          % change polar settings
   oo = current(o);
   oo = cache(oo,'polar');

   n = 500; tic
   for (i=1:n)
      r = cache(oo,'polar.r');         % access cache variable p
      p = cache(oo,'polar.p');         % access cache variable p
   end
   elapse = toc;
   ms2 = elapse/n/2 * 1e3;

      % show status
      
   message(o,'Polar cache test with brewing',...
      {sprintf('%g ms per access with each time brewing',o.rd(ms1,2)),...
       sprintf('%g ms per access with caching',o.rd(ms2,2))}); 

end
