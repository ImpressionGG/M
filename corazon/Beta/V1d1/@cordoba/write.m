function oo = write(o,varargin)        % Write CORDOBA Object To File  
%
% WRITE    Write a CORDOBA object to file.
%
%             oo = write(o,'WriteSmpDat',path) % write a simple object 
%             oo = write(o,'WriteGenDat',path) % write a general object 
%             oo = write(o,'WritePkgPkg',path) % write a package object
%
%          Besides of WRITE drivers there are also auxillary functions
%          for partial write tasks:
%
%             oo = write(oo,'Type',fid)     % write object type
%             oo = write(oo,'Param',fid)    % write parameters
%             oo = write(oo,'Header',fid)   % write parameters
%             oo = write(oo,'Data',fid)     % write parameters
%
%          Copyright(c): Bluenetics 2020 
%
%          See also: CORDOBA, EXPORT
%
   [gamma,oo] = manage(o,varargin,@Error,@WriteSmpDat,...
                                  @WriteGenDat,@WritePkgPkg,...
                                  @Type,@Param,@Header,@Data);
   oo = gamma(oo);
end

%==========================================================================
% Data Writing for Plain and Simple Type
%==========================================================================

function oo = WriteGenDat(o)           % Universal Export Drv. for .dat
   oo = WriteSmpDat(o);                % delegate to simple data write
end
function oo = WriteSmpDat(o)           % Export Driver For .dat File   
   path = arg(o,1);                    % fetch path argument
   fid = fopen(path,'w');              % open log file for write
   if (fid < 0)
      error('cannot open export file');
   end
   
   oo = write(o,'Type',fid);           % write type
   fprintf(fid,'%%\n%% Parameters\n%%\n');
   oo = write(oo,'Param',fid);         % write parameters
   fprintf(fid,'%%\n%% Header & Data\n%%\n');
   oo = write(oo,'Header',fid);        % write header
   oo = write(oo,'Data',fid);          % write data
   fprintf(fid,'%%\n%% End of Object\n%%\n');

   fclose(fid);                        % close export file
   %message(o,'Export to log data file completed!',['File: ',o.upath(path)]);
end

%==========================================================================
% Package Writing for 'pkg' Type
%==========================================================================

function oo = WritePkgPkg(o)           % Export Driver For .pkg File   
   path = arg(o,1);                    % fetch path argument
   fid = fopen(path,'w');              % open log file for write
   if (fid < 0)
      error('cannot open export file');
   end
   
   oo = write(o,'Type',fid);           % write type
   fprintf(fid,'%%\n%% Parameters\n%%\n');
   oo = write(oo,'Param',fid);         % write parameters
   fprintf(fid,'%%\n%% End of Package Object\n%%\n');

   fclose(fid);                        % close export file
   %message(pull(o),'Export to package file completed!',['File: ',o.upath(path)]);
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function o = Type(o)                   % Write Type to File            
   fid = arg(o,1);
   if isequal(o.type,'plain')
      fprintf(fid,'$type=%s\n',o.type);
   else
      fprintf(fid,'$type=''%s''\n',o.type);
   end
end
function o = Param(o)                  % Write Parameters to File      
   fid = arg(o,1);
   if o.is(get(o,'title'))
      if isequal(o.type,'plain')
         fprintf(fid,'$title=%s\n',get(o,'title'));
      else
         fprintf(fid,'$title=''%s''\n',get(o,'title'));
      end
   end
   
   flds = fields(o.par);
   for (i=1:length(flds))
      tag = flds{i};
      if isequal(tag,'title')
         continue;                     % title already logged
      end
      value = o.par.(tag);
      typ = class(value);
      switch typ
         case 'char'
            if ~o.is(o.type,'title')   % title has been allready written
               if isequal(o.type,'plain')
                  fprintf(fid,'$%s=%s\n',tag,value);
               else
                  fprintf(fid,'$%s=',tag);
                  Char(o,value);       % write char value
                  fprintf(fid,'\n');
               end
            end
         case 'double'
            if isempty(value)
               fprintf(fid,'$%s=[]',tag);
            else
               fprintf(fid,'$%s=',tag);
               Numeric(o,value);
            end
            fprintf(fid,'\n');
         case 'cell'
            if isequal(tag,'comment');
               for (i=1:length(value))
                  if ~isa(value{i},'char')
                     error('all comments must be char!');
                  end
                  if isequal(o.type,'plain')
                     fprintf(fid,'$comment=%s\n',value{i});
                  else
                     fprintf(fid,'$comment=''%s''\n',value{i});
                  end
               end
            else
               fprintf(fid,'$%s=',tag);
               Cell(o,value);
               fprintf(fid,'\n');
            end
         case 'struct'
            Structure(o,tag,value);
      end
   end
   
   function o = Structure(o,tag,value) % Write Structure               
      tags = fields(value);
      for (k=1:length(tags))
         xtag = [tag,'.',tags{k}];
         xvalue = value.(tags{k}); 
         switch class(xvalue)
            case 'struct'
               Structure(o,xtag,xvalue);
            otherwise
               fid = arg(o,1);
               fprintf(fid,'$%s=',xtag);
               Value(o,xvalue);
               fprintf(fid,'\n');
         end
      end
   end
