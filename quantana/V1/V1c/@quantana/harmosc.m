function harmosc(obj)
%
% HARMOSC     Callbacks for demo menu 'harmonic', regarding the
%             Harmonic Oscillator
%
%             Topics
%             - eigen functions
%             - eigen oscillations
%             - coherent state
%
   func = arg(obj);
   if isempty(func)
      mode = setting('harmonic.func');
   else
      setting('harmonic.func',func);
   end

   eval([func,'(obj);']);               % invoke callback
   return
   
%==========================================================================
% Harmonic Oscillators
%==========================================================================

function CbEigenFuncs(obj)
%
% EIGENFUNCTS  Plot eigen functions of harmonic oscillator
%
   hbar = 1; 
   om = 1;  % frequency of oszillator
   [t,z] = cspace(obj);
   
   cls(obj);

   hob = harmonic(1,z);    % create harmonic oscillator
   [psi,E] = eig(hob,0:6);

   V = 2*(z/2).^2;
   color(plot([min(z) max(z)],E*[1 1]),'a');
   hold on;
   plot(z,V,'b');
   
   for (n=0:6)
       E = (n+1/2)*hbar*om;
       if (n == 0)
           Hn = 1+0*z;
       elseif (n == 1)
           Hn1 = Hn;
           Hn = 2*z;
       else
           Hn2 = Hn1;  Hn1 = Hn;
           Hn = 2*z.*Hn1 - 2*(n-1)*Hn2;
       end
       facn = gamma(n+1);   % n!
       An = sqrt(1/(sqrt(pi)*2^n*facn));
       psi = An*exp(-z.*z/2).*Hn;
       
       %plot(z,E+0*z,'k:');
       color(plot(z,E+psi/2),'r',3);
   end
   
   plot([0 0],get(gca,'ylim'),'k');
   set(gca,'xlim',2*[min(z),max(z)],'ylim',[0,7]);
   ylabel('Potential V');
   title(sprintf('Eigen Functions of Harmonic Oscillator (omega = %g)',om));
   shg

   return
   
%==========================================================================

function CbEigenOscis(obj)
%
% EIGENOSCIS  Animate eigen states of harmonic oscillator
%
   hbar = 1; 
   om = 1;  % frequency of oszillator
   [t,z] = cspace(obj);
   
   cls(obj);

   V = 2*(z/2).^2;
   plot(z,V,'b');
   hold on;
   
   N = 6;
   
   % coefficients of coherent state
   
   for (i=0:N)
       for(j=0:N)
           c(i+1,j+1) = sqrt(i^j*exp(-i)/gamma(j+1));
       end
   end
   
   hdlr = zeros(1,N+1);
   hdlb = zeros(1,N+1);
   hdlg = zeros(1,N+1);

   dt = t(2) - t(1);
   smo = timer(smart,dt);

   t = 0;
   while (~stop(smo))
       Psi = zeros(length(z),N+1);
       for (n=0:N)
          k = n+1;
          En = (n+1/2)*hbar*om;
          if (n == 0)
             Hn = 1+0*z;
          elseif (n == 1)
             Hn1 = Hn;
             Hn = 2*z;
          else
             Hn2 = Hn1;  Hn1 = Hn;
             Hn = 2*z.*Hn1 - 2*(n-1)*Hn2;
          end
          facn = gamma(n+1);   % n!
          An = sqrt(1/(sqrt(pi)*2^n*facn));
          
          psi = An*exp(-z.*z/2).*Hn;
          psi = psi*exp(-sqrt(-1)*En*t);    
          Psi(:,n+1) = psi;
         
          phi = 0*z;
          for (j=0:n)
             phi = phi + c(n+1,j+1)*Psi(:,j+1);
          end
          
          if (hdlr(k)) delete(hdlr(k)); end
          if (hdlb(k)) delete(hdlb(k)); end
          if (hdlg(k)) delete(hdlg(k)); end
       
          if (i == 1)
             plot(z,En+0*z,'k:');
          end
          hdlr(k) = plot(z,En+real(psi)/2);
          color(hdlr(k),'r',3);

          hdlb(k) = plot(z,En+real(phi)/2);
          color(hdlb(k),'b',1);

          P = abs(phi).^2;
          
          hdlg(k) = plot(z,En+P);
          color(hdlg(k),'g',3);
       end
   
       if (t==0)
          plot([0 0],get(gca,'ylim'),'k');
          set(gca,'xlim',2*[min(z),max(z)],'ylim',[0,7]);
          ylabel('Potential V, Eigen Functions psi(n)');
          title(sprintf('Eigen Functions of Harmonic Oscillator (omega = %g)',om));
       end
       t = t + dt;

       smo = wait(smo);
   end
   return

%==========================================================================

