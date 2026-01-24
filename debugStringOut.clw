

  member()

   map
      module('win32')
        OutputDebugStringA(*cstring s),raw,pascal,name('OutputDebugStringA')
      end
   end
  include('debugStringOut.inc'),once

debugStrOut.ouputStr procedure(string s)

cs  &cstring

  code

  cs &= new(cstring(size(s) + 1) )
  cs = s 
  OutputDebugStringA(cs) 
 
  dispose(cs)
    
  return
! ---------------------------------------------------------------------------

debugStrOut.ouputStr procedure(*cstring s)

  code

  OutputDebugStringA(s)

  return
! ---------------------------------------------------------------------------

debugStrOut.ouputStr procedure(*IDynStr s)

  code 

  OutputDebugStringA(s.CStr())

  return
! ---------------------------------------------------------------------------