end
function o = Header(o)                 % Write Header to File          
%
% HEADER   Write a data header
%
%    [syms,units] = WriteHead(o,fid)   % write one line header
%
   fid = arg(o,1);                     % file ID
   oo = with(o,'simple');
   tab = opt(oo,{'tabulator',15});     % tabulator
   sep = opt(oo,{'separator',''});     % separator

   tab = max(15,tab);

   dat = data(o);
   if ~isstruct(dat)
      error('data must be a structure!');
   end
   
   symbols = {};  units = {};  heads = {};
   flds = fields(dat);
   
      % deal with time
      
   timesyms = {'time','t'};            % possibilities of naming for time
   for (i=1:length(timesyms))
      sym = timesyms{i};
      idx = o.find(sym,flds);
      if (idx > 0)                        % then 'time' symbol found
         flds(idx) = [];                  % remove 'time' from flds
         symbols{end+1} = sym;
         units{end+1} = 's';
         heads{end+1} = [' ',sym,' [',units{end},']'];
         break;
      end
   end
   
   if isempty(symbols)
      % error('time symbol is missing!');
   end
   
      % get list of other data signals and get according units
      
   for (i=1:length(flds))
      sym = flds{i};
      unit = '1';                      % init by default
      [sub,col,cat] = config(o,sym);   % find configuration attributes
      if ~isempty(cat)
         [spec,limit,unit] = category(o,cat);
      end
      symbols{end+1} = sym;
      units{end+1} = unit;
      heads{end+1} = sprintf(' %s [%s]',sym,unit);
      tab = max(tab,length(heads{i}));
   end
   
      % write header
      
   format = sprintf(' %%%gs',tab);
   if o.is(sep)
      fprintf(fid,'%s',sep);
   end
   for (i=1:length(symbols))
      sym = symbols{i};
      unit = units{i};
      fprintf(fid,format,heads{i});
      if o.is(sep)
         fprintf(fid,'%s',sep);
      end
   end
   fprintf(fid,'\n');                  % header completed
   
   o = var(o,'symbols',symbols);
   o = var(o,'units',units);
   o = var(o,'tabulator',tab);
   o = var(o,'separator',sep);
end
function o = Data(o)                   % Write Data to File            
   fid = arg(o,1);                     % file ID
   tab = var(o,{'tabulator',15});      % tabulator
   sep = var(o,{'separator',''});      % separator
   symbols = var(o,{'symbols',{}});    % symbol list
   
   tab = max(15,tab);
   
   format = o.iif(o.is(sep),sep,'');
   log = [];
   chunk = sprintf(' %%%gf',tab);
   for (i=1:length(symbols))
      sym = symbols{i};
      vec = data(o,sym);
      log = [log,vec(:)];
      format = [format,chunk,sep];
   end
   format = [format,'\n'];
   
      % write data
      
   fprintf(fid,format,log');
end

function o = Value(o,value)            % Write Any Value to File       
   typ = class(value);
   switch (typ)
      case 'char'
         Char(o,value);
      case 'double'
         Numeric(o,value);
      case 'struct'
         Struct(o,value);
      case 'cell'
         Cell(o,value);
      otherwise
         fid = arg(o,1);
         fprintf(fid,'NaN');
   end
end
function o = Char(o,value)             % Write Character Value to File 
   fid = arg(o,1);
   fprintf(fid,'''%s''',value);
end
function o = Numeric(o,value)          % Write Numeric Value to File   
   fid = arg(o,1);
   fprintf(fid,'[');
   rsep = '';  csep = '';
   [m,n] = size(value);
   for (i=1:m)
      fprintf(fid,'%s',rsep);  rsep = ';';
      for (j=1:n)
         fprintf(fid,'%s',csep);  csep = ',';
         str = sprintf('%15f',value(i,j));
         while length(str) > 0 && str(1) == ' '
            str(1) = '';
         end

         if ~isempty(find(str=='.'))
            while length(str) > 0 && str(end) == '0'
               str(end) = '';
            end
         end
         if  length(str) > 0 && str(end) == '.'
            str(end) = '';
         end
         fprintf(fid,'%s',str);
      end
      csep = '';
   end
   fprintf(fid,']');
end
function o = Struct(o,value)           % Write Structure to File       
   fid = arg(o,1);
   sep = '';
   fprintf(fid,'(struct(');
   tags = fields(value);
   for (k=1:length(tags))
      xtag = tags{k};
      xvalue = value.(xtag); 
      fprintf(fid,sep);               % first separator is empty
      sep = ',';                      % following separators are comma
      fprintf(fid,'''%s'',',xtag);     % write tag
      Value(o,xvalue);
   end
   fprintf(fid,'))');
end
function o = Cell(o,value)             % Write Cell Array              
   fid = arg(o,1);
   fprintf(fid,'{');
   rsep = '';  csep = '';
   [m,n] = size(value);
   for (i=1:m)
      fprintf(fid,'%s',rsep);  rsep = ';';
      for (j=1:n)
         fprintf(fid,'%s',csep);  csep = ',';
         Value(o,value{i,j});          % write value (any type)
      end
      csep = '';
   end
   fprintf(fid,'}');
end
