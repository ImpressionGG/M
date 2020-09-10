function obj = integrity(obj)
%
% INTEGRITY All necessary operations are done to recover a shell object's
%           integrity, if necessary.
%
%           This function will most likely be used after object creation to
%           achieve a parameter state which establishes object integrity.
%
%              obj = integrity(obj)
%
%           Remarks: a state which violates system integrity can occure
%           if parameters and options are transferred from another object.
%
%           See also: SHELL IMPORT
%

% one thing to recover is empty shell.ohdl

   ohdl = option(obj,'shell.ohdl');
   if (~isempty(ohdl))
      obj = option(obj,'shell.ohdl',[]);
   end
   
% eof