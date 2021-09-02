%
% DYNAMIC   Add a menu and mark it as dynamic, or update all dynamic menus
%
%    Syntax
%
%       dynamic(o);            % make menu item a dynamic menu
%       enabled = dynamic(o)   % is dynamic mode enabled
%
%       o = dynamic(o,true);   % enable dynamic shell
%       o = dynamic(o,false);  % disable dynamic shell
%
%       oo = dynamic(o,oo)     % update all dynamic menus
%
%    Example: setup Plot and Animation menu as dynamic menus
%
%       o = dynamic(o,{'Plot','Animation'});  % setup dynamic menus
%
%    Dynamic menus are updated after each object selection change (usually
%    initiated by method CURRENT). The process is as follows:
%
%    1) Any dynamic shell must define the dynamic menu items by providing
%    the string 'Dynamic' in the user data.
%    2) Any object that wants to utilize dynamic menus must
%       a) support & publish local functions that build-up the dynamic menu
%       b) provide & publish a local shell function 'Dynamic' which returns
%       a list of the dynamic menu items to be activated
%    3) Upon object selection the shell must run the following process, 
%    which is supported by invoking oo = dynamic(o,oo):
%       a) clearing all dynamic menus and making them invisible
%       b) asking the object's shell for the list of dynamic items (by
%       invoking the published 'Dynamic' function
%       c) building up the dynamic menu items by invoking the according
%       local functions
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZON, MENU, CURRENT
%
