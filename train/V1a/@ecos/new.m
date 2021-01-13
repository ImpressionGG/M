function oo = new(o,varargin)          % ECOS New Method              
%
% NEW   New ECOS object
%
%           oo = new(o,'Menu')         % menu setup
%
%           o = new(ecos,'Kaisewrthal');

%           o = new(ecos,'Auto')       % Auto object
%           o = new(ecos,'Block')      % Block object
%           o = new(ecos,'Control')    % Control object
%           o = new(ecos,'Detect')     % Detect object
%           o = new(ecos,'Fahrweg')    % Fahrweg object
%           o = new(ecos,'Page')       % Page object
%           o = new(ecos,'Signal')     % Signal object
%           o = new(ecos,'Taste')      % Taste object
%           o = new(ecos,'Weiche')     % Weiche object
%
%       See also: ECOS
%
   [gamma,oo] = manage(o,varargin,@Kaiserthal,@Menu,...
                       @Signal,@Block,@Taste,@Auto,@Fahrweg,@Weiche);
   oo = gamma(oo);
end

%==========================================================================
% Menu Setup
%==========================================================================

function oo = Menu(o)                  % Setup Menu
   oo = mitem(o,'Auto',{@Callback,'Auto'},[]);
   oo = mitem(o,'Block',{@Callback,'Block'},[]);
   oo = mitem(o,'Control',{@Callback,'Control'},[]);
   oo = mitem(o,'Detect',{@Callback,'Detect'},[]);
   oo = mitem(o,'Fahrweg',{@Callback,'Fahrweg'},[]);
   oo = mitem(o,'Page',{@Callback,'Page'},[]);
   oo = mitem(o,'Signal',{@Callback,'Signal'},[]);
   oo = mitem(o,'Taste',{@Callback,'Taste'},[]);
   oo = mitem(o,'Weiche',{@Callback,'Weiche'},[]);
end
function oo = Callback(o)
   mode = arg(o,1);
   oo = new(o,mode);
   paste(o,oo);                        % paste object into shell
end

%==========================================================================
% New Objects
%==========================================================================

function oo = Auto(o,page,index,name)  % New Auto                      
   if (nargin < 4)
      name = '';
   end
   
   oo = ecos('auto');
   oo.data = [];
   
   oo.par.page = page;
   oo.par.index = index;
   oo.par.title = name;
   
   num = name;
   idx = find(num<'0' & num>'9');
   num(idx) = [];
   
   oo.par.text1 = ['Auto ',num];
   oo.par.text2 = '';
   
   if isempty(oo.par.index)
      message(o,sprintf('Page %g is full!',page));
      oo = [];
   end
   
   if (nargout==0)
      paste(oo);
   end
end
function oo = Block(o,page,index,name) % New Block                     
   if (nargin < 4)
      name = '';
   end
   
   oo = ecos('block');
   oo.data = [];
   
   oo.par.page = page;
   oo.par.index = index;
   oo.par.title = name;
   
   num = name;
   idx = find(num<'0' & num>'9');
   num(idx) = [];
   
   oo.par.text1 = ['Block ',num];
   oo.par.text2 = '';
   
   if isempty(oo.par.index)
      message(o,sprintf('Page %g is full!',page));
      oo = [];
   end
   
   if (nargout==0)
      paste(oo);
   end
end
function oo = Taste(o,page,index,name) % New Taste                     
   if (nargin < 4)
      name = '';
   end
   
   oo = ecos('taste');
   oo.data = [];
   
   oo.par.page = page;
   oo.par.index = index;
   oo.par.title = name;
   
   num = name;
   idx = find(num<'0' & num>'9');
   num(idx) = [];
   
   oo.par.text1 = ['Taste ',num];
   oo.par.text2 = '';
   
   if isempty(oo.par.index)
      message(o,sprintf('Page %g is full!',page));
      oo = [];
   end
   
   if (nargout==0)
      paste(oo);
   end
end
function oo = Signal(o,page,index,name,kind,addr,sector)   % New Signal
   if (nargin < 4)
      name = '';  kind = 'Hp0';  addr = 331;
   end
   
   oo = ecos('signal');
   oo.data = [];
   
   oo.par.page = page;
   oo.par.index = index;
   oo.par.title = name;
   oo.par.addr = addr;
   oo.par.kind = kind;
   
   num = name;
   idx = find(num<'0' & num>'9');
   num(idx) = [];
   
   oo.par.text1 = ['Signal ',num];
   
   if (nargin < 7)
      oo.par.text2 = sprintf('#%g',addr);
   else
      oo.par.text2 = sprintf('#%g [%s]',addr,sector);
   end
   
   if isempty(oo.par.index)
      message(o,sprintf('Page %g is full!',page));
      oo = [];
   end
   
   if (nargout==0)
      paste(oo);
   end
end

%==========================================================================
% Helper
%==========================================================================

%==========================================================================
% Anlage Kaiserthal
%==========================================================================

function o = Kaiserthal(o)
   o = pull(o);
   o.data = {};                        % clear all objects
   push(o);
   
      % page 56
   
   page = 56;
   Auto(o,page,1,'A16');
   Signal(o,page,2,'S16','Hp0',331,'F3');
   Block(o,page,3,'B16');
   Taste(o,page,4,'T16');
   
   control(o,'callback',{'plot' 'Page' 56});
end
