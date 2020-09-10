function fisimenu(obj,mode,cbo)
% 
% FISIMENU  Filter demo menu
%
%             fisimenu               % setup CHAMEO object and open menu
%
%          See also   CHAMEO SETUP MENU GFO TWIN KAFI REFI

%==========================================================================
% 1) setup CHAMEO object and open menu
  
   if (nargin == 0)
      title = 'Filter Simulation';
      comment = {'We study several filters, such as'
                 '1) Ordinary Order 1 Filters (PT1)'
                 '2) Twin Filters (TWIN)'
                 '3) Enhanced Twin Filters (XTWIN)'
                 '4) Kalman Filters (KAFI)'
                 '5) Regression Filters (REFI)'
                };
      obj = setup(chameo,'GMA',mfilename,title,comment);
      menu(obj);
      %set(gcf,'position',get(0,'monitorposition'));
      return
   end
   
%==========================================================================
% 2) handle a call for setting up user defined menu

  if (nargin == 1)
      LB = 'label';  CB = 'callback';  UD = 'userdata';   % shorthands  
      EN = 'enable'; MF = mfilename;                      % shorthands
      
% Menu Setup: View

      men = uimenu(gcf,LB,'View');
            uimenu(men,LB,'Standard Menues',CB,'fisimenu(gfo,''menu'')');
            uimenu(men,LB,'Grid on/off',CB,'grid;');
            uimenu(men,LB,'Standard Window Size',CB,'set(gcf,''position'',[50,100,1100,600])');

