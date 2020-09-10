classdef quantana < carabao       % Quantana Class Definition
%
% QUANTANA  Basis class (derived from CARABAO) to provide 1D and 2D based
%           data analysis capabilities.
%
%    Important methods
%
%       read, write:              % import/export driver and building block
%       cook:                     % data pre-processing for plotting
%       config, category, subplot % configuration for plotting
%
%    CARAMEL also provides a couple of plugins:
%
%       simple(caramel)           % plugin for SIMPLE & PLAIN typed objects
%       pbi(caramel)              % post bond analysis (x/y/theta)
%       dana(caramel)             % 2D based data analysis (x/y)
%       vibration(caramel)        % vibration analysis (x,y)
%
%    See also: CARABAO
%
   methods                             % public methods                
      function o = quantana(arg)       % quantana constructor  
         if (nargin == 0)
            arg = 'shell';             % 'shell' type by default
         end
         o@carabao(arg);               % construct base object
         o.tag = mfilename;            % tag must equal derived class name
      end
   end
   methods (Static)
      psi = normalize(psi,z)
      [P,sigma] = prob(psi,z)
      I = integrate(F,z)
   end
end


% % function out = quantana(varargin)
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
%              ball         % plot a ball sphere
%              bestof       % best of quantana
%              cls          % clear screen
%              cindex       % calculate proper color indices for cmap
%              cmap         % set color map
%              color        % set color according to color map
%              envi         % setup an environment for a quon
%              get          % get user defined parameter
%              gramschmidt  % Gram-Schmidt: calculate orthonormal base
%              invoke       % invoke a callback
%              light        % add a light to current axes
%              set          % set user defined parameter
%              demo         % demonstration
%              pale         % visualise a wave function by pales
%              pcolor       % phase color
%              potential    % 3D plot of potential function
%              sceene       % setup a sceene
%              surf         % surface plot
%              view         % change view angles
%              wall         % wall plot of a function psi
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
% %    varargin = varargfix(varargin);
% % 
% %    if (isempty(varargin))
% %       varargin = {'#DEMO'};
% %    end
% %    
% %    [obj,she] = derive(shell(varargin),mfilename);
% %    obj = class(obj,obj.tag,she);     
% % 
% %    if (nargout==0)
% %       demo(obj);
% %    else
% %       out = obj;
% %    end
% %    return           

% eof   