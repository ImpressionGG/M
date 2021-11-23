classdef corazito                      % v0b/@corazito/corazito.m
%
%  Copyright(c): Bluenetics 2020 
%
   methods
      function o = corazito(arg)       % Corazito Class Constructor      
         % nothing to do
      end
   end
   methods (Static)
      [n,varargout] = args(l,varargin) % quick arg access with defaults
      [value,i] = assoc(key,list,pair) % seek in assoc list
      [c,w,t] = color(arg1,arg2,width) % color setting
      hdl = plot(varargin);            % extended plot routine
      oo = cuo(o)                      % get/set current object from shell            
      value = either(value,defval)     % 'either' function 
      value = iif(condition,v1,v2)     % inline if
      match = is(arg1,arg2)            % compare or find string in list
      oo = master(obj,evt,varargin)    % master callback
      [date,time] = now(stamp,time)    % get current time
      y = rd(x,n)                      % round to ndigits
      [n,nout] = ticn(n)               % tic for n Runs                
      time = tocn(msg,digits)          % toc for n Runs                
      [txt,c] = trim(txt,where)        % trim text
      oo = sho(o)                      % Get Shell Object            
      out = profiler(name,mode)        % profiler operations
      argcheck(low,high,number)        % check number of arguments
   end
end