% Menu Setup: Test Functions
            
      men = uimenu(gcf,LB,'Test Functions');
            uimenu(men,LB,'Deterministic Noise',CB,'fisimenu(gfo,''deterministic'')');
            uimenu(men,LB,'Show Current Test Function', CB,'fisimenu(gfo,''test'')');
            uimenu(men,LB,'--------------------------------------------');
            uimenu(men,LB,'Exponential Curve, V = 50, T = 35',CB,callback(MF,'reference','[1,50 35]'));
            uimenu(men,LB,'Symmetric Ramp, T = 10',CB,callback(MF,'reference','[2 10 35 100]'));
            uimenu(men,LB,'Asymmetric Ramp, T = 2',CB,callback(MF,'reference','[3 2 35 100]'));
            uimenu(men,LB,'Square Wave, T = 5', CB,callback(MF,'reference','[4 5]'));
            uimenu(men,LB,'Time Varying System, T = 35', CB,callback(MF,'reference','[5 50 35]'));
            uimenu(men,LB,'--------------------------------------------');
      itm = uimenu(men,LB,'Exponential Curves');
            uimenu(itm,LB,'Breaks, V = 5, T = 35',    CB,callback(MF,'reference','[1 5 35 30 100]'));
            uimenu(itm,LB,'Breaks, V = 10,T = 35',    CB,callback(MF,'reference','[1 10 35 30 100]'));
            uimenu(itm,LB,'Breaks, V = 20,T = 35',    CB,callback(MF,'reference','[1 20 35 30 100]'));
            uimenu(itm,LB,'Breaks, V = 50,T = 35 !!!',CB,callback(MF,'reference','[1 50 35 30 100]'));
            uimenu(itm,LB,'--------------------------');
            uimenu(itm,LB,'Continuous, V = 50, T = 20',    CB,callback(MF,'reference','[1 50 20 100]'''));
            uimenu(itm,LB,'Continuous, V = 50, T = 35 !!!',CB,callback(MF,'reference','[1 50 35 100]'''));
            uimenu(itm,LB,'Continuous, V = 50, T = 60',    CB,callback(MF,'reference','[1 50 60 100]'''));
      itm = uimenu(men,LB,'Symmetric Ramps');
            uimenu(itm,LB,'Symmetric Ramp, T = 1',CB,callback(MF,'reference','[2 1 35 30 100]'));
            uimenu(itm,LB,'Symmetric Ramp, T = 2',CB,callback(MF,'reference','[2 2 35 30 100]'));
            uimenu(itm,LB,'Symmetric Ramp, T = 5',CB,callback(MF,'reference','[2 5 35 30 100]'));
            uimenu(itm,LB,'Symmetric Ramp, T = 10 !!!',CB,callback(MF,'reference','[2 10 35 30 100]'));
            uimenu(itm,LB,'Symmetric Ramp, T = 20',CB,callback(MF,'reference','[2 20 35 30 100]'));
      itm = uimenu(men,LB,'Asymmetric Ramps');
            uimenu(itm,LB,'Asymmetric Ramp, T = 1',CB,callback(MF,'reference','[3 1 35 30 100]'));
            uimenu(itm,LB,'Asymmetric Ramp, T = 2 !!!',CB,callback(MF,'reference','[3 2 35 30 100]'));
            uimenu(itm,LB,'Asymmetric Ramp, T = 5',CB,callback(MF,'reference','[3 5 35 30 100]'));
            uimenu(itm,LB,'Asymmetric Ramp, T = 10',CB,callback(MF,'reference','[3 10 35 30 100]'));
            uimenu(itm,LB,'Asymmetric Ramp, T = 20',CB,callback(MF,'reference','[3 20 35 30 100]'));
      itm = uimenu(men,LB,'Square Waves');
            uimenu(itm,LB,'Square Wave, T = 1', CB,callback(MF,'reference','[4 1 35 30 100]'));
            uimenu(itm,LB,'Square Wave, T = 2', CB,callback(MF,'reference','[4 2 35 30 100]'));
            uimenu(itm,LB,'Square Wave, T = 5 !!!', CB,callback(MF,'reference','[4 5 35 30 100]'));
            uimenu(itm,LB,'Square Wave, T = 10', CB,callback(MF,'reference','[4 10 35 30 100]'));
            uimenu(itm,LB,'Square Wave, T = 20', CB,callback(MF,'reference','[4 20 35 30 100]'));
            uimenu(men,LB,'--------------------------------------------');
            uimenu(men,LB,'Zoom Symmetric Ramp',CB,callback(MF,'reference','[2 10 0.2 35 10]'));
            uimenu(men,LB,'Zoom Asymmetric Ramp',CB,callback(MF,'reference','[3 2 0.2 35 50]'));

 % Menu Setup: Filter Simulation
            
      men = uimenu(gcf,LB,'Filter Simulation');
            uimenu(men,LB,'Uniform Filter Time Constant',CB,callback(MF,'uniform'));
            uimenu(men,LB,'------------------------');
            uimenu(men,LB,'NOFI (1)  -  No Filter',CB,callback(MF,'filter','{''orfi'',1}'));
            uimenu(men,LB,'ORFI (0)  -  Ordinary PT1 Filter',CB,callback(MF,'filter','{''orfi'',0}'));
            uimenu(men,LB,'TWIN (1)  -  Twin Filter - Type 1',CB,callback(MF,'filter','{''twin'',1}'));
            uimenu(men,LB,'XTWIN (2) -  XTwin Filter - Type 2',CB,callback(MF,'filter','{''twin'',2}'));
            uimenu(men,LB,'ATWIN (3) -  ATwin Filter - Type 3',CB,callback(MF,'filter','{''twin'',3}'));
            uimenu(men,LB,'DKAFI (1) -  Kalman Filter - Type 1 (DI)',CB,callback(MF,'filter','{''kafi'',1}'));
            uimenu(men,LB,'PKAFI (2) -  Kalman Filter - Type 2 (PT1)',CB,callback(MF,'filter','{''kafi'',2}'));
            uimenu(men,LB,'SKAFI (3) -  Kalman Filter - Type 3 (Scalar)',CB,callback(MF,'filter','{''kafi'',3}'));
            uimenu(men,LB,'TKAFI (4) -  Kalman Filter - Type 4 (Twin)',CB,callback(MF,'filter','{''kafi'',4}'));
            uimenu(men,LB,'REFI (1)  -  Regression Filter - Type 1',CB,callback(MF,'filter','{''refi'',1}'));
            uimenu(men,LB,'------------------------');
      itm = uimenu(men,LB,'Tf: Filter Time Constant');
            uimenu(itm,LB,'Tf = 0.1',CB,callback(MF,'Tf','0.1'));
            uimenu(itm,LB,'Tf = 0.25',CB,callback(MF,'Tf','0.25'));
            uimenu(itm,LB,'Tf = 0.5',CB,callback(MF,'Tf','0.5'));
            uimenu(itm,LB,'Tf = 0.75',CB,callback(MF,'Tf','0.75'));
            uimenu(itm,LB,'Tf = 1.0',CB,callback(MF,'Tf','1.0'));
            uimenu(itm,LB,'Tf = 1.25',CB,callback(MF,'Tf','1.25'));
            uimenu(itm,LB,'Tf = 1.5',CB,callback(MF,'Tf','1.5'));
            uimenu(itm,LB,'Tf = 1.75',CB,callback(MF,'Tf','1.75'));
            uimenu(itm,LB,'Tf = 2.0',CB,callback(MF,'Tf','2.0'));
            uimenu(itm,LB,'Tf = 2.25',CB,callback(MF,'Tf','2.25'));
            uimenu(itm,LB,'Tf = 2.5',CB,callback(MF,'Tf','2.5'));
            uimenu(itm,LB,'Tf = 2.75',CB,callback(MF,'Tf','2.75'));
            uimenu(itm,LB,'Tf = 3.0',CB,callback(MF,'Tf','3.0'));
            uimenu(itm,LB,'Tf = 3.25',CB,callback(MF,'Tf','3.25'));
            uimenu(itm,LB,'Tf = 3.5',CB,callback(MF,'Tf','3.5'));
            uimenu(itm,LB,'Tf = 3.75',CB,callback(MF,'Tf','3.75'));
            uimenu(itm,LB,'Tf = 4.0',CB,callback(MF,'Tf','4.0'));
            uimenu(itm,LB,'Tf = 4.25',CB,callback(MF,'Tf','4.25'));
            uimenu(itm,LB,'Tf = 4.5',CB,callback(MF,'Tf','4.5'));
            uimenu(itm,LB,'Tf = 4.75',CB,callback(MF,'Tf','4.75'));
            uimenu(itm,LB,'Tf = 5.0',CB,callback(MF,'Tf','5.0'));
      itm = uimenu(men,LB,'Kp: Kalman Parameter');
            uimenu(itm,LB,'Kp = 0.1',CB,callback(MF,'Kp','0.1'));
            uimenu(itm,LB,'Kp = 0.2',CB,callback(MF,'Kp','0.2'));
            uimenu(itm,LB,'Kp = 0.3',CB,callback(MF,'Kp','0.3'));
            uimenu(itm,LB,'Kp = 0.4',CB,callback(MF,'Kp','0.4'));
            uimenu(itm,LB,'Kp = 0.5',CB,callback(MF,'Kp','0.5'));
            uimenu(itm,LB,'Kp = 0.6',CB,callback(MF,'Kp','0.6'));
            uimenu(itm,LB,'Kp = 0.7',CB,callback(MF,'Kp','0.7'));
            uimenu(itm,LB,'Kp = 0.8',CB,callback(MF,'Kp','0.8'));
            uimenu(itm,LB,'Kp = 0.9',CB,callback(MF,'Kp','0.9'));
            uimenu(itm,LB,'Kp = 1.0',CB,callback(MF,'Kp','1.0'));
      itm = uimenu(men,LB,'Nx: Extra Measurements After Break');
            uimenu(itm,LB,'Nx = 0',CB,callback(MF,'Nx','[0]'));
            uimenu(itm,LB,'Nx = 1',CB,callback(MF,'Nx','[1]'));
            uimenu(itm,LB,'Nx = 2',CB,callback(MF,'Nx','[2]'));
            uimenu(itm,LB,'Nx = 3',CB,callback(MF,'Nx','[3]'));
            uimenu(men,LB,'------------------------');
      itm = uimenu(men,LB,'Number of simulation runs Ns');
            uimenu(itm,LB,'Ns = 1',CB,callback(MF,'Ns','1'));
            uimenu(itm,LB,'Ns = 5',CB,callback(MF,'Ns','5'));
            uimenu(itm,LB,'Ns = 30',CB,callback(MF,'Ns','30'));
            uimenu(itm,LB,'Ns = 50',CB,callback(MF,'Ns','50'));
            uimenu(itm,LB,'Ns = 100',CB,callback(MF,'Ns','100'));
            uimenu(itm,LB,'Ns = 200',CB,callback(MF,'Ns','200'));
            uimenu(itm,LB,'Ns = 500',CB,callback(MF,'Ns','500'));
            uimenu(itm,LB,'Ns = 1000',CB,callback(MF,'Ns','1000'));
      
