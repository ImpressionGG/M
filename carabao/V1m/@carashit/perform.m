function perform(o)
%
% PERFORM   Performance tests
%
%              perform(carabull);
%
%           See also: CARABULL
%
   [ticn,tocn] = util(carabull,'ticn','tocn');
%
% performance estimastion control
%
   control.construction = 1;
   control.cast = 1;
   control.figure = 1;
   control.shelf = 1;
   
   if (control.construction)
      fprintf('object construction:\n');
      for(i=1:ticn(1000)) o = carabase;  end; tocn('o = carabase');
      for(i=1:ticn(1000)) o = caracow;  end; tocn('o = caracow');
      for(i=1:ticn(5000)) o = carabull; end; tocn('o = carabull');
      for(i=1:ticn(500)) o = carabao;  end; tocn('o = carabao');
      for(i=1:ticn(500)) o = carashit;  end; tocn('o = carashit');
   end
   
   if (control.cast)
      fprintf('object casting:\n');
      o = carabao; 
      for(i=1:ticn(2000)) oo = cast(o,'caracow');  end; 
      tocn('o = carabao; oo = cast(o,''caracow'')');
      for(i=1:ticn(2000)) oo = cast(o,'carashit');  end; 
      tocn('oo = caracow; oo = cast(o,''carashit'')');
   end
   
   if (control.figure)
      fprintf('figure management:\n');
      o = carabao;   fig = gcf;
      
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
      bull = carabull;  o = carabao;

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
   