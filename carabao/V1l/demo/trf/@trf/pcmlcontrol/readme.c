		浜様様様様様様様様様様様様様様様様様様様様様様様様様融
		�		 < P C - M A T L A B >		     �
		�		 Control System Toolbox		     �
		�  Copyright (c) The MathWorks, Inc. 1984,1985,1986  �
		�	  	  All rights reserved		     �
		�		Version 2.03  17-Mar-86		     �
		藩様様様様様様様様様様様様様様様様様様様様様様様様様夕
		    Summary of files on the Control Disk

This disk contains .M files that are used with PC-MATLAB for control
system engineering.

1. New .M Files

Here are some .M files that are NOT described in the user's guide because
they were added after printing:

File		Synopsis

balreal.m	Balanced state-space realization.
gram.m		Controllability and observability gramians.
lyap.m		Solve Lyapunov equation.
dlyap.m		Solve discrete Lyapunov equation.


2. Unlisted .M Files

Here are some .M files that are NOT described in the user's guide because
they were not significant enough to warrant expostulation:

File		Synopsis

abcdcheck.m	Check the consistency of an (A,B,C,D) set.
dric.m		Verify discrete Riccati equation.
errmsg.m	Display error message.
fixphase.m	Unwrap phase for Bode plots.
nargcheck.m	Make sure .m file has correct number of arguments.
ord2.m		Generate A,B,C,D for a second order system.
ric.m		Verify continuous Riccati equation.


3. Basic Toolbox Functions

Most of the .M files on this disk implement some feature of the Toolbox 
and ARE described in the user's guide.  Here is a list of them:

File		Synopsis

append.m	Append system dynamics.
blkbuild.m	Build a diagonal model from block diagram.
bode.m		Bode plots.
c2d.m		Conversion from continuous to discrete time.
connect.m	State-space model from a block diagram.
ctrb.m		Controllability matrix.
d2c.m		Conversion from discrete to continuous time.
damp.m		Damping factors and natural frequencies.
dbode.m		Discrete Bode plots.
dimpulse.m	Discrete-time unit sample response.
dlqe.m		Discrete linear quadratic estimator design.
dlqr.m		Discrete linear quadratic regulator design.
dlsim.m		Discrete system simulation to arbitrary inputs.
dstep.m		Discrete-time step response.
impulse.m	Impulse response.
lqe.m		Linear quadratic estimator design.
lqr.m		Linear quadratic regulator design.
lsim.m		Continuous system simulation to arbitrary inputs.
margin.m	Gain and phase margins.
nyquist.m	Nyquist plots.
obsv.m		Observability matrix.
parallel.m	Parallel system connection.
place.m		Pole placement.
rlocus.m	Root-locus.
series.m	Series system connection.
ss2tf.m		State-space to transfer function conversion.
ss2zp.m		State-space to Zero-Pole-Gain conversion.
step.m		Step response.
tf2ss.m		Transfer function to state-space conversion.
tf2zp.m		Transfer function to zero-pole conversion.
zp2tf.m		Zero-pole to transfer function conversion.
zp2ss.m		Zero-pole to state-space conversion.
tzero.m		Transmission zeros.


4. Demonstrations

There is a .M file that demonstrates the use of some of these tools:

ctrldemo.m	Control system tools demonstration.


5. Supersede

The following .M files supersede .M files that are supplied on the 
Utility Disk:

demo.m		These two update the demo facility to include the
demolist.m	control system demo.
                                                                                                                                                                                                                                                                                                                                                                 