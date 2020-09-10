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
% Release Notes Quantana/V1B
% ==========================
%
% - study the Schroedinger equation
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