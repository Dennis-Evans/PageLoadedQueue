
  member

  map
  end

  include('spBrowseQueue.inc')once
  include('debugStringOut.inc'),once
  
!region setup cleanup
spBrowseQueue.init procedure(*file f, *group g, *queue q, long listCtrl)

  code

  self.myFile &= f
  parent.init(g, q, listCtrl)

  return
! -------------------------------------------------------------
!endregion setup cleanup

!region file access 
!!!<summary>
!!! opens the file for use 
!!!</summary>
!!!<returns>
!!! level:benign for success any other value is a failure 
!!!</returns>
spBrowseQueue.open procedure()

retv byte(level:benign)

  code

  open(self.myFile, 0)
  if (errorcode() > 0) 
    retv = Level:Notify
  end 

  return retv
! -------------------------------------------------------------

!!!<summary>
!!! closes the file in use
!!!</summary>
spBrowseQueue.close procedure()

  code
  
  close(self.myFile) 

  return
! -------------------------------------------------------------

!!!<summary>
!!! read the next row from the result set 
!!!</summary>
!!!<returns>
!!! byte value level:benign idicates success, any other value is a failure 
!!!</returns>
!!!<remarks>
!!! the call will return notify when the last row is read 
!!!<remarks>
spBrowseQueue.next procedure() !,byte

retv byte(level:benign)

  code

   next(self.myFile)
  
   if (errorcode() > 0) 
      retv = Level:Notify
  end

  return retv
! ---------------------------------------------------------------
!endregion file access

!region load queue
!!!<summary>
!!! loads the queue from the result set. 
!!!</summary>
!!!<remarks>
!!! this function requires the <c>sqlCode</c> memeber is set
!!!<remarks>
spBrowseQueue.loadQueue procedure() !virtual,byte

rows long,auto
retv   byte(Level:Benign)

  code

  if (self.sqlCodeLength() <= 0) 
    return Level:Notify
  end

  self.setTotalRows(self.countRows(self.schemaName, self.tableName))
  if (self.open() = level:benign) 
    self.readRows()
    self.close() 
 else
    retv = level:notify
 end

  return retv
! ------------------------------------------------------------

!!!<summary>
!!! loads the queue from the data source
!!!</summary>
!!!<param name="s">
!!! string that contains the sql statement to be executed,
!!! assigns the string to the data member
!!!</param>
spBrowseQueue.loadQueue      procedure(*string s) !,virtual,byte

retv byte,auto

  code

  self.setSqlCode(s)
  retv = self.loadQueue()

  return retv
! --------------------------------------------------------------

!!!<summary>
!!! reads the rows from the result set and calls the functions to fill and format the 
!!! the queue record for each row 
!!!</summary>
spBrowseQueue.readRows procedure() 

  code

  self.bindParameters()  
  
  if (self.execSql() = Level:Benign) 
   self.loadResultSet()
  end

  self.unbindParameters()

  return
! ---------------------------------------------------------------------------------------------

!!!<summary>
!!! iterate over the result set and fill and format the queue items 
!!!</summary>
spBrowseQueue.loadResultSet procedure() !protected 

  code

  loop while (self.next() = level:benign)
    self.fillQueueBuffer()
    self.formatQueue()
  end

  return
! -------------------------------------------------------------------------------------------
!endregion load queue

!region database access
!!!<summary>
!!! executes the sql statement using prop:sql
!!!</summary>
!!!<returns>
!!! A  byte value, level:benign idicates success, any other value is a failure 
!!!</returns>
spBrowseQueue.execSql procedure() !byte,protected

retv byte(level:benign)
cnt long(0)

  code 
  
  self.myFile{prop:sql} = self.getSqlCode() 
  if (errorcode() <> 0)
    retv = Level:Notify
  end

  return retv
! --------------------------------------------------------------

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
!!! the column may not be updated quickly after a roll back 
!!!</remarks>
spBrowseQueue.countRows procedure(string schemaName, string tableName) !virtual,byte,protected

retv      long,auto

  code

  self.bindCountParameters(retv)
  
  self.myFile{prop:sql} = 'noresultcall dbo.readPartitionRows(&inSchemaName [in], &inTableName [in], &retv [out])';
  if (errorcode() > 0)
    retv = -1
  end

  self.unBindCountParameters()

  return retv
! --------------------------------------------------------------
!endregion database access

!region count parameters
!!!<summary>
!!! bind any parameters used by the count rows function 
!!!</summary>
spBrowseQueue.bindCountParameters procedure(*long retv)

  code

  bind('inschemaName', self.schemaName)
  bind('intableName', self.tableName)
  bind('retv', retv)

  return
! ----------------------------------------------------------------------   

!!!<summary>
!!! unbind any parameters used by the count rows function 
!!!</summary>
spBrowseQueue.unbindCountParameters procedure()   

  code

  unbind('inschemaName')
  unbind('intableName')
  unbind('retv')

  return
! ----------------------------------------------------------------------   
!endregion count parameters

