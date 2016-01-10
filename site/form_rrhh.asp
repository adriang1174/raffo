<%@ CodePage=65001 Language="VBScript" %>
<% Option Explicit %>
<% On Error Resume Next
 ' CoffeeCup Flash Form Builder: Form Results Handler
 '
 ' This file is in charge of handling the form results
 ' posted from the CoffeeCup Flash Form Builder SWF.  
 ' It has several primary functions:
 '
 ' - Assure that the user is running the proper version of
 '   VBScript and has properly configured their server for
 '   CoffeeCup Flash Form Builder by uploading the provided
 '   files and assigning the appropriate server settings
 '   and permissions.
 ' - Upload a file if the 'Request.Form("Filedata")' variable is
 '   populated
 ' - If the Request.Form collection has been populated,
 '   process the form by:
 '   - Reading the config file provided in the 'Request.Form("xmlfile")'
 '     variable.
 '   - Saving the form data to a file if the 'CC_FB_SaveFile' constant
 '     has been populated.
 '   - Saving the form data to the database provided in 'CC_FB_DBAddress'
 '     if the 'CC_FB_DBAddress' constant is populated.
 '   - Emailing the form data to the form owner via the address provided
 '     in the 'Request.Form("_ALT_EMAIL")' variable or the 
 '     Request.Form("mailto")' variable if the 'Request.Form("_ALT_EMAIL")'
 '     variable is not populated.
 '   - Emailing the form data to the form user via the address provided in
 '     the 'Request.Form("eM")' variable if the 'Request.Form("eM")' variable 
 '     has been populated and the 'emailuser' config option is set to 'true'.
 '   - Taking the form user to the landing page provided in the
 '     'Request.Form("thankyoupage")' variable or to a default landing page
 '     if the 'Request.Form("thankyoupage")' is empty.
 ' - Prints out an informational page with version numbers and release
 '   dates if an error occurs or if this script is called without
 '   the 'Request.Form' Collection variable being set.
 '
 ' @license http://www.coffeecup.com/legal/eula.html  
 ' @author Jeff Welch <jw@coffeecup.com>
 ' @version 4.0
 ' @package CC_FB
 '
 
   '
   ' The version of CoffeeCup Flash Form Builder that
   ' generated this script.
   '
   Private Const CC_FB_Version = "8.0"
   '
   ' The release date of the version of CoffeeCup Flash Form
   ' Builder that generated this script.
   '
   Private Const CC_FB_LastUpdated = "08/31/2007"
   
   '
   ' The version of this script.
   '
   Private Const CC_FB_ScriptVersion = "5.0"
   '
   ' The release date of this script.
   '
   Private Const CC_FB_ScriptLastUpdated = "03/31/2009"

   '
   ' The required VBScript version for this script.
   '
   Private Const CC_FB_VBScriptVersion = 5
   
   '
   ' Will the owner of this form be emailed the 
   ' form data
   '
   Private Const CC_FB_DoEmail = true
   '
   ' To default To address.
   '   
   Private Const CC_FB_ToEmail = "luisraffo@laboratorioraffo.com"
   '
   ' The default CC address.
   '   
   Private Const CC_FB_CCEmail = ""
   '
   ' The default BCC address.
   '   
   Private Const CC_FB_BCCEmail = ""
   '
   ' The message to send to the form owner
   '  
   Dim CC_FB_OwnerMessage 
   CC_FB_OwnerMessage = "[FORMOWNERMSG]"
   '
   ' If we should send a message back to the user.
   '
   Private Const CC_FB_AutoReply = false
   '
   ' The subject of the message to be sent to the user.
   '  
   Private Const CC_FB_AutoReplySubject = ""
   '
   ' If we should include the form results 
   ' in the message we send to the user.
   '  
   Private Const CC_FB_AutoReplyFormResults = false
   '
   ' The position of the auto-reply message
   ' in the email.
   '  
   Private Const CC_FB_AutoReplyPosition = "bottom"
   
   '
   ' The page to redirect to after the form is submitted.
   '  
   Private Const CC_FB_ResultsRedirect = "http://www.laboratoriosraffo.com.ar/gracias.html"
   
   '
   ' The address of the database where the form results 
   ' will be saved.
   '
   Private Const CC_FB_DBAddress = "[ADDRESS]"
   '
   ' The port number of the database where the form results 
   ' will be saved.
   '
   Private Const CC_FB_DBPort = "[DBPORT]"   
   '
   ' The username for the database where the form results 
   ' will be saved.
   '
   Private Const CC_FB_DBUsername = "[DBUSER]"
   '
   ' The password for the database where the form results
   ' will be saved.
   '
   Private Const CC_FB_DBPassword = "[DBPASS]"
   '
   ' The name of the database where the form results
   ' will be saved.
   '
   Private Const CC_FB_DBName = "[DBNAME]"
   '
   ' The name of the database table where the form results
   ' will be saved.
   '
   Private Const CC_FB_DBTable = "[DBTABLE]"     
     
   '
   ' The address of the SMTP Server used for sending
   ' emails.
   '
   Private Const CC_FB_SMTPAddress = "[SMTPADDRESS]"
   '
   ' The port for the SMTP Server used for sending
   ' emails.
   '
   Private Const CC_FB_SMTPPort = "[SMTPPORT]"   
   '
   ' The user for the SMTP Server used for sending
   ' emails.
   '
   Private Const CC_FB_SMTPUsername = "[SMTPUSER]"
   '
   ' The password for the SMTP Server used for sending
   ' emails.
   '
   Private Const CC_FB_SMTPPassword = "[SMTPPASS]"
 
   '
   ' The file to log the form results to if necessary.
   '
   Private Const CC_FB_SaveFile = "[FILENAME]"

   '
   ' The filetypes that are acceptable for file uploads.
   '
   Private Const CC_FB_AcceptableFileTypes = "txt|gif|jpg|jpeg|zip|doc|png|pdf|rtf|html|docx|xsls"
   '
   ' The directory where files are uploaded
   '
   Private Const CC_FB_UploadsFolder = "files"   
   '
   ' The extension that gets added to file uploads
   '
   Private Const CC_FB_UploadsExtension = "_fbu"
   '
   ' Will we save the file uploads to the server
   '     
	 Private Const CC_FB_AttachmentSaveToServer = true
   '
   ' Will we save the file uploads to the db
   '
   Private Const CC_FB_AttachmentSaveToDB = false
   '
   ' Will we send the file upload as an attachment
   '
   Private Const CC_FB_AttachmentAddToEmail = false
   
   ' Makes sure that the user is using the required version
   ' of VBScript as specified by {@link CC_FB_VBScriptVersion}.   
   If ScriptEngineMajorVersion < CC_FB_VBscriptVersion Then
      printMessage "Invalid VBScript Version",_
         "We're sorry but CoffeeCup Flash Form Builder requires VBScript " & _
            " version " & CC_FB_VBscriptVersion & " or greater.  Please " & _
            "contact your server administrator."
   End If
   ' If the content type is mutipart, process the file upload
   Dim contentType  
   contentType = Request.ServerVariables("HTTP_Content_Type")
   If len(contentType) = 0 Then 
      contentType = Request.ServerVariables("CONTENT_TYPE")
   End If
	If LCase(Left(contentType, 19)) = "multipart/form-data" Then 
      processFileUpload   
   ' If the Request.Form collection is populated, process the
   ' form results.     
   ElseIf Request.Form.Count > 0 Then       
      ' we need this since asp wont let us override request.form("Uploaded_File")
      dim uploadedFile
      processMailForm 
   ' If all else fails, print out a blank page with version
   ' numbers and release dates.          
   End If
   printMessage "",""
   
   
   '
   ' Process the mail form results.
   '
   ' This method is in charge of processing the mail form which
   ' is posted from the CoffeeCup Flash Form Builder SWF.  This
   ' process includes:
   ' 
   ' - Retrieving the preferences from the included CoffeeCup Flash
   '   Form Builder XML preferences file.
   ' - Formats output for file output as well as for an email to
   '   the form user and the form owner as necesarry.
   ' - Writes output to a file and sends it to the form user and
   '   the form owner as necessary.
   ' - Writes form results to a database if necesarry.
   '
   Private Sub processMailForm()
      On Error Resume Next   
      
      Dim ownerEmailResponse, userEmailResponse, formResponse, txtFile, _
         item, preferences, FSO
      
      fixUploadedFileName
      
      Set preferences = getPreferences()

      For Each item In preferences("formFields")   
      
         If Trim(Request.Form(item)) <> "" Then
            ownerEmailResponse = ownerEmailResponse & item & ": " & _ 
               Request.Form(item) & VbCrLf & VbCrLf
            txtFile = txtFile & item & ": " & Request.Form(item) & "|"
            
            ' Make sure we aren't displaying hidden fields
            ' to end-users
            If preferences(item)("type") <> "hiddenfield" Then
               userEmailResponse = userEmailResponse & item & ": " & _ 
                  Request.Form(item) & VbCrLf & VbCrLf                  
               formResponse = formResponse & item & ": " & _ 
                  Request.Form(item) & "<br />" & VbCrLf         
            End If
         End If
         
      Next

      ' If a file was uploaded, add the appropriate data to the response
      ' fields
      If uploadedFile <> "" Then
         ownerEmailResponse = ownerEmailResponse & "Uploaded File: " & _
            uploadedFile
         userEmailResponse = userEmailResponse & "Uploaded File: " & _
            uploadedFile       
        
        formResponse = formResponse & "    Uploaded File: " & _
            uploadedFile & "<br />" & VbCrLf
        
        txtFile = txtFile & "Uploaded File: " & _
            uploadedFile & "|"
      End If
      
      sendResponseEmails ownerEmailResponse, userEmailResponse, preferences
      writeResponseToFile txtFile
      writeResponseToDatabase preferences
      
      ' Make sure we delete the file from the server if the user doesn't
      ' want it
      If Not CC_FB_AttachmentSaveToServer And _ 
         uploadedFile <> "" Then
         
         Set FSO = Server.CreateObject("Scripting.FileSystemObject")
         FSO.DeleteFile Server.MapPath(CC_FB_UploadsFolder) & "\" & _
            uploadedFile, true 
            
      End If
      
      printResponsePage formResponse, preferences
      
      Set preferences = Nothing
      Set FSO = nothing
   End Sub
   

   '
   ' Send response emails to the appropriate recipients.
   '
   ' Sends an email to the scripts owner as well as the end-user
   ' if appropriate.  If the sending of mail fails, an error
   ' message will be printed out to the screen.
   ' 
   ' @param string ownerEmailResponse the message to mail to the owner.
   ' @param string userEmailResponse the message to mail to the user.
   ' @param dictionary preferences the CoffeeCup Flash Form Builder Preferences.
   '
   Private Sub sendResponseEmails(ByRef ownerEmailResponse, _
      ByRef userEmailResponse, ByRef preferences)
      On Error Resume Next
            
      Dim mail, unreg
      Set mail = Server.CreateObject("CDO.Message")
      
      ' If we could not create a CDO.Message object, they are lacking
      ' CDOSYS which is required for e-mail functionality.
      If Err.Number <> 0 Then
         Err.Clear
         printMessage "Unable to Send E-Mail.", _
            "We're sorry but we were unable to send an email. " & _
               "Sending email requires CDOSYS, which we were unable to " & _
               "locate on your server.  Please contact your server " & _
               "administrator "
      End If 
      
      ' If the program is unregistered, add the unregistered message.
      If Request.Form("unreg") <> "" Then
         unreg = "------------------------" & VbCrLf & VbCrLf & _ 
            "This Form was sent to you using CoffeeCup " & _
            "Flash Form Builder." & VbCrLf & "Please tell a friend about " & _
            "us: http://www.coffeecup.com/form-builder/" & VbCrLf
      End If      
      
     ' Make sure the mail is unicode for internationality.          
      mail.Bodypart.ContentMediaType = "text/plain"
      mail.Bodypart.ContentTransferEncoding = "7bit"
      mail.Bodypart.Charset = "utf-8"      

      ' Configure SMTP options if provided
      If CC_FB_SMTPAddress <> "[SMTPADDRESS]" Then
         mail.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/" & _
            "configuration/sendusing") = 2
         mail.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/" & _
            "configuration/smtpserver") = CC_FB_SMTPAddress
         If CC_FB_SMTPPort <> "[SMTPPORT]" Then
            mail.Configuration.Fields.Item("http://schemas.microsoft.com/" & _
               "cdo/configuration/smtpserverport") = CC_FB_SMTPPort
         End If
         If CC_FB_SMTPUsername <> "[SMTPUSER]" Then
            mail.Configuration.Fields.Item("http://schemas.microsoft.com/" & _
               "cdo/configuration/smtpauthenticate") = 1
            mail.Configuration.Fields.Item("http://schemas.microsoft.com/" & _
               "cdo/configuration/sendusername") = CC_FB_SMTPUsername
            mail.Configuration.Fields.Item("http://schemas.microsoft.com/" & _
               "cdo/configuration/sendpassword") = CC_FB_SMTPPassword        
         End If
         mail.Configuration.Fields.Update
      End If
      
      ' Add an attachment is required
      If CC_FB_AttachmentAddToEmail And _
         uploadedFile <> "" Then
         mail.AddAttachment Server.MapPath(CC_FB_UploadsFolder) & "\" & _
            uploadedFile
      End If
      
      ' Use the alternative email if one is provided.
      If Request.Form("_ALT_EMAIL") <> "" Then
         mail.To = Request.Form("_ALT_EMAIL")
      Else
         mail.To = CC_FB_ToEmail
      End If
      
      ' Set a default subject if one is not provided.
      If Request.Form("subject") <> "" Then
         mail.Subject = parseMessage(Request.Form("subject"), preferences)
      Else
         mail.Subject = "Form Submission"
      End If    
   
      ' Set a default message if one is not provided.
      If CC_FB_OwnerMessage <> "[FORMOWNERMSG]" Then
         mail.TextBody = parseMessage(CC_FB_OwnerMessage, preferences)
      Else
         mail.TextBody = "Here is the information submitted to " & _
            Request.ServerVariables("SERVER_NAME") & _
               Request.ServerVariables("SCRIPT_NAME") & " from " & _
               Request.ServerVariables("REMOTE_ADDR") & " on " & _
               FormatDateTime(Date, 1) & " at " & Time & _
               VbCrLf & "------------------------" & VbCrLf & _
               ownerEmailResponse & unreg
      End If
                  
      ' If we collected the end-user's email
      If Request.Form("eM") <> "" Then

         ' Send a message to the form's owner with the end-user's email
         ' as the reply-to address.     
         If CC_FB_DoEmail Then   
            mail.From = Request.Form("eM")
            mail.Cc = CC_FB_CCEmail
            mail.Bcc = CC_FB_BCCEmail
            mail.Send
         End If
         
         ' If mail.Send threw an error, hault the script and notify
         ' the user.
         If Err.Number <> 0 Then
            Err.Clear

            mail.From = "CoffeeCup Flash Form Builder <formbuilder@" & _
               Request.ServerVariables("SERVER_NAME") & ">"
            mail.Send
            
            If Err.Number <> 0 Then 
            Err.Clear
               printMessage "Unable To Send E-Mail", _
                  "We're sorry but we were unable to send your e-mail. " & _
                     "If you are sure that you entered all your email " & _
                     "addresses properly, you should contact your server " & _
                     "administrator."
            End If
         End If
         
         ' If necesarry, send a message to the end-user as well.
         If CC_FB_AutoReply Then
            
            Dim formUserResponse
            
            formUserResponse = parseMessage("", preferences)
            
            If CC_FB_AutoReplyFormResults Then               
               If CC_FB_AutoReplyPosition = "top" Then
                  formUserResponse = formUserResponse & _ 
                     VbCrLf & VbCrLf & userEmailResponse
               Else
                  formUserResponse = userEmailResponse & _
                     VbCrLf & VbCrLf & formUserResponse
               End If
            End If

            mail.Attachments.DeleteAll
            mail.Subject =  parseMessage(CC_FB_AutoReplySubject, preferences)
            mail.TextBody = formUserResponse & unreg
            mail.From = mail.To
            mail.To = Request.Form("eM")
            mail.Cc = ""
            mail.Bcc = ""            
            mail.Send
            
            ' If mail.Send threw an error, try to send with different
            ' From: address
            If Err.Number <> 0 Then
               Err.Clear

               mail.From = Request.ServerVariables("SERVER_NAME") & " Form" &_
                  " <forms@" & Request.ServerVariables("SERVER_NAME") & ">"
               mail.Send
            
               If Err.Number <> 0 Then 
                  Err.Clear
               End If
            End If

         End If
      ' Send a message to the form's owner.
      ElseIf CC_FB_DoEmail Then
         mail.From = "CoffeeCup Flash Form Builder <formbuilder@" & _
            Request.ServerVariables("SERVER_NAME") & ">"  
            mail.Cc = CC_FB_CCEmail
            mail.Bcc = CC_FB_BCCEmail            
         mail.Send      

         ' If mail.Send threw an error, hault the script and notify
         ' the user.         
         If Err.Number <> 0 Then
            Err.Clear
            printMessage "Unable To Send E-Mail", _
               "We're sorry but we were unable to send your e-mail. " & _
                  "If you are sure that you entered all your email " & _
                  "addresses properly, you should contact your server " & _
                  "administrator."        
         End If
      End If

      Set mail = Nothing

   End Sub


   '
   ' Gets the real name of the file that was uploaded.
   '
   ' Since the file upload occurs in a different request,
   ' this method helps us resolve what the name of the 
   ' uploaded file was in case it was renamed.
   ' 
   Private Function parseMessage(ByRef message, ByRef preferences)
      On Error Resume Next

      Dim item, replaceWith
      parseMessage = message

      For Each item In preferences("formFields") 
      
         If preferences("formFields")(item)("type") = "checkbox" OR _
            preferences("formFields")(item)("type") = "radiobutton" Then
            
            If Request.Form(item) <> "" Then         
               replaceWith = preferences("formFields")(item)("label")
            Else
               replaceWith = ""
            End If
               
         Else
            replaceWith = Request.Form(item)
         End If
         
         parseMessage = Replace(parseMessage, "[" & item & "]", replaceWith)         
         
      Next

   End Function
   
   
   '
   ' Gets the real name of the file that was uploaded.
   '
   ' Since the file upload occurs in a different request,
   ' this method helps us resolve what the name of the 
   ' uploaded file was in case it was renamed.
   ' 
   Private Sub fixUploadedFileName()
      On Error Resume Next
      
      Dim newUploadName, FSO, extension, basename, folder, i
      
      If Request.Form("Uploaded File") <> "" Then
         
         Set FSO = Server.CreateObject("Scripting.FileSystemObject")

         folder = Server.MapPath(CC_FB_UploadsFolder)
         basename = FSO.GetBaseName(Request.Form("Uploaded File"))
         extension = "." & FSO.GetExtensionName(Request.Form("Uploaded File"))
                     
         While FSO.FileExists(folder & "\" & basename & _
            CC_FB_UploadsExtension & i & extension)
            newUploadName = basename & CC_FB_UploadsExtension & i & extension
            i = i + 1            
         Wend
         
      End If
      uploadedFile = newUploadName
      
      Set FSO = Nothing
      
   End Sub
   
   
   '
   ' Write form response to a database.
   '
   ' Writes the form response to the database specified at 'CC_FB_DBAddress'
   ' if appropriate.  If the database doesn't it exist, the 'CC_FB_DBTable'
   ' table doesn't exist or if the 'CC_FB_DBTable' table doesn't comply with
   ' the structure of the current form then the database will be restructured
   ' accordingly.
   ' 
   ' @param dictionary preferences the CoffeeCup Flash Form Builder Preferences.
   '    
   Private Sub writeResponseToDatabase(ByRef preferences)
      On Error Resume Next
      
      Dim connection, command, results
      Dim result, columns, column, query, field, i, parameters, bound
            
      ' If the CC_FB_DbAddress constant has been populated, then
      ' the user wants to write their data to a database.      
      If CC_FB_DBAddress <> "[ADDRESS]" Then
         
         ' Firstly, lets make sure we can access ADODB.
         Set connection = Server.CreateObject("ADODB.Connection")
         
         If Err.Number <> 0 Then
            Err.Clear
            printMessage "Unable to Connect to Database Server.", _
               "We're sorry but we were unable to connect to your " & _
                  "database server.  Saving to a database requires ADODB, " & _
                  "which we were unable to locate on your server.  " & _
                  "Please contact your server administrator."             
         End If         
         
         connection.Open "Driver={MySQL ODBC 3.51 Driver};" & _
            "Server=" & CC_FB_DBAddress & ";" & _
               "Port=" & CC_FB_DBPort & ";" & _
               "Uid=" & CC_FB_DBUsername & ";" & _
               "Pwd=" & CC_FB_DBPassword & ";"

         If Err.Number <> 0 Then
            ' If the error description mentions a driver, let the user
            ' know they are missing the mysql driver
            If InStr(Err.Description, "driver") Then
               Err.Clear
               printMessage "Unable to Connect to Database Server.", _
                  "We're sorry but we were unable to connect to your " & _
                     "database server.  Saving to a database requires " & _
                     "the ""MySQL ODBC 3.51 Driver"" which we were unable " & _
                     "to locate on your server.  Please contact your " & _
                     "administrator."               
            ' Otherwise Let the user know they have entered incorrect
            ' credentials
            Else
               Err.Clear
               printMessage "Unable to Connect to Database Server.", _
                  "We're sorry but we were unable to connect to your " & _
                     "database server. Please be sure you have entered " &_
                     "your database settings correctly."                 
            End If             
         End If
         
         ' Attempt to make a connection to the specified DB
         Set command = Server.CreateObject("ADODB.Command") 
         
         command.ActiveConnection = connection
         command.CommandText = "USE `" & CC_FB_DBName & "`"
         command.Execute

         ' If we can't select their DB, lets try to create our own.         
         If Err.Number <> 0 Then
            Err.Clear

            command.CommandText = "CREATE DATABASE `" & CC_FB_DBName  & "`"
            command.Execute

            ' If we can't create or own, let the user know            
            If Err.Number <> 0 Then
               connection.Close
               Err.Clear
               printMessage "Unable to Create Database.", _
                  "We're sorry but we were unable to create your database. " & _
                     "If you believe the database already exists, please " & _
                     "be sure that you have the proper permissions to " & _
                     "select it.  Otherwise, please be sure that you " & _
                     "have permissions to create databases.  If you " & _
                     "are still experiencing troubles, please contact " & _
                     "your server administrator."     
            ' If we could create our own, try selecting it now
            Else
               command.CommandText = "USE `" & CC_FB_DBName & "`"
               command.Execute      
               
               ' If we still can't select the DB, let the user know
               If Err.Number <> 0 Then
                  connection.Close
                  Err.Clear
                  printMessage "Unable to select Database.", _
                     "We're sorry but we were unable to select your " & _
                        "database. Please be sure that you have the proper " & _
                        "permissions to select it.  If you are still " & _
                        "experiencing trouble, please contact your " & _
                        "server administrator."                
               End If 
            End If
         End If
         
         command.CommandText = "SHOW TABLES LIKE '" & CC_FB_DBTable & "'"
         Set results = command.Execute

         ' If a form_results table exists, make sure it is in the
         ' proper format.
         If Not (results.EOF Or results.BOF) Then
            results.Close
            
            command.CommandText = "SHOW COLUMNS FROM `" & CC_FB_DBTable & "`"
            Set results = command.Execute
                        
            ' If for some reason we can't querty the DB, let the user know
            If results.EOF And results.BOF Then
               results.Close
               connection.Close
               printMessage "Unable to Query Database.", _
                  "We're sorry but we were unable to query your database " & _
                     "table. Please be sure that you have the proper " & _
                        "permissions to select from the " & CC_FB_DBTable & _
                        " table. If you are still experiencing trouble, " & _
                        "please contact your server administrator."
            End If
            
            Set columns = Server.CreateObject("Scripting.Dictionary") 
            ' Populate the columns collection with the columns of the
            ' 'CC_FB_DBTable' table
            Do Until results.EOF
               If results.Fields.Item("Field") <> "id" And _
                  results.Fields.Item("Field") <> "created_at" Then
                  Set column = Server.CreateObject("Scripting.Dictionary")
                  column.Add "Field", CStr(results.Fields.Item("Field"))
                  column.Add "Type", CStr(results.Fields.Item("Type"))                  
                  columns.Add CStr(results.Fields.Item("Field")), column
               End If
               results.MoveNext
            Loop
                 
            results.Close

            ' If the fields from our form don't match the fields from
            ' the 'CC_FB_DBTable' table, archive the old table and
            ' create a new one corresponding to the current form
            If Not formFieldsEqualsTableFields(preferences("formFields"), _
               columns) Then
               archiveOldTable command
               createTableFromFormFields preferences("formFields"), command
            End If
         ' Otherwise create the 'CC_FB_DBTable' table in the proper format.  
         Else
            createTableFromFormFields preferences("formFields"), command
         End If
         
         parameters = Array()
         
         ' If all went well, lets attempt to write the form results to
         ' the database.
         For Each field In preferences("formFields")
            query = query & "`" & field & "` = ?, "
            bound = UBound(parameters) + 1
            Redim Preserve parameters(bound)
            
            If request.form(field) = "" Then
               parameters(bound) = ""
            Else
               parameters(bound) = Request.Form(field)
            End If
         Next         
         
         ' Add the uploaded file to the query if necessary
         If CC_FB_AttachmentSaveToDB Then
            If uploadedFile <> "" Then
               Dim textStream, filepath, contents
            
               filepath = Server.MapPath(CC_FB_UploadsFolder) & "\" & _
                  uploadedFile
            
               Set textStream = Server.CreateObject("ADODB.Stream")
               textStream.Open
               textStream.Type = 1
               textStream.LoadFromFile filepath
            
               If Err.Number <> 0 Then
                  printMessage "Unable To Open Attachment File", _
                     "We're sorry but we were unable to open your uploaded " & _
                     "file to attatch it for email. Please be sure that " & _
                     "you have the proper permissions."
               End If
            
               query = query & "`uploaded_file_name` = ?,`uploaded_file` = ?,"
            
               bound = UBound(parameters) + 2
               Redim Preserve parameters(bound)
               parameters(bound - 1) = uploadedFile
               parameters(bound) = textStream.read
            
               textStream.Close
               Set textStream = Nothing
            Else
               query = query & "`uploaded_file_name` = '',`uploaded_file` = '',"            
            End If
         End If
         
         command.CommandText = "INSERT INTO `" & CC_FB_DBTable & "` SET " & _
            query & "`created_at` = NOW()"
         command.Execute ,parameters

         ' If we couldn't write to the database, notify the user.
         If Err.Number <> 0 Then
            connection.Close  
            Err.Clear
            printMessage "Unable to Insert Into Database Table.", _ 
               "We're sorry but we were unable to insert the form results " & _
                  "into your database table. Please be sure that you have " & _
                   "the proper permissions to insert data into the " & _
                   CC_FB_DBTable & " table. If you are still experiencing " & _
                   "trouble, please contact your server administrator."                   
         End If
         connection.Close          
      End If
      
      Set connection = Nothing
      Set command = Nothing
      Set results = Nothing
      Set columns = Nothing  
      
   End Sub


   '
   ' Archives an old 'CC_FB_DBTable' table.
   '
   ' Renames a form results table to 'CC_FB_DBTable'_old or 
   ' 'CC_FB_DBTable'_old with a numerical value on the end of it 
   ' if appropriate.
   ' 
   ' @param ADO Command Object command a database abstraction 
   '  
   Private Sub archiveOldTable(ByRef command)
      On Error Resume Next   
      Dim i, results
      
      command.CommandText = "SHOW TABLES LIKE '" & CC_FB_DBTable & "_old'"
      set results = command.Execute
      
      Do Until results.EOF And results.BOF
         i = i + 1
         command.CommandText = "SHOW TABLES LIKE '" & CC_FB_DBTable & _
            "_old" & i & "'"
         set results = command.Execute
      Loop
         
      command.CommandText = "RENAME TABLE `" & CC_FB_DBTable & "` TO `" & _
         CC_FB_DBTable & "_old" & i & "`"
      command.Execute()
      
      If Err.Number <> 0 Then
         Err.Clear
         printMessage "Unable to Rename Database Table.", _
            "We're sorry but we were unable to rename your database " & _
               "table. Please be sure that you have the proper " & _
               "permissions to rename the " & CC_FB_DBTable & " table. If " & _
               "you are still experiencing trouble, please contact your " & _
               "server administrator."
      End If 
      
      Set results = Nothing
      
   End Sub

   '
   ' Checks if the columns from a table match the the structure
   ' of the fields from a form.
   ' 
   ' @param array form_fields the structure from the form
   ' @param array table_fields the structure from the table
   ' @return boolean value, true if the structures are the same,
   ' false if the structures are not.
   '      
   Private Function formFieldsEqualsTableFields(ByRef formFields, _
      ByRef tableFields)
      On Error Resume Next
      Dim Field, f
      
      ' Make sure we have the proper fields for saving uploaded
      ' files to the database if the user has requested we do so
      If CC_FB_AttachmentSaveToDB Then
         If tableFields.Exists("uploaded_file") And _
            tableFields.Exists("uploaded_file_name") Then
            tableFields.Remove("uploaded_file")
            tableFields.Remove("uploaded_file_name")
         Else
            formFieldsEqualsTableFields = False            
            Exit Function
         End If
      End If      
      
      If formFields.Count <> tableFields.Count Then
         formFieldsEqualsTableFields = False
         Exit Function
      End If
      
      For Each field In formFields
         If Not tableFields.Exists(field) OR _
            Not ((formFields(field)("type") = "textarea" AND _
              tableFields(field)("Type") = "text") OR _
              tableFields(field)("Type") = "varchar(255)") Then              
            formFieldsEqualsTableFields = False            
            Exit Function
         End If
      Next
      
      formFieldsEqualsTableFields = True
   End Function


   '
   ' Create a MySQL table from the form structure.
   '
   ' Uses the structure of the form, pulled from the XML preferences
   ' file to create a database table to store the form results.
   ' 
   ' @param dictionary formFields the structure of the form    
   ' @param ADO Command Object command a database abstraction
   '      
   Private Sub createTableFromFormFields(ByRef formFields, ByRef command)
      On Error Resume Next
      Dim field
      
      command.CommandText = "DROP TABLE IF EXISTS `" & CC_FB_DBTable & "`"
      command.Execute()
      
      command.CommandText = "CREATE TABLE `" & CC_FB_DBTable & "` (" & _
         "`id` int(11) NOT NULL auto_increment," & _
         "`created_at` DATETIME NOT NULL"     
         
      If CC_FB_AttachmentSaveToDB Then
         command.CommandText = command.CommandText & _
            ",`uploaded_file_name` varchar(255) NOT NULL DEFAULT ''" & _
            ",`uploaded_file` MEDIUMBLOB NOT NULL"
      End If
                      
      For Each field In formFields
         ' Make sure we don't try to create a table with column names
         ' that exceed the MySQL maximum column identifier length.
         If Len(field) > 64 Then 
            printMessage "Unable to Create Table.", "We're sorry but we " & _
               "were unable to create a database table for your form " & _
                  "results.  Unfortunately, MySQL does not permit field " & _
                  "names longer than 64 characters.  In order to utilize " & _
                  "MySQL for this form, you will first have to limit the " & _
                  """" & field & """ field to 64 characters."
         End If      
      
         command.CommandText = command.CommandText & ", `" & field & "` "
         If formFields(field)("type") = "textarea" Then
            command.CommandText = command.CommandText & "text"    
         Else
            command.CommandText = command.CommandText & "varchar(255) " & _
               "DEFAULT ''"       
         End If
         command.CommandText = command.CommandText & " NOT NULL "
      Next
         
      command.CommandText = command.CommandText & ", PRIMARY KEY(`id`))"
      command.Execute()
      
      If Err.Number <> 0 Then
         Err.Clear
         printMessage "Unable to Create Table.", "We're sorry but we were " & _
            "unable to create a database table for your form results. " & _
               "Please be sure that you have the proper permissions to " & _
               "create tables. If you are still experiencing trouble, " & _
               "please contact your server administrator."
      End If
   End Sub

   
   '
   ' Write form response to a log file.
   '
   ' Writes the form response to the log file specified at 'CC_FB_SaveFile'
   ' if appropriate.  If the file writing fails, an error message will be 
   ' printed out to the screen.
   ' 
   ' @param string txtFile the response to write to the log file.
   '  
   Private Sub writeResponseToFile(ByRef txtFile)
      On Error Resume Next
      Dim FSO, filePath, textStream
      
      txtFile = Request.ServerVariables("SERVER_NAME") & _
                Request.ServerVariables("SCRIPT_NAME") & "|" & _
                FormatDateTime(Now) & "|" &_
                Request.ServerVariables("REMOTE_ADDR") & "|" & _
                txtFile & VbCrLf

      ' If a log file location has been set
      If CC_FB_SaveFile <> "[FILENAME]" Then

         Set FSO = Server.CreateObject("Scripting.FileSystemObject")
         filePath = Server.MapPath(CC_FB_SaveFile)

         Set textStream = FSO.OpenTextFile(filePath, 8, True)
         
         If Err.Number <> 0 Then
            Err.Clear
            printMessage "Unable To Open File", _
               "We're sorry but we were unable to open " & filePath & _
                  ". Please contact your server administrator to be sure " & _ 
                  "that you have the proper permissions."         
         End If
         
         textStream.Write(txtFile)
         
         If Err.Number <> 0 Then
            Err.Clear
            printMessage "Unable To Write To File", _
               "We're sorry but we were unable to write to " & _
                  filePath & ". Please contact your server " & _
                  "administrator to be sure that you have the proper " & _
                  "permissions."
         End If         
         
         textStream.Close
         
         Set textStream = Nothing
         Set FSO = Nothing
         
      End If
   End Sub


   '
   ' Prints the HTML-formatted, form response page for the end-user.
   '
   ' Writes the form response to an HTML-formatted page for the end-user
   ' or redirects the user to a thank you page if specified.
   ' 
   ' @param string form_response the response to write to the page.
   ' @param array preferences the CoffeeCup Flash Form Builder Preferences.
   '    
   Private Sub printResponsePage(ByRef formResponse, ByRef preferences)   
      On Error Resume Next
      
      ' Redirect to a thank you page if the user has created one.
      If CC_FB_ResultsRedirect <> "[RESULTSREDIRECT]" Then
         Response.Redirect CC_FB_ResultsRedirect
      ' Otherwise create a thank you page.
      Else   
         Dim resultsMsg 
         
         resultsMsg = "[RESULTSMSG]"
      
         Response.Write(Replace(resultsMsg, _
            "$form_results", formResponse))
      End If    
      
      ' End Transmission
      Response.End
      
   END Sub


   '
   ' Returns the CoffeeCup Flash Form Builder Preferences.
   '
   ' Opens the CoffeeeCup Flash Form Builder XML preferences file
   ' and retrieves the preferences and form fields from it.  If
   ' the preferences file is not found or can not be opened, an
   ' error message is printed to the screen.
   ' 
   ' @return dictionary preferences a dictionary of preferences specified
   ' in the CoffeeCup Flash Form Builder XML preferences file.
   '
   Private Function getPreferences()
      On Error Resume Next
      Dim FSO, filePath, textStream, contents, preferences, formFields
      
      ' Initialize the preferences dictionary
      Set preferences = Server.CreateObject("Scripting.Dictionary") 
      Set formFields = Server.CreateObject("Scripting.Dictionary")
      
      Set FSO = Server.CreateObject("Scripting.FileSystemObject")
      filePath = Server.MapPath(Request.Form("xmlfile"))
      
      ' If the specified preferences file doesn't exist, let the user
      ' know
      If Not FSO.FileExists(filePath) Then
         printMessage "Unable To Locate XML File", "We're sorry but we " & _
            "were unable to locate your XML file.  Please be sure that " & _
               "the '" & Request.Form("xmlfile") & "' is on your server in " & _
               "the same directory as your other form builder files."      
      End If
      
      ' Read in the text from the specified preferences file
      Set textStream = FSO.OpenTextFile(filePath, 1, False, -2)

      ' If we were unable to open the specified xml file, let the suer
      ' know
      If Err.Number <> 0 Then
         Err.Clear
         printMessage "Unable To Open XML File","We're sorry but we were "  & _
            "unable to open your XML file.  Please be sure that you have " & _
               "the proper permissions to read '" & Request.Form("xmlfile") & _
                "'. If you are still experiencing problems, please contact " & _
                "your server administrator."       
      End If      
      
      contents = textStream.ReadAll
      textStream.Close
      
      ' If for some reason the text from the preferences file is empty
      ' let the user know
      If contents = "" Then
         printMessage "Unable To Read XML File","We're sorry but we were "  & _
            "unable to read your XML file.  Please be sure that you have " & _
               "the proper permissions to read '" & Request.Form("xmlfile") & _
                "'. If you are still experiencing problems, please contact " & _
                "your server administrator."
      End If
      
      ' Strips out all the XML nodes from the preferences file.      
      Dim contentsRegexp, nodes, node 

      Set contentsRegexp = New RegExp
      contentsRegexp.Pattern = "<([a-z]+?)\s+([^>]*?)>"
      contentsRegexp.IgnoreCase = True
      contentsRegexp.Global = True
      contentsRegexp.Multiline = True

      Set nodes = contentsRegexp.Execute(contents)
      
      For Each node In nodes 
         ' Skip over item, hidden, button and label nodes, as we're not 
         ' interested in them.
         If node.SubMatches(0) <> "item" And _ 
            node.SubMatches(0) <> "hidden" And _
            node.SubMatches(0) <> "submitbutton" And _ 
            node.SubMatches(0) <> "resetbutton" And _             
            node.SubMatches(0) <> "browsebutton" And _
            node.SubMatches(0) <> "label" Then
            
           ' For each node, we will strip out all of the attributes                                  
           Dim nodeDictionary, nodeRegexp, attributes, attribute, name
           
           Set nodeRegexp = New RegExp
           nodeRegexp.Pattern = "([a-z0-9]+?)=""([^""]*?)"""
           nodeRegexp.IgnoreCase = True
           nodeRegexp.Global = True
           nodeRegexp.Multiline = True
           
           Set nodeDictionary = Server.CreateObject("Scripting.Dictionary")
           Set attributes = nodeRegexp.Execute(node.SubMatches(1))
           
           For each attribute In attributes
              nodeDictionary.Add attribute.SubMatches(0), _
                 HTMLDecode(attribute.SubMatches(1))
           Next
           
            ' If the node has an attribute called 'name', it is a form field.           
           If nodeDictionary.Exists("name") Then
              name = nodeDictionary("name")
              If nodeDictionary.Exists("label") Then
                 name = name & " - " & nodeDictionary("label")
              End If
              nodeDictionary.Add "type", node.SubMatches(0)
              formFields.Add name, nodeDictionary
            ' If the node type is 'form', it is the form preferences              
           ElseIf node.SubMatches(0) = "form" Then
              preferences.Add "formPreferences", nodeDictionary
            ' otherwise just dump everything into a general array depending
            ' on its node type.              
           Else
              If Not preferences.Exists(node.SubMatches(0)) Then
                 preferences.Add node.SubMatches(0), Array(nodeDictionary)
              Else
                 Dim nodeDictionaries, bound
                 
                 nodeDictionaries = preferences(node.SubMatches(0))
                 
                 bound = UBound(nodeDictionaries) + 1
                 
                 Redim Preserve nodeDictionaries(bound)
                 Set nodeDictionaries(bound) = nodeDictionary
                 
                 preferences(node.SubMatches(0)) = nodeDictionaries
              End If        
           End If
        End If
      Next
      
      preferences.Add "formFields", formFields
      Set getPreferences = preferences
      
      Set FSO = Nothing 
      Set textStream = Nothing 
      Set preferences = Nothing
      
   End Function


   '
   ' Uploads a user-submitted file.
   '
   Private Sub processFileUpload()
      On Error Resume Next
   
      Dim data, position, separator 
      Dim folder, filedata, filename, basename, extension, filenameRegexp, i
      Dim binaryString, FSO, filePath, textStream
      
      data = Request.BinaryRead(Request.TotalBytes)
   
      ' If we couldn't retrieve the binary request, it's most likely
      ' because the file exceeded the servers maximum post size
      If Err.Number <> 0 Then
	      Err.Clear
         printMessage "Unable to Upload File.", _
            "We're sorry but we were unable to upload your file because " & _
               "it exceeded the maximum file upload size."
   	End If  
   	
   	' Get the mime boundry
      separator = MidB(data, 1, InstrB(data, ChrB("10")) - LenB(ChrB("10")) - 1)
      ' The position where filedata is first mentioned
	   position = InstrB(data, StringToBinary("Filedata"))
	   
	   ' If filedata is found
	   If position > 0 Then

         ' Get filename
	      binaryString = StringToBinary("filename=""")
	      position = InstrB(position, data, binaryString) + LenB(binaryString)
	      filename = BinaryToString(MidB(data, position, _
	         InstrB(position, data, ChrB("34")) - position))
	   
	      ' Get filedata
	      position = InstrB(position, data, ChrB("10") & ChrB("13")) _
	         + LenB(ChrB("10") & ChrB("13") & ChrB("10"))
         filedata = BinaryToString(MidB(data, position, _
            InstrB(position, data, separator) - position - _
               LenB(ChrB("10") & ChrB("13"))))

         ' Make sure the file upload is of an acceptable file type
         If CC_FB_AcceptableFileTypes <> "" Then         
            Set filenameRegexp = New RegExp
            filenameRegexp.Pattern = "\.(" & CC_FB_AcceptableFileTypes & ")$"
            filenameRegexp.IgnoreCase = True

            If Not filenameRegexp.Test(filename) Then
               printMessage "Invalid File Type", _
                  "We're sorry but we were unable to upload your file " & _
                  "because the file type is not acceptable."
            End If
         End If
		
         Set FSO = Server.CreateObject("Scripting.FileSystemObject")      

         ' Create the files folder if it doesn't already exist
         folder = Server.MapPath(CC_FB_UploadsFolder)
         If Not FSO.FolderExists(folder) Then
            FSO.CreateFolder(folder)
            
            If Err.Number <> 0 Then
               Err.Clear
               printMessage "Folder Creation Failed", _
                  "We're sorry but we were unable to create a folder for " & _
                  "your file uploads.  Please contact your server " & _
                  "administrator."  
            End If            
         End If

         basename = FSO.GetBaseName(filename)
         extension = "." & FSO.GetExtensionName(filename)
            
         filePath = folder & "\" & basename & CC_FB_UploadsExtension & extension

         ' If the file already exists, append a version number
         While FSO.FileExists(filePath)
            i = i + 1
            filePath = folder & "\" & basename & CC_FB_UploadsExtension & _
               i & extension
         Wend
      
         Set textStream = FSO.CreateTextFile(filePath, True)
         
         ' Let the user know if we can't create the file
         If Err.Number <> 0 Then
            Err.Clear
            printMessage "Unable To Create File", _
               "We're sorry but we were unable to create " & filePath & _
                  ". Please contact your server administrator to be sure " & _ 
                  "that you have the proper permissions."         
         End If
         
         textStream.Write(filedata)
         
         ' Let the user know if we can't save the file
         If Err.Number <> 0 Then
            Err.Clear
            printMessage "Unable To Write To File", _
               "We're sorry but we were unable to write to " & _
                  filePath & ". Please contact your server " & _
                  "administrator to be sure that you have the proper " & _
                  "permissions."
         End If         
         
         textStream.Close	   
         
         Set filenameRegexp = Nothing
         Set FSO = Nothing         
         Set textStream = Nothing
	   
	   End If	
   End Sub


   '
   ' Prints a message to the screen.
   '
   ' Prints an HTML-formatted message to the screen that also contains
   ' the current PHP version number the server is running, the current
   ' version number and release date of this script as well as the 
   ' current version number and release date of the version of CoffeeCup 
   ' Flash Form Builder that generated this script.
   '
   ' NOTE: This function stops execution of the script.
   ' 
   ' @param string title the title of the page
   ' @param string message the message to print to the screen
   '
   Private Sub printMessage(ByRef title, ByRef message)
      On Error Resume Next
   
      ' The title of the html-formatted page.
      Dim pageTitle, cdosysMsg, adodbMsg

      ' If the user has provided a title, format it for HTML
      If Not title = "" Then
         title = Server.HTMLEncode(title)
         pageTitle = title & " - " 
         title = "<h1>" & title & "</h1>"
      End If
      
      ' If the user has provided a message, formit it for HTML
      If Not message = "" Then
         message = "<p>" & Server.HTMLEncode(message) & "</p>"
      End If
      
      ' Check if CDOSYS is available
      Server.CreateObject("CDO.Message")
      If Err.Number <> 0 Then
         Err.Clear
         cdosysMsg = "Not Available"
      Else
         cdosysMsg = "Available"
      End If      
      
      ' Check if ADODB is available
      Server.CreateObject("ADODB.Connection")
      If Err.Number <> 0 Then      
         Err.Clear
         adodbMsg = "Not Available"
      Else
         adodbMsg = "Available"    
      End If         
      
      Response.Write ("<?xml version=""1.0"" encoding=""utf-8""?>" & VbCrLf & _
"<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Strict//EN""" & VbCrLf & _
"    ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"">" & VbCrLf & _
"<html xmlns=""http://www.w3.org/1999/xhtml"" xml:lang=""en"" lang=""en"">" & _ 
VbCrLf & _
"" & VbCrLf & _
"<head>" & VbCrLf & _
"  <title>" & pageTitle & "CoffeeCup Form Builder</title>" & VbCrLf & _
"  <meta http-equiv=""Content-Type"" content=""text/html; charset=utf-8"" />"& _
VbCrLf & _
"  <meta name=""robots"" content=""noindex,nofollow"" />" & VbCrLf & _
"  <style type=""text/css"">" & VbCrLf & _
"   <!--" & VbCrLf & _
"    div#script_info" & VbCrLf & _
"    {" & VbCrLf & _
"       border-top: 1px solid #666;" & VbCrLf & _
"       font-size:  .85em;" & VbCrLf & _
"    }" & VbCrLf & _
"   -->" & VbCrLf & _
"  </style>" & VbCrLf & _
"</head>" & VbCrLf & _
"" & VbCrLf & _
"<body>" & VbCrLf & _
"  " & title & VbCrLf & _
"  " & message & VbCrLf & _
"  <div id=""script_info"">" & VbCrLf & _
"    <p>" & VbCrLf & _
"      VBScript Version: " & ScriptEngineMajorVersion & VbCrLf & _
"    </p>" & VbCrLf & _
"    <p>" & VbCrLf & _
"      Software Version: " & CC_FB_Version & "<br />" & VbCrLf & _
"      Software Last Updated: " & CC_FB_LastUpdated & VbCrLf & _
"    </p>" & VbCrLf & _
"    <p>" & VbCrLf & _
"      Script Version: " & CC_FB_ScriptVersion & "<br />" & VbCrLf & _
"      Script Last Updated: " & CC_FB_ScriptLastUpdated & VbCrLf & _
"    </p>" & VbCrLf & _
"    <p>" & VbCrLf & _
"      CDOSYS: " & cdosysMsg & "<br />" & VbCrLf & _
"      ADODB: " & adodbMsg & VbCrLf & _
"    </p>" & VbCrLf & _
"  </div>" & VbCrLf & _
"</body>" & VbCrLf & _
"" & VbCrLf & _
"</html>")

      Response.End
   End Sub


   '
   ' Decodes html entities in text
   '
   ' @param text the text to decode
   ' @return html decoded text
   '
   Function HTMLDecode(text)
      On Error Resume Next
      Dim i
      
      text = Replace(text, "&quot;", """")
      text = Replace(text, "&lt;"  , "<")
      text = Replace(text, "&gt;"  , ">")
      text = Replace(text, "&amp;" , "&")
      text = Replace(text, "&nbsp;", " ")
      
      For i = 1 To 255
         text = Replace(text, "&#" & i & ";", Chr(i))
      Next
      
      HTMLDecode = text
   End Function   


   '
   ' Converts a C-style string to binary
   '
   ' @param cstring the string to be converted
   ' @return binary text
   '
   Function StringToBinary(cstring)
      On Error Resume Next
      Dim i
      For i=1 To Len(cstring)
         StringToBinary = StringToBinary & ChrB(Asc(Mid(cstring,i,1)))
      Next
   End Function


   '
   ' Converts a binary string to C-style
   '
   ' @param binary string to be converted
   ' @return C-style text
   '
   Function BinaryToString(binaryString)
      On Error Resume Next
      Dim i
      For i=1 To LenB(binaryString)
         BinaryToString = BinaryToString & Chr(AscB(MidB(binaryString,i,1)))
      Next
   End Function

%>