function oo = signal(o,varargin)       % Signal Method                 
%
% SIGNAL   Definition building blocks for signal menu
%
%             cfg = 't,x[µ]:r,y[µ]:b'; % configuration string 
%             signal(o,txt,'X/Y','XY') % add Signal menu item
%
%             o = signal(o,label,tag)  % add a signal option to object
%             signal(o,label,tag)      % add a signal setting to shell
%
%             o = signal(o,[])         % reset object's signal options
%             signal(o,[])             % reset shell's signal settings
%
%             oo = signal(o,NaN);      % refresh signal menu
%             signal(o,oo)             % unconditional signal setting
%             signal(o,{oo})           % conditional signal setting
%
%             oo = signal(o,'Config'); % signal configuration callback
%
%             o = signal(o,bag)        % set bag to object's signal options
%             signal(o,bag)            % set bag to shell's signal settings
%
%             bag = signal(o)          % get structure of signal options
%             signal(o)                % display all signal options
%             signal(sho)              % display all signal settings
%
%          Standard Setups
%
%             o = signal(o,'xy')       % red x[µ], blue y[µ]
%             o = signal(o,'xyth')     % red x[y], blue y[y], green th[m°]
%
%          Remark: the standard setup will change the object's options if
%          an output arg is provided, otherwise affects the shell settings
%
%          Example 1: Define a signal menu with three entries for a
%          'play' typed CARAMEL object
%
%             o = caramel('play');
%             o = category(o,1,[],[],'µ')
%
%             o = config(o,[]);
%             o = config(o,'x',{1,'r',1}); 
%             o = config(o,'y',{2,'b',1});
%             o = signal(o,'X and Y','XandY');
%
%             o = config(o,[]);
%             o = config(o,'x',{1,'r',1}); 
%             o = signal(o,'X','X');
%
%             o = config(o,[]);
%             o = config(o,'y',{2,'b',1}); 
%             o = signal(o,'Y','Y');
%
%          Example 2: Define a signal menu with two entries for a 'pbi'
%          typed CARAMEL object
%
%             o = caramel('pbi');     
%             o = category(o,1,[-2 2],[],'µ')
%             o = category(o,2,[-20 20],[],'m°')
%
%             o = config(o,[]);
%             o = config(o,'x',{1,'r',1}); 
%             o = config(o,'y',{2,'b',1});
%             o = signal(o,'X and Y','XandY');
%
%             o = config(o,[]);
%             o = config(o,'x',{1,'r',1}); 
%             o = config(o,'y',{1,'b',1});
%             o = config(o,'th',{2,'g',2});
%             o = signal(o,'X/Y and Theta','XYandTh');
%
%          See also: CARAMEL, CONFIG, CATEGORY, SUBPLOT
%
   [gamma,o] = Manage(o,varargin,nargout);
   if (nargout > 0)
      oo = gamma(o);
   else
      gamma(o);
   end
end

%==========================================================================
% Manage Input/Output Argument Lists of Method Signal
%==========================================================================

function [gamma,oo] = Manage(o,ilist,nout)                             
%
% MANAGE   Manage arg lists of signal method
%
   [Nargin,Nargout,in1,in2,in3] = o.args([{nout},ilist]);
%
% One input argument
% bag = signal(o) % get structure of signal entries
% signal(o) % display signal entries
%
   while (Nargin == 1)                                                 
      mode = o.either(arg(o,1),'');
      switch mode
         case 'Config'
%           Config(o)
            gamma = @Config;
            oo = arg(o,{arg(o,2)});    % pass arg2 over as new arg1
            return
         case '';
            'ok';                      % continue
         otherwise
            error(['bad mode: ',mode]);
      end
      
      if (Nargout == 0)
%        Display(o)
         gamma = @Display;             % signal(o)
         oo = arg(o,{0});              % indicate with arg1: nargout = 0
      else
%        bag = Retrieve(o)
         gamma = @Retrieve;            % bag = signal(o)
         oo = arg(o,{1});              % indicate with arg1: nargout = 1
      end
      return
   end
%   
% Two input args with arg2 being a struct or empty
% o = signal(o,bag) % set bag to object's signal settings
% o = signal(o,[]) % reset object's signal options
% signal(o,bag) % set bag to shell's signal settings
% signal(o,[]) % reset shell's signal options
%
   while (Nargin == 2) && (isstruct(in1) || isempty(in1))          
      bag = in1;                        % in1 arg has meaning of a bag
      if (Nargout == 0)
