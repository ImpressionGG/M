function err = integrity(o,lamb)
%
% INTEGRITY   Integrity check for spectral functions (debug method)
%
%                err = integrity(o,lambda0)
%
%             Copyright(c): Bluenetics 2021
%
%             See also: SPM, CRITICAL, GAMMA
%
   [i0,j0,K,f,Ljw] = var(lamb,'i0,j0,K,f,fqr');
   
   if isinf(K)                   % no further checks
      err = 0;                   % no error
      return
   end
   
      % K correction for gamma functions
      
   name = [get(lamb,{'name',''}),'____'];
   if isequal(name(1:4),'gamm')
      K = 1;
   end
   
      % calculate Nyquist error
   
   Ljw0 = Ljw(:,j0);
   
   M = abs(1+K*Ljw0);
   [err,i] = min(M);                   % Nyquist error
   
   if (i ~= i0)
      error('index integrity violated (i0)');
   end
   
   if (err > 1e-6)
      error('high Nyquist error');
   end
end