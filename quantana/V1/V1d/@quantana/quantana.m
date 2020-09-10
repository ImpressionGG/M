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
%              envi         % setup an environment for a quon
%              get          % get user defined parameter
%              gramschmidt  % Gram-Schmidt: calculate orthonormal base
%              light        % add a light to current axes
%              set          % set user defined parameter
%              demo         % demonstration
%              pale         % visualise a wave function by pales
%              pcolor       % phase color
%              potential    % 3D plot of potential function
%              sceene       % setup a sceene
%              surf         % surface plot
%              view         % change view angles
%              well         % plot a cylindrical potential well in 3D
%              wing         % visualise a wave function by wings
%              zoom         % zoom in/out
%
%          Demo Methods:
%              demo         % demonstration
%              basics       % visualization of basics
%              harmonic     % harmonic oscillator
%              scatter      % demonstration
%
%          See also SHELL QUANTANA/DEMO, QUON, BION, HARMONIC, LADDER
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