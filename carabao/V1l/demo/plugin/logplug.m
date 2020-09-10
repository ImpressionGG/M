function oo = logplug(o,varargin)      % Simple Plugin 1 Manager       
%
% HPXPLUG   Simple plugin demo function to allow log data import
%
%              logplug                 % register PBI plugin
%
%              oo = logplug(o,func)    % call local function of logplug
%
%         See also: CARABAO
%
   if (nargin == 0) || isempty(figure(o))
      o = pull(carabao);               % pull object from active shell
   end
   
   [gamma,oo] = manage(o,varargin,@Setup,@Register,@New,@Import,@Export,...
                       @Read,@Write,@Signal);
   oo = gamma(o);
end

%==========================================================================
% Plugin Registration
%==========================================================================

function o = Setup(o)                  % Setup Registration            
   o = Register(o);                    % register plugins
   rebuild(o);                         % rebuild menu
end
function o = Register(o)               % Plugin Registration           
   name = class(o);
   plugin(o,[name,'/shell/New'],{mfilename,'New'});
   plugin(o,[name,'/shell/Import'],{mfilename,'Import'});
   plugin(o,[name,'/shell/Export'],{mfilename,'Export'});
   plugin(o,[name,'/shell/Signal'],{mfilename,'Signal'});
end

%==========================================================================
% File Menu Plugins
%==========================================================================

function o = New(o)                    % New Simple Trace              
   % intentionally empty!
end
function o = Import(o)                 % Import from File              
   oo = mitem(o,'Log Data');
   ooo = mitem(oo,'TPX Log File (.tpx)',{@ImportCb,@TpxFile,'.tpx'});
   return
   function o = ImportCb(o)            % Import Log Data Callback      
      driver = arg(o,1);               % export driver
      ext = arg(o,2);                  % file extension
      
      caption = sprintf('Import TPX object from %s file',ext);
      [files, dir] = fselect(o,'i',ext,caption);

      list = {};                       % init: empty object list
      for (i=1:length(files))
         path = [dir,files{i}];           % construct path
         oo = Read(o,driver,path);        % call read driver function

            % returned object can either be container (kids list appends to
            % list) or non-container (which goes directly into list)

         if container(oo)
            list = [list,data(oo)];       % append container's kids to list
         else
            list{end+1} = oo;             % add imported object to list
         end
      end
      paste(o,list);
   end
end
function o = Export(o)                 % Export to File                
end

%==========================================================================
% View Menu
%==========================================================================

