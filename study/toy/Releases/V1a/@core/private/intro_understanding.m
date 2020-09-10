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
%    uimenu    create user interface menu
%
% 2) Creation of a shell object and opening a menu
% ================================================
%
%    shell     constructor of shell object; optionally open a shell menu
%
% 3) Mounting menu roots, choice and check menu functionality
% ===========================================================
%
%    mount     mounting a menu root on a given mount location (mount point)
%    choice    Choose from a number of alternative options
%    check     Change check-mark of toggling menu item
%
% 4) Shell Settings
% =================
%
%    default    provide a default value for a shell setting
%    setting    get/set value of shell setting; get/show all shell settings
%
% 5) Refreshing a figure
% ================================================
%
%    cbsetup    setup a callback for figure refreshment
%    refresh    refresh figure
%    cls        clear screen
%
% Let's introduce these functions step by step!
%
[];
