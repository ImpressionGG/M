function out = quantana(varargin)
% 
% QUANTANA Quantana Shell
%          Create a QUANTANA object as a derived SHELL object of kind PLAY.
%
%              quantana                       % open demo
%
%              obj = quantana;                % generic constructor
%              obj = quantana(format,par,dat) % general form of constructor
%
%          General functions
%              normalize    % normalize a psi function
%
%          Methods:
%              cls          % clear screen
%              cindex       % calculate proper color indices for cmap
%              cmap         % set color map
%              color        % set color according to color map
%              get          % get user defined parameter
%              light        % add a light to current axes
%              set          % set user defined parameter
%              demo         % demonstration
%              pcolor       % phase color
%              surf         % surface plot
%
%          Demo Methods:
%              demo         % demonstration
%              basics       % visualization of basics
%              harmonic     % harmonic oscillator
%              scatter      % demonstration
%
%          See also SHELL QUANTANA/DEMO
%
   varargin = varargfix(varargin);

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