function o = Signal(o)                 % Signal Menu                   
   typ = type(current(o));
   if isequal(typ,'pbi')
      oo = mitem(o,'X and Y',{@SignalXY});
      oo = mitem(o,'Theta',{@SignalTh});
      oo = mitem(o,'X/Y and Theta',{@SignalXYTh});
   end
   
   tpxtypes = {'tpx1','tpx2','tpx12','tpx13'};
   if o.is(typ,tpxtypes)
      oo = mitem(o,'Upward Camera',{@ConfigUpCam});
   end
   if o.is(typ,'tpx12')
      oo = mitem(o,'Upward Camera 1',{@ConfigUpCam1});
      oo = mitem(o,'Upward Camera 2',{@ConfigUpCam2});
   end
   if o.is(typ,tpxtypes)
      oo = mitem(o,'A/B Actors',{@ConfigAB});
   end
   return
   
   function o = SignalXY(o)            % Configure for XY Signals      
      o = subplot(o,'layout',1);       % layout with 1 subplot column   
      o = config(o,[]);                % set all sublots to zero
      o = config(o,'x',{1,'r'});
      o = config(o,'y',{2,'b'});
      o = config(o,o);                 % update settings, rebuild & refresh
   end
   function o = SignalTh(o)            % Configure for Th Signal       
      o = subplot(o,'layout',1);       % layout with 1 subplot column   
      o = config(o,[]);                % set all sublots to zero
      o = config(o,'th',{1,'g'});
      o = config(o,o);                 % update settings, rebuild & refresh
   end
   function o = SignalXYTh(o)          % Configure for XY & Th Signal  
      o = subplot(o,'layout',1);       % layout with 1 subplot column   
      o = config(o,[]);                % set all sublots to zero
      o = config(o,'x',{1,'r'});
      o = config(o,'y',{1,'b'});
      o = config(o,'th',{2,'g'});
      o = config(o,o);                 % update settings, rebuild & refresh
   end

   function o = ConfigUpCam(o)                                         
      o = subplot(o,'layout',1);       % layout with 1 subplot column   
      o = config(o,[]);                % set all sublots to zero
      o = config(o,'ux',{1,'b'});
      o = config(o,'uy',{2,'c'});
      o = config(o,o);                 % update settings, rebuild & refresh
   end
   function o = ConfigAB(o)                                            
      o = subplot(o,'layout',2);       % layout with 1 subplot column   
      o = config(o,[]);                % set all sublots to zero
      o = config(o,'a',{1,'g'});
      o = config(o,'b',{2,'d'});
      o = config(o,'ia',{3,'r'});
      o = config(o,'ib',{4,'m'});
      o = config(o,o);                 % update settings, rebuild & refresh
   end
   function o = ConfigUpCam1(o)                                        
      o = subplot(o,'layout',2);       % layout with 1 subplot column   
      o = config(o,[]);                % set all sublots to zero
      o = config(o,'ux1',{1,'b'});
      o = config(o,'uy1',{2,'c'});
      o = config(o,o);                 % update settings, rebuild & refresh
   end
   function o = ConfigUpCam2(o)                                        
      o = subplot(o,'layout',1);       % layout with 1 subplot column   
      o = config(o,[]);                % set all sublots to zero
      o = config(o,'ux2',{1,'b'});
      o = config(o,'uy2',{2,'c'});
      o = config(o,o);                 % update settings, rebuild & refresh
   end
end

%==========================================================================
% Read Driver
%==========================================================================

function oo = Read(o,driver,filepath)  % Read CARAMEL Object To File   
%
% READ   Read a CARMA object from file.
%
%             oo = read(o,path,'LogData')
%
%          See also: CARMA, IMPORT, WRITE
%
   o = arg(o,{filepath});              % pack arguments
   switch char(driver)
      case 'TpxFile'
         oo = TpxFile(o);              % let read driver do the read job
      otherwise
         error('unknown driver!');
   end
   oo = launch(oo,launch(o));          % inherit launch function
end

%==========================================================================
% Read Driver for .tpx File
%==========================================================================

function oo = TpxFile(o)               % Read Driver for .tpx File     
   path = arg(o,1);                    % get path argument
   fid = fopen(path,'r');              % open tpx file for write
   if (fid < 0)
      error('cannot open export file');
   end
   
   line = fgetl(fid);
   while ~o.is(line,-1) && ~o.is(parameter(o,line),'format')
      line = fgetl(fid);
   end
   
   if isequal(parameter(o,line),'format')
      [~,format] = parameter(o,line);
   else
      message(o,'Error: Log file (.log) must provide $format parameter!');
      format = '';
   end
   fclose(fid);

      % dispatch format
      
   switch format
      case {'TextFile1','TextFile11','TextFile12','TextFile13','TextFile2'}
         gamma = eval(['@',format]);   % function handle
         oo = gamma(o);
         oo.par.comment = [['Type: ',oo.type],oo.par.comment];
      otherwise
         message(o,['Error: bad format "',format,'"!']);
         oo = [];
   end
end

%==========================================================================
% Text File Read #11
%==========================================================================

