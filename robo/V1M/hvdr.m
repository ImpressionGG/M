function [Vh,Dh,Rh] = hvdr(Th)
%
% HVDR      VDR factorizaton of a homogeneous 3H or 4H transformation matrix.
%
%              [Vh,Dh,Rh] = hvdr(Th)     % VDR factorization: Th = Vh*Dh*Rh
%
%           where
%              Vh: 3H or 4H translation matrix
%              Dh: 3H or 4H deformation matrix (Dh=Sh*Kh - scale and then shear)
%              Rh: 3H or 4H rotation matrix
%
%           See also: ROBO, RKS, HSKR, HRKS, HROT, SCALE, SHEAR, HTRAN
%
   [Sh,Kh,Rh,Vh] = hskr(Th);
   Dh = Sh*Kh;
   
% eof   