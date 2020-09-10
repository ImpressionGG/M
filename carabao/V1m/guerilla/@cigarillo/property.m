function prop = property(o,propname,proplist)
% 
% PROPERTY   Get a property of a DANA object
%      
%    Syntax:
%       o = dana(data)                        % create DANA object
%       p = property(o,'series')              % get proerty value 'isseries'
%       ok = property(o,'count',{'#BKB01'})   % is property in property list
% 
%       Supportet properties:
% 
%          acalc     mode of calculating actor coordinates
%          calc      default mode for calculation
%          count
%          filter    default mode for filter
%          kind      TDK, BKB, TKP
%          menu
%          pcalc     mode of calculating position coordinates
%          pdata     P-data (position data)
%          qdata     Q-data (isometric coordinates)
%          series    1 if DANAOBJ is a series or 0 otherwise
%          time      how to get time data
%          tqk       transformation matrix Tqk
%          tqp       transformation matrix Tqp
% 
%       See also DANA, DANAOBJ
%
   general = {'acalc','dcalc','calc','count','filter','kind','menu',...
              'pcalc','pdata','qdata','series','time','tqk','tqp'};
   
   switch propname
      case general                     % general properties handeled here!
      otherwise                        % rest done by CORE property method
         prop = property(o.trace,propname);
         return
   end

% handle general properties for TRACE objects

   fmt = format(o);
   prop = [];             % by default
   
% property KIND

      % TDK: Temperaturdrift-Kompensation (kann Kind-Objekte haben)
      % BKB: Basiskalibrierung
      % TKP: Prueflauf (Kontrollauf)
   
   switch propname      
      case 'kind'
         switch fmt
            case {'#TDK01','#TDK02'}
               prop = 'TDK';
            case {'#BKB01','#BKB02','#BKB03'}
               prop = 'BKB';
            case {'#TKP01','#TKP02'}
               prop = 'TKP';
            case {'#CAP01','#CAP02'}
               prop = 'CAP';
            otherwise
               prop = '???';
         end

      case 'series'
         if strcmp(fmt,'#TDK02')
            prop = 1;
         else
            prop = 0;
         end
         
      case 'count'
         assoc = {
            {'#BKB01','#BKB02','#BKB03'},'BKB_A'
            {'#CAP01','#CAP02'},'CAP_A'
            {'#FPR01'},'FPR_A'
            {'#RKK01'},'RKK_A'
            {'#TDK01'}, 'TDK_A'
            {'#TDK02'}, 'TDK_B'
            {'#TDM01','#TDM02'},'TDM_A' 
            {'#TKP01','#TKP02'},'TKP_A' 
            'else','#???'
         };
         prop = associate(fmt,assoc);
   
      
      case 'menu'
                           % supported menus are:
                           % 1: Choose
                           % 2: View
                           % 3: Temperature
                           % 4: Raw Reading
                           % 5: Correction
                           % 6: Drift
                           % 7: Analysis
                           % 8: Study
                           % 9: Info
                           % 10: Characteristics
                           % 11: Offset
         assoc = {
            {'#BKB01','#BKB02','#BKB03'},[1 2 3 4 5 9 10 11]
            {'#BUY01','#BUY02'},[1 2 7.01 7.02]
            {'#CAP01','#CAP02'},[1 2 6 7 9]
            {'#FPR01'}, [1 2 5 9]
            {'#TDM01','#TDM02'}, (1:9)
            {'#TDK01'}, (1:9)
            {'#TDK02'}, [1 9]
            {'#TKP01','#TKP02'},[1 2 4 6 7 8 9 10 11] 
            'else',(1:9)
         };
         prop = associate(fmt,assoc);

      case {'tqk','pdata'}
         % property TQK, TQP, PDATA

         % methods to retrieve Tqk, Tqp transformation matrix, or pdata
         % 0: Calculate (reconstruction)
         % 1: Retrieve machine data
   
         assoc = {
            {'#TKP01','#TKP02'},1
            'else',0
         };
         prop = associate(fmt,assoc);
   
      case 'tqp'
         assoc = {
            {'#TKP01'},1
            {'#TKP02'},2
            'else',0
         };
         prop = associate(fmt,assoc);
   
      case 'qdata'
         % property QDATA

         % methods to retrieve qdata
         % 0: Calculate via Tqk and K-coordinates (reconstruction)
         % 1: Calculate via Tqp and P-coordinates (reconstruction)
   
         assoc = {
            {'#TKP01'},1
            {'#TKP02'},2
            'else',0
         };
         prop = associate(fmt,assoc);
   
      case 'calc'    % property CALC - default mode for calculation
         prop = 1;   % default mode 1 for calculation (all object classes)
   
      case 'filter'
         prop = 6;   % default mode 6 for filter (all object classes)
   
      case 'acalc'                     % property ACALC
         assoc = {
            {'#BKB02'},'BKB_A'
            {'#BKB03'},'BKB_A'
            {'#TKP01','#TKP02'},'TKP_A'
            'else','???'
         };
         prop = associate(fmt,assoc);
   
      case 'time'                      % property TIME
         assoc = {
            {'#TDK01','#TDK02','#BKB01','#BKB02','#BKB03','#TKP01','#TKP02'},'TIME_A'
            {'#TDM01','#TDM02'},'TIME_B'
            'else','???'
         };
         prop = associate(fmt,assoc);

      case 'dcalc'                     % property DCALC
         assoc = {
            {'#BKB02'},'BKB_A'
            {'#BKB03'},'BKB_B'
            'else','???'
         };
         prop = associate(fmt,assoc);

      case 'pcalc'                     % property PCALC     
         assoc = {
            {'#TKP01'},'TKP_1'
            {'#TKP02'},'TKP_2'
            'else','???'
         };
         prop = associate(fmt,assoc);
   end
   
      % If nargin >= 3 we check if property is in property list
   
   if nargin >= 3
      prop = isequal(prop,proplist);
   end
end
   
%==========================================================================
% Auxillary Functions   
%==========================================================================
   
function prop = associate(fmt,assoc)
   prop = [];   % by default
   for i=1:size(assoc,1),
      list = assoc{i,1};
      if iscell(list)
         if isequal(fmt,list)
            prop = assoc{i,2};
            return
         end
      elseif (i==size(assoc,1) && ischar(list))
         if strcmp(list,'else')
            prop = assoc{i,2};
            return
         end
      else
         error('bug: bad format of assoc list!')
      end
   end
end
