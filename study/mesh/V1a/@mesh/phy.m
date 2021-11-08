function [oo,A,B,D,R0] = phy(o)
%
% PHY     PHY-layer based parameters and definitions
%
%            [L,A,B,D,R0] = phy(o)     % get phy parameters
%            phy(o)                    % display PHY parameters                  
%
%         Parameter description
%            L:   length of packet (for 31 bytes: 31*8 = 248 us)
%            A:   advertising packet period (0.5 ms)
%            B:   advertising burst length (B = 3*A)
%            D:   waiting delay between advertising bursts
%            R0:  maximum transition rate per node (46.51 #/s)
%
%         Explanation:
%
%            1) Each ADV packet is transfered as a burst over 3 advertising
%               channels.
%            2) A listener (for advertising packets) can only listen to 1
%               channel at one time for an advertising packet
%            3) If the packets in one channel are colliding with the packet
%               of another sender, then also the other packets in the other
%               channels are colliding
%            4) This means, that the triple of channels can be treated as a
%               single channel
%            5) It also implies that the transmission rate cannot me
%            greater than 1/(21.5ms/#) = 46.5
%
%     A = 0.5                                    A = 0.5
%    |<----->|                                  |<----->|
%      L                                          L 
%    |<->|                                      |<->|
%     .25 .25                                    .25 .25
%    |###|---+---+---+---+---+ ............... -|###|---+---+---+---+---|--
%    |       |.25 .25|       |                  |       |.25 .25|       |
%    +---+---|###|---+---+---+ ............... -+---+---|###|---+---+---|--
%    |               |.25 .25|                  |               |.25 .25|
%    +---+---+---+---|###|---+ ............... -+---+---+---+---|###|---|--
%    |         B = 1.5       |      D = 20      |         B = 1.5       |
%    |<--------------------->|<------.....----->|<--------------------->|
%
%
%         Copyright(c): Bluenetics 2021
%
%         See also: MESH, COLLSIM, OPTIMAL, YIELD
%
   L = 0.250e-3;                       % packet length (0.25ms)
   A = 0.5e-3;                         % advertising packet period (0.5ms)
   B = 3*A;                            % advertising burst length (1.5ms)
   D = 20e-3;                          % delay between ADV bursts
   
      % maximum transmission rate per node
      
   R0 = 1/(B + D);
   
   if (nargout > 0)
      oo = L;
   else
      fprintf('PHY parameters\n');
      fprintf('   packet length              L: %g ms\n',L*1e3);
      fprintf('   advertising packet period  A: %g ms\n',A*1e3);
      fprintf('   advertising burst length   B: %g ms\n',B*1e3);
      fprintf('   delay between ADV bursts   D: %g ms\n',D*1e3);
      fprintf('   max x-mit rate per node    R0:%g #/s\n',R0);
   end
end
