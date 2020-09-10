function display(o)
% 
% DISPLAY  Display a LEPTON object
%
%    Syntax:
%
%       o = lepton(query)        % construct a LEPTON object
%       display(o);
%
%    This function is implicitely called if a command line expession
%    has been typed in without semicolon.
%          
%    Code lines: 32
%
%    See also: LEPTON, VALIDATE
%
   query = o.query;
   admin = o.admin;
   
   if isempty(query)
      info = '<Generic Lepton Object>';
   else
      info = '<Lepton Object>';
   end
%
% replace datenum by readable string
%
   fprintf([info,'\n']);
   if (isempty(query))
      fprintf(['  QUERY: []\n']);
   else
      query.datenum = Readable(query.datenum);
   
      fprintf(['  QUERY:\n']);
      disp(query);   
   end
   
   if (isempty(admin))
      fprintf(['  ADMIN: []\n']);
   else
      admin.created = Readable(admin.created);
      admin.saved = Readable(admin.saved);

      fprintf(['  ADMIN:\n']);
      disp(admin);   
   end
end

function str = Readable(datenum)       % convert datenum to readable text
   nstr = sprintf('%15f',datenum);
   while (nstr(1) == ' ')
      nstr(1) = '';                    % left trim nstr
   end
   str = sprintf('%s (%s)',nstr,datestr(datenum));
end