% Menu Setup: Optimal Behavior
        
      men = uimenu(gcf,LB,'Optimal Behavior');
      itm = uimenu(men,LB,'Exponential Curve');
            uimenu(itm,LB,'Exponential Curve, V = 50, T = 35',CB,callback(MF,'reference','[1,50 35]'));
            uimenu(itm,LB,'--------------------------------------------');
            uimenu(itm,LB,'ORFI(0): Tf = 0.5',CB,callback(MF,'filter','{''orfi'',0, 0.5,0.6}'));
            uimenu(itm,LB,'TWIN(1): Tf = 1.25',CB,callback(MF,'filter','{''twin'',1, 1.25,0.1}'));
            uimenu(itm,LB,'XTWIN(2): Tf = 1.25, Kp = 0.3',CB,callback(MF,'filter','{''twin'',2, 1.25,0.3}'));
            uimenu(itm,LB,'ATWIN(3): Tf = 1, Kp = 0.6',CB,callback(MF,'filter','{''twin'',3, 1,0.6}'));
            uimenu(itm,LB,'DKAFI(1): Tf = 2, Kp = 0.3',CB,callback(MF,'filter','{''kafi'',1, 2,0.3}'));
            uimenu(itm,LB,'PKAFI(2): Tf = 0.5, Kp = 0.4',CB,callback(MF,'filter','{''kafi'',2, 0.5,0.4}'));
            uimenu(itm,LB,'SKAFI(3): Tf = 0.5, Kp = 0.2',CB,callback(MF,'filter','{''kafi'',3, 0.5,0.2}'));
            uimenu(itm,LB,'TKAFI(4): Tf = 1.5, Kp = 0.1',CB,callback(MF,'filter','{''kafi'',4, 1.5,0.1}'));
            uimenu(itm,LB,'REFI(1): Tf = 2.8, Kp = 0.8',CB,callback(MF,'filter','{''refi'',1, 2.8,0.8}'));
      itm = uimenu(men,LB,'Asymmetric Ramp');
            uimenu(itm,LB,'Asymmetric Ramp, T = 2',CB,callback(MF,'reference','[3 2]'));
            uimenu(itm,LB,'--------------------------------------------');
            uimenu(itm,LB,'ORFI(0): Tf = 0.3',CB,callback(MF,'filter','{''orfi'',0, 0.3,0.6}'));
            uimenu(itm,LB,'TWIN(1): Tf = 0.75',CB,callback(MF,'filter','{''twin'',1, 0.75,0.1}'));
            uimenu(itm,LB,'XTWIN(2): Tf = 0.75, Kp = 0.1',CB,callback(MF,'filter','{''twin'',2, 0.75,0.1}'));
            uimenu(itm,LB,'ATWIN(3): Tf = 2.5, Kp = 0.1',CB,callback(MF,'filter','{''twin'',3, 2.5,0.1}'));
            uimenu(itm,LB,'DKAFI(1): Tf = 0.1, Kp = 0.1',CB,callback(MF,'filter','{''kafi'',1, 0.1,0.1}'));
            uimenu(itm,LB,'PKAFI(2): Tf = 0.3, Kp = 0.1',CB,callback(MF,'filter','{''kafi'',2, 0.3,0.1}'));
            uimenu(itm,LB,'SKAFI(3): Tf = 0.5, Kp = 0.2',CB,callback(MF,'filter','{''kafi'',3, 0.5,0.2}'));
            uimenu(itm,LB,'TKAFI(4): Tf = 0.8, Kp = 0.1',CB,callback(MF,'filter','{''kafi'',4, 0.8,0.1}'));
            uimenu(itm,LB,'REFI(1): Tf = 0.3, Kp = 0.1',CB,callback(MF,'filter','{''refi'',1, 0.3,0.1}'));
      itm = uimenu(men,LB,'Symmetric Ramp');
            uimenu(itm,LB,'Symmetric Ramp, T = 10',CB,callback(MF,'reference','[2 10]'));
            uimenu(itm,LB,'DKAFI(1): Tf = 3, Kp = 0.3',CB,callback(MF,'filter','{''kafi'',1,3,0.3}'),EN,'off');
            uimenu(itm,LB,'PKAFI(2): Tf = 4, Kp = 0.4',CB,callback(MF,'filter','{''kafi'',2,4,0.4}'),EN,'off');
            uimenu(itm,LB,'REFI(1): Tf = 2.5, Kp = 0.6',CB,callback(MF,'filter','{''refi'',1,2.5,0.6}'),EN,'off');
      itm = uimenu(men,LB,'Zoom Asymmetric Ramp');
            uimenu(itm,LB,'Zoom Asymmetric Ramp, T = 2 (2.7 Sigma)',CB,callback(MF,'reference','[3 2 0.2 35 50]'));
            uimenu(itm,LB,'--------------------------------------------');
            uimenu(itm,LB,'ORFI(0): Tf = 0.25 (4.1 Sigma)',CB,callback(MF,'filter','{''orfi'',0,0.25,0.1,0}'));
            uimenu(itm,LB,'DKAFI(1.3): Tf = 0.75, Kp = 0.1 (3.7 Sigma)',CB,callback(MF,'filter','{''kafi'',1,0.75,0.1,3}'));
            uimenu(men,LB,'------------------------');
            uimenu(men,LB,'Filter Analysis (5 runs)',CB,callback(MF,'analysis','5'));
            uimenu(men,LB,'Filter Analysis (15 runs)',CB,callback(MF,'analysis','15'));
            uimenu(men,LB,'Filter Analysis (30 runs)',CB,callback(MF,'analysis','30'));
            uimenu(men,LB,'Filter Analysis (50 runs)',CB,callback(MF,'analysis','50'));
            uimenu(men,LB,'Filter Analysis (100 runs)',CB,callback(MF,'analysis','100'));
            uimenu(men,LB,'Filter Analysis (200 runs)',CB,callback(MF,'analysis','200'));
            uimenu(men,LB,'Filter Analysis (400 runs)',CB,callback(MF,'analysis','400'));
            uimenu(men,LB,'Filter Analysis (1000 runs)',CB,callback(MF,'analysis','1000'));

