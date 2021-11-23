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
