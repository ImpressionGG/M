function [f,Y] = fft(o,t,y)
%
% FFT    Fast Fourier transform, calculates both frequency vector f and
%        magnitude M from a time vector t and data vector y
%
%            [f,Y] = fft(o,t,y)
%            [f,~] = fft(o,t,[])
%            [~,Y] = fft(o,[],y)
%
%        Without output args plot FFT
%
%            fft(o,t,y)       % plot FFT
%
%        Algorithm:
%
%           first trucate t and y to even numbered vectors
%           L = length(t) = length(y)
%           T = [max(t)-min(t)] / (L-1)
%
%           P = abs(fft(y)/L);  
%           Y = P(1:L/2+1);
%           Y(2:end-1) = Y(2:end-1);
%
%           f = 1/T * [0:(L/2)] / L;
%
%        See also: CUT
%
    f = [];  Y = [];
    
    if (rem(length(t),2) ~= 0)
       t(end) = [];
    end
    
    if (rem(length(y),2) ~= 0)
       y(end) = [];
    end
    
    if ~isempty(t)
       L = length(t);
       T = [max(t)-min(t)] / (L-1);
    elseif ~isempty(y)
       L = length(y);
    else
       error('either arg2 or arg3 must be nonempty!');
    end

        % check
        
    if (~isempty(t) && L ~= length(t))
       error('length mismatch (arg2)');
    end    
    
    if (~isempty(y) && L ~= length(y))
       error('length mismatch (arg3)');
    end

        % calculate f
        
    if (~isempty(t))
       f = 1/T * [0:(L/2)] / L;
    end    
    if (~isempty(y))
       P = abs(fft(y)/L);  
       Y = P(1:L/2+1);
       Y(2:end-1) = 2 * Y(2:end-1);
    end
    
    if (nargout == 0)
       if (isempty(f) || isempty(Y))
          error('both t (arg2) and y (arg3) must be provided for plotting');
       end
       
       hdl = plot(f,Y);
       
       lw = opt(o,{'style.linewidth',1});
       set(hdl,'linewidth',lw);
       xlabel('f (Hz)');
       ylabel('|Y(f)|');
       
       clear f F
    end
end
