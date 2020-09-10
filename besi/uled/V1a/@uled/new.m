function oo = new(o,varargin)          % ULED New Method              
%
% NEW   New ULED object
%
%           oo = new(o,'Menu')         % menu setup
%
%           o = new(uled,'Mfc1BH')     % MFC Concept @ 1BH
%
%       See also: ULED, PLOT, ANALYSIS, STUDY
%
   [gamma,oo] = manage(o,varargin,@Mfc1BH,@Menu);
   oo = gamma(oo);
end

%==========================================================================
% Menu Setup
%==========================================================================

function oo = Menu(o)                  % Setup Menu
   oo = mitem(o,'MFC 1 Bondhead',{@Callback,'Mfc1BH'},[]);
end
function oo = Callback(o)
   mode = arg(o,1);
   oo = new(o,mode);
   paste(o,oo);                        % paste object into shell
end

%==========================================================================
% MFC Concept @ 1 Bond Head
%==========================================================================

function oo = Mfc1BH(o)                % MFC concept @ 1 Bond Head
   oo = uled('mfc1bh');                % mfc1bh type
   
   [costs,labels,tags] = cost(uled);
   
   oo.par.title = 'MFC Concept @ 1 Bond Head';
   oo.par.cost = {'Wafer Handling','Panel Handling','Inspection',...
                  'MPA Tool','Rest of Bond Head','Post Inspection',...
                  'Bad Material Handling','Divers 1','Divers 2'};
  
   if ~isequal(oo.par.cost,labels)
      error('cost label mismatch');
   end
   
   oo.data.cost = ones(1,9);           % relative cost vector
   oo.data.pph = 900;                  
end

