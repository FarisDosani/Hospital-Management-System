; ====================================================================================
; Project Title: Hospital Management System (Mixed Mode)
; Authors: Group (Zaid, Faris, Ali)
; ====================================================================================

INCLUDE Irvine32.inc

MAX_PATIENTS = 20
MAX_DOCTORS = 10
STR_LIMIT = 50           
MAX_DOC_PATIENTS = 3     
BUFFER_SIZE = 5000       

.data
    ; ===============================
    ; UI STRINGS
    ; ===============================
    strTitle        BYTE "===============================================", 0dh, 0ah
                    BYTE "      HOSPITAL MANAGEMENT SYSTEM (ASM)         ", 0dh, 0ah
                    BYTE "===============================================", 0
    
    ; Setup & Login Strings
    strSetupTitle   BYTE "--- SYSTEM SETUP: CREATE ADMIN ACCOUNT ---", 0
    strSetupUser    BYTE "Set New Username: ", 0
    strSetupPass    BYTE "Set New Password: ", 0
    strSetupDone    BYTE "Admin Account Created! Press any key to Login...", 0dh, 0ah, 0

    strLoginMsg     BYTE "--- ADMIN LOGIN ---", 0
    strUserPrompt   BYTE "Username: ", 0
    strPassPrompt   BYTE "Password: ", 0
    strAccessGranted BYTE "Access Granted! Welcome Admin.", 0dh, 0ah, 0
    strAccessDenied BYTE "Access Denied!", 0dh, 0ah, 0
    strTriesLeft    BYTE " Tries remaining: ", 0
    strMaxTries     BYTE "Maximum login attempts reached. Exiting Program.", 0dh, 0ah, 0
    strPressAny     BYTE "Press any key to continue...", 0
    
    ; File Messages
    strLoadMsg      BYTE "Loading Database (Patients/Doctors)...", 0dh, 0ah, 0
    strSaveMsg      BYTE "Saving Database (Patients/Doctors)...", 0dh, 0ah, 0

    ; Menu Strings
    strMenu         BYTE 0dh, 0ah, "--- MAIN MENU ---", 0dh, 0ah
                    BYTE "1. Add New Patient", 0dh, 0ah
                    BYTE "2. Add New Doctor", 0dh, 0ah
                    BYTE "3. View All Patients", 0dh, 0ah
                    BYTE "4. View All Doctors", 0dh, 0ah
                    BYTE "5. Search Patient by ID", 0dh, 0ah
                    BYTE "6. Assign Doctor to Patient (Appointment)", 0dh, 0ah
                    BYTE "7. View Hospital Report", 0dh, 0ah
                    BYTE "8. Exit (Save & Quit)", 0dh, 0ah
                    BYTE "Choose option: ", 0

    ; Data Entry Prompts
    strEnterID      BYTE "Enter ID (Numeric, 0 to Cancel): ", 0
    strEnterName    BYTE "Enter Name: ", 0
    strEnterAge     BYTE "Enter Age: ", 0
    strEnterDis     BYTE "Enter Disease: ", 0
    strEnterSpec    BYTE "Enter Specialization: ", 0
    strFullError    BYTE "Error: Database is full!", 0
    strDupError     BYTE "Error: ID already exists! Please enter a unique ID.", 0dh, 0ah, 0
    strCancelMsg    BYTE "Operation Cancelled by User.", 0dh, 0ah, 0
    strSuccess      BYTE "Record added successfully!", 0
    strNotFound     BYTE "Record not found.", 0
    strAssignPromptP BYTE "Enter Patient ID to assign (0 to Cancel): ", 0
    strAssignPromptD BYTE "Enter Doctor ID to assign (0 to Cancel): ", 0
    strAssignOk     BYTE "Appointment Assigned Successfully!", 0
    strDocFull      BYTE "Error: This Doctor is fully booked (Max 3 Patients)!", 0
    strDash         BYTE "-----------------------------------------------", 0
    strListP        BYTE "--- PATIENT LIST ---", 0
    strListD        BYTE "--- DOCTOR LIST ---", 0
    strAssignedTo   BYTE "Assigned to Dr ID: ", 0
    strDocNamePre   BYTE " - Dr. ", 0  
    strPatCountMsg  BYTE " [Current Patients: ", 0
    strCloseBrac    BYTE "]", 0
    strNone         BYTE "None", 0

    ; ===============================
    ; ADMIN CREDENTIALS (Runtime Only)
    ; ===============================
    sysUser         BYTE 50 DUP(0) 
    sysPass         BYTE 50 DUP(0)
    inputUser       BYTE 50 DUP(0)
    inputPass       BYTE 50 DUP(0)

    ; ===============================
    ; DATABASE ARRAYS 
    ; ===============================
    ; --- PATIENT DATA ---
    pCount          DWORD 0
    pIDs            DWORD MAX_PATIENTS DUP(0)
    pAges           DWORD MAX_PATIENTS DUP(0)
    pNames          BYTE  MAX_PATIENTS * STR_LIMIT DUP(0)
    pDisease        BYTE  MAX_PATIENTS * STR_LIMIT DUP(0)
    pDocID          DWORD MAX_PATIENTS DUP(-1)

    ; --- DOCTOR DATA ---
    dCount          DWORD 0
    dIDs            DWORD MAX_DOCTORS DUP(0)
    dNames          BYTE  MAX_DOCTORS * STR_LIMIT DUP(0)
    dSpec           BYTE  MAX_DOCTORS * STR_LIMIT DUP(0)
    dPatientCount   DWORD MAX_DOCTORS DUP(0)

    ; ===============================
    ; FILING VARIABLES (Only for DB)
    ; ===============================
    filePat         BYTE "patients.txt", 0
    fileDoc         BYTE "doctors.txt", 0
    fileHandle      DWORD ?
    
    ; Buffers for I/O
    newLineStr      BYTE 0Dh, 0Ah, 0
    tempStr         BYTE STR_LIMIT DUP(0)
    charBuf         BYTE 1 DUP(?)        
    bytesRead       DWORD ?