function oo = TextFile11(o)            % Read Driver #1 for .txt File  
%
% TEXT-FILE   Import Birgit's log data from a .txt file
%
   typ = 'tpx11';
   path = arg(o,1);                    % get path argument
   fid = fopen(path,'r');
   if (fid < 0)
      error('cannot open import file!');
   end
   
   [~,par.title,~] = fileparts(path);
   par.comment = {};   
   
   tline = fgetl(fid);
   while ~isempty(tline) && tline(1) == '$'
       if strfind(tline,'$title=') == 1
           par.title = sscanf(tline,'$title=%[^\n]');
           tline = fgetl(fid);
           continue
       elseif strfind(tline,'$date=') == 1
           par.date = sscanf(tline,'$date=%[^\n]');
           tline = fgetl(fid);
           continue
       elseif strfind(tline,'$time=') == 1
           par.time = sscanf(tline,'$time=%[^\n]');
           tline = fgetl(fid);
           continue
       elseif strfind(tline,'$format=') == 1
           par.time = sscanf(tline,'$format=%[^\n]');
           tline = fgetl(fid);
           continue
       elseif strfind(tline,'$comment=') == 1
           par.comment{end+1} = sscanf(tline,'$comment=%[^\n]');
           tline = fgetl(fid);
           continue
       end
       break;    
   end
      
      % trim date/time
      
   if (length(find(par.date=='/')) == 6)
      vec = sscanf(par.date,'%f/%f/%f/%f/%f/%f/%f')';
      str = datestr(vec(1:6));
      par.date = str(1:11);
      par.time = str(13:end);
   end
   
   if ~isempty(par.time) && ~isempty(par.date)
       par.title = [par.date, ' @ ', par.time, ' ', par.title];
   elseif ~isempty(par.time)
       par.title = [ par.time, ' ', par.title];
   elseif ~isempty(par.date)
       par.title = [ par.date, ' ', par.title];
   end
   
   tline = fgetl(fid);
   data_matrix = [];
   while ischar(tline) && size(data_matrix,1) < 10000
      vals = sscanf(tline, '%f/%f/%f/%f/%f/%f/%f %f %f %f %f %f %f %f');
      numvar = 14;
      if numel(vals) == numvar % if the line contains data, saveit in data
          data_matrix(end+1,:) = vals;
          cnt = size(data_matrix,1);
          if rem(cnt,5000)==0
              disp(sprintf('data point %d', cnt));
          end
      end
      tline = fgetl(fid);
   end
   fclose(fid);
   
   oo = caramel(typ);                  % create a (derived) CARAMEL object
   oo.tag = class(pull(o));            % inherit tag from shell class
   oo = balance(oo);                   % restore balance
   
   oo = SetData(oo,data_matrix,1.1);   % for format #1
   oo = SetPar(oo,par);

   oo = Config(oo,1.1);                % provide #1 configuration defaults
   oo = set(oo,'sizes',[1 length(oo.data.T) 1]);
end

%==========================================================================
% Text File Read #12
%==========================================================================

function oo = TextFile12(o)            % Read Driver #1 for .txt File  
%
% TEXT-FILE   Import Birgit's log data from a .txt file
%
   typ = 'tpx12';
   path = arg(o,1);                    % get path argument
   fid = fopen(path,'r');
   if (fid < 0)
      error('cannot open import file!');
   end
   
   [~,par.title,~] = fileparts(path);
   par.comment = {};   
   
   tline = fgetl(fid);
   while ~isempty(tline) && tline(1) == '$'
       if strfind(tline,'$title=') == 1
           par.title = sscanf(tline,'$title=%[^\n]');
           tline = fgetl(fid);
           continue
       elseif strfind(tline,'$date=') == 1
           par.date = sscanf(tline,'$date=%[^\n]');
           tline = fgetl(fid);
           continue
       elseif strfind(tline,'$time=') == 1
           par.time = sscanf(tline,'$time=%[^\n]');
           tline = fgetl(fid);
           continue
       elseif strfind(tline,'$format=') == 1
           par.time = sscanf(tline,'$format=%[^\n]');
           tline = fgetl(fid);
           continue
       elseif strfind(tline,'$comment=') == 1
           par.comment{end+1} = sscanf(tline,'$comment=%[^\n]');
           tline = fgetl(fid);
           continue
       end
       break;    
   end
      
      % trim date/time
      
   if (length(find(par.date=='/')) == 6)
      vec = sscanf(par.date,'%f/%f/%f/%f/%f/%f/%f')';
      str = datestr(vec(1:6));
      par.date = str(1:11);
      par.time = str(13:end);
   end
   
   if ~isempty(par.time) && ~isempty(par.date)
       par.title = [par.date, ' @ ', par.time, ' ', par.title];
   elseif ~isempty(par.time)
       par.title = [ par.time, ' ', par.title];
   elseif ~isempty(par.date)
       par.title = [ par.date, ' ', par.title];
   end
   
   tline = fgetl(fid);
   data_matrix = [];
   while ischar(tline) && size(data_matrix,1) < 10000
      vals = sscanf(tline, '%f/%f/%f/%f/%f/%f/%f %f %f %f %f %f %f %f %f %f');
      numvar = 16;
      if numel(vals) == numvar % if the line contains data, saveit in data
          data_matrix(end+1,:) = vals;
          cnt = size(data_matrix,1);
          if rem(cnt,5000)==0
              disp(sprintf('data point %d', cnt));
          end
      end
      tline = fgetl(fid);
   end
   fclose(fid);
   
   oo = caramel(typ);                  % create a (derived) CARAMEL object
   oo.tag = class(pull(o));            % inherit tag from shell class
   oo = balance(oo);                   % restore balance
   
   oo = SetData12(oo,data_matrix,1.1); % for format #1
   oo = SetPar(oo,par);

   oo = Config12(oo,1.1);              % provide #1 configuration defaults
   oo = set(oo,'sizes',[1 length(oo.data.T) 1]);
