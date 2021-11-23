%
% CUO   Get Current Shell Object
%
%    Pull or refresh current object from current figure.
%
%       o = corazito.cuo;         % pull current object from current figure
%       o = corazito.cuo(o);      % refresh current object from current fig
%
%    Use a short hand for better readability.
%
%       cuo = @corazito.cuo            % provide short hand (8 �s)
%       cuo = util(corazito,'cuo')     % provide short hand (190 �s)
%
%       o = cuo();                % pull current object from current figure
%       o = cuo(o);               % refresh current object from current fig
%
%    Copyright(c): Bluenetics 2020 
%
%    See also CORAZITO, UTIL, SHO
%
