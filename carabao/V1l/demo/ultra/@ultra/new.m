function oo = new(o)                   % New Ultra Object
%
% NEW   New ultra typed caramel object
%
%          oo = new(ultra)
%
%       See also: ULTRA
%
   oo = caramel('ultra');              % ultra type carabao object
   sigma = 50;                         % 50 nm standard deviation
   
   title = ['Ultra Objject @ ',o.now];
   oo = set(oo,'title',title);
   
   t = 0:0.01:1;
   oo = data(oo,'t',t);
   oo = data(oo,'x',sigma*randn(size(t)));
   oo = data(oo,'y',sigma*randn(size(t)));

   oo = cast(oo,'ultra');              % to make Config working
   oo = shell(oo,'Config');
   oo = balance(oo);
   
   oo = launch(oo,launch(o));
end