end
function o = SetData12(o,data_matrix,n)% Set Data                      
   vec = [1:length(data_matrix(:,1))];
   td = data_matrix(:,3)*24*60*60; %s
   th = data_matrix(:,4)*60*60; %s
   tm = data_matrix(:,5)*60; %s
   ts = data_matrix(:,6);
   ts_1000 = data_matrix(:,7)/1000; % s
   time = td + th + tm + ts + ts_1000;
   time_0 = time - time(1);
   o.data.t = time_0';
    
   x_search = data_matrix(:,8)/1000; %[um]
   x_search_offset = x_search-mean(x_search);
   y_search = data_matrix(:,9)/1000; %[um]
   y_search_offset = y_search-mean(y_search);
   o.data.ux1 = x_search_offset';
   o.data.uy1 = y_search_offset';
    
   x_search = data_matrix(:,10)/1000; %[um]
   x_search_offset = x_search-mean(x_search);
   y_search = data_matrix(:,11)/1000; %[um]
   y_search_offset = y_search-mean(y_search);
   o.data.ux2 = x_search_offset';
   o.data.uy2 = y_search_offset';
   
   x1 = data_matrix(:,12)*1000;   x1_offset = x1-mean(x1); % nm
   x2 = data_matrix(:,13)*1000;   x2_offset = x2-mean(x2); % nm
   x = mean([x1 x2],2);   x_offset = x-mean(x);
   o.data.ax = x'/1000;
   y = data_matrix(:,14)*1000;  y_offset = y-mean(y);      % nm
   o.data.ay = y'/1000;
   
   w = data_matrix(:,15);   x1_offset = x1-mean(x1); % nm
   o.data.w = w';
   T = data_matrix(:,16)/10; 
   o.data.T = T';
   
   o.data.ux = o.data.ux2 - o.data.ux1;
   o.data.uy = o.data.uy2 - o.data.uy1;
end
function o = Config12(o,n)             % Provide Configuration Defaults
   o = category(o,1,[0 0],[0 0],'µ');  % category 1 for ux,uy,ax,ay
   o = category(o,2,[0 0],[0 0],'°C'); % category 2 for T
   o = category(o,3,[0 0],[0 0],'A');  % category 3 for currents

   o = config(o,'ux',{1,'b',1});
   o = config(o,'uy',{1,'c',1});
   o = config(o,'ax',{2,'n',1});
   o = config(o,'ay',{2,'m',1});
   o = config(o,'T', {0,'r',2});
   o = config(o,'ux1',{3,'b',1});
   o = config(o,'uy1',{3,'c',1});
   o = config(o,'ux2',{4,'b',1});
   o = config(o,'uy2',{4,'c',1});
   o = config(o,'w', {0,'g',1});
end

%==========================================================================
% Text File Read #13
%==========================================================================

