function [out,list] = make(obj,format,srcname,outname,verbose,nanmode,tslice,lmax)
%
% MAKE     Make method for SHELL objects. Dummy method just to report
%          that applying the make method to a SHELL object makes no sense.
%
%              make(shell,'gma1_347_000222a')  % parse & save from gma1_347_000222a.log, output to gma1_347_000222a.m
%
%          See also: SHELL CHAMEO/MAKE
%
   out = [];
   list = {};
   msgbox({'Make has been applied to a SHELL object.',...
           'This makes no sense!',...
           'Apply MAKE to an object which is derived from SHELL!'});
   return
   
% eof      
   