.code

; ====================================================================================
; MAIN PROCEDURE
; ====================================================================================
main PROC
    call Clrscr
    mov edx, OFFSET strTitle
    call WriteString
    call Crlf

    ; 1. Load Patients and Doctors (No Admin)
    mov edx, OFFSET strLoadMsg
    call WriteString
    call LoadAllData
    call Crlf

    ; 2. Always Run Setup (Old Approach)
    call AdminSetup

    ; 3. Perform Login
    call AdminLogin
    cmp eax, 0          
    je QuitProgram      

    ; 4. Main Menu Loop
MenuLoop:
    call Clrscr
    mov edx, OFFSET strTitle
    call WriteString
    
    mov edx, OFFSET strMenu
    call WriteString
    
    call ReadInt
    
    cmp eax, 1
    je  CallAddPatient
    cmp eax, 2
    je  CallAddDoctor
    cmp eax, 3
    je  CallViewPatients
    cmp eax, 4
    je  CallViewDoctors
    cmp eax, 5
    je  CallSearchPatient
    cmp eax, 6
    je  CallAssignAppt
    cmp eax, 7
    je  CallReport
    cmp eax, 8
    je  QuitProgram     
    jmp MenuLoop

CallAddPatient:
    call AddPatient
    jmp PauseScreen
CallAddDoctor:
    call AddDoctor
    jmp PauseScreen
CallViewPatients:
    call ViewPatients
    jmp PauseScreen
CallViewDoctors:
    call ViewDoctors
    jmp PauseScreen
CallSearchPatient:
    call SearchPatient
    jmp PauseScreen
CallAssignAppt:
    call AssignDoctor
    jmp PauseScreen
CallReport:
    call GenerateReport
    jmp PauseScreen

