function halt = progress(o,msg,percent,period)
%
% PROGRESS  Display progress in figure menu bar. 
%
%           Timed (conditional) progess messages
%
%              progress(o,n,msg)       % setup progress framework
%              progress(o,i)           % conditional progress message
%              progress(o)             % progress complete
%
%           First step is to setup a progress framework with progress text,
%           number of iterations and a refresh period (deault: 2s) after 
%           which progress message is updated. Second step is a periodic 
%           call progress(o,i) (providing the progress index i). This call
%           is ignored if progress period is not due, otherwise an update 
%           of the progress message is performed. At the end of all iter-
%           ations progress(o) cleans upo the progress framework and normal
%           title is displayed
%
%              progress(o,n,msg,period)% setup progress framework
%              progress(o,msg,percent) % display message with percentage
%              progress(o,msg)         % display message without percentage
%
%           Example 1 (recommended style):
%
%              n = 10000;
%              progress(o,n,'magic calculation')   % default: 2 sec period
%              for (i=1:n)
%                 progress(o,i);
%                 M{i} = magic(i); 
%              end
%              progress(o);            % done
%
%           Example 2:
%
%              n = 10000; 
%              for  (i=1:n)
%                 if (rem(i,100)==0)
%                    msg = sprintf(%g of %g: magic calclculation',i,n);
%                    progress(o,msg,i/n*100);
%                 end
%                 M{i} = magic(i); 
%              end
%              progress(o);            % done
%
%           Options:
%
%              progress:               % enable/disable display (default 1)
%
%           Copyright(c): Bluenetics 2020
%
%           See also: CORAZON, TITLE, STOP
%
   fig = figure(o);
   if isempty(fig)
      fig = gcf;
   end
   
   if (nargin == 1)
      Pop(o);
      title(o);                        % always - independent of 
      return                           % progress option setting
   elseif (nargin == 3 && isa(msg,'double')) || (nargin == 4)
      n = msg;  msg = percent;         % rename input args
      if (nargin < 4)
         period = 2;                   % default period
      end
      Push(o,msg,n,period);            % push progress framework
      Progress(o,0);
      return
   end
   
      % check 'progress' option and ignore if progress display is disabled
      
   if ~opt(o,{'progress',true})
      return
   end
   
      % progress display is enabled - display progress
      
   if (nargin == 2 && ischar(msg))
      set(fig,'Name',msg);
   elseif (nargin == 2 && isa(msg,'double'))
      i = msg;                         % arg 2 is progress index
      Progress(o,i);
   elseif (nargin == 3)
      set(fig,'Name',sprintf('%s (%g%%)',msg,o.rd(percent,0)));
   else
      error('1,2,3 or 4 input args expected');
   end
   
   idle(o);                            % give time to display
end

%==========================================================================
% Display Progress Message
%==========================================================================

function Progress(o,i)
   fig = o.either(figure(o),gcf);
   frame = shelf(o,fig,'progress.frame');
 
   if isempty(frame)
      Push(o,'',0,1);
      frame = shelf(o,fig,'progress.frame');
   end

   elapse = toc(frame.tic);
   if (elapse <= frame.period)
      return                           % too early to refresh progress msg
   end
   
      %  otherwise refresh progress message
      
   if (frame.n == 0)
      msg = sprintf('Iteration %g',i);
   else
      msg = frame.msg;  n = frame.n;  percent = i/n*100;
      msg = sprintf('%g of %g: %s (%g%%)',i,n,msg,o.rd(percent,0));
   end
   
   set(fig,'Name',msg);
   
      % refresh tic
      
   frame.tic = tic;
   shelf(o,fig,'progress.frame',frame);
end

%==========================================================================
% Push/Pop Progress Framework to/from Figure Shelf
%==========================================================================

function Push(o,msg,n,period)
   fig = o.either(figure(o),gcf);
   frame = shelf(o,fig,'progress.frame');
   stack = o.either(shelf(o,fig,'progress.stack'),{});
   
      % push current frame onto stack
      
   if o.is(frame)
      stack = [{frame},stack];         % extend stack by current frame
   end
   shelf(o,fig,'progress.stack',stack);
   
      % push new frame
      
   frame.msg = msg;
   frame.n = n;
   frame.period = period;
   frame.tic = tic-1e30;               % set an overdue condition
   
   shelf(o,fig,'progress.frame',frame);
end
function Pop(o)                        % pop frame from progress stack
   fig = o.either(figure(o),gcf);
   stack = o.either(shelf(o,fig,'progress.stack'),{});

   if o.is(stack)
      frame = stack{1};                % get stack head
      frame.tic = tic;                 % refresh tic
      stack(1) = [];                   % delete stack head
   else
      frame = [];
   end
   
   shelf(o,fig,'progress.stack',stack);
   shelf(o,fig,'progress.frame',frame);
end


