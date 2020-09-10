function motmenu(obj,mode,callback)
%
% MOTMENU   Add motion menu to a motion figure or handle menu item
%
   if (nargin == 0) obj = {[],1000,10000,[0.03 1],'mm','Motion'}; end   % default settings
   
   if iscell(obj)
      if (nargin < 2) mode = ''; end
      create(obj,mode);     % create menu items
      return;
   end
      
% dispatch menu items

   LB = 'label';  CB = 'callback';  UD = 'userdata';  EN = 'enable';   % shorthands

   switch mode
   case 'eval'
      args = getargs(obj);
      smax = args{1};  vmax = args{2};  amax = args{3};  ts = args{4};  unit = args{5};  infotext = args{6};
      algo = ts(2);  ts = ts(1);
      eval(callback);
   case 'motion'
      args = getargs(obj);
      smax = args{1};  vmax = args{2};  amax = args{3};  ts = args{4};  unit = args{5};  infotext = args{6};
      carma.motion(smax,vmax,amax,ts,unit);
      setpar(2,mode);  % update actual callback function
      
   case 'duty'
      args = getargs(obj);
      smax = args{1};  vmax = args{2};  amax = args{3};  ts = args{4};  unit = args{5};  infotext = args{6};
      carma.duty(smax,vmax,amax,ts,unit);
      setpar(2,mode);  % update actual callback function
      
   case 'motion map'
      args = getargs(obj);
      smax = args{1};  vmax = args{2};  amax = args{3};  ts = args{4};  unit = args{5};  infotext = args{6};
      carma.motion({smax},vmax,amax,ts,unit);
      setpar(2,mode);  % update actual callback function
      
   case 'duty map'
      args = getargs(obj);
      smax = args{1};  vmax = args{2};  amax = args{3};  ts = args{4};  unit = args{5};  infotext = args{6};
      carma.duty({smax},vmax,amax,ts,unit);
      setpar(2,mode);  % update actual callback function
      
   case 'datacon'
      args = getargs(obj);
      ts = args{4};  algo = ts(2);  ts = ts(1);
      args{4} = [ts 0];
      setargs(obj,args);
      reinvoke(obj);
      
   case 'etel'
      args = getargs(obj);
      ts = args{4};  algo = ts(2);  ts = ts(1);
      args{4} = [ts 1];
      setargs(obj,args);
      reinvoke(obj);
      
   case 'hux'
      args = getargs(obj);
      ts = args{4};  algo = ts(2);  ts = ts(1);
      args{4} = [ts 2];
      setargs(obj,args);
      reinvoke(obj);
      
   case 'etel3'
      args = getargs(obj);
      ts = args{4};  algo = ts(2);  ts = ts(1);
      args{4} = [ts 3];
      setargs(obj,args);
      reinvoke(obj);
      
   case 'clone'
      args = getargs(obj);
      callback = getpar(2);
      figure;
      [men,obj] = create(args,callback);       % create menu
      reinvoke(obj);
      
   case 'wobble'
      args = getargs(obj);
      ts = args{4}; algo = ts(2);
      for (vmax=50:10:400)
         carma.motion([],vmax,10000,[0.03 algo]);  
         set(gca,'xlim',[0 40]);
         set(gca,'ylim',[-100 100]);
         pause;
      end
      
      
   otherwise
      error(sprintf('bad mode: %g',mode));
   end
   
%============================================================================================================

function args = getargs(itm)
%
% GETARGS  Get arguments from top menu item
%
   UD = 'userdata';
   men = get(itm,UD);   % top menu item
   args = get(men,UD);
   return;
   
   
function setargs(itm,args)
%
% SETARGS  Get arguments from top menu item
%
   UD = 'userdata';
   men = get(itm,UD);   % top menu item
   set(men,UD,args);
   return;
   
function par = getpar(i)
%
% GETPAR  Get parameter i from figure user data
%
   UD = 'userdata';
   pars = get(gcf,UD);
   par = pars{i};
   return;
   