%        Bag(o,bag);                    % set bag to shell's signal settings
         gamma = @Bag;  oo = arg(o,{bag,0});
      else
%        oo = Bag(o,bag);               % set bag to object's signal options
         gamma = @Bag;  oo = arg(o,{bag,1});
      end
      return
   end
%   
% Two input args with arg2 being a string
% o = signal(o,'xy') % red x[µ], blue y[µ]
% o = signal(o,'xyth') % red x[y], blue y[y], green th[m°]
%
   while (Nargin == 2) && ischar(in1)                                
      mode = in1;                      % in1 arg has meaning of a mode
      if isequal(mode,'Config')
%        oo = Config(o);
         gamma = @Config;  oo = o;
         return
      end
      
      if (Nargout == 0)
%        Setup(o,mode);                % setup shell's signal settings
         gamma = @Setup;
         oo = arg(o,{mode,0});         % arg2 indicates nargout = 0
      else
%        oo = Setup(o,mode);           % setup object's signal options
         gamma = @Setup;
         oo = arg(o,{mode,1});         % arg2 indicates nargout = 1
      end
      return
   end
%   
% Two input args with arg2 being an object
% o = signal(o,NaN); % refresh Signal menu
%
   while (Nargin == 2) && isa(in1,'double') && isnan(in1)          
%     oo = Refresh(o);                 % refresh Signal menu items
      gamma = @Refresh;  oo = o;
      return
   end
%
% Two input args with second arg being an object
% signal(o,oo) % unconditional signal setting
%
   while (Nargin == 2) && isobject(in1)                              
      gamma = @UncondSetting;  oo = arg(o,{in1});
      return
   end
%
% Two input args with second arg being a list containing one object
% signal(o,{oo}) % conditional signal setting
%
   while (Nargin == 2) && length(in1) == 1 && iscell(in1) && isobject(in1{1})
      gamma = @CondSetting;  oo = arg(o,{in1{1}});
      return
   end
%
% Three input args
% o = signal(o,label,tag) % add a signal entry to object
% signal(o,label,tag) % add a signal entry to shell
%
   while (Nargin == 3)                                                 
      if (Nargout == 0)
%        Add(o,label,tag);             % add entry to shell's settings
         gamma = @Add;
         oo = arg(o,{in1,in2,0});      % arg3 indicates nargout = 0
      else
%        oo = Add(o,label,tag);        % add entry to object's options
         gamma = @Add;
         oo = arg(o,{in1,in2,1});      % arg3 indicates nargout = 1
      end
      return
   end
%
% Four input args
% cfg = 't,x[µ]:r,y[µ]:b'; % configuration string 
% signal(o,txt,'X/Y','XY') % add Signal menu item
%
   while(Nargin == 4)                                                  
      if (Nargout == 0)
%        Activate(o,cfg,lab,tag);      % activate signal menu item
         gamma = @Activate;
         oo = arg(o,{in1,in2,in3,0});  % arg4 indicates nargout = 0
      else
%        oo = Activate(o,cfg,lab,tag); % add entry to object's options
         gamma = @Activate;
         oo = arg(o,{in1,in2,in3,1});  % arg4 indicates nargout = 1
      end
      return
   end
%
% Any execution beyond this point is a syntax error!
%
   error('bad callig syntax!');
end

%==========================================================================
% Work Horses
%==========================================================================

function oo = Add(o,label,tag,nout)    % Add Signal Entry              
%
% ADD   Add signal entry to object's options or shell's settings. The label
%       (arg2) will show in the Signal menu, and tag (arg3) has to comply
%       to a MATLAB identifier syntax in order to support a structure field
%       of the signal options/settings.
%
%          Add(o,'X and Y','XandY',0)
%
%       The operation will add the following sub structure to the signal
%       options 'signal.<type>', where <type> is the object's type name.
%
%
   label = arg(o,1);  tag = arg(o,2);  nout = arg(o,3);
   
   bag.config = config(o);
   bag.category = category(o);
   bag.subplot = subplot(o);
   bag.tag = tag;
   bag.label = label;

      % get the signal option tag
      
   sigtag = Tag(o,[o.type,'.',tag]);   % get signal option's sub tag
   if (nout == 0)
      setting(o,sigtag,bag);           % store in shell's settings
   else
      oo = opt(o,sigtag,bag);          % add to signal options
      oo = arg(oo,{});                 % clear args
   end
