function prop = property(obj,propname,proplist)
% 
% PROPERTY Get a property of a SMART object
%      
%             obj = smart                    % create SMART object
%             p = property(obj,'kind')       % get proerty value 'kind'
%
%          Supported properties:
%
%             comment   list of comments
%             format    #GENERIC, #DATA
%             generic   1/0 whether generic CHAMEO obj or not
%             kind      GENERIC, DATA
%             title     object title
%
%          See also SMART

   fmt = format(obj);
   prop = [];             % by default

% Dispatch property ...   
   
   switch propname
       case 'comment'
          prop = get(obj,'comment');
       case 'format'
          prop = obj.format;
       case 'generic'
          prop = ~strcmp(obj.format,'#DATA');    % anything else but data!
       case 'title'
          prop = get(obj,'title');
   end

% property KIND

   if strcmp(propname,'kind')
      switch(fmt)
      case {'#GENERIC'}
            prop = 'GENERIC';
      case {'#DATA'}
            prop = 'DATA';
      case {'#BULK'}
            prop = 'BULK';
      end
      return
   end

% end