function oo = TextFile13(o)            % Read Driver #13 for .tpx File 
%
% TEXT-FILE   Import Birgit's log data from a .tpx file
%
   typ = 'tpx13';
   path = arg(o,1);                    % get path argument
   fid = fopen(path,'r');
   if (fid < 0)
      error('cannot open import file!');
   end
   
   [~,par.title,~] = fileparts(path);
   par.comment = {};   
   
   tline = fgetl(fid);
   while ~isempty(tline) && tline(1) == '$'
       if strfind(tline,'$title=') == 1
           par.title = sscanf(tline,'$title=%[^\n]');
           tline = fgetl(fid);
           continue
       elseif strfind(tline,'$date=') == 1
           par.date = sscanf(tline,'$date=%[^\n]');
           tline = fgetl(fid);
           continue
       elseif strfind(tline,'$time=') == 1
           par.time = sscanf(tline,'$time=%[^\n]');
           tline = fgetl(fid);
           continue
       elseif strfind(tline,'$format=') == 1
           par.time = sscanf(tline,'$format=%[^\n]');
           tline = fgetl(fid);
           continue
       elseif strfind(tline,'$comment=') == 1
           par.comment{end+1} = sscanf(tline,'$comment=%[^\n]');
           tline = fgetl(fid);
           continue
       end
       break;    
   end
      
      % trim date/time
      
   if (length(find(par.date=='/')) == 6)
      vec = sscanf(par.date,'%f/%f/%f/%f/%f/%f/%f')';
      str = datestr(vec(1:6));
      par.date = str(1:11);
      par.time = str(13:end);
   end
   
   if ~isempty(par.time) && ~isempty(par.date)
       par.title = [par.date, ' @ ', par.time, ' ', par.title];
   elseif ~isempty(par.time)
       par.title = [ par.time, ' ', par.title];
   elseif ~isempty(par.date)
       par.title = [ par.date, ' ', par.title];
   end
   
   tline = fgetl(fid);
   data_matrix = [];
   while ischar(tline) && size(data_matrix,1) < 10000
      vals = sscanf(tline, '%f/%f/%f/%f/%f/%f/%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f');
      numvar = 24;
      if numel(vals) == numvar % if the line contains data, saveit in data
          data_matrix(end+1,:) = vals;
          cnt = size(data_matrix,1);
          if rem(cnt,5000)==0
              disp(sprintf('data point %d', cnt));
          end
      end
      tline = fgetl(fid);
   end
   fclose(fid);
   
   oo = caramel(typ);                  % create a (derived) CARAMEL object
   oo.tag = class(pull(o));            % inherit tag from shell class
   oo = balance(oo);                   % restore balance
   
   oo = SetData13(oo,data_matrix,1.1); % for format #1
   oo = SetPar(oo,par);

   oo = Config13(oo,1.1);              % provide #1 configuration defaults
   oo = set(oo,'sizes',[1 length(oo.data.T) 1]);
end
function o = SetData13(o,data_matrix,n)% Set Data                      
   vec = [1:length(data_matrix(:,1))];
   td = data_matrix(:,3)*24*60*60; %s
   th = data_matrix(:,4)*60*60; %s
   tm = data_matrix(:,5)*60; %s
   ts = data_matrix(:,6);
   ts_1000 = data_matrix(:,7)/1000; % s
   time = td + th + tm + ts + ts_1000;
   time_0 = time - time(1);
   o.data.t = time_0';
    
   x_search = data_matrix(:,8)/1000-data_matrix(1,8)/1000; %[um]
   y_search = data_matrix(:,9)/1000-data_matrix(1,9)/1000; %[um]
   diff = linspace(0,x_search(end),length(x_search));
   %x_search_1 = x_search - diff';
   o.data.ux = x_search';
   o.data.uy = y_search';
    
   x1 = data_matrix(:,10)*1000;   x1_offset = x1-mean(x1); % nm
   x2 = data_matrix(:,11)*1000;   x2_offset = x2-mean(x2); % nm
   x = mean([x1 x2],2);   x_offset = x-mean(x);
   o.data.ax = x'/1000;
   y = data_matrix(:,12)*1000;  y_offset = y-mean(y);      % nm
   o.data.ay = y'/1000;
   
   T = data_matrix(:,13)/10; 
   o.data.T = T';
   i = data_matrix(:,14)/1000; % [A]
   o.data.i = i';

   a = data_matrix(:,15)/1000; % [µ]
   o.data.a = a';
   ia = data_matrix(:,16)/1000; % [A]
   o.data.ia = ia';
   b = data_matrix(:,17)/1000; % [µ]
   o.data.b = b';
   ib = data_matrix(:,18)/1000; % [A]
   o.data.ib = ib';

   ix1 = data_matrix(:,19)/1000; % [A]
   o.data.ix1 = ix1';
   ix2 = data_matrix(:,20)/1000; % [A]
   o.data.ix2 = ix2';
   iy = data_matrix(:,21)/1000; % [A]
   o.data.iy = iy';
   
   theta_search = data_matrix(:,22)/1000-data_matrix(1,22)/1000; %[deg]
   o.data.utheta = theta_search';
   theta = data_matrix(:,23);
   o.data.atheta = theta';
   itheta = data_matrix(:,24)/1000;
   o.data.itheta = itheta';
   
