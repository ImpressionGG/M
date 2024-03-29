function [Gm,Pm,Wcg,Wcp] = margin(mag,phase,w)
%MARGIN	Gain margin, phase margin, and crossover frequencies.
%	[Gm,Pm,Wcg,Wcp] = MARGIN(MAG,PHASE,W) returns gain margin Gm,
%	phase margin Pm, and associated frequencies Wcg and Wcp, given
%	the Bode magnitude, phase, and frequency vectors MAG, PHASE,
%	and W from a system.  Interpolation is performed between frequency
%	points to find the correct values.    Here is an example,
%
%		w = logspace(-1,2);
%		[mag,phase] = bode(a,b,c,d,1,w);
%		[Gm,Pm,Wcg,Wcp] = margin(mag,phase,w)


% 	J.N. Little 3-24-86
%	Copyright (c) 1985, 1986 by the MathWorks, Inc.

% Make phase continuous thru -180:
phase = fixphase(phase);
Gm = []; Pm = []; Wcg = []; Wcp = [];

% Find gain margin:
i = find(phase < -180);
if length(i) == 0
	disp('Warning: Gain margin undefined; phase does not cross -180')
else
	i2 = i(1);
	i1 = i2 - 1;
	w1 = w(i1);
	w2 = w(i2);
	m1 = mag(i1);
	m2 = mag(i2);
	p1 = phase(i1);
	p2 = phase(i2);
	Wcg = w1 - (180+p1)/(p2-p1)*(w2-w1);
	Gm = 1 / (mag(i1) + (m2-m1)/(w2-w1)*(Wcg-w1));
end

% Find phase margin:
i = find(mag < 1);
if length(i) == 0
	disp('Warning: Phase margin undefined; gain does not cross 1.0')
	return
end
i2 = i(1);
i1 = i2 - 1;
if i1 == 0
	disp('Warning: Phase margin undefined; gain does not cross 1.0')
	return
end
w1 = w(i1);
w2 = w(i2);
m1 = mag(i1);
m2 = mag(i2);
p1 = phase(i1);
p2 = phase(i2);
Wcp = w1 + (1-m1)/(m2-m1)*(w2-w1);
Pm = phase(i1) + (p2-p1)/(w2-w1)*(Wcp-w1) + 180;
             