PauseScreen:
    call Crlf
    mov edx, OFFSET strPressAny
    call WriteString
    call ReadChar
    jmp MenuLoop

QuitProgram:
    call Clrscr
    mov edx, OFFSET strSaveMsg
    call WriteString
    call SaveAllData
    exit
main ENDP

; ====================================================================================
; FILING PROCEDURES (Only Patients/Doctors)
; ====================================================================================

; --------------------------------------------------------
; SaveAllData
; --------------------------------------------------------
SaveAllData PROC
    ; --- NO ADMIN SAVING HERE ---

    ; 1. SAVE PATIENTS
    mov edx, OFFSET filePat
    call CreateOutputFile
    mov fileHandle, eax

    mov eax, pCount
    call WriteNumToFile

    cmp pCount, 0
    je EndSaveP
    mov ecx, pCount
    mov esi, 0
SaveLoopP:
    push ecx
    push esi
    
    mov eax, pIDs[esi*4]
    call WriteNumToFile

    mov eax, esi
    mov ebx, STR_LIMIT
    mul ebx
    mov edx, OFFSET pNames
    add edx, eax
    call WriteStrToFile

    mov eax, pAges[esi*4]
    call WriteNumToFile

    mov eax, esi
    mov ebx, STR_LIMIT
    mul ebx
    mov edx, OFFSET pDisease
    add edx, eax
    call WriteStrToFile

    mov eax, pDocID[esi*4]
    call WriteNumToFile

    pop esi
    pop ecx
    inc esi
    
    ; FIX: Using DEC/JNZ
    dec ecx
    jnz SaveLoopP
    
EndSaveP:
    mov eax, fileHandle
    call CloseFile

    ; 2. SAVE DOCTORS
    mov edx, OFFSET fileDoc
    call CreateOutputFile
    mov fileHandle, eax

    mov eax, dCount
    call WriteNumToFile

    cmp dCount, 0
    je EndSaveD
    mov ecx, dCount
    mov esi, 0
SaveLoopD:
    push ecx
    push esi

    mov eax, dIDs[esi*4]
    call WriteNumToFile

    mov eax, esi
    mov ebx, STR_LIMIT
    mul ebx
    mov edx, OFFSET dNames
    add edx, eax
    call WriteStrToFile

    mov eax, esi
    mov ebx, STR_LIMIT
    mul ebx
    mov edx, OFFSET dSpec
    add edx, eax
    call WriteStrToFile

    mov eax, dPatientCount[esi*4]
    call WriteNumToFile

    pop esi
    pop ecx
    inc esi
    
    ; FIX: Using DEC/JNZ
    dec ecx
    jnz SaveLoopD

EndSaveD:
    mov eax, fileHandle
    call CloseFile
    ret
SaveAllData ENDP

; --------------------------------------------------------
; LoadAllData
; --------------------------------------------------------
LoadAllData PROC
    ; --- NO ADMIN LOADING HERE ---

LoadPatients:
    ; 1. LOAD PATIENTS
    mov edx, OFFSET filePat
    call OpenInputFile
    cmp eax, INVALID_HANDLE_VALUE
    je LoadDoctors          
    mov fileHandle, eax

    mov edx, OFFSET tempStr
    mov ecx, STR_LIMIT
    call ReadStringFromFile
    mov edx, OFFSET tempStr
    call ParseDecimal32
    mov pCount, eax

    cmp pCount, 0
    je CloseLoadP

    mov ecx, pCount
    mov esi, 0
