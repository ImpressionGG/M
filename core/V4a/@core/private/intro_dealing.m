% intro_dealing
echo on;
%
% DEALING WITH AN OBJECT
% ======================
%
% It seems that we have created a graphical shell which allows us to change
% some settings, display  these settings and do some plotting which is 
% based on the selected settings.
%
% We did, however, also create an OBJECT which allows us to control all the
% tasks listed above. This object is a CORE object, and it means, that the
% object is a so called 'instance' of class CORE. 
%
% The nature of OBJECTs is the idea of encapsulated data and a well defined
% set of functions which are the only ones to manipulate the encapsulated
% data.
%
% In object oriented context the encapsulated data is called 'data members'
% and the well defined set of functions for data member manipulation are
% called 'methods'.
%
% Let's see how we can access our CORE object:
%
   figure(0815);    % make sure that Sine Demo is active figure
   obj = gfo        % get current figure's object
%
   disp(obj)
%
[];
