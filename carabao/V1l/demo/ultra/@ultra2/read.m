function oo = read(o,varargin)         % Read ULTRA2 Object From File
%
% READ   Read a ULTRA2 object from file.
%
%             oo = read(o,driver,path)
%
%             oo = read(o,'ReadUltra2Log',path)   % read .log data
%             oo = read(o,'ReadUltra2Dat',path)   % read .dat data
%
%          See also: ULTRA2, IMPORT, EXPORT, WRITE
%
   [gamma,oo] = manage(o,varargin,@Error,@ReadUltra2Log,@ReadUltra2Dat);
   oo = gamma(oo);
   oo = launch(oo,launch(o));          % inherit launch function
end

function o = Error(o)                  % Default Error Method
   error('two input args expected!');
end

%==========================================================================
% Read Driver for Ultra2 Data
%==========================================================================

function oo = ReadUltra2Log(o)         % Read Driver for Ultra2 .log   
   path = arg(o,1);
   [x,y,par] = Read(path);             % read data into variables x,y,par
   
   oo = ultra2('log');                  % create 'log' typed ULTRA2 object
   oo.par = par;                       % store parameters in object
   oo.data.x = x';                     % store x-data in object
   oo.data.y = y';                     % store y-data in object
   oo = Config(oo);                    % overwrite configuration
   return
   
   function [x,y,par] = Read(path)     % read log data (v1a/read.m)
      fid = fopen(path,'r');
      if (fid < 0)
         error('cannot open log file!');
      end
      par.title = fscanf(fid,'$title=%[^\n]');
      log = fscanf(fid,'%f',[2 inf])'; % transpose after fscanf!
      x = log(:,1); y = log(:,2);
   end
end

function oo = ReadUltra2Dat(o)         % Read Driver for Ultra2 .dat   
   path = arg(o,1);
   oo = read(o,'ReadGenDat',path);
   oo = Config(oo);                    % configure plotting
end

%==========================================================================
% Configuration of Plotting
%==========================================================================

function o = Config(o)
   o = subplot(o,'layout',1);       % layout with 1 subplot column   
   o = subplot(o,'color',[1 1 1]);  % background color
   o = config(o,[]);                % set all sublots to zero

   switch o.type
      case 'log'
         o = category(o,1,[-5 5],[0 0],'1');
         o = config(o,'x',{1,'r',1});
         o = config(o,'y',{2,'b',1});
      case 'pln'
         o = category(o,1,[-5 5],[0 0],'µ');
         o = category(o,2,[-50 50],[0 0],'m°');
         o = config(o,'x',{1,'r',1});
         o = config(o,'y',{1,'b',1});
         o = config(o,'p',{2,'g',2});
      case 'smp'
         o = category(o,1,[-5 5],[0 0],'µ');
         o = category(o,2,[-50 50],[0 0],'m°');
         o = category(o,3,[-0.5 0.5],[0 0],'µ');
         o = config(o,'x',{1,'r',1});
         o = config(o,'y',{1,'b',1});
         o = config(o,'p',{2,'g',2});
         o = config(o,'ux',{3,'m',3});
         o = config(o,'uy',{3,'c',3});
   end         
end