LoadLoopP:
    push ecx
    push esi
    
    ; ID
    mov edx, OFFSET tempStr
    mov ecx, STR_LIMIT
    call ReadStringFromFile
    mov edx, OFFSET tempStr
    call ParseDecimal32
    mov pIDs[esi*4], eax

    ; Name
    mov eax, esi
    mov ebx, STR_LIMIT
    mul ebx
    mov edx, OFFSET pNames
    add edx, eax
    mov ecx, STR_LIMIT
    call ReadStringFromFile

    ; Age
    mov edx, OFFSET tempStr
    mov ecx, STR_LIMIT
    call ReadStringFromFile
    mov edx, OFFSET tempStr
    call ParseDecimal32
    mov pAges[esi*4], eax

    ; Disease
    mov eax, esi
    mov ebx, STR_LIMIT
    mul ebx
    mov edx, OFFSET pDisease
    add edx, eax
    mov ecx, STR_LIMIT
    call ReadStringFromFile

    ; DocID
    mov edx, OFFSET tempStr
    mov ecx, STR_LIMIT
    call ReadStringFromFile
    mov edx, OFFSET tempStr
    call ParseInteger32      ; FIX: Signed integer
    mov pDocID[esi*4], eax

    pop esi
    pop ecx
    inc esi
    
    ; FIX: Jump too far solution
    dec ecx
    jnz LoadLoopP

CloseLoadP:
    mov eax, fileHandle
    call CloseFile

LoadDoctors:
    ; 2. LOAD DOCTORS
    mov edx, OFFSET fileDoc
    call OpenInputFile
    cmp eax, INVALID_HANDLE_VALUE
    je EndLoad
    mov fileHandle, eax

    mov edx, OFFSET tempStr
    mov ecx, STR_LIMIT
    call ReadStringFromFile
    mov edx, OFFSET tempStr
    call ParseDecimal32
    mov dCount, eax

    cmp dCount, 0
    je CloseLoadD

    mov ecx, dCount
    mov esi, 0
LoadLoopD:
    push ecx
    push esi

    ; ID
    mov edx, OFFSET tempStr
    mov ecx, STR_LIMIT
    call ReadStringFromFile
    mov edx, OFFSET tempStr
    call ParseDecimal32
    mov dIDs[esi*4], eax

    ; Name
    mov eax, esi
    mov ebx, STR_LIMIT
    mul ebx
    mov edx, OFFSET dNames
    add edx, eax
    mov ecx, STR_LIMIT
    call ReadStringFromFile

    ; Spec
    mov eax, esi
    mov ebx, STR_LIMIT
    mul ebx
    mov edx, OFFSET dSpec
    add edx, eax
    mov ecx, STR_LIMIT
    call ReadStringFromFile

    ; PatientCount
    mov edx, OFFSET tempStr
    mov ecx, STR_LIMIT
    call ReadStringFromFile
    mov edx, OFFSET tempStr
    call ParseDecimal32
    mov dPatientCount[esi*4], eax

    pop esi
    pop ecx
    inc esi
    
    ; FIX: Jump too far solution
    dec ecx
    jnz LoadLoopD

CloseLoadD:
    mov eax, fileHandle
    call CloseFile

EndLoad:
    ret
LoadAllData ENDP

; --------------------------------------------------------
; HELPER: ReadStringFromFile
; --------------------------------------------------------
ReadStringFromFile PROC
    push edi
    push eax
    push ebx
    
    mov edi, edx          
    mov ebx, 0            

ReadCharLoop:
    mov eax, fileHandle
    mov edx, OFFSET charBuf
    mov ecx, 1
    call ReadFromFile
    cmp eax, 0            
    je EndReadStr

    mov al, charBuf
    cmp al, 0Dh           
    je IgnoreCR
    cmp al, 0Ah           
    je EndReadStr         

    mov [edi], al         
    inc edi
    inc ebx
    jmp ReadCharLoop

IgnoreCR:
    jmp ReadCharLoop      

EndReadStr:
    mov BYTE PTR [edi], 0 
    
    pop ebx
    pop eax
    pop edi
    ret
ReadStringFromFile ENDP

; --------------------------------------------------------
; HELPER: WriteStrToFile
; --------------------------------------------------------
WriteStrToFile PROC
    push eax
    push ecx
    
    push edx              
    INVOKE Str_length, edx
    mov ecx, eax          
    pop edx
    mov eax, fileHandle
    call WriteToFile      

    mov edx, OFFSET newLineStr
    mov ecx, 2
    mov eax, fileHandle
    call WriteToFile

    pop ecx
    pop eax
    ret
