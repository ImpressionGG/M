function open(o)
%
% OPEN   Present a file selection dialog to launch and open a Carabao
%        object which is stored in a .mat file
%
%           open(carabao)
%
   bag = load(carabao);                % bring a dialog to load .mat file
   if ~isempty(bag)
      oo = construct(carabao,bag);     % construct object o from bag struct
      launch(oo);                      % launch a proper shell
   end
end

