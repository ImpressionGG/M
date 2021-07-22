%
% READ     Read a CORAZON object from file.
%
%             oo = read(o,'ReadLogLog',path)  % Log data .log read driver
%             oo = read(o,'ReadStuffTxt',path) % Stuff .txt read driver
%
%          Read some generic stuff
%
%             oo = read(o,'ReadPkgPkg',path) % Package Info .pkg driver
%             oo = read(o,'ReadGenDat',path) % General Log Data .dat driver
%             oo = read(o,'ReadSmpDat',path) % Simple or Plain .dat driver
%             oo = read(o,'ReadVibTxt',path) % Vibration test .txt driver
%             oo = read(o,'ReadBmcTxt',path) % BMC test .txt driver
%             oo = read(o,'ReadPbiPbi',path) % PBI .pbi data driver
%
%          Besides of READ drivers there are also auxillary functions
%          for partial read tasks:
%
%             oo = read(o,'Open',path) % open file & create object
%             oo = read(oo,'Init')     % init object
%             oo = read(oo,'Type')     % extract object type
%             oo = read(oo,'Param')    % read parameters
%             oo = read(oo,'Head')     % read header
%             oo = read(oo,'Data')     % read data
%             oo = read(oo,'Close')    % close file & cleanup object
%             oo = read(o,'Snif',path) % Snif Parameters
%
%          Also possible to get next line from file, updating line number
%          and verbose talking
%
%             oo = read(oo,'Line')
%             line = var(o,'line')     % EOF for ~ischar(line)
%
%          Options
%
%             progress     % show progress bar (enabled by default)
%                                    
%          Copyright (c): Bluenetics 2020 
%
%          See also: CORAZON, IMPORT, WRITE
%
