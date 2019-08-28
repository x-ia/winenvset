Attribute VB_Name "Module2"
' https://outlooklab.wordpress.com/2018/05/19/%e5%8f%97%e4%bf%a1%e3%81%97%e3%81%9f%e3%83%a1%e3%83%bc%e3%83%ab%e3%82%92%e8%87%aa%e5%8b%95%e7%9a%84%e3%81%ab-msg-%e3%83%95%e3%82%a1%e3%82%a4%e3%83%ab%e3%81%a8%e3%81%97%e3%81%a6%e4%bf%9d%e5%ad%98/
' https://outlooklab.wordpress.com/2011/10/22/%e5%8f%97%e4%bf%a1%e3%81%97%e3%81%9f%e3%83%a1%e3%83%bc%e3%83%ab%e3%82%92%e6%8c%af%e3%82%8a%e5%88%86%e3%81%91%e5%89%8d%e3%81%ab%e4%bf%9d%e5%ad%98%e3%81%99%e3%82%8b%e3%83%9e%e3%82%af%e3%83%ad/
Private Sub Application_NewMailEx(ByVal EntryIDCollection As String)
     On Error Resume Next
     Dim objItem As Object
     Dim objMsg As MailItem
     ' 受信アイテムを取得
     Set objItem = Session.GetItemFromID(EntryIDCollection)
     ' アイテムがメールだったら保存処理
     If TypeName(objItem) = "MailItem" Then
         Set objMsg = objItem
         ExportAsTxt objMsg
     End If
End Sub
  '
  ' MSG ファイルとして保存するサブ プロシージャ
Public Sub ExportAsTxt(ByRef objMsg As MailItem)
     ' ファイルを保存するフォルダーを指定。最後に \ が必要
     Const SAVE_PATH = "Z:\mydata\1_doc\4_mail\"
     Dim objFSO As Object ' FileSystemObject
     Dim strDirPath As String
     Dim strMon As String
     Dim strSubject As String
     Dim strFileBase As String
     Dim strFileName As String
     Dim i As Integer
     Dim ch As String
     Dim c As Integer
     '
     Set objFSO = CreateObject("Scripting.FileSystemObject")
'
' ここで条件指定
' 例えば、test という文字列を件名に含むものだけ保存する場合、
' 「test を件名に含まない場合に Exit Sub」というコードにする
'
'  If Not (objMsg.Subject Like "*test*") Then Exit Sub
'
  strMon = Format(objMsg.ReceivedTime, "yyyymm")
  strDate = Format(objMsg.ReceivedTime, "yyyymmdd")
  strTime = Format(objMsg.ReceivedTime, "hhnn")

  strDirPath = SAVE_PATH
'  strDirPath = SAVE_PATH & strMon & "\"
'  If Dir(strDirPath) = "" Then
'    MkDir (strDirPath)
'  End If

     ' 件名をファイル名にする
     strSubject = objMsg.Subject
     ' 件名の前に受信日時をつける場合は以下を使用
     ' strSubject = objMsg.ReceivedTime & " " & objMsg.Subject
     ' 件名の前に差出人をつける場合は以下を使用
     ' strSubject = objMsg.SenderName & " " & objMsg.Subject
     ' ファイル名に使用できない文字を _ に置き換える
     strFileBase = ""
     For i = 1 To Len(strSubject)
         ch = Mid(strSubject, i, 1)
         If InStr("\/*<>", ch) > 0 Then
             ch = "_"
         End If
         If InStr("""", ch) > 0 Then
             ch = "'"
         End If
         If InStr(":,;?|", ch) > 0 Then
             ch = "."
         End If
         If InStr(vbTab, ch) > 0 Then
             ch = "  "
         End If
         strFileBase = strFileBase & ch
     Next
     ' 
     strFileName = strDirPath & strDate & "T" & strTime & "_" & strFileBase & ".txt"
     '
     c = 1
     ' 同名のファイルが存在したら
     While objFSO.FileExists(strFileName)
         ' ファイル名に -連番 をつける
         strFileName = strDirPath & strDate & "T" & strTime & "_" & strFileBase & "-" & c & ".txt"
         c = c + 1
     Wend
     ' MSG ファイルとして保存する
     objMsg.SaveAs strFileName, olTXT
     Set objFSO = Nothing
End Sub
