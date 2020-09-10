function bestof(obj,varargin)
%
% BESTOF  Best of Quantana Collection
%
%
   [cmd,obj,list,func] = dispatch(obj,varargin,{{'@','invoke'}},'Setup');
   eval(cmd);
   return
end

%==========================================================================
% Setup the Roll Down Menu
%==========================================================================

function Setup(obj)
%
% SETUP       Setup the roll down menu for Alastair
%
   [LB,CB,UD,EN,CHK,CHKR,VI,CHC,CHCR,MF] = shortcuts(obj);

   men = mount(obj,'<main>',LB,'Best of');
   sub = uimenu(men,LB,'Bohmian Motion');
   itm = uimenu(sub,LB,'1 Particle in a Box',CB,call('@BohmianMotion'),UD,'1 Particle');
   itm = uimenu(sub,LB,'3 Particles in a Box',CB,call('@BohmianMotion'),UD,'3 Particles');
   itm = uimenu(sub,LB,'10 Particles in a Box',CB,call('@BohmianMotion'),UD,'10 Particles');
   itm = uimenu(sub,LB,'________________________',EN,'off');
   itm = uimenu(sub,LB,'1 With Velocity',CB,call('@BohmianMotion'),UD,'1 With Velocity');
   itm = uimenu(sub,LB,'3 With Velocity',CB,call('@BohmianMotion'),UD,'3 With Velocity');
   itm = uimenu(sub,LB,'10 With Velocity',CB,call('@BohmianMotion'),UD,'10 With Velocity');
   itm = uimenu(sub,LB,'________________________',EN,'off');
   itm = uimenu(sub,LB,'Record Without Particles',CB,call('@BohmianMotion'),UD,'Record Without');
   itm = uimenu(sub,LB,'Record With 10 Particles',CB,call('@BohmianMotion'),UD,'Record With 10');
   itm = uimenu(sub,LB,'________________________',EN,'off');
   itm = uimenu(sub,LB,'3 Peripheral Particles in a Box',CB,call('@BohmianMotion'),UD,'Peripheral in a Box');
   
   return
end

%==========================================================================
% Bohmian Movement
%==========================================================================

function BohmianMotion(obj)
%
   bohm = option(obj,'bohm');
   bohm.order = 3;            % order of wave function for Bohmian motion
   bohm.number = 1;           % number of particles for Bohmian motion
   bohm.white = 0;            % show white spot of Bohmian motion
   bohm.gradient = 0;         % show gradient of Bohmian motion
   bohm.velocity = 0;         % show velocity of Bohmian motion
   bohm.ny = 0;               % show ny-function of Bohmian motion
   bohm.trans = 0.2;          % transparency
   bohm.record = 0;           % position recording
   bohm.reference = 0;        % reference recording
   bohm.balley = 1;           % probability balley
   bohm.dt = 0.05;            % time interval
   bohm.periphery = 0;        % display particle at periphery
   
   mode = args(obj,1);
   switch mode
      case '1 Particle'
         % all setup!
      case '3 Particles'
         bohm.number = 3;      % number of particles for Bohmian motion
         bohm.trans = 0.5;     % transparency
      case '10 Particles'
         bohm.number = 10;     % number of particles for Bohmian motion
         bohm.trans = 0.5;     % transparency
      case '1 With Velocity'
         bohm.velocity = 1;    % show velocity of Bohmian motion
      case '3 With Velocity'
         bohm.number = 3;      % number of particles for Bohmian motion
         bohm.trans = 0.5;     % transparency
         bohm.velocity = 1;    % show velocity of Bohmian motion
      case '10 With Velocity'
         bohm.number = 10;     % number of particles for Bohmian motion
         bohm.trans = 0.5;     % transparency
         bohm.velocity = 1;    % show velocity of Bohmian motion
      case 'Record Without'
         bohm.order = 5;       % order of wave function for Bohmian motion
         bohm.number = 10;     % number of particles for Bohmian motion
         bohm.trans = 1.0;     % transparency
         bohm.record = 1;      % position recording
      case 'Record With 10'
         bohm.order = 5;       % order of wave function for Bohmian motion
         bohm.number = 10;     % number of particles for Bohmian motion
         bohm.trans = 0.5;     % transparency
         bohm.record = 1;      % position recording
      case 'Peripheral in a Box'
         bohm.number = 3;      % number of particles for Bohmian motion
         bohm.trans = 0.1;     % transparency
         bohm.periphery = 1;   % display particle at periphery
   end
   
   obj = option(obj,'bohm',bohm);
   quondemo(obj,'BohmianMotion');
   return
end
   
   