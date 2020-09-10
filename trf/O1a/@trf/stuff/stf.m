function [Gs,Ts] = stf(obj)
%
% STF     S-transformation.
%
%            [Gs,Ts] = tffstf(Gq)
%            [Gs,Ts] = tffstf(Gz)
%
%         Gs = STF(Gq) converts a q type transfer function or a z type
%         transfer function into an s type transfer function. 
%         In addition [Gs,Ts] = tffstf(Gq) returns the sampling intervall. 
%
%	  See also: TFF, ZTF, QTF
%
     
   G = data(obj);
   [Gs,Ts] = tffstf(G);
   Gs = tff(Gs);
   
   return
   
%eof   