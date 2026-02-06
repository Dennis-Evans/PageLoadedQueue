
  member

  map
  end

  include('spBrowseQueueBase.inc')once
  include('debugStringOut.inc'),once

!region setup clean up
!!!<summary>
!!! default constructor, sets some starting values and allocates two objects 
!!!</summary>
spBrowseQueueBase.construct procedure()
  
  code 

  self.offset = startOffset
  self.pageSize = defaultPageSize
  self.queIndex = firstRow
  self.rowNumber = firstRow
  self.SqlCode &= NewDynStr()
  self.debugStrOut &= new(debugStrOut)
  
  return
! ----------------------------------------------------------------
 
 !!!<summary>
!!! default destructo, disposes object members 
!!!</summary>
spBrowseQueueBase.destruct procedure()

  code 

  disposeDynStr(self.sqlCode)
  dispose(self.debugStrOut)

  return 
! -------------------------------------------------------------

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
spBrowseQueueBase.init procedure(*group g, *queue q, long listCtrl)

  code

  self.que &= q
  self.fgrp &= g
  self.listControl = listCtrl

  return
! -------------------------------------------------------------
!endregion setup cleanup

!region open close
!!!<summary>
!!! opens the conection, file or what ever the data source uses 
!!! must be overloaded in a derived object
!!!</summary>
spBrowseQueueBase.open  procedure() !,byte,virtual

  code
  halt('Must be implemented in a derived class')
  return level:fatal
! ------------------------------------------------------------

!!!<summary>
!!! closes the file in use
!!!</summary>
spBrowseQueueBase.close procedure() !,virtual
 
  code
  halt('Must be implemented in a derived class')
  return
! ----------------------------------------------------------------------
!endregion open close

!region getters and setters 

!!!<summary>
!!! setter the total rows member closes the file in use
!!!</summary>
spBrowseQueueBase.setTotalRows procedure(long tr)
 
  code
 
  self.totalRows = tr

  return
! ----------------------------------------------------------------------

!!!<summary>
!!! set the code or sql statement for stored procedure call 
!!!</summary>
spBrowseQueueBase.setSqlCode procedure(string cs)

  code

  self.SqlCode.kill()
  self.sqlCode.Cat(cs) 

  return
! ----------------------------------------------------------------------

!!!<summary>
!!! set the code or sql statement for stored procedure call 
!!!</summary>
spBrowseQueueBase.setSqlCode procedure(*IDynStr cs)

  code
  
  self.sqlCode.Kill()
  self.sqlCode.Cat(cs.CStr())

  return
! --------------------------------------------------------------------

!!!<summary>
!!! getter the the SQL statement in use
!!!</summary>
!!!<returns>
!!! a cstring with the sal statement 
!!!</returns>
spBrowseQueueBase.getSqlCode procedure() !*cstring

  code

  return self.sqlCode.CStr()
! --------------------------------------------------------------------

!!!<summary>
!!! gets the length of the SQL statement in use, used to check the statement has been assigned 
!!!</summary>
spBrowseQueueBase.sqlCodeLength procedure() !,long

retv long,auto

  code

  retv = self.sqlCode.StrLen()

  return retv
 ! -------------------------------------------------------------------------------------------

!!!<summary>
!!! sets the schema name and the database name used by the function to count the rows 
!!!</summary>
spBrowseQueueBase.setDbNames procedure(string sn, string tn)

  code

  self.schemaname =  sn
  self.tablename = tn
  
  return 
! ----------------------------------------------------------------------

!!!<summary>
!!! set the offSet value for the page load
!!!</summary>
spBrowseQueueBase.setOffset procedure(long offset)

  code 
  
  self.offset = Offset

  return
! -------------------------------------------------------------------

!!!<summary>
!!! get the offSet value for the page load
!!!</summary>
spBrowseQueueBase.getOffset procedure() !long 

  code

  return self.offset
! ------------------------------------------------------------------

!!!<summary>
!!! set the pageSize value for the page load
!!!</summary>
spBrowseQueueBase.setPageSize procedure(long pageSize)

  code 
  
  self.pageSize = pageSize

  return
! -------------------------------------------------------------------

!!!<summary>
!!! get the pageSize value for the read
!!!</summary>
spBrowseQueueBase.getPageSize procedure() !long 

  code

  return self.pageSize
! ------------------------------------------------------------------