WriteStrToFile ENDP

; --------------------------------------------------------
; HELPER: WriteNumToFile
; --------------------------------------------------------
WriteNumToFile PROC
    push edx
    push ecx
    
    push eax
    push ebx
    push edi
    
    mov edi, OFFSET tempStr
    or eax, eax
    jns PosNum
    mov BYTE PTR [edi], '-'
    inc edi
    neg eax
PosNum:
    mov ebx, 10
    xor ecx, ecx
DivLoop:
    xor edx, edx
    div ebx
    push edx
    inc ecx
    test eax, eax
    jnz DivLoop
StoreLoop:
    pop eax
    add al, '0'
    mov [edi], al
    inc edi
    loop StoreLoop      
    mov BYTE PTR [edi], 0  

    pop edi
    pop ebx
    pop eax

    mov edx, OFFSET tempStr
    call WriteStrToFile

    pop ecx
    pop edx
    ret
WriteNumToFile ENDP

; ====================================================================================
; ADMIN LOGIN
; ====================================================================================
AdminLogin PROC
    mov ebx, 3           

LoginLoop:
    call Clrscr
    mov edx, OFFSET strLoginMsg
    call WriteString
    call Crlf

    cmp ebx, 3
    je GetInput
    mov edx, OFFSET strTriesLeft
    call WriteString
    mov eax, ebx
    call WriteDec
    call Crlf

GetInput:
    mov edx, OFFSET strUserPrompt
    call WriteString
    mov edx, OFFSET inputUser
    mov ecx, STR_LIMIT
    call ReadString

    mov edx, OFFSET strPassPrompt
    call WriteString
    mov edx, OFFSET inputPass
    mov ecx, STR_LIMIT
    call ReadString

    INVOKE Str_compare, ADDR inputUser, ADDR sysUser
    jne LoginFail
    INVOKE Str_compare, ADDR inputPass, ADDR sysPass
    jne LoginFail

    mov edx, OFFSET strAccessGranted
    call WriteString
    call WaitMsg
    mov eax, 1
    ret

LoginFail:
    mov edx, OFFSET strAccessDenied
    call WriteString
    call WaitMsg
    
    dec ebx
    cmp ebx, 0
    jne LoginLoop

    call Crlf
    mov edx, OFFSET strMaxTries
    call WriteString
    mov eax, 0
    ret
AdminLogin ENDP

; ====================================================================================
; ADMIN SETUP (Run every time - No Filing)
; ====================================================================================
AdminSetup PROC
    call Clrscr
    mov edx, OFFSET strSetupTitle
    call WriteString
    call Crlf
    call Crlf

    mov edx, OFFSET strSetupUser
    call WriteString
    mov edx, OFFSET sysUser
    mov ecx, STR_LIMIT
    call ReadString

    mov edx, OFFSET strSetupPass
    call WriteString
    mov edx, OFFSET sysPass
    mov ecx, STR_LIMIT
    call ReadString

    call Crlf
    mov edx, OFFSET strSetupDone
    call WriteString
    
    call ReadChar
    ret
AdminSetup ENDP

; ====================================================================================
; ADD PATIENT
; ====================================================================================
AddPatient PROC
    mov eax, pCount
    cmp eax, MAX_PATIENTS
    jae ListFull

    call Clrscr
    mov edx, OFFSET strListP
    call WriteString
    call Crlf

