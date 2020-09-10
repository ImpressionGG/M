function [kr,cr] = thdr(o,t,x)
%
% THDR    Total harmonic distortion (RMS) of a signal x
%
%            kr = thdr(o,t,x)        % kr: total harominc distortion (rms)
%            [kr,cr] = thdr(o,t,x)   % cr: credibilitx 1-kr in percent
%
%         Definition
%
%            kr = sum(i=2,...){X_rms,i^ 2} / X_rms,tot
%
%         See also: CUT, FFT
%
   [f,X] = fft(o,t,x);
   
   idx = find(f>1500);   
   kr = norm(X(idx))/norm(X);
   cr = o.rd((1-kr)*100,1);
end