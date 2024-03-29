function [z,p,k] = tf2zp(num,den)
%TF2ZP	Transfer function to zero-pole conversion.
%	[Z,p,k] = TF2ZP(NUM,den)  finds the zeros, poles, and gains:
%
%			  (s-z1)(s-z2)...(s-zn)
%		H(s) =  K ---------------------
%			  (s-p1)(s-p2)...(s-pn)
%
%	from a SIMO transfer function in polynomial form:
%
%			NUM(s)
%		H(s) = -------- 
%			den(s)
%
%	Vector DEN specifies the coefficients of the denominator in 
%	descending powers of s.  Matrix NUM indicates the numerator 
%	coefficients with as many rows as there are outputs.  The zero
%	locations are returned in the columns of matrix Z, with as many 
%	columns as there are rows in NUM.  The pole locations are returned 
%	in column vector P, and the gains for each numerator transfer function
%	in vector K. See ZP2TF to convert the other way.

[a,b,c,d] = tf2ss(num,den);
[z,p,k] = ss2zp(a,b,c,d,1);
                                                                                                                                                      