end
function oo = Bag(o,bag,nout)          % Set Bag of Signal Options     
%
% BAG   Set signal options or reset signal optins
%
%          oo = Bag(o,bag,1)           % set object's options
%          oo = Bag(o,[],1);           % reset object's options
%          Bag(o,bag,0)                % set shell's signal settings
%          Bag(o,[],0);                % reset shell's signal settings
%
   if (nargin < 2)
      bag = arg(o,1);
   end
   if (nargin < 3)
      nout = arg(o,2);
   end
   
   if ~(isempty(bag) && isa(bag,'double') || isstruct(bag))
      error('bag (arg2) must be struct or empty!');
   end
   
   sigtag = Tag(o,o.type);             % get signal option's sub tag
   if (nout == 0)
      setting(o,sigtag,bag);
   else
      oo = opt(o,sigtag,bag);
   end
end
function oo = Retrieve(o)              % Retrieve Signal Options       
   sigtag = Tag(o,o.type);             % get signal option's sub tag
   oo = opt(o,sigtag);                 % retrieve options
end
function oo = Setup(o,mode,nout)       % Setup Signal Options          
%
% SETUP   Setup object's signal options or shell's signal settings
%
%            Setup(o,mode);            % setup shell's signal settings
%            oo = Setup(o,mode);       % setup object's signal options
%
%         where mode can have the following values
%
%            'xy'       % red x[µ], blue y[µ]
%            'xyth'     % red x[y], blue y[y], green th[m°]
%
   mode = arg(o,1);  nout = arg(o,2);
   tag = Tag(o);                       % get proper signal tag
   o = arg(o,{});                      % clear args
   
   o = config(o,[]);                  
   o = subplot(o,'layout',1);
   
   switch mode
      case 'xy'
         o = XY(o)
      case 'xyth'
         o = XYTh(o)
      otherwise
         o = Compose(o,mode);
   end
   
   if (nout >= 1)
      oo = o;
   else
      bag = opt(o,tag);                % retrieve bag of signal options
      setting(o,tag,bag);              % copy options to shell settings
   end
   return
   
   function o = XY(o)                  % X,Y Setup                     
   %
   % XY   Setup for red x[µ], blue y[µ]
   %      no spec limits
   %
      o = category(o,1,[],[],'µ');

      o = config(o,[]);
      o = config(o,'x',{1,'r',1}); 
      o = config(o,'y',{2,'b',1});
      o = signal(o,'X and Y','XandY');

      o = config(o,[]);
      o = config(o,'x',{1,'r',1}); 
      o = signal(o,'X','X');

      o = config(o,[]);
      o = config(o,'y',{2,'b',1}); 
      o = signal(o,'Y','Y');
   end
   function o = XYTh(o)                % X,Y,Theta Setup               
   %
   % XYTh Setup for red x[µ], blue y[µ], green th[m°]
   %      spec limits -2µ...2µ for x,y and -20...20m° for th
   %
      o = category(o,1,[-2 2],[],'µ')
      o = category(o,2,[-20 20],[],'m°')

      o = config(o,[]);
      o = config(o,'x',{1,'r',1}); 
      o = config(o,'y',{2,'b',1});
      o = signal(o,'X and Y','XandY');

      o = config(o,[]);
      o = config(o,'x',{1,'r',1}); 
      o = config(o,'y',{1,'b',1});
      o = config(o,'th',{2,'g',2});
      o = signal(o,'X/Y and Theta','XYandTh');

      o = config(o,[]);
      o = config(o,'x',{1,'r',1}); 
      o = signal(o,'X','X');

      o = config(o,[]);
      o = config(o,'y',{1,'b',1}); 
      o = signal(o,'Y','Y');

      o = config(o,[]);
      o = config(o,'th',{1,'g',2}); 
      o = signal(o,'Theta','Th');
      
      o = config(o,[]);
      o = config(o,'x',{1,'r',1}); 
      o = config(o,'y',{2,'b',1});
      o = config(o,'th',{3,'g',2});
      o = signal(o,'All','All');
   end
   function o = Compose(o,line)        % Compose a configuration       
      o = smart(o,line);               % parse configuration into object
   end
end
function tag = Tag(o,type)             % Compose Proper Tag            
%
% TAG   Get proper signal tag, which depends on type
%
%          tag = Tag(o)                % based on object's type
%          tag = Tag(o,type)           % based on explicite type
%
   if (nargin < 2)
      type = o.type;
   end
   tag = ['signal.',type];
