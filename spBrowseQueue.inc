
!ABCIncludeFile

  OMIT('_EndOfInclude_',_spPageBrowseQueue_)  ! Omit this if already compiled
_spPageBrowseQueue_         EQUATE(1)

  include('dynstr.inc'),once
  include('spBrowseQueueBase.inc'),once

!!!<summary>
!!! object to read and load a queue from a stored procedure call
!!!</summary>
spBrowseQueue  class(spBrowseQueueBase),type,module('spBrowseQueue.clw'),LINK('spBrowseQueue.clw',_ABCLinkMode_),DLL(_ABCDllMode_)
!region fields 
myFile                       &file,protected
!endregion fields 

!region setup
init                         procedure(*file f, *group g, *queue q, long listCtrl)
!endregion setup

!region file access 
!!!<summary>
!!! opens the file for use 
!!!</summary>
!!!<returns>
!!! level:bengin for success, any other value is a failure
!!!</returns>
open                         procedure(),byte,virtual

!!!<summary>
!!! closes the file in use
!!!</summary>
close                        procedure(),virtual

!!!<summary>
!!! read the next row from the result set 
!!!</summary>
!!!<returns>
!!! byte value level:benign idicates success, any other value is a failure 
!!!</returns>
!!!<remarks>
!!! the call will return notify when the last row is read, this is expected 
!!!<remarks>
next procedure(),byte
!endregion file access 

!region load queue
!!!<summary>
!!! loads the queue from the data source
!!!</summary>
loadQueue procedure(),virtual,byte,proc

!!!<summary>
!!! loads the queue from the data source
!!!</summary>
!!!<param name="s">
!!! string that contains the sql statement to be executed,
!!! assigns the string to the data member
!!!</param>
loadQueue procedure(*string s),virtual,byte,proc

!!!<summary>
!!! reads the rows from the result set and calls the functions to fill and format the 
!!! the queue record for each row 
!!!</summary>
readRows procedure(),virtual
!!!<summary>
!!! iterate over the result set and fill and format the queue items 
!!!</summary>
loadResultSet procedure(),protected 
!endregion queue load

!region database access 
!!!<summary>
!!! executes the sql statement using prop:sql
!!!</summary>
!!!<returns>
!!! a byte value, level:benign idicates success, any other value is a failure 
!!!</returns>
execSql                      procedure(),byte,protected

!!!<summary>
!!! counts the rows in the table input 
!!!</summary>
!!!<param name="schemaName">
!!! name of the schema for the table
!!!</param>
!!!<param name="tableName">
!!! name of the table
!!!</param>
!!!<returns>
!!! a long value that is the number of rows in the table
!!!</returns>
!!!<remarks>
!!! this sp call uses the row column from the partition table
!!! the column may not be updated quick;y after a roll back 
!!!</remarks>
countRows       procedure(string schemaName, string tableName),long,virtual,protected
!endregion database access 

!region count parameters
!!!<summary>
!!! bind any parameters used by the count rows function 
!!!</summary>
bindCountParameters  procedure(*long retv),private

!!!<summary>
!!! unbind any parameters used by the count rows function 
!!!</summary>
unbindCountParameters procedure(),private   
!endregion count parameters
  end

_EndOfInclude_