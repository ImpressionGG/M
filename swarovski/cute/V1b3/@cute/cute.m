classdef cute < corazon                % Cute Class Definition
%
% CUTE   Class constructor for CUTE objects. CUTE objects have CORAZON as a
%        superclass and are to manage the analysis of Cutting Process Data
%        using Cutting Process Data Toolbox.
%
%           o = cute;                  % 'shell' typed CUTE construction
%           oo = cute(o);              % CUTE cast constructor
%
%        Supported CUTE types
%
%           o = cute('article');       % article (with master data)
%           o = cute('cut');           % cutting process log data object
%           o = cute('mpl');           % measurement plan
%           o = cute('pkg');           % package
%           o = cute('shell');         % shell object (container)
%
%        Methods:
%
%        1) Construction
%
%           cute         class constructor
%
%        2) Shell, Menu, File Operations
%
%           collect      collect files
%           filedate     extract date from file
%           shell        CUTE shell
%           menu         menu building blocks
%           new          new CUTE object
%           read         read object from file
%           split        split file name into chunks
%           write        write object to file
%           version      toolbox version, toolbox features & change log
%
%        3) Data
%
%           angle        get facette angle
%           article      load article from file
%           articles     persistent storage of articles directory
%           brew         data brewing
%           cluster      find facette clusters
%           context      extract context from path
%           cook         data cooking
%           facette      return facette angle
%           velocity     calculate velocity and elongation
%
%        4) Plot, Analysis & Study
%
%           analyse      analyse menu
%           cpk          calculate Cpk
%           fft          perform FFT
%           harmonic     harmonic fit
%           plot         plot menu
%           spec         get spec values, plot spec limits
%           study        study menu
%           thdr         total harmonic distortion
%
%      
%        Copyright(c): Bluenetics 2020
%
%        See also: CUTE, SHELL, MENU, PLOT, ANALYSE
%
   methods                             % public methods
      function o = cute(arg)           % cute constructor
         if (nargin == 0)
            arg = 'shell';             % 'shell' type by default
         end
         o@corazon(arg);               % construct base object
         o.tag = mfilename;            % tag must equal derived class name

         if (nargout == 0)
            launch(o);
            clear o;
         end
      end
   end
end
