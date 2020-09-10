function oo = cost(o,varargin)         % Cost Menu                    
%
% COST   Manage COST menu
%
%           cost(o,'Setup');           %  Setup COST menu
%
%        See also: HUCK, SHELL, BOK
%
   [gamma,oo] = manage(o,varargin,@Setup,@Schematics,@ShowBom);
   oo = gamma(oo);
end

%==========================================================================
% Setup Cost Menu
%==========================================================================

function o = Setup(o)                  % Setup Study Menu              
   oo = mhead(o,'Circuit');
   ooo = mitem(oo,'Schematics',{@Schematics});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Show Actual BoM',{@ShowBom});
   ooo = mitem(oo,'Print Actual BoM',{@PrintBom});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Print Component Table',{@PrintTable});
end

%==========================================================================
% Local Functions
%==========================================================================

function o = ShowBom(o)                % Show Actual BoM              
   refresh(o,o);
   list = opt(o,{'component',{}});
   if isempty(list)
      message(o,'No component info!');
      return
   end
   
   title = ['Component Costs: ',list{1}];
   comment = {};  total = 0;  area = 0;
   for (i=2:length(list))
      item = list{i};
      if isempty(item)
         comment{end+1} = '';
         continue;
      end
      entries = bom(o,{item});
      entry = entries{1}; 
      rating = entry{2};
      pricing = entry{3};
      sizes = entry{4};
      supplier = entry{5};
      total = total + pricing{1};
      area = area + sizes(1)/10 * sizes(2)/10;
      txt = sprintf(['%s: %g%s @ %g%s - %s%5.3f #%g',...
                     ' @ %02.0f%02.0fx%02.0f (%s %s)'],...
               item{1},rating{1},rating{2},rating{3},rating{4},...
               pricing{2},pricing{1},pricing{3},...
               sizes(1),sizes(2),sizes(3),...
               supplier{1},supplier{2});
      comment{end+1} = txt;  % '0.1µF @ 25V - €0.005 #5000 @ 1005x05';
   end
   comment{end+1} = '';
   comment{end+1} = sprintf('Total cost: €%6.3f, Total area: %g mm2',...
                             total,area);
   oo = set(o,'title',title,'comment',comment);
   message(oo);
end
function o = PrintBom(o)               % Print Actual BoM              
   list = opt(o,{'component',{}});
   if isempty(list)
      message(o,'No component info!');
      return
   end
   
   title = ['Component Costs: ',list{1}];
   bom(o,list);
   message(o,'BoM printed to console!');
end
function o = PrintTable(o)             % Print Component Table         
   bom(o);
   message(o,'Table of components printed to console!');
end
function Schematics(o,imagefile,title) % Show Schematics               
   refresh(o,o);
   prefix = '@huck/image';
   fname = opt(o,'study.schematics');
   if ~isempty(fname)
      show(caravel,[prefix,'/',fname]);
   else
      message(o,'No schematics provided!');
   end
end
