function [knd,Ts] = kind(obj)
%
% KIND    Transfer function kind. Return either 's', 'z' or 'q', depending
%         on transfer function type G(s), h(z) or G#(q).
%
%            knd = kind(Gs)
%            [knd,Ts] = kind(Gs)    % get also sampling time
%
   G = data(obj);
   [class,knd,sign] = ddmagic(G);
   str = 'szq';
   knd = str(knd);
   Ts = G(2,1);
   return
   
%eof   