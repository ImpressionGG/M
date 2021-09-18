%
% MESSAGE   Show a message on screen
%
%              message(o);        % message of object's title & comment
%
%              message(o,'This is my message!');
%              message(o,'Error','No traces!','Consider to import!');
%              message(o,'Error',{'No traces!','Consider to import!'});
%
%           Display message of a catched exception
%
%              try
%               :
%              catch err
%                 message(o,err,'Error during Save ...',text2,...)
%              end
%
%           Options: opt(o,'halign') and opt(o,'valign') control the
%           horizontal (default 'center') and vertical (default: 'middle')
%           alignment.
%
%           Remark: the short form message(o,err) will display a list of
%           error stack messages on the shell's screen.
%
%           Messaging into a subplot:
%           => set o = opt(o,'subplot',1) for messaging into a subpolot
%
%           Options:
%              fontsize.title        font size of title (default: 14)
%              fontsize.comment      font size of comment (default:  8)
%              subplot               subplot identifier (default [1 1 1])
%              pitch                 vertical pitch width (default: 1)
%
%           Copyright(c): Bluenetics 2020 
%
%           See also: CORAZON, TEXT
%