!!!<summary>
!!! sets the position of the row number value in the queue.  the row number is from the 
!!! query or stored procedure, aids to tracking the reads of the queue 
!!!</summary>

spBrowseQueueBase.setRowNumberPos procedure(long pos)

  code 

  self.rowNumberPos = pos

  return
! ------------------------------------------------------------------

!!!<summary>
!!! gets the number of rows from the data source
!!!</summary>
spBrowseQueueBase.getNumberRows procedure() !long
 
retv   long,auto

   code
   return self.totalRows
! ------------------------------------------------------------------
!endregion getters and setters 

!region queue workers 
!!!<summary>
!!! loads the queue from the result set.  must be overloaded in a derived object
!!!</summary>
!!!<remarks>
!!! this function requires the <c>sqlCode</c> memeber is set
!!!<remarks>
spBrowseQueueBase.loadQueue procedure() !virtual,byte,proc

  code
  return 0
! ------------------------------------------------------------

!!!<summary>
!!! loads the queue from the result set.  must be overloaded in a derived object
!!!</summary>
!!!<remarks>
!!! this function requires the <c>sqlCode</c> memeber is set
!!!<remarks>
spBrowseQueueBase.loadQueue procedure(*string cs) !virtual,byte,proc
  
  code 
  return 0
! ---------------------------------------------------------------------------------

!!!<summary>
!!! reads the result set and fills the queue must be overloaded in a derived object
!!!</summary>
spBrowseQueueBase.readRows procedure() 

  code
  return 0
! ---------------------------------------------------------------------------------------------

!!!<summary>
!!! fills the queue from the record read.  the file and queue definition are the same in this example so just assign
!!!</summary>
spBrowseQueueBase.fillQueueBuffer procedure()

   code

  self.que = self.fgrp

  return
! ---------------------------------------------------------------------------------------------

!!!<summary>
!!! adds the record to the queue.  Overload to perfom any formatting for display  
!!!</summary>
spBrowseQueueBase.formatQueue procedure()  !virtual 

  code

  if (self.addTop = true)
    add(self.que, 1)
   else 
    add(self.que)
  end

  return
! -------------------------------------------------------------------------------------------

!!!<summary>
!!! removes an element from the queue, typically the first or last element. 
!!! called when scrolling a single row up or down 
!!!</summary>
spBrowseQueueBase.removeQueueElement procedure(long index)

  code
  
  get(self.Que, index)
  delete(self.Que)

  return
! ---------------------------------------------------------------------------------------
!endregion queue workers 
 
!region scrolling 

!region scroll top/bottom 
!!!<summary>
!!! scrolls the queue to the first or last row 
!!!</summary>
spBrowseQueueBase.takeScrollEnd procedure(long ev)

saveIndex long

  code

 ! 0xC000041d = STATUS_FATAL_USER_CALLBACK_EXCEPTION
  if (ev = event:scrollBottom)
    if (self.rowNumber < self.getNumberRows())
      self.offset = self.totalRows - self.pageSize
      free(self.que)
      self.loadQueue()
      self.queIndex = self.pageSize
      get(self.que, self.queIndex)
      self.listControl{prop:selected} = self.queIndex 
      self.updateGroup()
   end 
  else 
    if (self.rowNumber > 1)  
      self.offset = 0
      free(self.que)
      self.loadQueue()
      self.queIndex = firstRow
      get(self.Que, self.queIndex)
      self.listControl{prop:selected} = self.queIndex  
      self.updateGroup()
   end
  end  ! if ev
  
  return
! ----------------------------------------------------------------------------------------
!endregion scroll top/bottom 

!region scroll page up/down
!!!<summary>
!!! scrolls the queue one page up or down
!!!</summary>
!!!<param name='ev'>
!!! id of the event, page up or page down 
!!!</param>
!!!<remarks>
!!! moves the queue down one page, the page in this case is the list control prop:items and 
!!! not the pageSize data member 
!!!</remarks>
spBrowseQueueBase.takeScrollPage procedure(long ev)

  code

  if (ev = event:PageDown)
    self.movePageDown()
  else 
    self.movePageUp()
  end 

  self.updateGroup()
  
  display(self.listControl)

  return
! ----------------------------------------------------------------------------------------

!!!<summary>
!!! moves the queue down one page
!!!</summary>
spBrowseQueueBase.movePageDown procedure() ! private 