GetPID:
    mov edx, OFFSET strEnterID
    call WriteString
    call ReadInt
    
    cmp eax, 0
    je CancelOp

    push eax            
    call CheckDupPID    
    cmp eax, 1
    pop eax             
    je DuplicateMsg

    mov esi, pCount
    mov pIDs[esi*4], eax 

    mov edx, OFFSET strEnterName
    call WriteString
    mov eax, pCount
    mov ebx, STR_LIMIT
    mul ebx
    mov edx, OFFSET pNames
    add edx, eax
    mov ecx, STR_LIMIT
    call ReadString

    mov edx, OFFSET strEnterAge
    call WriteString
    call ReadInt
    mov esi, pCount
    mov pAges[esi*4], eax

    mov edx, OFFSET strEnterDis
    call WriteString
    mov eax, pCount
    mov ebx, STR_LIMIT
    mul ebx
    mov edx, OFFSET pDisease
    add edx, eax
    mov ecx, STR_LIMIT
    call ReadString

    mov esi, pCount
    mov pDocID[esi*4], -1

    inc pCount
    mov edx, OFFSET strSuccess
    call WriteString
    ret

DuplicateMsg:
    mov edx, OFFSET strDupError
    call WriteString
    jmp GetPID          

CancelOp:
    mov edx, OFFSET strCancelMsg
    call WriteString
    ret

ListFull:
    mov edx, OFFSET strFullError
    call WriteString
    ret
AddPatient ENDP

; ====================================================================================
; ADD DOCTOR
; ====================================================================================
AddDoctor PROC
    mov eax, dCount
    cmp eax, MAX_DOCTORS
    jae ListFull

    call Clrscr
    mov edx, OFFSET strListD
    call WriteString
    call Crlf

GetDID:
    mov edx, OFFSET strEnterID
    call WriteString
    call ReadInt
    
    cmp eax, 0
    je CancelOp

    push eax
    call CheckDupDID
    cmp eax, 1
    pop eax
    je DuplicateMsg

    mov esi, dCount
    mov dIDs[esi*4], eax

    mov edx, OFFSET strEnterName
    call WriteString
    mov eax, dCount
    mov ebx, STR_LIMIT
    mul ebx
    mov edx, OFFSET dNames
    add edx, eax
    mov ecx, STR_LIMIT
    call ReadString

    mov edx, OFFSET strEnterSpec
    call WriteString
    mov eax, dCount
    mov ebx, STR_LIMIT
    mul ebx
    mov edx, OFFSET dSpec
    add edx, eax
    mov ecx, STR_LIMIT
    call ReadString

    mov esi, dCount
    mov dPatientCount[esi*4], 0

    inc dCount
    mov edx, OFFSET strSuccess
    call WriteString
    ret

DuplicateMsg:
    mov edx, OFFSET strDupError
    call WriteString
    jmp GetDID

CancelOp:
    mov edx, OFFSET strCancelMsg
    call WriteString
    ret

ListFull:
    mov edx, OFFSET strFullError
    call WriteString
    ret
AddDoctor ENDP

; ====================================================================================
; HELPER: CHECK DUPLICATE PATIENT ID
; ====================================================================================
CheckDupPID PROC
    push ecx
    push esi
    push ebx
    
    mov ebx, eax         
    mov eax, 0           
    
    cmp pCount, 0
    je EndCheckP

    mov ecx, pCount
    mov esi, 0
ScanLoopP:
    cmp pIDs[esi*4], ebx
    je FoundDupP
    inc esi
    loop ScanLoopP
    jmp EndCheckP

FoundDupP:
    mov eax, 1

EndCheckP:
    pop ebx
    pop esi
    pop ecx
    ret
CheckDupPID ENDP

; ====================================================================================
; HELPER: CHECK DUPLICATE DOCTOR ID
; ====================================================================================
CheckDupDID PROC
    push ecx
    push esi
    push ebx
    
    mov ebx, eax
    mov eax, 0
    
    cmp dCount, 0
    je EndCheckD

    mov ecx, dCount
    mov esi, 0
ScanLoopD:
    cmp dIDs[esi*4], ebx
    je FoundDupD
    inc esi
    loop ScanLoopD
    jmp EndCheckD

FoundDupD:
    mov eax, 1

