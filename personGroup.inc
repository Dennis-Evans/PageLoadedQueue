
    OMIT('_EndOfInclude_',_personGroupPresent_)

_personGroupPresent_ EQUATE(1)

personGroup        group,type
BusinessEntityID     long
PersonType             string(3)
NameStyle               byte
Title                         string(10)
firstName                string(50)
middleName           string(50)
lastName                string(50)
rowNumber             long
                           end

personQueue     queue(personGroup)
                             end

 _EndOfInclude_