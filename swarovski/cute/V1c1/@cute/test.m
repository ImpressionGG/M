function test(o)
%
% TEST  Description of regression tests
%
% 1) Standard initialization
%    - load measurement plan (.xlsx)
%    - store as package
%    - clear objects
%    - load package
%    - select package and plot metrics
%    - save .pkg file
%
% 2) Missing package info must generate an error
%    - clear objects
%    - File>Import>Package (whith non existing .pkg file)
%    - => Error: missing package info file!
%
% 3) Load duplicate package (2x .xlsx load)
%    - File>Import>Package_Info_(.xlsx)
%    - cache(cuo,cuo,'spec') % hard refreshes cache for this object
%    - File>Import>Package_Info_(.xlsx)   (second time)
%    - => Alert box "Duplicate Package" must pop up
%      a) => Cancel
%         => object list is unaffected
%         => also check: cache(cuo) % all cache segments up to date
%      b) => Skip
%         => object list is unaffected
%         => also check: cache(cuo) % all cache segments up to date