EndCheckD:
    pop ebx
    pop esi
    pop ecx
    ret
CheckDupDID ENDP

; ====================================================================================
; VIEW PATIENTS
; ====================================================================================
ViewPatients PROC
    call Clrscr
    mov edx, OFFSET strListP
    call WriteString
    call Crlf

    cmp pCount, 0
    je NoRecords

    mov ecx, pCount
    mov esi, 0

PrintPLoop:
    push ecx
    push esi

    mov edx, OFFSET strDash
    call WriteString
    call Crlf

    mov eax, pIDs[esi*4]
    call WriteDec
    mov al, ' '
    call WriteChar
    mov al, '-'
    call WriteChar
    mov al, ' '
    call WriteChar

    mov eax, esi
    mov ebx, STR_LIMIT
    mul ebx
    mov edx, OFFSET pNames
    add edx, eax
    call WriteString
    
    mov al, ' '
    call WriteChar
    mov al, '('
    call WriteChar
    mov eax, esi
    mov ebx, STR_LIMIT
    mul ebx
    mov edx, OFFSET pDisease
    add edx, eax
    call WriteString
    mov al, ')'
    call WriteChar
    call Crlf

    ; --- PRINT ASSIGNED DOCTOR INFO ---
    mov edx, OFFSET strAssignedTo
    call WriteString
    mov eax, pDocID[esi*4]
    cmp eax, -1
    je PrintNone
    
    call WriteDec   
    
    push ecx
    push esi
    push eax        
    
    mov ebx, eax    
    mov ecx, dCount
    mov esi, 0
    
FindDNameLoop:
    cmp ecx, 0
    je EndDNameSearch
    
    mov eax, dIDs[esi*4]
    cmp eax, ebx
    je FoundDName
    
    inc esi
    dec ecx
    jnz FindDNameLoop
    jmp EndDNameSearch

FoundDName:
    mov edx, OFFSET strDocNamePre
    call WriteString
    
    mov eax, esi
    push ebx        
    mov ebx, STR_LIMIT
    mul ebx
    pop ebx
    
    mov edx, OFFSET dNames
    add edx, eax
    call WriteString

EndDNameSearch:
    pop eax
    pop esi
    pop ecx
    ; ----------------------------------
    
    jmp EndPRec

PrintNone:
    mov edx, OFFSET strNone
    call WriteString

EndPRec:
    call Crlf
    pop esi
    pop ecx
    inc esi
    dec ecx
    jnz PrintPLoop
    ret

NoRecords:
    mov edx, OFFSET strNotFound
    call WriteString
    ret
ViewPatients ENDP

; ====================================================================================
; VIEW DOCTORS
; ====================================================================================
ViewDoctors PROC
    call Clrscr
    mov edx, OFFSET strListD
    call WriteString
    call Crlf

    cmp dCount, 0
    je NoRecords

    mov ecx, dCount
    mov esi, 0

PrintDLoop:
    push ecx
    push esi

    mov edx, OFFSET strDash
    call WriteString
    call Crlf

    ; ID
    mov eax, dIDs[esi*4]
    call WriteDec
    mov al, ' '
    call WriteChar
    
    ; Name
    mov eax, esi
    mov ebx, STR_LIMIT
    mul ebx
    mov edx, OFFSET dNames
    add edx, eax
    call WriteString

    ; Spec
    mov al, ' '
    call WriteChar
    mov al, '['
    call WriteChar
    mov eax, esi
    mov ebx, STR_LIMIT
    mul ebx
    mov edx, OFFSET dSpec
    add edx, eax
    call WriteString
    mov al, ']'
    call WriteChar
    
    ; Show Patient Count
    mov edx, OFFSET strPatCountMsg
    call WriteString
    mov eax, dPatientCount[esi*4]
    call WriteDec
    mov edx, OFFSET strCloseBrac
    call WriteString
    
    call Crlf

    pop esi
    pop ecx
    inc esi
    dec ecx
    jnz PrintDLoop
    ret