% Menu Setup: Principles
            
      men = uimenu(gcf,LB,'Principles');
            uimenu(men,LB,'Filter Cpk 1x(filtercpk(1))',CB,handle(obj,MF,'filtercpk(1)'));
            uimenu(men,LB,'Filter Cpk 3x (filtercpk(3))',CB,handle(obj,MF,'filtercpk(3)'));
            uimenu(men,LB,'Filter Cpk 30x (filtercpk(30))',CB,handle(obj,MF,'filtercpk(30)'));
            uimenu(men,LB,'Kalman Demo 1 @ PT1-Glied (kaldemo1)',CB,handle(obj,MF,'kaldemo1'));
            uimenu(men,LB,'Kalman Demo 2 @ PT1-Glied (kaldemo2)',CB,handle(obj,MF,'kaldemo2'));
            uimenu(men,LB,'Kalman Demo 3 @ Doppelintegrierer (kfidemo3)',CB,handle(obj,MF,'kafidemo3'));
            uimenu(men,LB,'Kalman Demo 4 @ Doppelintegrierer (kfidemo4)',CB,handle(obj,MF,'kafidemo4'));

            
% Initializing and setup key press function

      set(gcf,'WindowButtonDownFcn','fisimenu(gfo,''keypress'')');

      setud('callback','');
      setud('deterministic',0);
      setud('uniform',0);              % uniform filter time constant
      setud('kind','twin');            % filter kind
      setud('type',2);                 % filter type
      setud('Tf',3);                   % filter time constant Tf = 3
      setud('Kp',0.1);                 % filter parameter Kp = 0.1
      setud('Ns',1);                   % number of runs per parameter set

      setud('ref.mode',1);             % reference: exponential curve
      setud('ref.V',50);               % reference: V  = 50
      setud('ref.T',35);               % reference: T = 35
      setud('ref.T1',30);              % reference: T1 = 30
      setud('ref.Ts',0.2);             % reference: Ts = 0.2
      setud('ref.Tmax',100);           % reference: Tmax = 100
      setud('ref.Nx',0);               % reference: Nx = 0

      return
   end
   
