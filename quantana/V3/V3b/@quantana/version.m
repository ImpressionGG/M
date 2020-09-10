function out = version(obj)
%
% VERSION   Get version of QUANTANA toolbox
%
%              vs = version(quantana); % get version string
%              version(quantana);      % type also release notes
%                                        / known bugs
%
%           See also: QUANTANA
%
%---------------------------------------------------------------------------
%
% Release Notes Quantana/V1A
% ==========================
%
% - Build basic methods and basic demo features
% - phase color and complex color maps and visualization
% - harmonic oscillator basics
% - scattering of classical particles, bosons and fermions
%
% Release Notes Quantana/V3A
% ==========================
%
% - First success in Bohmian motion animation. Still need correction of v
%   by  a factor of 5
% - BAK4
% - tube thickness of wing plot reduced by 2/3
% - new method QUANTANA/WALL (wall plot)
% - invoke method QUANTANA/INVOKE added
% - BAK9
% - TENSOR object introduced
% - Release Mar-08-2015
%
% Release Notes Quantana/V3B
% ==========================
%
   path = upper(which('quantana/version'));
   idx = max(strfind(path,'\@QUANTANA\VERSION.M'));
   vers = path(idx-3:idx-1);
   
   if (nargout == 0)
      help quantana/version
      line = '-------------------';
      fprintf([line,line,line,line,'\n']);
      fprintf(['Quantana Toolbox - Version: ',vers,'\n']);
      fprintf([line,line,line,line,'\n']);
   else
      out = vers;
   end
   return
   
% eof   