function oo = image(o,varargin)
%
% IMAGE  Create or draw image data object
%
%           oo = image(o,'Create',img) % create image object from image
%           oo = image(o,'Create',img,cmap)  % provide also color map
%
%           oo = image(o,'Load',fname) % create image object from file name
%           oo = image(o,'Read',path)  % create image object from file path
%
%           image(oo,'Plot')           % plot image
%
%        Examples:
%
%           img = imread('myimage.jpg');
%           oo = image(o,img);
%
%        Images are stored in cell embedded structures:
%
%           oo.data.kind               % data kind = 'image'
%           oo.data.image              % image data
%           oo.data.cmap               % color map
%
%        See also: CARAVEL
%
   [gamma,oo] = manage(o,varargin,@Error,@Load,@Create,@Plot);
   oo = gamma(oo);
end

%==========================================================================
% Error Handling
%==========================================================================

function o = Error(o)
   error('No local function provided!');
end

%==========================================================================
% Local functions
%==========================================================================

function oo = Read(o)                  % Read Image from Path          
   oo = [];
end
function oo = Load(o)                  % Load Image from Standard Path 
   oo = [];
   fname = arg(o,1);
   if isempty(fname)
      error('missing file name!');
   end
   
   if exist(fname) == 2
      path = fname;
   else

      path = '';  img = [];
      list = Path(o);                     % get list of pathes
      for (i=1:length(list))
         path = [list{i},'/',fname];
         if exist(path) == 2
            break;
         end
         path = '';                       % not found
      end
   end
   
      % no path has been setup with proper value
      
   if isempty(path)
      if exist(fname) == 2
         img = imread(fname);
      else
         error(['cannot load image file: ',fname]);
      end
   else
      img = imread(path);
   end
   oo = Create(o,img);
end
function oo = Create(o,img,cmap)
%
% CREATE   Create image object. Below is the code from SMART class
%
%       case '#IMAGE'
%          check(length(data)==2,'2 element cell array expected for arg1!'); 
%          img = data{1};  cmap = data{2};
%          check(isa(img,'uint8'),'1st element of arg1 must be uint8 for #IMAGE format!'); 
%          check(size(cmap,2)==3,'3 columns expected for colormaps (#IMAGE format)!'); 
%          obj.data.kind = 'image';
%          obj.data.image = img;
%          obj.data.cmap = cmap;
%
   if (nargin < 2)
      img = arg(o,1);
   end
   if (nargin < 3)
      cmap = arg(o,2);
   end
   if isempty(img)
      error('no image provided!');
   end
   
   if ~isa(img,'uint8')
      error('1st element of arg1 must be uint8 for #IMAGE format!');
   end
   if ~isempty(cmap) && size(cmap,2) ~= 3
      error('3 columns expected for colormaps (#IMAGE format)!');
   end
   
   oo = o;                             % copy object
   oo.data = [];                       % clear all data
   
   oo.data.kind = 'image';
   oo.data.image = img;
   oo.data.cmap = cmap;
   oo.data.position = [];
   
   oo = arg(oo,{});
end
function oo = Plot(o)                  % Plot Image
   oo = o;
   
   fig = figure(o);
   hax = gca(fig);
   
   ydir = get(hax,'ydir');
   hdl = image(o.data.image);
   if ~isempty(o.data.cmap)
       colormap(o.data.cmap);
   end
   set(hax,'ydir',ydir);

   position = o.either(eval('o.data.position','[0;0]'),[0;0]);
   xdata = eval('o.data.xdata','[]');
   ydata = eval('o.data.ydata','[]');

   xdata = o.iif(isempty(xdata),get(hdl,'xdata'),xdata);
   ydata = o.iif(isempty(ydata),get(hdl,'ydata'),ydata);

   set(hdl,'xdata',xdata+position(1),'ydata',ydata+position(2));
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function list = Path(o)                % Get List of MATLAB Pathes     
   txt = path;
   list = {};
   while ~isempty(txt)
      idx = find(txt == ';');
      if isempty(idx)
         return
      end
      idx = min(idx);                  % get first occurence ofd ';'
      list{end+1} = txt(1:idx-1);
      txt = txt(idx+1:end);
   end
end