function CbCoherent(obj)
%
% EIGENOSCIS  Animate eigen states of harmonic oscillator
%
   hbar = 1; 
   om = 1;  % frequency of oszillator

   obj = option(obj,'global.zmin',-10,'global.zmax',10,'global.nz',200);
   [t,z] = cspace(obj);
   
   
   cls(obj);

   V = 2*(z/2).^2;
   plot(z,V,'b');
   hold on;
   
   M = 20;
   PsiM = hobase(hbar*om,z,M);     % eigenfunctions of harmonic oscillator
   for (N=1:6)                     % N does not need to be an integer
      c = ccoeff(N,M);
      CBase{N} = PsiM*diag(c);     % coherent base
   end
   
   nmax = 6;
   
   % coefficients of coherent state
   
   for (i=0:N)
       for(j=0:N)
           c(i+1,j+1) = sqrt(i^j*exp(-i)/gamma(j+1));
       end
   end
   
   hdlr = zeros(1,N+1);
   hdlb = zeros(1,N+1);
   hdlg = zeros(1,N+1);
   hdlR = zeros(1,N+1);
   hdlB = zeros(1,N+1);

   dt = t(2) - t(1);
   smo = timer(smart,dt);

   t = 0;
   while (~stop(smo))
       Psi = zeros(length(z),nmax+1);
       for (n=0:nmax)
          k = n+1;
          En = (n+1/2)*hbar*om;
          if (n == 0)
             Hn = 1+0*z;
          elseif (n == 1)
             Hn1 = Hn;
             Hn = 2*z;
          else
             Hn2 = Hn1;  Hn1 = Hn;
             Hn = 2*z.*Hn1 - 2*(n-1)*Hn2;
          end
          facn = gamma(n+1);   % n!
          An = sqrt(1/(sqrt(pi)*2^n*facn));
          
          psin = An*exp(-z.*z/2).*Hn;
          psi = psin*exp(-sqrt(-1)*En*t);    
          Psi(:,n+1) = psi;
         
          phi = 0*z;
          for (j=0:n)
             phi = phi + c(n+1,j+1)*Psi(:,j+1);
          end
          
          if (hdlr(k)) delete(hdlr(k)); end
          if (hdlb(k)) delete(hdlb(k)); end
          if (hdlg(k)) delete(hdlg(k)); end
          if (hdlR(k)) delete(hdlR(k)); end
          if (hdlB(k)) delete(hdlB(k)); end
       
          if (i == 1)
             plot(z,En+0*z,'k:');
          end
          hdlr(k) = plot(z,En+real(psi)/2);
          color(hdlr(k),'r',3);

          hdlR(k) = plot(z,En+real(PsiM(:,n+1))/2);
          color(hdlR(k),'w',1);
          
          hdlb(k) = plot(z,En+real(phi)/2);
          color(hdlb(k),'b',1);

          if (k > 1)
             N = k-1;
             p = cophasor(M,om,t);   % actual phasor for coherent state
             CB = CBase{N};
             psiN = CB * p;          % coherent state

             apm = abs(psiN).^2;  apm = apm/sum(apm);
             hdlB(k) = plot(z,apm*50); %, En+real(p),[1:length(p)]','o');
             color(hdlB(k),'c',3);
          end
          
          P = abs(phi).^2;
          
          hdlg(k) = plot(z,En+P);
          color(hdlg(k),'g',3);
       end
   
       if (t==0)
          plot([0 0],get(gca,'ylim'),'k');
          set(gca,'xlim',[min(z),max(z)],'ylim',[0,7]);
          ylabel('Potential V, Eigen Functions psi(n)');
          title(sprintf('Eigen Functions of Harmonic Oscillator (omega = %g)',om));
       end
       t = t + dt;

       smo = wait(smo);
   end
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
  
   
function PsiM = hobase(hbarom,z,M)
%
% HOBASE       Retrieve the matrix of M+1 eigen functions according to
%              a coordinate vector z according to the harmonic oscillator
%
%                 PsiM = hobase(hbaromega,z,M)  % M+1 eigen functions
%
   for (n=0:M)
       if (n == 0)
           Hn = z*0 + 1;    % H0 = 1
       elseif (n == 1)
           Hn1 = Hn;
           Hn = 2*z;        % H1 = 2*z
       else
           Hn2 = Hn1;  Hn1 = Hn;
           Hn = 2*Hn1.*z - 2*(n-1)*Hn2;
       end
       
       An = 1/sqrt(sqrt(pi)*2^n*gamma(n+1));
       psin = An * exp(-z.*z/2) .* Hn;
       
       PsiM(1:length(z),n+1) = psin(:);
   end
   return

function PM = cobase(N,M,z)
%
% COBASE     Get the coherent base matrix which allows to calculate the
%            coherent state Psi_N(z,t) comprising M summation terms of the
%            infinite sum, 
%
%               Psi_N(z,t) = Sum(n=0:inf){CNn*exp[-i*(n+1/2)*om*t]*psi_n(z)}
%
%            thus defining
%
%               PM = PsiM * diag(CNn) = 
%                 = [psi_0(z)*CN0, psi_1(z)*CN1, ...,psi_M(z)*CNM]
%
%            where the resulting N x (M+1) matrix P can be used to calculate
%            
%               Psi_N ~ PM * exp(-i*([0 1 2 ... M]+1/2)*om*t)
%            
   PsiM = hobase(hbar*om,z,M);     % eigenfunctions of harmonic oscillator
   cN = ccoeff(N,M);
   PM = PsiM*diag(cN);
 
return

function p = cophasor(M,om,t)
%
% COPHASOR  Galculate the actual phasor (vector) which allows together
%           with the coherent base to calculate the coherent state.
%
%              PM = cobase(N,M,z);       % coherent base
%              p = cophasor(M,omega,t);  % actual phasor
%              psiN = PM*p;              % coherent state
%
   iu = sqrt(-1);   % imaginary unit
   p = exp(-iu*([0:M]+1/2)*om*t);
   p = p(:);
   return
   
%eof   
   