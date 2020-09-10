function oo = write(o,varargin)        % Write CARMA Object To File
%
% EXPORT   Export a CARALOG object to file.
%
%             oo = write(o,path,'LogData')
%
%          See also: CARMA, EXPORT
%
   [gamma,oo] = manage(o,varargin,@Error,@LogData);
   oo = gamma(oo);
end

%==========================================================================
% Write Log Data
%==========================================================================

function oo = LogData(o)               % Export Driver For .log File
   path = arg(o,1);
   oo = [];
   if ~o.is(o.type,{'plain','simple'})
      message(o,'Error during export',...
         'only plain & simple type allowed for log data (.log) export!');
      return
   end

   fid = fopen(path,'w');              % open log file for write
   if (fid < 0)
      error('cannot open export file');
   end
   
   fprintf(fid,'$type=''%s''\n',o.type);
   if o.is(get(o,'title'))
      fprintf(fid,'$title=''%s''\n',get(o,'title'));
   end
   
   flds = fields(o.par);
   for (i=1:length(flds))
      tag = flds{i};
      value = o.par.(tag);
      typ = class(value);
      switch typ
         case 'char'
            if ~o.is(tag,{'title'})
               fprintf(fid,'$%s=''%s''\n',tag,value);
            end
         case 'double'
            fprintf(fid,'$%s=[',tag);
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
            fprintf(fid,']\n');
         case 'cell'
            if isequal(tag,'comment');
               for (i=1:length(value))
                  if ~isa(value{i},'char')
                     error('all comments must be char!');
                  end
                  fprintf(fid,'$comment="%s"\n',value{i});
               end
            end
      end
   end

      % write the data header
      
   fprintf(fid,'time ');
   log = [data(o,'time')'];  units = {};  
   format = '%10f';
   n = config(o,inf);
   for (i=1:n)
      [sym,sub,col,cat] = config(o,i);
      [spec,limit,unit] = category(o,cat);
      log(:,end+1) = data(o,sym)';
      units{i} = unit;

      fprintf(fid,'%s ',sym);
   end
   fprintf(fid,'\n');
   
   fprintf(fid,'[s]');
   for (i=1:n)
      fprintf(fid,' [%s]',units{i});
      format = [format,' %10f'];
   end
   fprintf(fid,'\n');
   fprintf(fid,[format,'\n'],log');    % write x/y data
   
   fclose(fid);                        % close export file
   oo = o;                             % succesful writing
end
