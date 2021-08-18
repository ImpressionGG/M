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
