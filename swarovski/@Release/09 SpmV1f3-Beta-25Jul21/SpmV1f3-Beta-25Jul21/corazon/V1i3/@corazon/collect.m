%
% COLLECT   Collect log files of a package directory
%
%    Before applying a collect operation a collection configuration must be
%    setup in prior (1,2). After that the collection can be applied (3).
%
%    1) Setup a collection configuration: this happens by repeated
%    assignment of an object type list with an import table
%
%       collect(o,{})                  % init (reset) collection config
%       collect(o,types,table)         % setup collection config
%       collect(o,{'pln','smp'},table) % setup collection config
%       collect(o,{},table0)           % provide default import table
%
%    2) Display collect configuration
%
%       collect(o)                     % display collection config
%
%    3) Apply collection: collect files according to previously defined
%    configuration
%
%       list = collect(o)              % collect files of a package
%
%    Remark: the collection configuration is an assoc table where each 
%    configured type is assigned with an import driver table, while each
%    import driver table tells the collect method how to import a log file.
%    A default table
%
%       setting(o,'collect',{{type1,table1},{type2,table2},...,table0})
%
%    Example 1: provide only default table
%
%       collect(o,{})                  % reset collection config
%       table0 = {{@read,'myclass','PackageDrv','.pkg'},...
%                 {@read,'myclass','UniLogDrv', '.log'}};
%       collect(o,{},table0);          % only default table
%
%    Example 2: provide general collection configuration
%
%       collect(o,{})                  % reset collection config
%
%       table1 = {{@read,'myclass','PackageDrv','.pkg'},...
%                 {@read,'myclass','UniLogDrv', '.log'}};
%       collect(o,{'pln','smp'},table1); 
%
%       table2 = {{@read,'myclass','PackageDrv','.pkg'},...
%                 {@read,'myclass','UniLogDrv', '.log'}};
%                 {@basis,'myclass','Ob1TxtDrv','.txt'}},...
%       collect(o,{'ob1'},table2); 
%
%       table3 = {{@read,'myclass','PackageDrv','.pkg'},...
%                 {@read,'myclass','UniLogDrv', '.log'}};
%                 {@basis,'myclass','Ob2TxtDrv','.txt'}},...
%                 {@basis,'myclass','Ob2PbiDrv','.pbi'}},...
%       collect(o,{'ob2'},table3); 
%
%    See also: CORAZON, IMPORT
%
