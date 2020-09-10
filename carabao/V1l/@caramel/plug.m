function plug(o)
%
% PLUG   Install all available CARAMEL plugin_s
%
%
%        sample:  plugin supporting sample log data file types like
%                 simple sample ('smp' type, extension .smp, .dat) 
%                 and plain sample ('pln' type, extension .pln, .dat)
%
%        basis:   plugin supporting log data files for vibration
%                 test ('vib' type, extension .txt, .dat) and BMC
%                 test ('bmc' type, extension .dat, .txt, .pbi)
%
%        pbi:     plugin support for matrix based PBI log files
%                 ('pbi' type, extension .dat, .txt, .pbi), inclu-
%                 ding and matrix-BMC test ('mbc' type, extension
%                 .dat, .pbi, .txt)
%
%        dana:    plugin support data analysis log files ('dana' type,
%                 extension .dat, .m)
%
%        tcb:     plugin support for TCB trace files ('tcb' type,
%                 extension .dat, .trace)
%
%        motion:  plugin support for MOTION trace files ('motion' type,
%                 extension .dat, .mot)
%
%        See also: CARAMEL, PLUGIN, SAMPLE, BASIS, PBI, DANA, TCB, MOTION
%
   fprintf('installing SAMPLE plugin ...\n');
   sample(o,'Register');               % register sample plugin

   fprintf('installing BASIS plugin ...\n');
   basis(o,'Register');                % register basis plugin

   fprintf('installing PBI plugin ...\n');
   pbi(o,'Register');                  % register pbi plugin
   
   fprintf('installing DANA plugin ...\n');
   dana(o,'Register');                 % register dana plugin
   
   fprintf('installing TCB plugin ...\n');
   tcb(o,'Register');                  % register tcb plugin
   
   fprintf('installing MOTION plugin ...\n');
   motion(o,'Register');               % register motion plugin
   
   fprintf('rebuilding menu ...\n');
   rebuild(o);                         % rebuild menu
end
