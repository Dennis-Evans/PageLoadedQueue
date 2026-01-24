
!ABCIncludeFile

  OMIT('_EndOfInclude_',_debugStringOut_)  ! Omit this if already compiled
_debugStringOut_         EQUATE(1)

    include('dynstr.inc'),once

debugStrOut class,type,module('debugStringOut.clw'),LINK('debugStringOut.clw',_ABCLinkMode_),DLL(_ABCDllMode_)
ouputStr             procedure(string s)
ouputStr             procedure(*cstring s)
ouputStr             procedure(*IDynStr s)
                         end

_EndOfInclude_