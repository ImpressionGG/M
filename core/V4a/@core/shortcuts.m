function [LB,CB,UD,EN,CHK,CHKR,VI,CHC,CHCR,MF,AC] = shortcuts(obj)
%
% SHORTCUTS  Define shortcuts for menu construction
%
%               [LB,CB,UD,EN,CHK,CHKR,VI,CHC,CHCR,MF,AC] = shortcuts(shell)
%
%            See also: SHELL
%
   stack = dbstack;           % get calling stack 
   path = stack(2).file;      % get path of mfile name

   [p,mfile,ext] = fileparts(path);

   %mfile = handle(gfo);   
   %cbrefresh = [mfile,'(gfo,''','refresh',''');'];
   cbrefresh = [mfile,'(arg(gfo,''','refresh','''));'];

   LB = 'label';  CB = 'callback';  UD = 'userdata';  EN = 'enable'; 
   %CHK = 'check(gcbo);';  CHKR = [CHK,call('refresh')];  VI = 'visible';
   %CHC = 'choice(gcbo);'; CHCR = [CHC,call('refresh')]; 
   CHK = 'check(gcbo);';  CHKR = [CHK,cbrefresh];  VI = 'visible';
   CHC = 'choice(gcbo);'; CHCR = [CHC,cbrefresh]; 
   MF = mfile;  AC = 'accelerator';
   
   return

% eof