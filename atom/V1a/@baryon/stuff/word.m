function oo = word(o,varargin)         % Word Automation
%
% WORD   Word automation functions
%
%    Create a Word Automation Server and make it visible on the screen.
%    This would be the equivalent of opening MS Word
%
%       oo = word(o,'Begin')           % begin new Word document
%       word(oo,'Add')                 % add current screen into Word doc
%       word(oo,'End')                 % end Word document
%
%    Note: the Active-X (Word-) handle is stored in var(o,'word.hdl')
%
%    Example
%       oo = word(o,'Begin')           % begin new Word document
%       cls(o)
%       plot(0:0.1:10,sin(0:0.1:10),'r');
%       title('Sine Curve');
%       oo = word(oo,'Add')            % add current screen to Word doc
%       word(oo,'End')                 % end Word document
%       
%    See also: CARABAO
%
   [gamma,o] = manage(o,varargin,@Begin,@Add,@End);
   oo = gamma(o);
end

%==========================================================================
% Word Automation Functions
%==========================================================================

function oo = Begin(o)                 % Begin a New Word Document     
%
   word.hdl = actxserver('word.application');
   set(word.hdl,'visible',1);

      % Create a new document

   word.doc = invoke(word.hdl.documents,'add');

      % Specify the location by creating a range

   word.range = invoke(word.doc,'range');
   word.count = 0;                     % no figures added

   oo = var(o,'word',word);
end

function oo = Add(o)                   % Add Current Graphics Screen 
%
   word = var(o,'word');               % get word access structure
   doc = word.doc;

   invoke(doc.Paragraphs,'Add');        % Adds a new paragraph
   count = word.count + 1;

      % Select the new paragraph range
      
   start = word.doc.Paragraphs.Item(count).Range.Start;
   word.range = invoke(word.doc,'range',start);      
      
      % copy current figure into clip board and paste clip board into doc
      % i.e., paste the figure into the Word Document range that was
      % previously selected
      
   print(gcf,'-dmeta');
   invoke(word.range,'Paste')

      % store current count in word structure and pack into object variable
      
   word.count = count;                 % store current count
   oo = var(o,'word',word);
end

function oo = End(o)                   % End Word Document Creation
   word = var(o,'word');
   delete(word.hdl);                   % delete all created handles
   oo = o;                             % return object
end
