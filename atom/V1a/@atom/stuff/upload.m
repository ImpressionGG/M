function oo = upload(o,varargin)
%
% UPLOAD   Upload options to shell settings, either unconditionally or
%          conditionally.
%
%          1) Upload of options which are not type specific
%
%             upload(o,tag)            % uncond upload of all tag options 
%             upload(o,{tag})          % cond upload of all tag options 
%
%          2) Composite tags: the following pairs of  statements have the
%             same effect:
%
%             upload(o,tag1,tag2,...,tag3)
%             upload(o,[tag1,'.',tag2,'.',...,'.',tagn])
%
%             upload(o,tag1,'*',tag2)
%
%             opts = o.either(opt(o,tag1),struct{''});
%             tags = fields(opts);
%             for (i=1:length(tags))
%                upload(o,[tag1,'.',tags{i},tag2)
%             end
%
%          Example 1: to upload cnfig options opts = opt(o,'config') the
%          uncondtional upload is done using:
%
%             upload(o,'config')       % uncond upload of 'config' options
%
%          This is equivalent with the following sequence of unconditional
%          upload of 'config' options:
%
%             opts = o.either(opt(o,'config'),struct('')); % sub-option bag
%             tags = fields(opts);
%             for (i=1:length(tags))
%                tagi = ['config.',tags{i}];
%                setting(o,tagi,opt(o,tagi));   % unconditional upload !!!
%             end
%
%          Example 2: to upload cnfig options opts = opt(o,'config') the
%          condtional upload is done using:
%
%             upload(o,{'config'})     % uncond upload of 'config' options
%
%          This is equivalent with the following sequence of conditional
%          upload of 'config' options:
%
%             opts = opt(o,'config')   % get bag of config options
%             tags = o.either(fields(opts),struct(''))
%             for (i=1:length(tags))
%                tagi = ['config.',tags{i}];
%                setting(o,tagi,opt(o,tagi));   % unconditional upload !!!
%             end
%
%          Example 3: uploading of all category options
%
%             upload(o,'config','*','category');      % unconditional
%             upload(o,{'config','*','category'});    % conditional
%
%          Example 4: uploading object type specific category options
%
%             upload(o,'config',o.type,'category');   % unconditional
%             upload(o,{'config',o.type,'category'}); % conditional
%
%          See also: CARAMEL, CONFIG, CATEGORY, SUBPLOT, SIGNAL
%
   ilist = varargin;                   % copy input args
   if length(ilist) == 0
      error('at least one tag (arg2) expected!');
   end
   
   if length(ilist) == 1 && iscell(ilist{1})
      ilist = ilist{1};
      CheckArgs(ilist);
      Upload(o,ilist,true);            % conditional upload
   else
      CheckArgs(ilist);
      Upload(o,ilist,false);           % unconditional upload
   end
end

%==========================================================================
% Upload Work Horse
%==========================================================================

function Upload(o,ilist,conditional)
%
   is = @isequal;                      % short hand
   
   if length(ilist) == 0
      error('*** bug!');
   elseif (length(ilist) == 1)
      tag = ilist{1};
      opts = o.either(opt(o,tag),struct(''));   % get bag of sub-options
      tags = fields(opts);
      for (i=1:length(tags))
         tagi = [tag,'.',tags{i}];
         bag = opt(o,tagi);
         if (conditional)
            setting(o,{tagi},bag);     % conditional upload !!!
         else
            setting(o,tagi,bag);       % unconditional upload !!!
         end
      end
   elseif length(ilist) >= 2 && is(ilist{2},'*')   % wild card
      tag = ilist{1};
      opts = o.either(opt(o,tag),struct(''));   % get bag of sub-options
      tags = fields(opts);
      for (i=1:length(tags))
         tagi = [tag,'.',tags{i}];
         list = [{tagi},ilist(3:end)];
         Upload(o,list,conditional);
      end
   elseif length(ilist) >= 2
      tag = [ilist{1},'.',ilist{2}];
      list = [{tag},ilist(3:end)];
      Upload(o,list,conditional);
   else
      error('*** bug!');
   end
end

%==========================================================================
% Auxillary functions
%==========================================================================

function CheckArgs(list)
   for (i=1:length(list))
      if ~ischar(list{i})
         error('all input args must be strings!');
      end
   end
end
