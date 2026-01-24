
  member

  map
  end

  include('spBrowseQueueBase.inc')once
  include('debugStringOut.inc'),once

!region setup cleanup
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
 
spBrowseQueueBase.destruct procedure()

  code 

  disposeDynStr(self.sqlCode)
  dispose(self.debugStrOut)

  return 
! -------------------------------------------------------------

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
!!! opens the file for use 
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

spBrowseQueueBase.setTotalRows procedure(long tr)
 
  code
 
  self.totalRows = tr

  return
! ----------------------------------------------------------------------

! add the single quotes here, 
spBrowseQueueBase.setDbNames procedure(string sn, string tn)


  code
  
  self.schemaname = '<39>' & sn & '<39>'
  self.tablename = '<39>' & tn & '<39>'

  return 
! ----------------------------------------------------------------------

spBrowseQueueBase.setSqlCode procedure(string cs)

  code

  self.SqlCode.kill()
  self.sqlCode.Cat(cs) 

  return

spBrowseQueueBase.setSqlCode procedure(*IDynStr cs)

  code
  
  self.sqlCode.Kill()
  self.sqlCode.Cat(cs.CStr())

  return
! --------------------------------------------------------------------

spBrowseQueueBase.getSqlCode procedure() !*cstring

  code

  return self.sqlCode.CStr()
! --------------------------------------------------------------------

spBrowseQueueBase.sqlCodeLength procedure() !,long

retv long,auto

  code

   retv = self.sqlCode.StrLen()

   return retv
 ! -------------------------------------------------------------------------------------------

spBrowseQueueBase.setOffset procedure(long offset)

  code 
  
  self.offset = Offset

  return
! -------------------------------------------------------------------

spBrowseQueueBase.getOffset procedure() !long 

  code

  return self.offset
! ------------------------------------------------------------------

spBrowseQueueBase.setPageSize procedure(long pageSize)

  code 
  
  self.pageSize = pageSize

  return
! -------------------------------------------------------------------

spBrowseQueueBase.getPageSize procedure() !long 

  code

  return self.pageSize
! ------------------------------------------------------------------

spBrowseQueueBase.setRowNumberPos procedure(long pos)

  code 

  self.rowNumberPos = pos

  return
! ------------------------------------------------------------------

spBrowseQueueBase.getNumberRows procedure() !long
 
retv   long,auto

   code

    !retv = self.countRows(self.schemaName, self.tableName)

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
spBrowseQueueBase.loadQueue procedure(long rn) !virtual,byte,proc

  code
  return 0
! ------------------------------------------------------------

!!!<summary>
!!! loads the queue from the result set.  must be overloaded in a derived object
!!!</summary>
!!!<remarks>
!!! this function requires the <c>sqlCode</c> memeber is set
!!!<remarks>
spBrowseQueueBase.loadQueue procedure(*string cs, long rn) !virtual,byte,proc
  
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

spBrowseQueueBase.removeQueueElement procedure(long index)

  code
  
  get(self.Que, index)
  delete(self.Que)

  return
! ---------------------------------------------------------------------------------------
!endregion queue workers 
 
!region scrolling 

!region scroll top/bottom 
spBrowseQueueBase.takeScrollEnd procedure(long ev)

  code

 ! 0xC000041d = STATUS_FATAL_USER_CALLBACK_EXCEPTION
  if (ev = event:scrollBottom)
    self.offset = self.totalRows - self.pageSize
    free(self.que)
    self.loadQueue(0)
    self.queIndex = self.pageSize
    get(self.que, self.queIndex)
    self.listControl{prop:selected} = self.queIndex
  else
    self.offset = 0
    free(self.que)
    self.loadQueue(0)
    self.queIndex = firstRow
    get(self.Que, self.queIndex)
    self.listControl{prop:selected} = self.queIndex
  end  ! case event 

  self.updateGroup()

  return
! ----------------------------------------------------------------------------------------
!endregion scroll top/bottom 

!region scroll page up/down
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

spBrowseQueueBase.movePageDown procedure() ! private 

listItems   long,auto
listIndex   long,auto
totalRows long,auto

   code

   listIndex  = self.listControl{PROP:Selected}
   listItems = self.listControl{prop:items}
   totalRows = self.getNumberRows()
 
   self.debugStrOut.ouputStr('not in range')

   self.offset = self.rowNumber + (listItems - listIndex)
   if (self.offset > totalRows)
     self.offset = totalRows - self.pageSize
   end
   !self.scrollPage(listIndex)
   free(self.Que)
   self.loadQueue(0)
   get(self.Que, listIndex)
   self.listControl{prop:Selected} = listIndex
   self.queIndex = listIndex

   return
! --------------------------------------------------------------------------------------

spBrowseQueueBase.movePageUp procedure() ! private 

listIndex  long,auto 

   code
  
   if (self.rowNumber <= self.listControl{prop:items})
      self.offset = 0
      self.scrollPage(1)
   else 
   if (self.rowNumber > 1) 
       listIndex  = self.listControl{prop:Selected}
        if (listIndex = self.listControl{prop:items})
          listIndex = 1
        end
     self.debugStrOut.ouputStr('page up list index ' & listIndex & ' ' & self.offset)
       self.offset = (self.rowNumber - self.listControl{prop:items}) 
       if (self.offset < 0)
         self.offset = 0
       end       
       self.scrollPage(listIndex)
     end 
   end 

   return
! ---------------------------------------------------------------------------------------

spBrowseQueueBase.scrollPage procedure(long listIndex) ! private 

  code

  free(self.Que)
  self.loadQueue(0)
  get(self.Que, listIndex)
  self.listControl{prop:Selected} = listIndex
  self.queIndex = listIndex

  return
! ---------------------------------------------------------------------------------------
!endregion scroll page up/down

!region scroll one row 
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

spBrowseQueueBase.moveDownOne procedure()

rows  long auto
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
       self.loadQueue(self.rowNumber) 
       self.removeQueueElement(1)
       get(self.Que, self.queIndex)    
       self.listControl{prop:selected} = self.queIndex
       self.pageSize = savePage
    end
  end

  self.updateGroup()

  return
! -----------------------------------------------------------------------------------------

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
        self.loadQueue(self.rowNumber)
        self.updateGroup()
        self.removeQueueElement(records(self.Que))
        get(self.Que, self.queIndex)
        self.listControl{prop:selected} = self.queIndex
        self.addTop = false 
        self.pageSize = savePageSize
    end  
  end

  return
! -----------------------------------------------------------------------------------------
!endregion scroll one row 

!endregion scrolling 

!region general workers 
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

