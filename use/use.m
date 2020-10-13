function use(tag,version)
%
% USE   use a context
%
%           use            % use default context
%           use cut        % use CUT toolbox (Swarovski - schleifen)
%           use corazon    % use CORAZON toolbox
%           use corinth    % rational arithmetics
%           use cordoba    % use CORDOBA extension for CORAZON
%           use trf        % use TRF toolbox (transfer functions)
%           use spm        % use (Andy's) SPM toolbox (ANSYS)
%           use work       % use classes in work directory
%
%           use pll
%           use kalman
%           use surge
%           use trade
%           use antenna    % Willy's Antennen Toolbox
%
%        Releases
%
%           use cute-v1a   % Cute V1a release @ 24Aug20
%           use cute-v1b1  % Cute V1b1   beta @ 27Aug20
%           use cute-v1b2  % Cute V1b2   beta @ 28Aug20
%           use cute-v1b3  % Cute V1b3   beta @ 31Aug20
%           use cute-v1b   % Cute V1b release @ 07Aug20
%
%           use spm-v1c    % SPM V1c release @ 12Oct20
%
   if (nargin < 2)
      version.carabao = 'V1l';
      version.corazon = 'V1f';
      version.corinth = 'V1f';
      version.cordoba = 'V1c';
      version.rat = 'V1a';
      version.cut = 'V1b';
      version.cute = 'V1b';
      version.trf = 'V2a';
      
      version.spm = 'V1c';
      
      version.pll = 'V1a';
      version.kalman = 'V1a';
      version.surge = 'V1a';
      version.trade = 'V1a';
      version.antenna = 'V1a';
      
      version.uled = 'V1a';
   end
   
      % path for article database
      
   artpath = '/users/hux/Documents/Bluenetics/[Database]/@Article';
   cutpath = '/Users/hux/Documents/Bluenetics/[Database]/[70er-Kugel]';
   
      % provide default tag
      
   if (nargin == 0)
      %tag = 'corazon';
      fprintf('   type ''help use'' to see how to activate toolboxes!\n');
      return
   end
   
   switch (tag)
      case 'antenna'
         use corazon
         addpath([mhome,'/willy/antenna/',version.antenna]);
         fprintf(['   Antenna Toolbox ',version.antenna,'\n']);   

      case 'carabao'
         addpath([mhome,'/carabao/',version.carabao]);
         addpath([mhome,'/study']);
         fprintf(['   using CARABAO toolbox ',version.carabao,'\n']);   

      case 'corazon'
         addpath([mhome,'/corazon/',version.corazon]);
         fprintf(['   using CORAZON toolbox ',version.corazon,'\n']);   

      case 'corinth'
         use corazon
         addpath([mhome,'/corinth/',version.corinth]);
         fprintf(['   using CORINTH toolbox ',version.corinth,'\n']);   

      case 'cordoba'
         use corazon
         addpath([mhome,'/cordoba/',version.cordoba]);
         fprintf(['   using CORDOBA extension ',version.cordoba,'\n']);   
      case 'cut'
         use corazon
         use cordoba
         use trf
         addpath([mhome,'/swarovski/cut/',version.cut]);
         fprintf(['   using Cutting Toolbox ',version.cut,'\n']);
         articles(cut,artpath);
         disp(pwd)
         
      case 'cute'
         use corazon
         addpath([mhome,'/swarovski/cute/',version.cute]);
         fprintf(['   using Cute Toolbox ',version.cute,'\n']);
         articles(cute,artpath);
         directory(cute,cutpath);
         disp(pwd)
         
       case 'kalman'
         use corazon
         addpath([mhome,'/kalman/',version.kalman]);
         fprintf(['   using KALMAN toolbox ',version.kalman,'\n']);   
      case 'rat'
         addpath([mhome,'/rat/',version.rat]);
         fprintf(['   using RAT toolbox ',version.rat,'\n']);   
      case 'pll'
         use corazon
         addpath([mhome,'/pll/',version.pll]);
         fprintf(['   using PLL toolbox ',version.pll,'\n']);   
      case 'surge'
         use corazon
         addpath([mhome,'/study/surge/',version.surge]);
         fprintf(['   Surge Study ',version.surge,'\n']);   
      case 'trade'
         use corazon
         addpath([mhome,'/trade/',version.trade]);
         fprintf(['   Trade Toolbox ',version.trade,'\n']);   
      case 'trf'
         use cordoba
         addpath([mhome,'/trf/',version.trf]);
         fprintf(['   using TRF toolbox ',version.trf,'\n']);  
         
      case 'spm'
         use corazon
         addpath([mhome,'/swarovski/spm/',version.spm]);
         fprintf(['   using SPM toolbox ',version.spm,'\n']);            
         
      case 'uled'
         use corazon
         addpath([mhome,'/besi/uled/',version.uled]);
         fprintf(['   uLED Toolbox ',version.uled,'\n']);   
      case 'work'
         addpath([mhome,'/work']);
         fprintf(['   using classes in WORK directory\n']);  
         
         % releases

      case 'cute-v1a'
         CuteV1aRelease;
      case 'cute-v1b1'
         CuteV1b1Beta;
      case 'cute-v1b2'
         CuteV1b2Beta;
      case 'cute-v1b3'
         CuteV1b3Beta;
      case 'cute-v1b'
         CuteV1bRelease;

      case 'spm-v1c'
         SpmV1cRelease;
   end
end

function CuteV1aRelease                % CuteV1a Release @ 24Aug20     
   release = 'CuteV1a-Release-24Aug20';
   fprintf('Setting up for %s\n',release); 

   
   relpath = [mhome,'/swarovski/@Release/01 ',release,'/',release];
   artpath = [relpath,'/@Article']; 

   version.corazon = 'V1d';
   version.cute = 'V1a';

      % use corazon

   corazonpath = [relpath,'/corazon/',version.corazon];
   addpath(corazonpath);
   fprintf(['   using Corazon Toolbox ',version.corazon,'\n']);

      % use cute

   cutepath = [relpath,'/cute/',version.cute];
   addpath(cutepath);
   fprintf(['   using Cute Toolbox ',version.cute,'\n']);
   
      % show current directory path
      
   articles(cute,artpath);
   disp(['   ',pwd]);
end
function CuteV1b1Beta                  % CuteV1b1 Beta   @ 27Aug20     
   release = 'CuteV1b1-Beta-27Aug20';
   fprintf('Setting up for %s\n',release); 

   
   relpath = [mhome,'/swarovski/@Release/02 ',release,'/',release];
   artpath = [relpath,'/@Article']; 

   version.corazon = 'V1e1';
   version.cute = 'V1b1';

      % use corazon

   corazonpath = [relpath,'/corazon/',version.corazon];
   addpath(corazonpath);
   fprintf(['   using Corazon Toolbox ',version.corazon,'\n']);

      % use cute

   cutepath = [relpath,'/cute/',version.cute];
   addpath(cutepath);
   fprintf(['   using Cute Toolbox ',version.cute,'\n']);
   
      % show current directory path
      
   articles(cute,artpath);
   disp(['   ',pwd]);
end
function CuteV1b2Beta                  % CuteV1b2 Beta   @ 28Aug20     
   release = 'CuteV1b2-Beta-28Aug20';
   dirnum = '03';
   version.corazon = 'V1e2';
   version.cute = 'V1b2';
   
   
   fprintf('Setting up for %s\n',release); 

   
   relpath = [mhome,'/swarovski/@Release/',dirnum,' ',release,'/',release];
   artpath = [relpath,'/@Article']; 


      % use corazon

   corazonpath = [relpath,'/corazon/',version.corazon];
   addpath(corazonpath);
   fprintf(['   using Corazon Toolbox ',version.corazon,'\n']);

      % use cute

   cutepath = [relpath,'/cute/',version.cute];
   addpath(cutepath);
   fprintf(['   using Cute Toolbox ',version.cute,'\n']);
   
      % show current directory path
      
   articles(cute,artpath);
   disp(['   ',pwd]);
end
function CuteV1b3Beta                  % CuteV1b3 Beta   @ 31Aug20     
   release = 'CuteV1b3-Beta-31Aug20';
   dirnum = '04';
   version.corazon = 'V1e3';
   version.cute = 'V1b3';
   
   
   fprintf('Setting up for %s\n',release); 

   
   relpath = [mhome,'/swarovski/@Release/',dirnum,' ',release,'/',release];
   artpath = [relpath,'/@Article']; 


      % use corazon

   corazonpath = [relpath,'/corazon/',version.corazon];
   addpath(corazonpath);
   fprintf(['   using Corazon Toolbox ',version.corazon,'\n']);

      % use cute

   cutepath = [relpath,'/cute/',version.cute];
   addpath(cutepath);
   fprintf(['   using Cute Toolbox ',version.cute,'\n']);
   
      % show current directory path
      
   artpath = '/users/hux/Documents/Bluenetics/[Database]/@Article';
   articles(cute,artpath);
   disp(['   ',pwd]);
end
function CuteV1bRelease                % CuteV1b Release @ 07Sep20     
   release = 'CuteV1b-Release-07Sep20';
   dirnum = '05';
   version.corazon = 'V1e';
   version.cute = 'V1b';
   
   
   fprintf('Setting up for %s\n',release); 

   
   relpath = [mhome,'/swarovski/@Release/',dirnum,' ',release,'/',release];
   artpath = [relpath,'/@Article']; 


      % use corazon

   corazonpath = [relpath,'/corazon/',version.corazon];
   addpath(corazonpath);
   fprintf(['   using Corazon Toolbox ',version.corazon,'\n']);

      % use cute

   cutepath = [relpath,'/cute/',version.cute];
   addpath(cutepath);
   fprintf(['   using Cute Toolbox ',version.cute,'\n']);
   
      % show current directory path
      
   artpath = '/users/hux/Documents/Bluenetics/[Database]/@Article';
   articles(cute,artpath);
   disp(['   ',pwd]);
end

function SpmV1cRelease                 % SpmV1c  Release @ 12Oct20     
   release = 'SpmV1c-Release-12Oct20';
   dirnum = '06';
   version.corazon = 'V1f';
   version.spm = 'V1c';
   
   fprintf('Setting up for %s\n',release); 
   relpath = [mhome,'/swarovski/@Release/',dirnum,' ',release,'/',release];

      % use corazon

   corazonpath = [relpath,'/corazon/',version.corazon];
   addpath(corazonpath);
   fprintf(['   using Corazon Toolbox ',version.corazon,'\n']);

      % use spm

   spmpath = [relpath,'/spm/',version.spm];
   addpath(spmpath);
   fprintf(['   using SPM Toolbox ',version.spm,'\n']);
   
      % show current directory path
      
   disp(['   ',pwd]);
end


