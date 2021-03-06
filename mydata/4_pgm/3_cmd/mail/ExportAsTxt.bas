' Quoted from
' https://outlooklab.wordpress.com/2018/05/19/%e5%8f%97%e4%bf%a1%e3%81%97%e3%81%9f%e3%83%a1%e3%83%bc%e3%83%ab%e3%82%92%e8%87%aa%e5%8b%95%e7%9a%84%e3%81%ab-msg-%e3%83%95%e3%82%a1%e3%82%a4%e3%83%ab%e3%81%a8%e3%81%97%e3%81%a6%e4%bf%9d%e5%ad%98/
' https://outlooklab.wordpress.com/2011/10/22/%e5%8f%97%e4%bf%a1%e3%81%97%e3%81%9f%e3%83%a1%e3%83%bc%e3%83%ab%e3%82%92%e6%8c%af%e3%82%8a%e5%88%86%e3%81%91%e5%89%8d%e3%81%ab%e4%bf%9d%e5%ad%98%e3%81%99%e3%82%8b%e3%83%9e%e3%82%af%e3%83%ad/
' on 2019-11-10

Attribute VB_Name = "ExportAsTxt"
' Event on receiving 
Private Sub App_MailEx(ByVal EntryIDCollection As String)
    On Error Resume Next
    Dim objItem As Object
    Dim objMsg As MailItem
    ' Retrieve received messages
    Set objItem = Session.GetItemFromID(EntryIDCollection)
    ' Save if the item is e-mail
    If TypeName(objItem) = "MailItem" Then
        Set objMsg = objItem
        SaveAsTxt objMsg
    End If
End Sub

' Sub procedure saving as txt file
Public Sub SaveAsMsg(ByRef objMsg As MailItem)
    ' Directory path to save message files (Addition '\' at the end)
    Const PATH_SAVE = "Z:\mydata\1_doc\4_mail\"
    Dim objFSO As Object ' FileSystemObject
    Dim strDirPath As String
    Dim strMon As String
    Dim strDate As String
    Dim strTime As String
    Dim strSubject As String
    Dim strFileBase As String
    Dim strFileName As String
    Dim i As Integer
    Dim char As String
    Dim cnt As Integer
    
    Set objFSO = CreateObject("Scripting.FileSystemObject")

' Determine criteria
' For example; save for containing string "test" in subject,
' the otherwise end with `Exit Sub`
'
'    If Not (objMsg.Subject Like "*test*") Then Exit Sub

    strMon = Format(objMsg.ReceivedTime, "yyyymm")
    strDate = Format(objMsg.ReceivedTime, "yyyymmdd")
    strTime = Format(objMsg.ReceivedTime, "hhnn")

    strDirPath = PATH_SAVE
'    strDirPath = PATH_SAVE & strMon % "\"
'    If Dir(strDirPath) = "" Then
'        MkDir(strDirPath)
'    End If

    ' Set the file name into the subject
    strSubject = objMsg.Subject
    ' Addition the received time at the beginning of the subject
    ' strSubject = objMsg.ReceivedTime & " " & objMsg.Subject
    ' Addition the sender at the beginning of the subject
    ' strSubject = objMsg.SenderName & " " & objMsg.Subject
    ' Replace invalid characters into '_' in file path
    strFileBase = ""
    For i = 1 To Len(strSubject)
        char = Mid(strSubject, i, 1)
        If InStr("\/*<>", char) > 0 Then
            char = "_"
        End If
        If InStr("""", char) > 0 Then
            char = "'"
        End If
        If InStr(":,;?|", char) > 0 Then
            char = "."
        End If
        If InStr(vbTab, char) > 0 Then
            char = "    "
        End If
        strFileBase = strFileBase & char
    Next

    strFileBase = Left(strFileBase, 200)
    strFileName = strDirPath & strDate & "T" & strTime & "_" & strFileBase & ".txt"

    cnt = 1
    ' If the same path already exists
    While objFSO.FileExists(strFileName)
        ' Numbering
        strFileName = strDirPath & strDate & "T" & strTime & "_" & strFileBase & "-" & cnt & ".txt"
        cnt = cnt + 1
    Wend
    ' Save as TXT file
    objMsg.SaveAs strFileName, olTXT
    Set objFSO = Nothing
End Sub
