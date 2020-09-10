% nstep - Antwort Strangdurchmesser auf Drehzahländerung

   path = 'messdaten/DSPScope14.csv_cut.csv';
   T = readtable(path);                         % read .CSV file into table
   M = table2array(T);                          % convert to normal matrix
   names = T.Properties.VariableNames;
   
% copy into single variables

   Ts = 0.01;              % Abtastzeit
   
   t{1} = (M(:,1)-1)*Ts;   % Zeit
   n{1} = M(:,2);          % Drehzahl
   d2{1} = M(:,3);         % Durchmesser oben
   d1{1} = M(:,4);         % Durchmesser unten

% Messdatensatz 2

   path = 'messdaten/DSPScope15.csv_cut.csv';
   T = readtable(path);                         % read .CSV file into table
   M = table2array(T);                          % convert to normal matrix
   names = T.Properties.VariableNames;
