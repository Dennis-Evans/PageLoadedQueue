
  program

  map
  end

  include('equates.clw'),once
  include('abwindow.inc'),once
  include('personGroup.inc').once
  include('spBrowseQueue.inc')once
  include('fileDef.inc'),once
                     
personQ  personQueue
myWindow WINDOW('Caption'),AT(,,503,224),GRAY,FONT('Segoe UI',9)
    BUTTON('&OK'),AT(291,201,41,14),USE(?OkButton),DEFAULT
    BUTTON('&Cancel'),AT(340,201,42,14),USE(?CancelButton),STD(STD:Close)
    LIST,AT(8,8,489,172),USE(?personList),IMM,FROM(personQ),FORMAT('60L(2)|M~Bus' & |
        'iness Entity ID~L(1)@n-14@#1#40L(2)|M~Person Type~L(0)@s10@#2#12L(2)|M~' & |
        'Name Style~L(0)@n3@#3#40L(2)|M~Title~L(0)@s10@#4#80L(2)|M~first Name~L(' & |
        '0)@s50@#5#80L(2)|M~middle Name~L(0)@s50@#6#80L(2)|M~last Name~L(0)@s50@' & |
        '#7#80L(2)|M~row number~L(0)@s50@#8#')
  END

thisWindow class(windowManager),type
spBrw                 &spBrowseQueue
init                       procedure(),byte,virtual,proc
takeWindowEvent procedure(),byte,virtual  
loadQueue         procedure()
                     end  

win    thisWindow  

  code

  win.spBrw &= new(spBrowseQueue)

  win.Run()

  return
! --------------------------------------------------------------------------------------  

thisWindow.init  procedure() !byte,virtual,proc

retv byte,auto

  code
  
  retv = parent.init()

  if (retv = level:benign) 
    self.Open(MyWindow)   
  end 

  return retv
! ------------------------------------------------------------------------------------

thisWindow.takeWindowEvent procedure() !byte,virtual

retv byte,auto

  code

  retv = parent.TakeWindowEvent()
  if (retv = Level:Benign)  
    if (event() = EVENT:OpenWindow)
      win.addItem(win.spBrw.WindowComponent)
      win.spBrw.init(personFile, personFile.Record, personQ, ?personList)
      win.spBrw.setRowNumberPos(where(personQ, personQ.rowNumber)) 
      win.spBrw.setDbNames('person', 'person')
      win.spBrw.setSqlCode('call dbo.readTableOnePaged(&offset [in], &pageSize [in])')
       self.loadQueue()
    end 
  end
  
  return retv

thisWindow.loadQueue procedure()

retv byte,auto

  code

  retv = win.spBrw.loadQueue()

  select(?personList)
  ?personList{prop:selected} = 1
  get(personQ, 1)

  return
! -----------------------------------------------------------------------------------