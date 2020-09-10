% intro_understanding
echo on;
%
% UNDERSTANDING THE SINE DEMO
% ===========================
%
% We want to have a closer look to the Sine Demo in order to understand the
% details. The functions which are involved with Sine Demo can be grouped 
% into the following categories:
%
% 1) Standard MATLAB functions regarding figures and menu setup
% =============================================================
%
%    figure    create figure window or make a figure to current figure
%    gcf       get handle to current figure
%    get       get object properties
%    set       set object properties
%
% 2) Construction of a CORE object and opening a menu
% ===================================================
%
%    core      constructor for a CORE object
%
% 3) Menu item construction, choice and check menu functionality
% ==============================================================
%
%    mitem     Construct a menu item
%    choice    Choose from a number of alternative options
%    check     Change check-mark of toggling menu item
%
% 4) Context Settings
% ===================
%
%    default    provide a default value for a context setting
%    setting    get/set value of context setting; get/show all settings
%
% 5) Refreshing a figure
% ======================
%
%    refresh    setup a callback for figure refreshment / refresh figure
%    cls        clear screen
%
% Let's introduce these functions step by step!
%
[];
