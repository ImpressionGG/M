function o = tvs(o,number)
%
% TVS  Setup parameters of a particular TVS Diode
%
%         o = tvs(o,1)       % 1.5SMC350CA
%         o = tvs(o,2)       % 1.5SMC400CA
%
%      See also: SURGE, SIMU, STUDY
%
    switch number
       case 1
          o = Tvs1(o);
       case 2
          o = Tvs2(o);
       case 3
          o = Tvs3(o);
    end
end

%==========================================================================
% TVS Setup
%==========================================================================
          
function o = Tvs1(o)
   p.name = '1.5SMC350CA';           % name of TVS diode
   
   p.Pmax   = 1500;                  % [W] max power
   p.Ubmin  = 332;                   % [V] breakdown minimum voltage
   p.Ubmax  = 368;                   % [V] breakdown maximum voltage
   p.Uclamp = 482;                   % [V] max clamping voltage
   p.Ipp    = 3.2;                   % [A] peak impulse current
   
   o = set(o,'tvs',p);
end
function o = Tvs2(o)
   p.name = '1.5SMC400CA';           % name of TVS diode
   
   p.Pmax   = 1500;                  % [W] max power
   p.Ubmin  = 380;                   % [V] breakdown minimum voltage
   p.Ubmax  = 420;                   % [V] breakdown maximum voltage
   p.Uclamp = 548;                   % [V] max clamping voltage
   p.Ipp    = 2.8;                   % [A] peak impulse current

   o = set(o,'tvs',p);
end