end
function o = Config13(o,n)             % Provide Configuration Defaults
   o = category(o,1,[0 0],[0 0],'µ');  % category 1 for ux,uy,ax,ay
   o = category(o,2,[0 0],[0 0],'°C'); % category 2 for T
   o = category(o,3,[0 0],[0 0],'A');  % category 3 for currents
   o = category(o,4,[0 0],[0 0],'deg');% category 4 for angles

   o = config(o,'ux',{1,'b',1});
   o = config(o,'uy',{1,'c',1});
   o = config(o,'ax',{2,'n',1});
   o = config(o,'ay',{2,'m',1});
   o = config(o,'T', {3,'r',2});
   o = config(o,'utheta',{1,'d',4});
   o = config(o,'i',{3,'v',3});
   o = config(o,'ia',{0,'p',3});
   o = config(o,'ib',{0,'m',3});
   o = config(o,'ix1',{0,'p',3});
   o = config(o,'ix2',{0,'p',3});
   o = config(o,'iy',{0,'m',3});
   o = config(o,'itheta',{4,'v',3});
   o = config(o,'atheta',{2,'u',1});
  
end

%==========================================================================
% Text File Read #1
%==========================================================================

function oo = TextFile1(o)             % Read Driver #1 for .txt File  
%
% TEXT-FILE   Import Birgit's log data from a .txt file
%
   typ = 'tpx1';
   path = arg(o,1);                    % get path argument
   fid = fopen(path,'r');
   if (fid < 0)
      error('cannot open import file!');
   end
   
   [~,par.title,~] = fileparts(path);
   par.comment = {};   
   
   tline = fgetl(fid);
   while ~isempty(tline) && tline(1) == '$'
       if strfind(tline,'$title=') == 1
           par.title = sscanf(tline,'$title=%[^\n]');
           tline = fgetl(fid);
           continue
       elseif strfind(tline,'$date=') == 1
           par.date = sscanf(tline,'$date=%[^\n]');
           tline = fgetl(fid);
           continue
       elseif strfind(tline,'$time=') == 1
           par.time = sscanf(tline,'$time=%[^\n]');
           tline = fgetl(fid);
           continue
       elseif strfind(tline,'$format=') == 1
           par.time = sscanf(tline,'$format=%[^\n]');
           tline = fgetl(fid);
           continue
       elseif strfind(tline,'$comment=') == 1
           par.comment{end+1} = sscanf(tline,'$comment=%[^\n]');
           tline = fgetl(fid);
           continue
       end
       break;    
   end
      
      % trim date/time
      
   if (length(find(par.date=='/')) == 6)
      vec = sscanf(par.date,'%f/%f/%f/%f/%f/%f/%f')';
      str = datestr(vec(1:6));
      par.date = str(1:11);
      par.time = str(13:end);
   end
   
   if ~isempty(par.time) && ~isempty(par.date)
       par.title = [par.date, ' @ ', par.time, ' ', par.title];
   elseif ~isempty(par.time)
       par.title = [ par.time, ' ', par.title];
   elseif ~isempty(par.date)
       par.title = [ par.date, ' ', par.title];
   end
   
   tline = fgetl(fid);
   data_matrix = [];
   while ischar(tline) && size(data_matrix,1) < 10000
      vals = sscanf(tline, '%f/%f/%f/%f/%f/%f/%f %f %f %f %f %f %f'); numvar = 13;
      if numel(vals) == numvar % if the line contains data, saveit in data
          data_matrix(end+1,:) = vals;
          cnt = size(data_matrix,1);
          if rem(cnt,5000)==0
              disp(sprintf('data point %d', cnt));
          end
      end
      tline = fgetl(fid);
   end
   fclose(fid);
   
   oo = caramel(typ);                  % create a (derived) CARAMEL object
   oo.tag = class(pull(o));            % inherit tag from shell class
   oo = balance(oo);                   % restore balance
   
   oo = SetData(oo,data_matrix,1);     % for format #1
   oo = SetPar(oo,par);

   oo = Config(oo,1);                  % provide #1 configuration defaults
   oo = Repeats(oo);                   % Extract Repeats
