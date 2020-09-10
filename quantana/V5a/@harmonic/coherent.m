function cN = coherent(obj,N,M)
%
% COHERENT    Get the coefficients with index 0..M for the coherent state
%             number N of a given harmonic oscillator. Note that N can be
%             any positive real number
%
%                cN = coherent(osc,N,M) % coefficients for states 0..M 
%
%                cN = coherent(osc,N)   % get as many as there have been
%                                       % specified in the setup call. by
%                                       % default get M = 25
%                           
%             To calculate the coherent state psiN(z,t):
%
%                N = 6;  M = 25;
%                osc = harmonic(1.0);
%                psiN = eig(osc,0:M,z,t) * coherent(osc,N,M);
%
%             See also: HARMONIC, SETUP, EIG
%
   if (nargin < 3)
      PSI = eig(obj);
      M = size(PSI,2);
   end
   
   cN = ccoeff(N,M);
   return
   
%==========================================================================   
   
function cN = ccoeff(N,M)
%
% CCOEFF     Get coefficient (M+1) vector for the coherent state N
%            cN = [cN0; cN1; ...; cNM]
%
%               cN = ccoeff(N,M)  % coefficients of coherent state
%
%            These calculate:
%
%               CNn = sqrt( N^n*exp(-N) / n! )
%
%            The coherent state then calculates as follows:
%
%               Psi_N(z,t) = Sum(n=0:inf){CNn*exp[-i*(n+1/2)*om*t]*psi_n(z)}
%
   for (n=0:M)
      CNn = sqrt(N^n*exp(-N)/gamma(n+1));
      cN(n+1) = CNn;
   end
   cN = cN(:);
   return
  
      