function txt = capital(txt)
%
% CAPITAL   Raise first character of a text to a capital character.
%
%    If first character of a text is a letter then this letter will be
%    replaced by a capital letter. Otherwise no change to the text.
%
%       txt = o.capital('plot')        % => txt = 'Plot' 
%       txt = o.capital('Plot')        % => txt = 'Plot' 
%       txt = o.capital('ploT')        % => txt = 'PloT' 
%       txt = o.capital(' plot')       % => txt = ' plot' 
%       txt = o.capital('123')         % => txt = '123' 
%
%    See also: CARMA
%
   if ~ischar(txt)
      error('string expected for arg2!');
   end
   
   if ~isempty(txt)
      txt(1) = upper(txt(1));
   end
end