function setpar(i,par)
%
% SETPAR  Set parameter i in figure user data
%
   UD = 'userdata';
   pars = get(gcf,UD);
   pars{i} = par;
   set(gcf,UD,pars);
   return;
   
   
function reinvoke(obj)
%
% REINVOKE  Reinvoke recent relevant callback after parameter changes
%
   callback = getpar(2);
   if (~isempty(callback))
      callback = sprintf('carma.motmenu(%20.20f,''%s'');',obj,callback);
      eval(callback);
   end
   return
   
function check(itm)
%
% CHECK    Activate menu item check and uncheck sibling items
%
   parent = get(itm,'parent');
   siblings = get(parent,'children');
   set(siblings,'check','off');
   set(itm,'check','on');
   return
   
function [men,obj] = create(args,callback)
%
% CREATE   Create menu items
%
%             men = create(args,callback);
%
%          User data of figure is composed of following list of variables:
%
%             userdata = {men, callback}
%
%          Meaning:
%             men:      menu handle of motion menu
%             callback: last invoked callback (empty if not applicable)
%
   iif = @carma.iif;
   LB = 'label';  CB = 'callback';  UD = 'userdata';  EN = 'enable';  CH = 'checked';  % shorthands
   
   if (nargin < 2) callback = ''; end
   
   smax = args{1};  vmax = args{2};  amax = args{3};
   ts = args{4};    algo = ts(2);  ts = ts(1);
   unit = args{5};  infotext = args{6};
   
   men = uimenu(gcf,LB,'Motion',UD,args);
   
   itm = uimenu(men,LB,'Velocity/Distance',CB,'carma.motmenu(gcbo,''motion'')',UD,men,EN,iif(isempty(smax),'off','on'));
   itm = uimenu(men,LB,'Acceleration/Jerk',CB,'carma.motmenu(gcbo,''duty'')',UD,men,EN,iif(isempty(smax),'off','on'));
   sub = uimenu(men,LB,'Map');
   itm = uimenu(sub,LB,'Motion Map',CB,'carma.motmenu(gcbo,''motion map'')',UD,men);
   itm = uimenu(sub,LB,'Duty Map',CB,'carma.motmenu(gcbo,''duty map'')',UD,men);
   sub = uimenu(men,LB,'Algorithm');
   itm = uimenu(sub,LB,'0: Datacon',CB,'carma.motmenu(gcbo,''datacon'')',UD,men, CH,iif(algo==0,'on','off'));
   itm = uimenu(sub,LB,'1: ETEL',CB,'carma.motmenu(gcbo,''etel'')',UD,men, CH,iif(algo==1,'on','off'));
   itm = uimenu(sub,LB,'2: HUX',CB,'carma.motmenu(gcbo,''hux'')',UD,men, CH,iif(algo==2,'on','off'));
   itm = uimenu(sub,LB,'3: ETEL',CB,'carma.motmenu(gcbo,''etel3'')',UD,men, CH,iif(algo==3,'on','off'));
   
   sub = uimenu(men,LB,'Arguments');
   ssmax = '';
   if (length(smax)==0)
      ssmax = '[]';
   elseif (length(smax)==1)
      ssmax = sprintf('%g %s',smax,unit);
   else
      ssmax = sprintf('[%g',smax(1));
      for (i=2:length(smax))
         ssmax = [ssmax,sprintf(',%g',smax(i))];
      end
      ssmax = [ssmax,'] ',unit];
   end
   
   itm = uimenu(sub,LB,sprintf('Distance: %s',ssmax), UD,men, EN,'off');
   itm = uimenu(sub,LB,sprintf('Max. Velocity: %g %s/s',vmax,unit), UD,men, EN,'off');
   itm = uimenu(sub,LB,sprintf('Max. Acceleration: %g %s/s^2',amax,unit), UD,men, EN,'off');
   itm = uimenu(sub,LB,sprintf('S-Time: %g ms',ts*1000),UD,men, EN,'off');
   itm = uimenu(sub,LB,sprintf('Algorithm: %g',algo),UD,men, EN,'off');
   
   chk = uimenu(men,LB,'Examples');
   sub = uimenu(chk,LB,'ts = 0');
   itm = uimenu(sub,LB,'motion([],1000,10000,0)',UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion([],1000,10000,[0 algo])'')');
   itm = uimenu(sub,LB,'motion(50,1000,10000,0)',UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(50,1000,10000,[0 algo])'')');
   itm = uimenu(sub,LB,'motion(100,1000,10000,0)',UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(100,1000,10000,[0 algo])'')');
   itm = uimenu(sub,LB,'motion(150,1000,10000,0)',UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(150,1000,10000,[0 algo])'')');
   
   sub = uimenu(chk,LB,'tc > ts');
   itm = uimenu(sub,LB,'motion([],400,10000,0.03)',UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion([],400,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(1,400,10000,0.03)',UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(1,400,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(2.25,400,10000,0.03)',UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(2.25,400,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(6,400,10000,0.03)',UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(6,400,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(9,400,10000,0.03)',UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(9,400,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(12,400,10000,0.03)',UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(12,400,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(16,400,10000,0.03)',UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(16,400,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(24,400,10000,0.03)',UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(24,400,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(28,400,10000,0.03)',UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(28,400,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(36,400,10000,0.03)',UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(36,400,10000,[0.03 algo])'')');
   
   sub = uimenu(chk,LB,'tc = ts');
   itm = uimenu(sub,LB,'motion([],300,10000,0.03)',  UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion([],300,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(1,300,10000,0.03)',   UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(1,300,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(2.25,300,10000,0.03)',UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(2.25,300,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(6,300,10000,0.03)',   UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(6,300,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(9,300,10000,0.03)',   UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(9,300,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(12,300,10000,0.03)',  UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(12,300,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(18,300,10000,0.03)',  UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(18,300,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(25,300,10000,0.03)',  UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(25,300,10000,[0.03 algo])'')');
   
   sub = uimenu(chk,LB,'tc < ts');
   itm = uimenu(sub,LB,'motion([],200,10000,0.03)',  UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion([],200,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(1,200,10000,0.03)',   UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(1,200,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(2.25,200,10000,0.03)',UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(2.25,200,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(3,200,10000,0.03)',  UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(3,200,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(4,200,10000,0.03)',  UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(4,200,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(5,200,10000,0.03)',  UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(5,200,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(6,200,10000,0.03)',   UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(6,200,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(8,200,10000,0.03)',   UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(8,200,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(10,200,10000,0.03)',  UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(10,200,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(12,200,10000,0.03)',  UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(12,200,10000,[0.03 algo])'')');
   
   sub = uimenu(chk,LB,'tc << ts');
   itm = uimenu(sub,LB,'motion([],100,10000,0.03)',  UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion([],100,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(0.5,100,10000,0.03)',   UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(0.5,100,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(1,100,10000,0.03)',UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(1,100,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(1.5,100,10000,0.03)',   UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(1.5,100,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(2,100,10000,0.03)',   UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(2,100,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(2.5,100,10000,0.03)',  UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(2.5,100,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(3,100,10000,0.03)',  UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(3,100,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(3.5,100,10000,0.03)',  UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(3.5,100,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(4,100,10000,0.03)',  UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(4,100,10000,[0.03 algo])'')');
   itm = uimenu(sub,LB,'motion(6,100,10000,0.03)',  UD,men,CB,'carma.motmenu(gcbo,''eval'',''carma.motion(6,100,10000,[0.03 algo])'')');
   
   itm = uimenu(chk,LB,'Wobble', UD,men,CB,'carma.motmenu(gcbo,''wobble'')');
   
   obj = uimenu(men,LB,'Clone Window',CB,'carma.motmenu(gcbo,''clone'')',UD,men);
   
   %uimenu(gcf,LB,'Update',CB,'carma.motmenu(gcbo,''motion map'')',UD,men);
   
   set(gcf,UD,{men,callback});   % store menu handle in user data of figure
   
% eof   