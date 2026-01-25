
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

spBrowseQueue.countRows procedure(string schemaName, string tableName) !virtual,byte,protected

retv      long,auto

  code 

  bind('inschemaName', self.schemaName)
  bind('intableName', self.tableName)
  bind('retv', retv)
  
  self.myFile{prop:sql} = 'noresultcall dbo.readPartitionRows(&inSchemaName [in], &inTableName [in], &retv [out])';
  if (errorcode() > 0)
    retv = -1
  end

  unbind('inschemaName')
  unbind('intableName')
  unbind('retv')

  return retv
! --------------------------------------------------------------

!!!<summary>
!!! loads the queue from the result set. 
!!!</summary>
!!!<remarks>
!!! this function requires the <c>sqlCode</c> memeber is set
!!!<remarks>
spBrowseQueue.loadQueue procedure(long rn) !virtual,byte

rows long,auto
retv   byte(Level:Benign)

  code

  if (self.sqlCodeLength() <= 0) 
    return Level:Notify
  end

  self.setTotalRows(self.countRows(self.schemaName, self.tableName))  

  if (rn = 1)
    return retv
  end 

  if (self.getNumberRows() = rn) 
    return retv
  end 

  if (self.open() = level:benign) 
    self.readRows()
    self.close() 
 else
    retv = level:notify
 end

  return retv
! ------------------------------------------------------------

spBrowseQueue.loadQueue      procedure(*string s, long rn) !,virtual,byte

retv byte,auto

  code

  self.setSqlCode(s)
  retv = self.loadQueue(rn)

  return retv
! --------------------------------------------------------------

spBrowseQueue.readRows procedure() 

  code

  self.bindParameters()  
  
   if (self.execSql() = Level:Benign) 
     loop  while (self.next() = level:benign)
       self.fillQueueBuffer()
       self.formatQueue()
    end
 end

  self.unbindParameters()

  return
! ---------------------------------------------------------------------------------------------

!endregion file access 

