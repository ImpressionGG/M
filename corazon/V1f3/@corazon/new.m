function oo = new(o,varargin)
%
% NEW   Create new CORAZON object.
%
%          oo = new(o,'Menu')          % setup menu
%
%       New Corazon stuff
%
%          oo = new(o,'Weird')         % oo.type = 'weird'
%          oo = new(o,'Ball')          % oo.type = 'ball'
%          oo = new(o,'Cube')          % oo.type = 'cube'
%          oo = new(o,'Txy')           % oo.type = 'txy'
%
%       Copyright(c): Bluenetics 2020 
%
%       See also: CORAZON
%
   [gamma,oo] = manage(o,varargin,@Error,@Menu,@Weird,@Ball,@Cube,@Txy);
   oo = gamma(oo);
end

%==========================================================================
% Error
%==========================================================================

function o = Error(o)
   error('local function arg (arg2) missing!');
end

%==========================================================================
% Menu Setup
%==========================================================================

function oo = Menu(o)                  % Setup Menu
   oo = mitem(o,'Weird',{@Callback,'Weird'});
   oo = mitem(o,'Ball',{@Callback,'Ball'});
   oo = mitem(o,'Cube',{@Callback,'Cube'});
   oo = mitem(o,'Txy', {@Callback,'Txy'});
end
function oo = Callback(o)
   oo = new(o);                        % create new (stuff) object
   oo = launch(oo,launch(o));          % inherit launch function
   paste(o,{oo});                      % paste object into shell
end

%==========================================================================
% Local Functions
%==========================================================================

function oo = Weird(o)                 % Create Weird Object           
   oo = Create(o,'weird');             % create new weird object
end
function oo = Ball(o)                  % Create Ball Object            
   oo = Create(o,'ball');              % create new ball object
end
function oo = Cube(o)                  % Create Cube Object            
   oo = Create(o,'cube');              % create new cube object
end
function oo = Txy(o)                   % Create Txy Object             
   oo = Create(o,'txy');               % create new txy object
end

%==========================================================================
% Actual Object Creation
%==========================================================================

function oo = Create(o,typ)            % Create New Object
   oo = corazon(o);                    % cast to CORAZON object
   oo.type = typ;                      % set type
   switch typ
      case 'weird'
         oo = Weird(oo);
      case {'ball','cube'}
         oo = Body(oo,typ);
      case 'txy'
         oo = Txy(oo);
      otherwise
         error('bad type!');
   end
   return
   
   function oo = Weird(o)              % Create Weird Object           
      Seeding(o);                      % update random seed
      t = (0:999)'/999;                % time vector, 1000 points
      f = 1+round(19*rand(1,4));       % frequencies (1:20)
      w = cos(2*pi*f(1)*t);            % w vector
      x = sin(2*pi*f(2)*t);            % x vector
      y = cos(2*pi*f(3)*t);            % y-vector
      z = cos(2*pi*f(4)*t);            % z-vector
      
      name = 'weird';
      oo = construct(o,o.tag);         % construct new object
      oo.type = name;
      oo = launch(oo,'shell');         % provide launch function
      
      name(1) = upper(name(1));        % capitalize 1st letter
      tit = sprintf('%s Object (%g-%g-%g-%g)',name,f(1),f(2),f(3),f(4));
      color = corazito.rd(rand(1,3),1);% random color
      oo = set(oo,'title',tit);        % set title
      oo = data(oo,'t',t,'w',w);       % store data in object
      oo = data(oo,'x',x,'y',y,'z',z); % store data in object
      oo = set(oo,'color',color);      % set random color
      oo = set(oo,'canvas',[1,1,1]);   % set canvas color white
   end
   function oo = Txy(o)                % Create Txy object             
      Seeding(o);                      % update random seed
      om = 2*pi*0.5;                   % 2*pi * (0.5 Hz)

      t = 0:0.01:10;                   % time vector
      x = (2+rand)*sin(om*t) + (1+rand)*sin(3*om*t+randn);
      y = (1.5+rand)*cos(om*t) + (0.5+rand)*cos(2*om*t+randn);

         % pack into object

      oo = corazon('txy');             % txy type
      oo.par.title = sprintf('Some TXY data (%s)',datestr(now));
      oo.data.t = t;
      oo.data.x = randn + x + 0.1*randn(size(t));
      oo.data.y = randn + y + 0.12*randn(size(t));
   end
   function oo = Body(o,name)          % Create Body Object            
      Seeding(o);                      % update random seed
      oo = construct(o,o.tag);         % construct new object
      oo.type = name;
      oo = launch(oo,'shell');         % provide launch function

      color = corazito.rd(rand(1,3),1);% random color
      oo = set(oo,'color',color);      % set color
      oo = set(oo,'canvas',[1,1,1]);   % set canvas color white

      name(1) = upper(name(1));        % capitalize 1st letter
      oo.par.title = [name,' ',sprintf('[%3.1f %3.1f %3.1f]',color)];
      oo.data.radius = abs(0.75+0.05*randn);
      oo.data.offset = 1/3*randn(1,3); % body offset
   end
   function Seeding(o)                 % Update Random Seed            
      seed = control(o,{'seed',0});    % get current random seed
      control(o,'seed',seed+1);        % update random seed
      rng(seed);                       % reset random generator to seed
   end
end