%==========================================================================
% 3) handle menu callbacks - start with auxillary menu handlers

   switch mode
      case 'handle'
         det = getud('deterministic');
         ref = getud('ref');            % reference
         cb = [cbo,';'];
         eval(cb);                      % execute callback
         setud('callback',cb);          % save callback for future repeats
         return
         
      case 'keypress'
         det = getud('deterministic');
         ref = getud('ref');            % reference
         kind = getud('kind'); 
         typ = getud('type'); 
         Tf = getud('Tf'); 
         Kp = getud('Kp');

         cb = getud('callback');
         clrscr
         eval(cb);
         return
   end

%==========================================================================
% View Menu

   switch mode
      case 'menu'
         itm = gcbo;   % get menu item handle
         if strcmp(get(itm,'checked'),'on')
            set(gcf,'menubar','none');
            set(itm,'checked','off');
         else
            set(gcf,'menubar','figure');
            set(itm,'checked','on');
         end
         return
       
      case 'deterministic'
         itm = gcbo;   % get menu item handle
         if strcmp(get(itm,'checked'),'on')
            set(itm,'checked','off');
            setud('deterministic',0);
         else
            set(itm,'checked','on');
            setud('deterministic',1);
         end
         return
   end
   
%==========================================================================
% Test Function Menu

   switch mode
      case 'test'   % show current test function
         showref;          
         return

      case 'reference'   % exponential curve
         if (length(cbo) >= 1) setud('ref.mode',cbo(1)); end
         if (length(cbo) >= 2) setud('ref.V',cbo(2));    end
         if (length(cbo) >= 3) setud('ref.T',cbo(3));    end
         if (length(cbo) >= 4) setud('ref.T1',cbo(4));   end
         if (length(cbo) >= 5) setud('ref.Tmax',cbo(5)); end
         showref;                % show reference
         return
   end
         
         
