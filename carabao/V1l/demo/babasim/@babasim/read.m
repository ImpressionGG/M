function oo = read(o,varargin)         % Read BABASIM Object From File
%
% READ   Read a BABASIM object from file.
%
%             oo = read(o,driver,path)
%
%          See also: BABASIM, IMPORT, EXPORT, WRITE
%
   [gamma,oo] = manage(o,varargin,@Error,@ReadBabasimDat);
   oo = gamma(oo);
   oo = launch(oo,launch(o));          % inherit launch function
end

function o = Error(o)                  % Default Error Method
   error('two input args expected!');
end

%==========================================================================
% Read Driver for Babasim Data
%==========================================================================

function oo = ReadBabasimDat(o)         % Read Driver for Babasim .dat   
   path = arg(o,1);
   oo = read(o,'ReadGenDat',path);
   oo = Config(oo);                    % overwrite configuration
end

%==========================================================================
% Configuration of Plotting
%==========================================================================

function o = Config(o)
   o = subplot(o,'layout',1);       % layout with 1 subplot column   
   o = subplot(o,'color',[1 1 1]);  % background color
   o = config(o,[]);                % set all sublots to zero

   switch o.type
      case 'pln'
         o = category(o,1,[-5 5],[0 0],'µ');
         o = category(o,2,[-50 50],[0 0],'m°');
         o = config(o,'x',{1,'r',1});
         o = config(o,'y',{1,'b',1});
         o = config(o,'p',{2,'g',2});
      case 'smp'
         o = category(o,1,[-5 5],[0 0],'µ');
         o = category(o,2,[-50 50],[0 0],'m°');
         o = category(o,3,[-0.5 0.5],[0 0],'µ');
         o = config(o,'x',{1,'r',1});
         o = config(o,'y',{1,'b',1});
         o = config(o,'p',{2,'g',2});
         o = config(o,'ux',{3,'m',3});
         o = config(o,'uy',{3,'c',3});
   end         
end
