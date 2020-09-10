function oo = read(o,varargin)         % Read FACEUP Object From File
%
% READ   Read a FACEUP object from file.
%
%             oo = read(o,driver,path)
%
%             oo = read(o,'ReadFaceupLog',path)   % read .log data
%             oo = read(o,'ReadFaceupDat',path)   % read .dat data
%
%          See also: FACEUP, IMPORT, EXPORT, WRITE
%
   [gamma,oo] = manage(o,varargin,@Error,@ReadFaceupLog,@ReadFaceupDat);
   oo = gamma(oo);
   oo = launch(oo,launch(o));          % inherit launch function
end

function o = Error(o)                  % Default Error Method
   error('two input args expected!');
end

%==========================================================================
% Read Driver for Faceup Data
%==========================================================================

function oo = ReadFaceupLog(o)         % Read Driver for Faceup .log   
   path = arg(o,1);
   oo = Read(path);                    % read data into variables x,y,par
   return
   
   function oo = Read(path)            % read log data (v1a/read.m)
      fid = fopen(path,'r');
      if (fid < 0)
         error('cannot open log file!');
      end
      
      oo = faceup('faceup');      
      oo = log(oo,'t','w1x','w1y','w2x','w2y','u1x','u1y','u2x','u2y',...
                  'p11x','p11y','p12x','p12y','p21x','p21y','p22x','p22y');
      
         % need to initialize variables in static work space
         
      w1x = [];  w1y = [];  w2x = [];  w2y = [];
      u1x = [];  u1y = [];  u2x = [];  u2y = [];
      p11x = []; p11y = []; p12x = []; p12y = [];
      p21x = []; p21y = []; p22x = []; p22y = [];
               
      n = 0;  k = 0;  t0 = [];
      while(1)
         n = n+1;                      % line count
         line = fgetl(fid);
         if isequal(line,-1)
            break;
         end
         
         if rem(length(line),2) ~= 0
            line(end) =[];             % make odd length
         end
         line = reshape(line,2,length(line)/2);
         line = line(1,:);
         if isempty(line)
            continue
         end
         
         idx = find(line == ',');
         if ~isempty(idx)
            line(idx) = setstr(0*idx + '.');
         end
         
            % get dtime
            
         idx = o.find(':',line);
         if (idx == 0)
            continue
         end
         
         time = line(idx-2:end);
         hh = str2num(time(1:2));
         mm = str2num(time(4:5));
         ss = str2num(time(7:8));
         t = hh*3600 + mm*60 + ss;
         if isempty(t0)
            t0 = t;
         end
         t = t - t0;

            % determine which signal
            
         table = {{'fatmax/DC_5mm-ps1','w1'}
                  {'fatmax/DC_5mm-ps2','w2'}
                  {'fatmax/DC_5mm-am1','u1'}
                  {'fatmax/DC_5mm-am2','u2'}
                  {'fatmax/PBI-pbi11','p11'}
                  {'fatmax/PBI-pbi12','p12'}
                  {'fatmax/PBI-pbi21','p21'}
                  {'fatmax/PBI-pbi22','p22'}};
               
         for (i=1:length(table))
            pair = table{i};
            tag = pair{1};
            idx = o.find(tag,line);
            if (idx > 0)               % then found
               line = line(idx+length(tag):end);
               idx = o.find('pos',line);
               line = line(idx+3:end);
               
               xy=sscanf(line,' %f %f');
               xvalue = xy(1);  yvalue = xy(2);
               
               sig = pair{2};
               cmd = [sig,'x = xvalue; ',sig,'y = yvalue;'];
               eval(cmd);
               break;
            end
         end                 
         
         if o.is(sig,'p22')
            oo = log(oo,t,w1x,w1y,w2x,w2y,u1x,u1y,u2x,u2y,...
                        p11x,p11y,p12x,p12y,p21x,p21y,p22x,p22y);
         end
      end
      
      [dir,fname,ext] = fileparts(path);
      oo  = set(oo,'title',fname);
   end
end

function oo = ReadFaceupDat(o)         % Read Driver for Faceup .dat   
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
