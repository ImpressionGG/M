function oo = extract(o,text)
%
% EXTRACT    Extract parameters from some signature, which might be a 
%            file name. The method is usually caled at the end of a read
%            method in order to extract parameter settings from a file
%            name.
%
%               oo = signature(o,file) % extract parameters from signature
%
%            This default signature method (which will be usually
%            overloaded extracts parameters from a filename according to
%            two syntactic rules:
%
%               (i)  a hash key ('#') followed by a number designates a 
%                    'number' parameter
%               (ii) an equal sign ('=') preceeded by an identifier and 
%                    followed by a numerical value or character string
%                    designates a parameter assignment given by the
%                    identifier. Values are terminated by the following 
%                    separator characters '.', ';', ',', '_' or end of 
%                    text
%
%            Example:
%    
%               file = 'Sample_data_#12_f=50_logged_with_level=medium.txt'
%               oo = extract(o,file)
%
%            This causes the implicite settings:
%
%               oo = o;
%               oo = set(oo,'number',12);
%               oo = set(oo,'f',50);
%               oo = set(oo,'level','medium');
%
%            Copyright(c): Bluenetics 2020
%
%            See also: CORAZON, READ, IMPORT, COLLECT, UPGRADE, ID
%
   oo = o;
   
   [c,text] = Next(text);
   while ~isempty(text)      
      if (c == '#');                   % number clause
         number = 0;
         [c,text] = Next(text);
         while IsDigit(c)
            number = number*10 + (c - '0');
            [c,text] = Next(text);
         end
         oo = set(oo,'number',number);
         continue
      elseif IsLetter(c)               % identifier
         ident = c;
         [c,text] = Next(text);
         while IsAlpha(c)
            ident = [ident,c];
            [c,text] = Next(text);
         end
         
         if (c == '=')                 % assignment clause
            value = '';
            [c,text] = Next(text);
            while ~IsSeparator(c)
               value = [value,c];
               [c,text] = Next(text);
            end
            
               % if value consists of all digits then convert value 
               % into a number otherwise take character string as value
               
            numeric = true;           % numeric by default
            for (i=1:length(value))
               if ~IsDigit(value(i))
                  numeric = false;    % not numeric
                  break              
               end
            end
            
            if (numeric)
               value = sscanf(value,'%f');
            end
            oo = set(oo,ident,value);
         end
         continue
      end
      [c,text] = Next(text);
   end
end

%==========================================================================
% Helper
%==========================================================================

function [c,text] = Next(text)
   if ~isempty(text)
      c = text(1);
      text(1) = [];
   else
      c = ' ';
   end
end   
function ok = IsDigit(c)               % Is Character a Digit?         
   ok = ('0' <= c && c <= '9');
end
function ok = IsLetter(c)              % Is Character a Letter?        
   ok = ('A' <= c && c <= 'Z') || ('a' <= c && c <= 'z');
end
function ok = IsAlpha(c)               % Is Character Alphanumeric?    
   ok = IsDigit(c) || IsLetter(c);
end
function ok = IsSeparator(c)
   sep = '.;,_ ';
   ok = ~isempty(strfind(sep,c));
end