listIndex    long,auto
totalRows long,auto
lastPage     long,auto

currentPage long,auto

   code

  currentPage = self.rowNumber / self.pageSize
  self.debugStrOut.ouputStr('current page ' & currentPage)
  ! if totals equal nothing to do
   totalRows = self.getNumberRows()
   if (self.rowNumber = totalRows)
     return
   end 

   listIndex  = self.listControl{PROP:Selected}

  lastPage =  totalRows - self.listControl{prop:items}
     self.debugStrOut.ouputStr('last page ' & lastPage)
   self.offset = self.rowNumber + (self.listControl{prop:items} - listindex)
   self.debugStrOut.ouputStr('offset ' & self.offset & ' current page ' & currentPage)
   if (self.offset < currentPage) 
      self.debugStrOut.ouputStr('do not load queue')
   else 
     self.debugStrOut.ouputStr('load queue')
     end
   if (self.offset >= totalRows)
     self.offset = totalRows - self.listControl{prop:items} 
     self.debugStrOut.ouputStr('offset 1 ' & self.offset)
   end
  if ((self.offset < totalRows) and (self.offset > lastPage))
    self.offset = totalRows - self.listControl{prop:items}
    listindex = self.listControl{prop:items}
   self.debugStrOut.ouputStr('offset 2 ' & self.offset & ' ' & lastPage)

  end 
  !self.scrollPage(listIndex)
  free(self.Que)
  self.loadQueue()
  get(self.Que, listIndex)
  self.listControl{prop:Selected} = listIndex
  self.queIndex = choice(self.listControl)

   self.debugStrOut.ouputStr('que index ' & self.queindex)
   return
! --------------------------------------------------------------------------------------

!!!<summary>
!!! moves the queue up one page 
!!!</summary>
spBrowseQueueBase.movePageUp procedure() ! private 

listIndex  long,auto 

   code
  
  self.debugStrOut.ouputStr('items ' & self.listControl{prop:items})

  ! nothing to do
  if (self.rowNumber = firstRow)
    return
  end
  
   if (self.rowNumber = self.getNumberRows())
   self.debugStrOut.ouputStr('on last row ' & self.listControl{prop:selected})
    listIndex = 1
  else      
   self.debugStrOut.ouputStr('selected ' & self.listControl{prop:selected})
    listIndex = self.listControl{prop:selected}
  end
   self.offset = (self.rowNumber - 1) - self.listControl{prop:items}
   self.debugStrOut.ouputStr('offset ' & self.offset & ' ' & listindex)
   if (self.offset < 1)
     self.offset = 0
  end

  free(self.Que)
  self.loadQueue()
  get(self.Que, 1)
  self.listControl{prop:Selected} = 1! listIndex
  self.queIndex = 1 !listIndex !choice(self.listControl)

!  self.scrollPage(listIndex)
  !self.debugStrOut.ouputStr('que index ' & self.queIndex & ' row number ' & self.rowNumber)
  self.updateGroup()
  self.debugStrOut.ouputStr('que index ' & self.queIndex & ' row number ' & self.rowNumber)

   return
! ---------------------------------------------------------------------------------------
!endregion scroll page up/down

!region scroll one row 
!!!<summary>
!!! moves the queue selection up or down one row 
!!!</summary>
!!!<remarks>
!!! depending on the up or down direction and if the queue is on the first or last row 
!!! this will read one row from the data source and remove one element form the queue  
!!!</remarks>
spBrowseQueueBase.takeScrollOne procedure(long ev)

  code

  case (ev) 
  of event:scrollDown   
     self.moveDownOne()
  of event:scrollUp
      self.moveUpOne()
  end

  return
! ------------------------------------------------------------------------------------------

!!!<summary>
!!! moves the queue selection down one row 
!!!</summary>
spBrowseQueueBase.moveDownOne procedure()

rows          long auto
savePage long,auto

  code

  rows = records(self.que)
  if (self.QueIndex < rows)    
    self.QueIndex += 1
    get(self.Que, self.QueIndex) 
    self.listControl{prop:selected} = self.queIndex
  else  
    if (self.queIndex = rows) 
       self.offset = self.rowNumber
       savePage = self.pageSize 
       self.pageSize = 1
       self.loadQueue() 
       self.removeQueueElement(1)
       get(self.Que, self.queIndex)    
       self.listControl{prop:selected} = self.queIndex
       self.pageSize = savePage
    end
  end

  self.updateGroup()
  display(self.listControl)

  return
