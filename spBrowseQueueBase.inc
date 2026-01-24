
!ABCIncludeFile

  OMIT('_EndOfInclude_',_spPageBrowseQueueBase_)  ! Omit this if already compiled
_spPageBrowseQueueBase_         EQUATE(1)

  include('dynstr.inc'),once
  include('abwindow.inc'),once
  include('debugStringOut.inc'),once

startOffset             equate(0)
defaultPageSize   equate(200)
firstRow                  equate(1)
maxMsLabel           equate(128) 

!!!<summary>
!!! object to read and load a queue from a stored procedure call
!!!</summary>
spBrowseQueueBase  class,type,implements(windowComponent),module('spBrowseQueueBase.clw'),LINK('spBrowseQueueBase.clw',_ABCLinkMode_),DLL(_ABCDllMode_)
!region fields 
fGrp                           &group,protected 
Que                           &queue,protected
listControl                 long,private
queIndex                   long,private
rowNumber               long,private
rowNumberPos        long,private
addTop                      bool,private
offset                          long,private
pageSize                   long,private
totalRows                  long,private
sqlCode                     &IDynStr,private
schemaName           string(maxMsLabel),protected
tableName                string(maxMsLabel),protected
debugStrOut             &debugStrOut,protected
!endregion fields 

!region setup clean up
!!!<summary>
!!! default constructor, sets some starting values and allocates two objects 
!!!</summary>
construct                   procedure()

!region setup
!!!<summary>
!!! default destructo, disposes objects members 
!!!</summary>
destruct                     procedure(),virtual

!region setup
!!!<summary>
!!! sets up the instance with the inputs 
!!!</summary>
!!!<param name='g'>
!!! referenceto the group used.  
!!!</param>
!!!<param name='q'>
!!! referenceto the queue used.  
!!!</param>
!!!<param name='listCtl'>
!!! id number of the list control used to dieplay the queue 
!!!</param>
init                              procedure(*group g, *queue q, long listCtrl)
!region setup clean up

!region getters and setters 
!!!<summary>
!!! set the code or sql statement for stored procedure call 
!!!</summary>
setSqlCode                 procedure(string cs)
!!!<summary>
!!! set the code or sql statement for stored procedure call 
!!!</summary>
setSqlCode                 procedure(*IDynStr cs)

!!!<summary>
!!! gets the the SQL statement in use
!!!</summary>
getSqlCode                 procedure(),*cstring

!!!<summary>
!!! gets the length of the SQL statement in use, used to check the statement has been assigned 
!!!</summary>
sqlCodeLength           procedure(),long

setTotalRows             procedure(long tr)

!!!<summary>
!!! sets the schema name and the database named used by the function to count the rows 
!!!</summary>
setDbNames               procedure(string sn, string tn)

!!!<summary>
!!! set the offSet value for the page load
!!!</summary>
setOffset                      procedure(long offset)

!!!<summary>
!!! get the offSet value for the page load
!!!</summary>
getOffset                      procedure(),long 

!!!<summary>
!!! set the pageSize value for the page load
!!!</summary>
setPageSize               procedure(long pageSize)

!!!<summary>
!!! get the pageSize value for the page load
!!!</summary>
getPageSize                procedure(),long 

!!!<summary>
!!! sets the position of the row number value in the queue.  the row number is from the 
!!! query or stored procedure, aids to tracking the reads of the queue 
!!!</summary>
setRowNumberPos     procedure(long pos)

!!!<summary>
!!! gets the number of rows from the data source
!!!</summary>
getNumberRows           procedure(),long
!endregion getters and setters 

!region open close 
!!!<summary>
!!! opens the conection, file or what ever the data source uses 
!!! must be overloaded in a derived object
!!!</summary>
open                         procedure(),byte,virtual
!!!<summary>
!!! closes the conection, file or what ever the data source is used 
!!! must be overloaded in a derived object
!!!</summary>
close                       procedure(),virtual
!endregion open close 

!region queue workers
!!!<summary>
!!! loads the queue from the result set. 
!!!</summary>
!!!<remarks>
!!! this function requires the <c>sqlCode</c> memeber is set
!!!<remarks>
loadQueue                  procedure(long rn),virtual,byte,proc

!!!<summary>
!!! loads the queue from the result set. 
!!!</summary>
!!!<param name='cs'>
!!! string containing the sql statment to be executed 
!!!</param>
!!!<remarks>
!!! this function sets the <c>sqlCode</c> memeber
!!!<remarks>
loadQueue                  procedure(*string cs, long rn),virtual,byte,proc

!!!<summary>
!!! reads the rows from the result se and calls the functions to fill and format the 
!!! the queue record for each row 
!!!</summary>
readRows                  procedure(),virtual,byte

!!!<summary>
!!! fills the queue buffer from the values read, once for each row i nthe result set
!!!</summary>
fillQueueBuffer         procedure(),virtual

!!!<summary>
!!! adds the record to the queue.  Overload to perfom any formatting for display  
!!!</summary>
formatQueue            procedure(),virtual 

!!!<summary>
!!! removes an element from the queue, typically the first or last element. 
!!! called when scrolling a single row up or down 
!!!</summary>
removeQueueElement procedure(long index),virtual
!endregion queue workers

!region scrolling 
!region scroll top/bottom
!!!<summary>
!!! scrolls the queue to the first or last row 
!!!</summary>
takeScrollEnd           procedure(long ev)
!endregion scroll top/bottom

!region scroll page up/down
!!!<summary>
!!! scrolls the queue one page up or down
!!!</summary>
!!!<remarks>
!!! calls the move page u[/down functions 
!!!</remarks>
takeScrollPage         procedure(long ev)

!!!<summary>
!!! moves the queue down one page 
!!!</summary>
movePageDown       procedure(),private

!!!<summary>
!!! moves the queue up one page 
!!!</summary>
movePageUp            procedure(), private 

!!!<summary>
!!! moves the queue using the input
!!!</summary>
!!!<param name='listIndex'>
!!!index into the list or the queue, postions the list
!!!</param>
scrollPage                  procedure(long listIndex), private 
!endregion scroll page up/down

!region scroll one row 
takeScrollOne           procedure(long ev)
moveDownOne         procedure()
moveUpOne               procedure()
!endregion scroll one row 
!endregion scrolling 

!region general workers 
takeNewSelection   procedure()
countRows                 procedure(string schemaName, string tableName),long,virtual,protected
updateGroup             procedure(),virtual
!endregion general workers 

!region parameters 
!!!<summary>
!!! bind any parameters used by the stored procedure.  binds the offset and page size for the call
!!! other paremetrs, if any, will be bound in a derived object  
!!!</summary>
bindParameters        procedure(),virtual
!!!<summary>
!!! unbind the parameters used by the stored procedure   unbinds the offset and page size for the call
!!! other paremetrs, if any, will be un-bound in a derived object  
!!!</summary>
unbindParameters    procedure(),virtual
!endregion parameters 
                                end

_EndOfInclude_