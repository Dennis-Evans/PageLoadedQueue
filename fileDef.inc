
    OMIT('_EndOfInclude_',_fileDefPresent_)
_fileDefPresent_ equate(1)

PersonFile         FILE,DRIVER('MSSQL','/IGNORETRUNCATION=TRUE /LOGONSCREEN=FALSE /TURBOSQL=TRUE /VERIFYVIASELECT=FALSE'),OWNER('dennis-ltsag\srv_3_1_18,AdventureWorks2019,'),NAME('Person.Person'),PRE(Per),BINDABLE,THREAD !                     
PK_Person_BusinessEntityID KEY(Per:BusinessEntityID),PRIMARY !                     
Record                   RECORD
person                      like(personGroup)
                               end
                        end


!PersonFile              FILE,DRIVER('MSSQL','/IGNORETRUNCATION=TRUE /LOGONSCREEN=FALSE /TURBOSQL=TRUE'),OWNER('dennis-ltsag\srv_3_1_18,AdventureWorks2019,'),NAME('Person.Person'),PRE(Per),BINDABLE,THREAD !                     
!FK_Person_BusinessEntity_BusinessEntityID KEY(Per:BusinessEntityID) !                     
!IX_Person_LastName_FirstName_MiddleName KEY(Per:LastName,Per:FirstName,Per:MiddleName),DUP,NOCASE !                     
!AK_Person_rowguid        KEY(Per:rowguid)                  !                     
!PK_Person_BusinessEntityID KEY(Per:BusinessEntityID),PRIMARY !                     
!AdditionalContactInfo       BLOB                           !                     
!Demographics                BLOB                           !                     
!Record                   RECORD,PRE()
!BusinessEntityID            LONG                           !                     
!PersonType                  STRING(3)                      !                     s
!NameStyle                   BYTE                           !                     
!Title                       STRING(10)                     !                     
!FirstName                   STRING(50)                     !                     
!MiddleName                  STRING(50)                     !                     
!LastName                    STRING(50)                     !                     
!Suffix                      CSTRING(11)                    !                     
!EmailPromotion              LONG                           !                     
!rowguid                     CSTRING(37),NAME('rowguid | READONLY') !                     
!ModifiedDate                STRING(8)                      !                     
!ModifiedDate_GROUP          GROUP,OVER(ModifiedDate)       !                     
!ModifiedDate_DATE             DATE                         !                     
!ModifiedDate_TIME             TIME                         !                     
!                            END                            !                     
!                         END
!                     END 

_EndOfInclude_