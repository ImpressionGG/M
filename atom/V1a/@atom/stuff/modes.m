function o = modes(o)                  % Provide Modes as Options      
%
% MODES   Provide unpacked plotting modes, if they are not already
%         provided, and use defaults from mode settings
%         
%            o = modes(o)              % provide plot modes from settings
%
%         The procedure is as follows
%            1) get the option value which was inherited from settings
%               (e.g opt(o,'mode.bias') and use this value as default
%            2) if the default of 2) is empty then use an explicite
%               default value (e.g. 'absolute')
%            3) provide the default to the intended option, this means the
%               option value will only be replaced with the default value
%               if the current option vaue is empty. Otherwise the current
%               option value will be unchanged!
%
%         For the following options according defaults are provided:
%
%            option         setting             default
%         --------------------------------------------------------
%            bias           mode.bias           'absolute'
%            plot           mode.plot           'Stream'
%
%            grid           view.grid           0
%            camera         view.camera         struct('azel', [-40 30])
%
%            bullets        style.bullets       0
%            linewidth      style.linewidth     1
%            labels         style.labels        'plain'
%            overlays       style.overlays      'index'
%            digits         style.digits        2
%            legend         style.legend        0
%            background     style.background    'white'
%
%            scope          select.scope        []
%            from           select.from         1
%            to             select.to           inf
%            ignore         select.ignore       0
%
%         Example:#%
%            o = modes(o)              % provide modes
%            overlays = opt(o,'overlays');
%            bias = opt(o,'bias');
%
%         See also: CARAMEL, PLOT, LABELS, SETTING
%
   list = {{'bias','absolute'},{'plot','Stream'}};
   o = Provide(o,'mode',list);         % provide mode options

      % view options

   list = {{'camera',struct('azel',[-40,30])},{'grid',0}};
   o = Provide(o,'view',list);         % provide 'view' options

      % style options

   list = {{'bullets',0},{'linewidth',1},{'labels','plain'},...
           {'overlays','index'},{'digits',2},{'legend',0},...
           {'background','white'}};
   o = Provide(o,'style',list);        % provide 'style' options
   
      % select options
      
   list = {{'scope',[]},{'from',1},{'to',inf},{'ignore',0}};
   o = Provide(o,'select',list);       % provide 'select' options
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function o = Provide(o,topic,list)     %  Provide Option Defaults      
   for (i=1:length(list))
      entry = list{i};
      tag = entry{1}; default = entry{2};
      value = opt(o,{[topic,'.',tag],default});
      o = opt(o,{tag},value);        % provide option value
   end
end
