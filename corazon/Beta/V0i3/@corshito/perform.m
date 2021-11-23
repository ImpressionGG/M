function perform(o)
%
% PERFORM   Performance tests
%
%              perform(corazito);
%
%           Copyright(c): Bluenetics 2020 
%
%           See also: CORSHITO
%
   [ticn,tocn] = util(corazito,'ticn','tocn');
%
% performance estimastion control
%
   control.construction = 1;
   control.cast = 1;
   control.figure = 1;
   control.shelf = 1;
   
   if (control.construction)
      fprintf('object construction:\n');
      for(i=1:ticn(1000)) o = corleon;  end; tocn('o = corleon');
      for(i=1:ticn(1000)) o = corazita;  end; tocn('o = corazita');
      for(i=1:ticn(5000)) o = corazito; end; tocn('o = corazito');
      for(i=1:ticn(500)) o = corazon;  end; tocn('o = corazon');
      for(i=1:ticn(500)) o = corshito;  end; tocn('o = corshito');
   end
   
   if (control.cast)
      fprintf('object casting:\n');
      o = corazon; 
      for(i=1:ticn(2000)) oo = cast(o,'corazita');  end; 
      tocn('o = corazon; oo = cast(o,''corazita'')');
      for(i=1:ticn(2000)) oo = cast(o,'corshito');  end; 
      tocn('oo = corazita; oo = cast(o,''corshito'')');
   end
   
   if (control.figure)
      fprintf('figure management:\n');
      o = corazon;   fig = gcf;
      
      for(i=1:ticn(20000)) fig = gcf; end;
      tocn('fig = gcf');

      for(i=1:ticn(5000)) ud = get(fig,'userdata'); end;
      tocn('ud = get(fig,''userdata'')');

      for(i=1:ticn(20000)) fig = gcf(o); end;
      tocn('fig = gcf(o)');
      
      for(i=1:ticn(20000)) oo = figure(o,fig); end;
      tocn('oo = figure(o,fig)');
      
      for(i=1:ticn(20000)) fig = figure(oo); end;
      tocn('fig = figure(oo)');

      for(i=1:ticn(20000)) o.work.figure = fig; end;
      tocn('o.work.figure = fig');

      for(i=1:ticn(20000)) fig = o.work.figure; end;
      tocn('fig = o.work.figure');
   end
   
   if (control.shelf)
      fprintf('shelf operations:\n');
      bull = corazito;  o = corazon;

      for(i=1:ticn(5000)) shelf(bull,fig,'object',o); end;
      tocn('shelf(bull,fig,''object'',o)');

      for(i=1:ticn(5000)) o = shelf(bull,fig,'object'); end;
      tocn('o = shelf(bull,fig,''object'')');

      for(i=1:ticn(1000)) push(o); end;
      tocn('push(o)');

      for(i=1:ticn(1000)) o = pull(o); end;
      tocn('o = pull(o)');
   end   
end   
   