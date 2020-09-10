function out = fito(varargin)
% 
% FITO     Filter Tools:
%          Create a FITO object as a derived SHELL object of kind PLAY.
%
%              fito                        % open demo
%
%              obj = fito;                 % generic constructor
%              obj = fito(format,par,dat)  % general form of constructor
%
%          Methods:
%              get          % get user defined parameter
%              set          % set user defined parameter
%              demo         % demonstration
%
%          See also SHELL FITO/DEMO

   if (isempty(varargin))
      varargin = {'#DEMO'};
   end
   
   [obj,she] = derive(shell(varargin),mfilename);
   obj = class(obj,obj.tag,she);     

   if (nargout==0)
      demo(obj);
   else
      out = obj;
   end
   return           

% eof   