! -----------------------------------------------------------------------------------------

!!!<summary>
!!! moves the queue selection up one row 
!!!</summary>
spBrowseQueueBase.moveUpOne procedure()

savePageSize long,auto

  code

  if (self.rowNumber = 1) 
    return
  end

   if ((self.rowNumber > 1) and (self.QueIndex > 1))
      self.queIndex -= 1
       get(self.Que, self.queIndex)
       self.listControl{prop:selected} = self.queIndex
       self.updateGroup()
   else
      if ((self.rowNumber > 1) and (self.QueIndex = 1))
        self.offset = self.rowNumber - 2
        if (self.offset < 0) 
          self.offset = 0
        end
        savePageSize = self.pageSize
        self.pageSize = 1
        self.addTop = true
        self.loadQueue()
        self.updateGroup()
        self.removeQueueElement(records(self.Que))
        get(self.Que, self.queIndex)
        self.listControl{prop:selected} = self.queIndex
        self.addTop = false 
        self.pageSize = savePageSize
    end  
  end

  display(self.listControl)

  return
! -----------------------------------------------------------------------------------------
!endregion scroll one row 

!endregion scrolling 

!region general workers 
!!!<summary>
!!! updates the instances members on a new selection of the list
!!!</summary>
spBrowseQueueBase.takeNewSelection procedure()

  code
 
  if (field() = self.listControl) 
    !self..currentChoice = choice(self.listControl) 
    self.queIndex = choice(self.listControl) 
    !self.listControl{prop:selected} = self.currentChoice
    self.listControl{prop:selected} = self.queIndex
    get(self.Que, self.queindex)    
    self.updateGroup()    
  end

  return
! ------------------------------------------------------------------------------------------

! must be overloaded in a derived object
spBrowseQueueBase.countRows procedure(string schemaName, string tableName) !virtual,byte,protected
  
   code  
   return 0
! ---------------------------------------------------------------------------------------

!!!<summary>
!!! updates the queue and sets the row number field to the current value
!!!</summary>
spBrowseQueueBase.updateGroup      procedure() ! virtual

a any,auto

  code

  self.fGrp = self.Que
  a &= what(self.que, self.rowNumberPos)
  self.rowNumber  = a;

  return
! ----------------------------------------------------------------------------------------
!endregion general workers 

!region parameters 
!!!<summary>
!!! bind any parameters used by the stored procedure 
!!! overload for other parameters 
!!!</summary>
spBrowseQueueBase.bindParameters  procedure() ! virtual

  code

  bind('offset', self.offset)
  bind('pageSize', self.pageSize)

  return
! -------------------------------------------------------------------------------------------

!!!<summary>
!!! unbind the parameters used by the stored procedure 
!!! overload for other parameters 
!!!</summary>
spBrowseQueueBase.unbindParameters  procedure() ! virtual

  code

  unbind('pageSize')
  unbind('offset')

  return
! -------------------------------------------------------------------------------------------
!endregion parameters 

!region window component 
spBrowseQueueBase.windowComponent.Kill procedure()

  code

  return
! --------------------------------------------------------------


spBrowseQueueBase.windowComponent.Reset procedure (BYTE Force)

  code

  return
! --------------------------------------------------------------

spBrowseQueueBase.windowComponent.ResetRequired procedure() !byte

  code

  return 0
! --------------------------------------------------------------

spBrowseQueueBase.windowComponent.SetAlerts procedure()

  code

  return
! --------------------------------------------------------------

spBrowseQueueBase.windowComponent.TakeEvent procedure() !byte

ev  long,auto

  code

  ev = event() 
  case field() 
    of Self.listControl
       case ev 
       of event:NewSelection
          self.takeNewSelection()
      of Event:scrollDown orof event:scrollUp
        self.takeScrollOne(ev)
      of event:ScrollTop orof event:ScrollBottom
         self.takeScrollEnd(ev)
      of event:pageDown orof event:pageUp
         self.takeScrollPage(ev)
     end
  end 

  return level:Benign
! --------------------------------------------------------------

spBrowseQueueBase.windowComponent.Update procedure()

  code
  
  return
! --------------------------------------------------------------

spBrowseQueueBase.windowComponent.UpdateWindow procedure()

  code
  return
! --------------------------------------------------------------
!endregion window component 