%==========================================================================
% Filter Simulation Function Menu

   switch mode

      case 'uniform'
         itm = gcbo;   % get menu item handle
         if strcmp(get(itm,'checked'),'on')
            set(itm,'checked','off');
            setud('uniform',0);
         else
            set(itm,'checked','on');
            setud('uniform',1);
         end
         return

      case 'analysis'
         setud('callback','');
         det = 0;                       % non deterministic
         ref = getud('ref');            % reference
         kind = getud('kind');          % filter kind
         typ = getud('type');           % filter type
         
         analysis(kind,{typ det ref},cbo);
         return

      case 'filter'                          % define filter kind, type, params
         kind = cbo{1};  setud('kind',kind); % filter kind
         typ = cbo{2};   setud('type',typ);  % filter type

         if (length(cbo) >= 3)
            Tf = cbo{3};  setud('Tf',Tf);    % filter time constant Tf
         end
         if (length(cbo) >= 4)
            Kp = cbo{4};  setud('Kp',Kp);    % filter parameter Kp
         end

         if (length(cbo) >= 5)
            Nx = cbo{5};  setud('ref.Nx',Nx);  % filter parameter Nx
         end
         
         filtersimu;             % filter simulation
         return

         
      case 'Tf'                  % define filter constant Tf
         setud('Tf',cbo); 
         filtersimu;             % filter simulation
         return
         
      case 'Kp'                  % define filter parameter Kp
         setud('Kp',cbo); 
         filtersimu;             % filter simulation
         return
         
      case 'Nx'                  % define number of extra measurements after break
         setud('ref.Nx',cbo); 
         filtersimu;             % filter simulation
         return
         
      case 'Ns'                  % define number of runs per parameter set
         setud('Ns',cbo); 
         filtersimu;             % filter simulation
         return

   end  

%==========================================================================
% Error if mode couldn't be handeled up to now

   error(['bad mode:  ',mode]);
   return
   
%==========================================================================
% 4) auxillary functions

function ud = getud(name)
   udata = get(gcf,'userdata');
   if (nargin == 0)
      ud = udata;
      return
   end
   eval(['ud = udata.',name,';']);
   return

function setud(name,ud)
   udata = get(gcf,'userdata');
   eval(['udata.',name,'=ud;']);
   set(gcf,'userdata',udata);
   return

function cb = callback(mfile,mode,cbo)
%
% CALLBACK   Create a callback string
%
   if (nargin == 2)
      cb = [mfile,'(gfo,''',mode,''');'];
      %cb = [mfile,'(gfo,''handle'',''',handler,''');'];      
   elseif (nargin == 3)
      cb = [mfile,'(gfo,''',mode,''',',cbo,');'];
   else 
       error('2 or 3 input args expected!');
   end
   return

function filtersimu
%
% FILTERSIMU   Filter Simulation; also setup a filter simulation
%              callback string for key press function
%
   det = getud('deterministic');
   ref = getud('ref');            % reference
   kind = getud('kind'); 
   typ = getud('type'); 
   Tf = getud('Tf'); 
   Kp = getud('Kp'); 
   Ns = getud('Ns'); 
   uniform = getud('uniform');
   if (uniform) typ = -typ; end
   
   cb = sprintf(['demo(''',kind,''',{%g,%g,ref},%g,%g,%g);'],typ,det,Tf,Kp,Ns);
   setud('callback',cb);
   
   cmd = [mfilename,'(gfo,''keypress'');'];
   eval(cmd);
   return

   
function showref
%
% SHOWREF    Show reference function
%
   ref = getud('ref');
   reference(ref);

   typ = getud('type');           % filter type
   kind = getud('kind');
   eval(sprintf(['F=',kind,'(%g);'],typ));
   ylabel(sprintf(['Filter to be applied: ',upper(F.kind),', type %g'],typ));
   return
   
% eof