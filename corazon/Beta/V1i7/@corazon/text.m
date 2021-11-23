%
% TEXT   Plot text into current graphic window using normalized coordinates
%        in the range x:[0,1], y:[0,1]. Every text will automatically be
%        processed by method UNDERSCORE
%
%           text(gao,'my_text',50,50);         % place into center
%           text(gao,'my_text');               % place into center
%            
%        Text method is sensitive to the following options:
%
%        1) Text Positioning
%
%           text(gao,txt,'position',[50 50]);
%           text(gao,txt,'position',[10 NaN]); % position x=10; y unchanged
%           text(gao,txt,'position',[NaN 70]); % position y=70; x unchanged
%           text(gao,txt,'position','center'); % top: position = [50,50]  
%           text(gao,txt,'position','top');    % top: position = [50,100]  
%           text(gao,txt,'position','bottom'); % bottom: position = [50,0]
%           text(gao,txt,'position','left');   % left:  position = [0,50]
%           text(gao,txt,'position','right');  % right: position = [100,50]
%           text(gao,txt,'position','home');   % top left
%
%        2) Horizontal & Vertical Alignment of Text
%
%           text(gao,txt,'halign','left');     % left horizontal alignment
%           text(gao,txt,'halign','center');   % center hor. alignment
%           text(gao,txt,'halign','right');    % right horizontal alignment
%
%           text(gao,txt,'valign','top');      % top vertical alignment
%           text(gao,txt,'valign','cap');      % cap vertical alignment
%           text(gao,txt,'valign','middle');   % middle vertical alignment
%           text(gao,txt,'valign','baseline'); % baseline vert. alignment
%           text(gao,txt,'valign','bottom');   % bottom vertical alignment
%
%        3) Text Size & Text Color
%
%           text(gao,txt,'size',8);            % set text size
%           text(gao,txt,'color','r');         % set text color
%
%        4) Continuous text display
%
%           smo = opt(corazon,'position','home','append',1);
%           text(smo,'1st line\n2nd line\n3rd line);
%
%        5) Test display of a figure full of texts
%
%           text(gao);                         % run all demos
%           text(opt(o,'mode','basic','size',4));
%           text(opt(o,'mode','info'));
%
%        Options:
%           position:   reference position
%           color:      text color
%           halign:     horizontal alignment
%           valign:     vertical alignment
%           size:       text size (in window height units)
%           spacing:    spacing factor   
%
%        Output Argument: contains graphics handle in var(out,'hdl')
%
%        Copyright (c): Bluenetics 2020 
%
%        See also: CORAZON
%
