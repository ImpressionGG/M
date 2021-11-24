%
% WRITE    Write a CORAZON object to file.
%
%             oo = write(o,'WriteLogLog',path)
%             oo = write(o,'WriteStuffTxt',path)
%
%          Some generic data formats
%
%             oo = write(o,'WriteSmpDat',path) % write a simple object 
%             oo = write(o,'WriteGenDat',path) % write a general object 
%             oo = write(o,'WritePkgPkg',path) % write a package object
%
%          Besides of WRITE drivers there are also auxillary functions
%          for partial write tasks:
%
%             oo = write(oo,'Type',fid)     % write object type
%             oo = write(oo,'Param',fid)    % write parameters
%             oo = write(oo,'Header',fid)   % write parameters
%             oo = write(oo,'Data',fid)     % write parameters
%
%          See also: CORAZON, EXPORT
%          Copyright (c): Bluenetics 2020 
%