end

%==========================================================================
% Text File Read #2
%==========================================================================

function oo = TextFile2(o)             % Read Driver #2 for .txt File  
%
% TEXT-FILE   Import Birgit's log data from a .txt file
%
   typ = 'tpx2';
   path = arg(o,1);                    % get path argument
   fid = fopen(path,'r');
   if (fid < 0)
      error('cannot open import file!');
   end
   
   [~,par.title,~] = fileparts(path);
   par.comment = {};   
   
   tline = fgetl(fid);
   while ~isempty(tline) && tline(1) == '$'
       if strfind(tline,'$title=') == 1
           par.title = sscanf(tline,'$title=%[^\n]');
           tline = fgetl(fid);
           continue
       elseif strfind(tline,'$date=') == 1
           par.date = sscanf(tline,'$date=%[^\n]');
           tline = fgetl(fid);
           continue
       elseif strfind(tline,'$time=') == 1
           par.time = sscanf(tline,'$time=%[^\n]');
           tline = fgetl(fid);
           continue
       elseif strfind(tline,'$format=') == 1
           par.time = sscanf(tline,'$format=%[^\n]');
           tline = fgetl(fid);
           continue
       elseif strfind(tline,'$comment=') == 1
           par.comment{end+1} = sscanf(tline,'$comment=%[^\n]');
           tline = fgetl(fid);
           continue
       end
       break;    
   end
      
      % trim date/time
      
   if (length(find(par.date=='/')) == 6)
      vec = sscanf(par.date,'%f/%f/%f/%f/%f/%f/%f')';
      str = datestr(vec(1:6));
      par.date = str(1:11);
      par.time = str(13:end);
   end
   
   if ~isempty(par.time) && ~isempty(par.date)
       par.title = [par.date, ' @ ', par.time, ' ', par.title];
   elseif ~isempty(par.time)
       par.title = [ par.time, ' ', par.title];
   elseif ~isempty(par.date)
       par.title = [ par.date, ' ', par.title];
   end
   
   tline = fgetl(fid);
   data_matrix = [];
   while ischar(tline) && size(data_matrix,1) < 10000
      vals = sscanf(tline, '%f/%f/%f/%f/%f/%f/%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f');
      numvar = 21;
      if numel(vals) == numvar % if the line contains data, saveit in data
          data_matrix(end+1,:) = vals;
          cnt = size(data_matrix,1);
          if rem(cnt,5000)==0
              disp(sprintf('data point %d', cnt));
          end
      end
      tline = fgetl(fid);
   end
   fclose(fid);
   
   oo = caramel(typ);                  % create a (derived) CARAMEL object
   oo.tag = class(pull(o));            % inherit tag from shell class
   oo = balance(oo);                   % restore balance
   
   oo = SetData(oo,data_matrix,2);     % for format #2
   oo = SetPar(oo,par);

   oo = Config(oo,2);                  % provide #2 configuration defaults
   oo = Repeats(oo);                   % Extract Repeats
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function o = SetPar(o,par)             % Set Parameters                
   o.par = par;
