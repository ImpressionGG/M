function oo = read(o,varargin)         % Read CARMA Object To File
%
% READ   Read a CARMA object from file.
%
%             oo = read(o,path,'LogData')
%
%          See also: CARMA, IMPORT, WRITE
%
   [gamma,oo] = manage(o,varargin,@Error,@LogData);
   oo = gamma(oo);
   oo = launch(oo,launch(o));          % inherit launch function
end

function o = Error(o)                  % Default Error Method
   error('two input args expected!');
end

%==========================================================================
% Log Data Read
%==========================================================================

function oo = LogData(o)               % Read Driver for .log File
   path = arg(o,1);                    % get first arg
   fid = fopen(path,'r');              % open log file for read
   if (fid < 0)
      error('cannot open export file');
   end
   
   oo = carma('trace');                % create CARMA object
   while 1 % (length(line) > 0 && line(1) == '$')
      tag = fscanf(fid,'$%[^=]');
      if isempty(tag)
         break
      end
      
      value = fscanf(fid,'=%[^\n]');
      rest = fgetl(fid);               % eat line feed
      
      if ~isempty(value)
         value = eval(value);          % convert to MATLAB type
      end
      
      if o.is(tag,'type')
         oo.type = value;
      elseif o.is(tag,'comment')
         if isempty(get(oo,'comment'))
            oo.par.comment = {};
         end
         oo.par.comment{end+1} = value;
      else
         oo.par.(tag) = value;         % set parameter
      end
   end

      % read data header and units
      
   header = fgetl(fid);                % read data header
   units = fgetl(fid);                 % read data units

      % process data header
      
   symbols = {};
   while o.is(header)
      header = o.trim(header);
      sym = sscanf(header,'%s',1);
      if o.is(sym)
         symbols{end+1} = sym;
         header = o.trim(header(length(sym)+1:end));
      end
   end
   
   n = length(symbols);   
   log = fscanf(fid,'%f',[n inf])';    % transpose after fscanf!
   
   ulist = {};
   for (i=1:n)
      oo.data.(symbols{i}) = log(:,i)';

      units = o.trim(units);
      sym = sscanf(units,'%s',1);
      unit = sym;
      if length(unit) > 2
         if length(unit) > 2 && unit(1) == '[' && unit(end) == ']'
            unit(1) = '';  unit(end) = '';
         end
         ulist{end+1} = unit;
         units = o.trim(units(length(sym)+1:end));
      end
   end
   
      % setup categories and configuration
      
   units = {};
   for (i=2:n)
      unit = ulist{i};  
      sym = symbols{i};
      cat = o.is(unit,units);
      if (cat == 0)
         units{end+1} = unit;  cat = length(units);
         oo = category(oo,cat,[0 0],[0 0],unit);
      end
      oo = config(oo,sym,{1,'k',cat});
   end
   fclose(fid);
end
