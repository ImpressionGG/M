function s = structure(varargin)
%
% STRUCTURE    Construct a structure. This function is same as STRUCT,
%              but with bug fixed.
%
%                 S = structure('field1',VALUES1,'field2',VALUES2,...)
%
   for i = 1:2:length(varargin)-1
      val = varargin{i+1};
      cmd = ['s.',varargin{i},'=val;'];
      eval(cmd);
   end
   return
   
%eof   