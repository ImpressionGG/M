%% Oscillator 
% Let us start with basics. Let us start with the investigation of a simple 
% oscillator. An undamped spring mass system is complex enough for these
% very first considerations. In a second step we will introduce damping to
% the spring mass system and will internalize the changes. Ready? Let's go!
%%

%% Undamped Spring-Mass System
% Consider the spring-mass system in the figure below!
%
% <<f1_1_undamped_spring_mass.png>>
%
% What is a proper mathematical description? What about Newton's law "mass
% times acceleration equals sum of forces"?
%
% $$m \ddot q=\sum F $$  
%
% Well, this task seems to be easy! Two forces can be identified, which act
% on mass $m$: the exciting force $F$ in positive direction and spring force
% $F_k=kq$ in negative direction with $q$ denoting the elongation from
% equilibrium. This gives Newton's law a specific face.
%
% $$  m\ddot q=F-kq $$
%
% we have now a mathematical description - a linear ordinary differential
% equation of order 2.

%% Homogeneous Solution
% How does the free system behave? This 
% question leads us to the homogeneous solution of our differential 
% equation with $F=0$. Let's rewrite our equation to better see what we 
% have in front of us.
%
% $$  m\ddot q+kq=0 $$
%

%% Stuff
s = dot(A,B);
%% Cross Product
% A cross product of two vectors yields a third
% vector perpendicular to both original vectors.
% Again, MATLAB has a simple command for cross products.
v = cross(A,B);
%% Inline Expression
% $x^2+e^{\pi i}$
%% Block Equation
%
% $$e^{\pi i} + 1 = 0$$
%