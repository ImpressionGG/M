%
% ACTIVE   Get active type. The active type is determined by the value of
%          the control variable control(o,'active').
%
%             active(o,type);               % change active type
%             type = active(o)              % retrieve active type
%
%             active(o)                     % print active settings
%             active(o,oo)                  % make sure oo.type is active
%
%          Typical events which change the active type are:
%          1) object selection (change of current object - changes the
%             active object according to the type of the selected object.
%          2) calling GRAPH method, which changes the active type according
%             to the type of the object which is passed to the GRAPH method
%          3) Explicite call of change(o,'active',type) to change active
%             type according to the value passed in arg3.
%
%          Changing the active type using change(o,'active',type) will 
%          always cause a change of the View/Signal menu, while using
%          active(o,type) does only change the control variable setting,
%          but not change the menus.
%
%          Copyright(c): Bluenetics 2020 
%
%          See also: CORAZON, CHANGE, GRAPH, CONTROL
%