NoRecords:
    mov edx, OFFSET strNotFound
    call WriteString
    ret
ViewDoctors ENDP

; ====================================================================================
; SEARCH PATIENT
; ====================================================================================
SearchPatient PROC
    call Clrscr
    mov edx, OFFSET strEnterID
    call WriteString
    call ReadInt
    
    cmp eax, 0
    je CancelSearch

    mov ebx, eax
    mov ecx, pCount
    mov esi, 0

    cmp ecx, 0
    je NotFound

SearchLoop:
    mov eax, pIDs[esi*4]
    cmp eax, ebx
    je Found
    inc esi
    loop SearchLoop
    jmp NotFound

Found:
    call Crlf
    mov edx, OFFSET strListP
    call WriteString
    call Crlf
    
    mov edx, OFFSET strEnterName
    call WriteString
    mov eax, esi
    push ebx
    mov ebx, STR_LIMIT
    mul ebx
    pop ebx
    mov edx, OFFSET pNames
    add edx, eax
    call WriteString
    call Crlf
    
    mov edx, OFFSET strEnterDis
    call WriteString
    mov eax, esi
    push ebx
    mov ebx, STR_LIMIT
    mul ebx
    pop ebx
    mov edx, OFFSET pDisease
    add edx, eax
    call WriteString
    call Crlf
    ret

NotFound:
    mov edx, OFFSET strNotFound
    call WriteString
    ret

CancelSearch:
    mov edx, OFFSET strCancelMsg
    call WriteString
    ret
SearchPatient ENDP

; ====================================================================================
; ASSIGN DOCTOR TO PATIENT
; ====================================================================================
AssignDoctor PROC
    call ViewPatients
    call Crlf
    
    mov edx, OFFSET strAssignPromptP
    call WriteString
    call ReadInt

    cmp eax, 0
    je CancelAssign

    mov edi, eax
    mov ecx, pCount
    mov esi, 0
    mov ebx, -1 

    cmp ecx, 0
    je NotFound

FindPLoop:
    cmp pIDs[esi*4], edi
    je PFound
    inc esi
    loop FindPLoop
    jmp NotFound

PFound:
    mov ebx, esi        ; EBX = Patient Index

    call Crlf
    
    push ebx
    call ViewDoctors
    pop ebx
    
    mov edx, OFFSET strAssignPromptD
    call WriteString
    call ReadInt
    
    cmp eax, 0
    je CancelAssign

    mov edi, eax        ; EDI = Doctor ID

    mov ecx, dCount
    mov esi, 0

    cmp ecx, 0
    je NotFound

FindDLoop:
    cmp dIDs[esi*4], edi
    je DFound
    inc esi
    loop FindDLoop
    jmp NotFound

DFound:
    mov eax, dPatientCount[esi*4]
    cmp eax, MAX_DOC_PATIENTS
    jae DoctorFull

    mov pDocID[ebx*4], edi           
    inc dPatientCount[esi*4]         
    
    mov edx, OFFSET strAssignOk
    call WriteString
    ret

DoctorFull:
    call Crlf
    mov edx, OFFSET strDocFull
    call WriteString
    ret

NotFound:
    mov edx, OFFSET strNotFound
    call WriteString
    ret

CancelAssign:
    mov edx, OFFSET strCancelMsg
    call WriteString
    ret
AssignDoctor ENDP

; ====================================================================================
; GENERATE REPORT
; ====================================================================================
GenerateReport PROC
    call Clrscr
    mov edx, OFFSET strTitle
    call WriteString
    call Crlf
    
    mov edx, OFFSET strListP
    call WriteString
    mov eax, pCount
    call WriteDec
    call Crlf

    mov edx, OFFSET strListD
    call WriteString
    mov eax, dCount
    call WriteDec
    call Crlf
    
    mov edx, OFFSET strDash
    call WriteString
    call Crlf
    ret
GenerateReport ENDP

END main