function use(tag)
%
% USE   use a context
%
%           use            % use default context
%           use cut        % use cut toolbox (Swarovski - schleifen)
%
%           use abravibe   % use ATOM toolbox
%           use atom       % use ATOM toolbox
%           use babasim    % use BABASIM tool
%           use carabao    % use CARABAO toolbox
%           use corazon    % USE CORAZON toolbox
%           use glass      % glass toolbox
%           use guerilla   % use GUERILLA
%           use sloc       % use context sloc
%           use hom        % use HOM toolbox
%           use quantana   % quantana toolbox
%           use robo       % use ROBO toolbox
%           use smart      % use SMART toolbox
%           use trf        % use TRF toolbox (transfer functions)
%
   version.atom = 'V1a';
   version.carabao = 'V1m';
   version.corazon = 'V1a';
   version.cut = 'V1a';
   version.trf = 'V1b';
   
   version.quantana = 'V4a';
   version.core = 'V4b';
   version.toy = 'V1c';
   
      % path for article database
      
   artpath = '/users/hux/Documents/Bluenetics/[Database]/@Article';
   
      % provide default tag
      
   if (nargin == 0)
      tag = 'corazon';
   end
   
   switch (tag)
      case 'abravibe'
         addpath([mhome,'/abravibe']);
         fprintf(['   using ABRAVIBE toolbox\n']);   
      case 'atom'
         addpath([mhome,'/atom/',version.atom]);
         fprintf(['   using ATOM toolbox ',version.atom,'\n']);   
      case 'babasim'
         addpath([mhome,'/carabao/',version.carabao,'/demo/babasim']);
         fprintf(['   using BABASIM tool','\n']);   
      case 'carabao'
         addpath([mhome,'/carabao/',version.carabao]);
         fprintf(['   using CARABAO toolbox ',version.carabao,'\n']);   
      case 'corazon'
         addpath([mhome,'/corazon/',version.corazon]);
         fprintf(['   using CORAZON toolbox ',version.corazon,'\n']);   
      case 'cut'
         use abravibe
         use carabao
         use trf
         addpath([mhome,'/cut/',version.cut]);
         fprintf(['   using Cutting Toolbox ',version.cut,'\n']);
         articles(cut,artpath);
         disp(pwd)
      case 'glass'
         use carabao
         addpath([mhome,'/work/swarovski/drehzahlregelung']);
         fprintf(['   using GLASS toolbox\n']);   
         cd([mhome,'/work/swarovski/drehzahlregelung']);
         disp(pwd);
      case 'guerilla'
         addpath([mhome,'/carabao/',version.carabao,'/guerilla']);
         fprintf(['   using GUERILLA\n']);   
      case 'sloc'
         cd
         cd([mhome,'/sloc']);
         disp(pwd);
      case 'hom'
         addpath([mhome,'/hom/V1A']);
         fprintf('use HOM toolbox V1A\n');
      case 'quantana'
         addpath([mhome,'/core/',version.core]);
         addpath([mhome,'/quantana/',version.quantana]);
         addpath([mhome,'/toy/',version.toy]);
         fprintf(['   using Quantana Toolbox ',version.quantana,'\n']);
         disp(pwd)
      case 'robo'
         use smart
         addpath([mhome,'/robo/V1M']);
         fprintf('use ROBO toolbox V1M\n');
      case 'smart'
         addpath([mhome,'/smart/V1m']);
         fprintf('use SMART toolbox V1M\n');
      case 'trf'
         addpath([mhome,'/trf/',version.trf]);
         fprintf(['   using TRF toolbox ',version.trf,'\n']);   
   end
end