end
function o = SetData(o,data_matrix,n)  % Set Data                      
   vec = [1:length(data_matrix(:,1))];
   td = data_matrix(:,3)*24*60*60; %s
   th = data_matrix(:,4)*60*60; %s
   tm = data_matrix(:,5)*60; %s
   ts = data_matrix(:,6);
   ts_1000 = data_matrix(:,7)/1000; % s
   time = td + th + tm + ts + ts_1000;
   time_0 = time - time(1);
   o.data.t = time_0';
    
   x_search = data_matrix(:,8)/1000; %[um]
   x_search_offset = x_search-mean(x_search);
   y_search = data_matrix(:,9)/1000; %[um]
   y_search_offset = y_search-mean(y_search);
   o.data.ux = x_search_offset';
   o.data.uy = y_search_offset';
    
   x1 = data_matrix(:,10)*1000;   x1_offset = x1-mean(x1); % nm
   x2 = data_matrix(:,11)*1000;   x2_offset = x2-mean(x2); % nm
   x = mean([x1 x2],2);   x_offset = x-mean(x);
   o.data.ax = x'/1000;
   y = data_matrix(:,12)*1000;  y_offset = y-mean(y);      % nm
   o.data.ay = y'/1000;
   T = data_matrix(:,13)/10; 
   o.data.T = T';
   
   if (n == 1.1)
      w = data_matrix(:,13);   x1_offset = x1-mean(x1); % nm
      o.data.w = w';
      T = data_matrix(:,14)/10; 
      o.data.T = T';
      return
   end

   if (n < 2)
      return
   end
   
      % new data streams
   
   i = data_matrix(:,14)/1000; % [A]
   o.data.i = i';

   a = data_matrix(:,15)/1000; % [µ]
   o.data.a = a';
   
   ia = data_matrix(:,16)/1000; % [A]
   o.data.ia = ia';

   b = data_matrix(:,17)/1000; % [µ]
   o.data.b = b';
   
   ib = data_matrix(:,18)/1000; % [A]
   o.data.ib = ib';

      % gantry current
      
   ix1 = data_matrix(:,19)/1000; % [A]
   o.data.ix1 = ix1';

   ix2 = data_matrix(:,20)/1000; % [A]
   o.data.ix1 = ix1';

   iy = data_matrix(:,21)/1000; % [A]
   o.data.iy = iy';
end
function o = Config(o,n)               % Provide Configuration Defaults
   o = category(o,1,[0 0],[0 0],'µ');  % category 1 for ux,uy,ax,ay
   o = category(o,2,[0 0],[0 0],'°C'); % category 2 for T
   o = category(o,3,[0 0],[0 0],'A');  % category 3 for currents

   o = config(o,'ux',{1,'b',1});
   o = config(o,'uy',{1,'c',1});
   o = config(o,'ax',{2,'n',1});
   o = config(o,'ay',{2,'m',1});
   o = config(o,'T', {3,'r',2});
   
   if (n == 1.1)
      o = config(o,'w', {0,'g',1});
      return
   end
   
   if (n < 2)
      return
   end

   o = config(o,'i', {0,'r',3});
   o = config(o,'a', {0,'g',1});
   o = config(o,'ia', {0,'r',3});
   o = config(o,'b', {0,'g',1});
   o = config(o,'ib', {0,'r',3});

   o = config(o,'ix1', {0,'r',3});
   o = config(o,'ix2', {0,'r',3});
   o = config(o,'iy',  {0,'r',3});
end
function o = Repeats(o)                % Extract Repeats               
   T = data(o,'T');
   if ~isempty(T)
      Tmin = min(T);  Tmax = max(T);
      Tl = Tmin + 0.25*(Tmax-Tmin);    % lower temperature threshold
      Tu = Tmin + 0.75*(Tmax-Tmin);    % upper temperature threshold
      
      r = 0;                           % init repeats
      level = 0;  index = [];
      for (i=1:length(T))
         if (level == 0)
            if (T(i) >= Tu)
               level = 1;
            end
         else
            if (T(i) <= Tu)
               level = 0;  r = r+1;
               index(end+1) = i;
            end
         end            
      end
      
         % update sizes
         
      sz = sizes(o);
      N = prod(sz);
      periode = round(mean(diff(index)));
      r = floor(N/periode);
      sz = [1 periode r];
      o.par.sizes = sz;
   end
end