end

function Display(o)                    % Display Signal Options        
   bag = opt(o,'signal');
   if isempty(bag)
      fprintf('   no signals configured!\n');
      return
   end
   
   types = fields(bag);
   for (k = 1:length(types))
      type = types{k};
      oo = caramel(type);              % working object
      
      fprintf('signal configuration: type ''%s''\n',type);
      bag = opt(o,Tag(o,type));
      if isempty(bag)
         fprintf('   no entries!\n');
      else
         tags = fields(bag);
         for (i=1:length(tags))
            tag = tags{i};
            entry = bag.(tag);
            fprintf(['   ',entry.tag,': label ''',entry.label,'''\n']);
            
            oo = subplot(oo,entry.subplot);
            subplot(oo);               % display subplot setting

            oo = category(oo,entry.category);
            category(oo);              % display categories

            oo = config(oo,entry.config);
            config(oo);                % display config
            
         end
      end
   end
end
function oo = Refresh(o)               % Refresh Signal Menu           
   atype = active(o);                  % get active type
   if isempty(atype)
      oo  = [];
      return                           
   end
   
   oo = type(pull(o),atype);           % change type of shell object
   bag = Retrieve(oo);                 % retrieve proper signal settings 

   if ~isempty(bag)
      tags = fields(bag);
      for (i=1:length(tags))
         tag = tags{i};
         entry = bag.(tag);
         oo = mitem(o,entry.label,{@signal 'Config'},tag);
      end
   end
   oo = o;
end
function o = Config(o,mode)            % get new configuration         
   mode = o.either(arg(o,1),'');

   atype = active(o);                  % get active type
%  [atype,cblist] = active(o);         % get active type
   if isempty(atype)
      oo  = [];
      return                           
   end
   
   oo = type(pull(o),atype);           % change type of shell object
   bag = Retrieve(oo);                 % retrieve proper signal settings 

   tags = fields(bag);
   idx = o.find(mode,tags);
   
   if (idx > 0)
      entry = bag.(mode);
      oo = type(o,atype);
      oo = config(oo,entry.config);    % get configuration
      oo = category(oo,entry.category);% get cattegory settings
      oo = subplot(oo,entry.subplot);  % get subplot options
      change(oo,'Config',mode);        % activate configuration
   end
end
function oo = CondSetting(o,oo)        % conditional sigopt setting    
   oo = arg(o,1);
   o = pull(o);
   
   bag = o.either(opt(o,'signal'),struct(''));
   otypes = fields(bag);               % get signal types

   bag = o.either(opt(oo,'signal'),struct(''));
   ootypes = fields(bag);              % get signal types
   
   for (i=1:length(ootypes))
      typ = ootypes{i};
      if o.find(typ,otypes) == 0       % if type not supported by settings
         ot = type(oo,typ);
         bag = Retrieve(ot);
         Bag(ot,bag,0);
      end
   end
end
function oo = UncondSetting(o,oo)      % unconditional sigopt setting  
   either = @o.either;                 % shorthand
   oo = arg(o,1);
   o = pull(o);
   
   bag = either(opt(oo,'signal'),struct(''));
   types = fields(bag);              % get signal types
   
   
   for (i=1:length(types))
      typ = types{i};
      ot = type(oo,typ);
      bag = Retrieve(ot);
      
      tags = fields(bag);
      for (j=1:length(tags))
         tag = tags{j};
         sigtag = Tag(o,[typ,'.',tag]);   % get signal option's sub tag
         chunk = bag.(tag);
         setting(o,sigtag,chunk);
      end
      %Bag(ot,bag,0);
   end
end
function oo = Activate(o,cfg,label,tag)% Activate a Signal Menu Item   
   cfg = arg(o,1);  label = arg(o,2);
   tag = arg(o,3);  nout = arg(o,4);
   
   oo = o;                             % copy object and clear
   oo.par = [];
   oo.data = [];
   oo.work = [];
   
   oo = smart(oo,cfg);                 % smart configuring of an object
   oo = signal(oo,label,tag);
   
   if (nout == 0)
      signal(oo,oo);
      %config(oo,oo);

      cblist = {@signal,'Config',tag};
      [oo,gamma] = call(o,cblist);
      gamma(oo);
      event(oo,'signal');              % actualize signal menu
   end
end
