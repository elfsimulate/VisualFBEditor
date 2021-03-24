﻿'#########################################################
'#  frmTools.bas                                         #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (2020)                   #
'#########################################################

#include once "frmTools.bi"
#include once "frmPath.bi"
#include once "Main.bi"

Dim Shared fTools As frmTools
pfTools = @fTools

'#Region "Form"
	Constructor frmTools
		' frmTools
		This.Name = "frmTools"
		This.Text = ML("Tools")
		This.BorderStyle = FormBorderStyle.FixedDialog
		This.ControlBox = True
		This.MinimizeBox = False
		This.MaximizeBox = False
		This.StartPosition = FormStartPosition.CenterParent
		This.OnCreate = @Form_Create
		This.SetBounds 0, 0, 484, 454
		' lvTools
		lvTools.Name = "lvTools"
		lvTools.Text = "ListView1"
		lvTools.SetBounds 12, 12, 366, 198
		lvTools.OnSelectedItemChanged = @lvTools_SelectedItemChanged
		lvTools.OnItemClick = @lvTools_ItemClick
		lvTools.Columns.Add ML("Name"), , 150
		lvTools.Columns.Add ML("Path"), , 200
		lvTools.Parent = @This
		' cmdOK
		cmdOK.Name = "cmdOK"
		cmdOK.Text = ML("OK")
		cmdOK.SetBounds 302, 392, 78, 24
		cmdOK.OnClick = @cmdOK_Click
		cmdOK.Parent = @This
		' cmdCancel
		cmdCancel.Name = "cmdCancel"
		cmdCancel.Text = ML("Cancel")
		cmdCancel.SetBounds 390, 392, 78, 24
		cmdCancel.OnClick = @cmdCancel_Click
		cmdCancel.Parent = @This
		' cmdHelp
		cmdHelp.Name = "cmdHelp"
		cmdHelp.Text = ML("Help")
		cmdHelp.SetBounds 390, 186, 78, 24
		cmdHelp.Parent = @This
		' cmdAdd
		With cmdAdd
			.Name = "cmdAdd"
			.Text = ML("Add")
			.SetBounds 390, 12, 78, 24
			.OnClick = @cmdAdd_Click
			.Parent = @This
		End With
		' cmdChange
		With cmdChange
			.Name = "cmdChange"
			.Text = ML("Change")
			.SetBounds 390, 41, 78, 24
			.OnClick = @cmdChange_Click
			.Parent = @This
		End With
		' cmdRemove
		With cmdRemove
			.Name = "cmdRemove"
			.Text = ML("Remove")
			.SetBounds 390, 72, 78, 24
			.OnClick = @cmdRemove_Click
			.Parent = @This
		End With
		' lblParameters
		With lblParameters
			.Name = "lblParameters"
			.Text = ML("Parameters") & ":"
			.SetBounds 16, 224, 104, 16
			.Parent = @This
		End With
		' txtParameters
		With txtParameters
			.Name = "txtParameters"
			.Text = ""
			.SetBounds 128, 221, 250, 21
			.OnChange = @txtParameters_Change
			.Parent = @This
		End With
		' lblInfo
		With lblInfo
			.Name = "lblInfo"
			.Text = "{P} " & ML("Project Name") & " {S} " & ML("Main Source File") & " {W} " & ML("Current Word") & " {E} " & ML("EXE/DLL Name")
			.SetBounds 136, 248, 240, 29
			.Parent = @This
		End With
		' lblWorkingFolder
		With lblWorkingFolder
			.Name = "lblWorkingFolder"
			.Text = ML("Working Folder") & ":"
			.SetBounds 16, 288, 104, 16
			.Parent = @This
		End With
		' txtWorkingFolder
		With txtWorkingFolder
			.Name = "txtWorkingFolder"
			.SetBounds 128, 285, 252, 21
			.OnChange = @txtWorkingFolder_Change
			.Parent = @This
		End With
		' lblTrigger
		With lblTrigger
			.Name = "lblTrigger"
			.Text = ML("Start on event") & ":"
			.SetBounds 16, 315, 112, 16
			.Parent = @This
		End With
		' cboEvent
		With cboEvent
			.Name = "cboEvent"
			.Text = "ComboBoxEdit1"
			.SetBounds 128, 312, 144, 21
			.OnChange = @cboEvent_Change
			.Parent = @This
			.AddItem ML("Only on user selected")
			.AddItem ML("On editor startup")
			.AddItem ML("Before compile")
			.AddItem ML("AfterCompile")
		End With
		' lblShortcut
		With lblShortcut
			.Name = "lblShortcut"
			.Text = ML("Shortcut") & ":"
			.SetBounds 16, 343, 80, 16
			.Parent = @This
		End With
		' hkShortcut
		With hkShortcut
			.Name = "hkShortcut"
			.Text = ""
			.SetBounds 128, 340, 144, 21
			.OnChange = @hkShortcut_Change
			.Parent = @This
		End With
		' chkWaitComplete
		With chkWaitComplete
			.Name = "chkWaitComplete"
			.Text = ML("Wait until tool quits")
			.SetBounds 16, 372, 256, 16
			.OnClick = @chkWaitComplete_Click
			.Parent = @This
		End With
		' cmdWorkingFolder
		With cmdWorkingFolder
			.Name = "cmdWorkingFolder"
			.Text = ML("Browse") & " ..."
			.SetBounds 390, 284, 78, 24
			.Parent = @This
		End With
		' cmdMoveUp
		With cmdMoveUp
			.Name = "cmdMoveUp"
			.Text = ML("Move Up")
			.SetBounds 390, 112, 78, 24
			.OnClick = @cmdMoveUp_Click
			.Parent = @This
		End With
		' cmdMoveDown
		With cmdMoveDown
			.Name = "cmdMoveDown"
			.Text = ML("Move Down")
			.SetBounds 390, 144, 78, 24
			.OnClick = @cmdMoveDown_Click
			.Parent = @This
		End With
	End Constructor
	
	#ifndef _NOT_AUTORUN_FORMS_
		fTools.Show
		
		App.Run
	#endif
'#End Region

Destructor frmTools
	
End Destructor

Private Sub frmTools.cmdOK_Click(ByRef Sender As Control)
	Var Fn = FreeFile
	Dim As UserToolType Ptr Tool, tt
	Dim As MenuItem Ptr mi
	Dim As Integer ToolsIndex
	#ifdef __USE_GTK__
		Open ExePath & "/Tools/ToolsX.ini" For Output Encoding "utf8" As #Fn
	#else
		Open ExePath & "/Tools/Tools.ini" For Output Encoding "utf8" As #Fn
	#endif
	With fTools
		For i As Integer = 0 To Tools.Count - 1
			Delete_( Cast(UserToolType Ptr, pTools->Item(i)))
		Next
		pTools->Clear
		For i As Integer = miXizmat->Count - 1 To 0 Step -1
			mi = miXizmat->Item(i)
			If mi->Name = "Tools" Then ToolsIndex = i
			If mi->OnClick = @mClickTool Then
				miXizmat->Remove mi
				'Delete mi
			End If
		Next
		Dim As My.Sys.Drawing.BitmapType Bitm
		Dim As My.Sys.Drawing.Icon Ico
		For i As Integer = 0 To .lvTools.ListItems.Count - 1
			tt = .lvTools.ListItems.Item(i)->Tag
			If tt = 0 Then Continue For
			Tool = New_( UserToolType)
			Tool->Name = tt->Name
			Tool->Path = tt->Path
			Tool->Parameters = tt->Parameters
			Tool->WorkingFolder = tt->WorkingFolder
			Tool->Accelerator = tt->Accelerator
			Tool->LoadType = tt->LoadType
			Tool->WaitComplete = tt->WaitComplete
			pTools->Add Tool
			#ifdef __USE_GTK__
			#else
				Ico.Handle = ExtractIconW(Instance, tt->Path, NULL)
				Bitm.Handle = Ico.ToBitmap
			#endif
			mi = miXizmat->Add(tt->Name & !"\t" & tt->Accelerator, Bitm, "Tools", @mClickTool, , i + ToolsIndex + 2)
			mi->Tag = tt
			Print #Fn, "Path=" & tt->Path
			Print #Fn, "Name=" & tt->Name
			Print #Fn, "Parameters=" & tt->Parameters
			Print #Fn, "WorkingFolder=" & tt->WorkingFolder
			Print #Fn, "Accelerator=" & tt->Accelerator
			Print #Fn, "LoadType=" & tt->LoadType
			Print #Fn, "WaitComplete=" & tt->WaitComplete
		Next
	End With
	Close #Fn
	fTools.CloseForm
	pfrmMain->Menu->ParentWindow = pfrmMain
End Sub

Private Sub frmTools.cmdCancel_Click(ByRef Sender As Control)
	fTools.CloseForm
End Sub

Private Sub frmTools.cmdAdd_Click(ByRef Sender As Control)
	pfPath->txtVersion.Text = ""
	pfPath->txtPath.Text = ""
	pfPath->lblVersion.Caption = ML("Tool Name")
	pfPath->SetFileNameToVersion = True
	If pfPath->ShowModal() = ModalResults.OK Then
		With fTools
			Dim As UserToolType Ptr Tool = New_( UserToolType)
			Tool->Name = pfPath->txtVersion.Text
			Tool->Path = pfPath->txtPath.Text
			.lvTools.ListItems.Add pfPath->txtVersion.Text
			.lvTools.ListItems.Item(.lvTools.ListItems.Count - 1)->Text(1) = pfPath->txtPath.Text
			.lvTools.ListItems.Item(.lvTools.ListItems.Count - 1)->Tag = Tool
		End With
	End If
	pfPath->SetFileNameToVersion = False
End Sub

Private Sub frmTools.cmdChange_Click(ByRef Sender As Control)
	With fTools
		If .lvTools.SelectedItem = 0 Then Exit Sub
		pfPath->txtVersion.Text = .lvTools.SelectedItem->Text(0)
		pfPath->txtPath.Text = .lvTools.SelectedItem->Text(1)
		Dim As UserToolType Ptr Tool = .lvTools.SelectedItem->Tag
		pfPath->lblVersion.Caption = ML("Tool Name")
		pfPath->SetFileNameToVersion = True
		If pfPath->ShowModal() = ModalResults.OK Then
			If Tool <> 0 Then
				Tool->Name = pfPath->txtVersion.Text
				Tool->Path = pfPath->txtPath.Text
			End If
			.lvTools.SelectedItem->Text(0) = pfPath->txtVersion.Text
			.lvTools.SelectedItem->Text(1) = pfPath->txtPath.Text
		End If
		pfPath->SetFileNameToVersion = False
	End With
End Sub

Private Sub frmTools.cmdRemove_Click(ByRef Sender As Control)
	With fTools
		If .lvTools.SelectedItem = 0 Then Exit Sub
		Delete_( Cast(UserToolType Ptr, .lvTools.SelectedItem->Tag))
		.lvTools.ListItems.Remove .lvTools.SelectedItemIndex
	End With
End Sub

Private Sub frmTools.lvTools_SelectedItemChanged(ByRef Sender As ListView, ItemIndex As Integer)
	Dim i As Integer = ItemIndex
	With fTools
		If i < 0 Then
			.txtParameters.Text = ""
			.txtParameters.Enabled = False 
			.txtWorkingFolder.Text = ""
			.txtWorkingFolder.Enabled = False
			.cmdWorkingFolder.Enabled = False
			.cboEvent.ItemIndex = -1
			.cboEvent.Enabled = False 
			.hkSHortcut.Text = ""
			.hkSHortcut.Enabled = False 
			.chkWaitComplete.Checked = False
			.chkWaitComplete.Enabled = False
		Else
			Dim As UserToolType Ptr tt = Sender.ListItems.Item(i)->Tag
			.txtParameters.Text = tt->Parameters
			.txtParameters.Enabled = True
			.txtWorkingFolder.Text = tt->WorkingFolder
			.txtWorkingFolder.Enabled = True
			.cmdWorkingFolder.Enabled = True
			.cboEvent.ItemIndex = tt->LoadType
			.cboEvent.Enabled = True
			.hkSHortcut.Text = tt->Accelerator
			.hkSHortcut.Enabled = True
			.chkWaitComplete.Checked = tt->WaitComplete
			.chkWaitComplete.Enabled = True
		End If
	End With
End Sub

Private Sub frmTools.lvTools_ItemClick(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	fTools.lvTools_SelectedItemChanged Sender, ItemIndex
End Sub

Sub ExecuteTool(Param As Any Ptr)
	Dim As UserToolType Ptr tt = Param
	If tt = 0 Then Exit Sub
	Dim As ProjectElement Ptr Project
	Dim As ExplorerElement Ptr ee
	Dim As TreeNode Ptr ProjectNode
	Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
	Dim As UString ProjectFile = ""
	Dim As UString MainFile = GetMainFile(, Project, ProjectNode)
	Dim As UString FirstLine = GetFirstCompileLine(MainFile, Project)
	Dim As UString ExeFile = GetExeFileName(MainFile, FirstLine)
	Dim As UString CurrentWord = ""
	Dim As UString Parameters = tt->Parameters
	If ProjectNode <> 0 Then ee = ProjectNode->Tag
	If ee <> 0 Then ProjectFile = *ee->FileName
	If tb <> 0 Then CurrentWord = tb->txtCode.GetWordAtCursor
	Parameters = Replace(Parameters, "{P}", ProjectFile)
	Parameters = Replace(Parameters, "{P|S}", IIf(ProjectFile = "", MainFile, ProjectFile))
	Parameters = Replace(Parameters, "{S}", MainFile)
	Parameters = Replace(Parameters, "{W}", CurrentWord)
	Parameters = Replace(Parameters, "{E}", ExeFile)
	Shell """" & GetRelativePath(tt->Path, pApp->FileName) & """ " & Parameters
End Sub

Sub UserToolType.Execute()
	If WaitComplete Then
		ExecuteTool @This
	Else
		ThreadCreate(@ExecuteTool, @This)
	End If
End Sub


Private Sub frmTools.Form_Create(ByRef Sender As Control)
	With fTools
		With .lvTools
			Dim As UserToolType Ptr Tool, tt
			Dim As ListViewItem Ptr Item
			For i As Integer = 0 To .ListItems.Count - 1
				Delete_( Cast(UserToolType Ptr, .ListItems.Item(i)->Tag))
			Next
			.ListItems.Clear
			For i As Integer = 0 To Tools.Count - 1
				Tool = Tools.Item(i)
				tt = New_( UserToolType)
				tt->Name = Tool->Name
				tt->Path = Tool->Path
				tt->Parameters = Tool->Parameters
				tt->WorkingFolder = Tool->WorkingFolder
				tt->Accelerator = Tool->Accelerator
				tt->LoadType = Tool->LoadType
				tt->WaitComplete = Tool->WaitComplete
				Item = .ListItems.Add(tt->Name)
				Item->Text(1) = tt->Path
				Item->Tag = tt
			Next
		End With
		.lvTools_SelectedItemChanged .lvTools, -1
	End With
End Sub

Private Sub frmTools.txtParameters_Change(ByRef Sender As TextBox)
	Dim Item As ListViewItem Ptr = fTools.lvTools.SelectedItem
	If Item = 0 Then Exit Sub
	Dim Tool As UserToolType Ptr = Item->Tag
	Tool->Parameters = Sender.Text
End Sub

Private Sub frmTools.txtWorkingFolder_Change(ByRef Sender As TextBox)
	Dim Item As ListViewItem Ptr = fTools.lvTools.SelectedItem
	If Item = 0 Then Exit Sub
	Dim Tool As UserToolType Ptr = Item->Tag
	Tool->WorkingFolder = Sender.Text
End Sub

Private Sub frmTools.cboEvent_Change(ByRef Sender As Control)
	Dim Item As ListViewItem Ptr = fTools.lvTools.SelectedItem
	If Item = 0 Then Exit Sub
	Dim Tool As UserToolType Ptr = Item->Tag
	Tool->LoadType = fTools.cboEvent.ItemIndex
End Sub

Private Sub frmTools.hkShortcut_Change(ByRef Sender As Control)
	Dim Item As ListViewItem Ptr = fTools.lvTools.SelectedItem
	If Item = 0 Then Exit Sub
	Dim Tool As UserToolType Ptr = Item->Tag
	Tool->Accelerator = fTools.hkShortcut.Text
End Sub

Private Sub frmTools.chkWaitComplete_Click(ByRef Sender As CheckBox)
	Dim Item As ListViewItem Ptr = fTools.lvTools.SelectedItem
	If Item = 0 Then Exit Sub
	Dim Tool As UserToolType Ptr = Item->Tag
	Tool->WaitComplete = Sender.Checked
End Sub

Private Sub frmTools.cmdMoveUp_Click(ByRef Sender As Control)
	With fTools.lvTools
		Dim i As Integer = .SelectedItemIndex
		If i < 1 Then Exit Sub
		Dim As ListViewItem Ptr ItemCurr = .SelectedItem, ItemPrev = .ListItems.Item(i - 1)
		Dim As UserToolType Ptr ToolCurr = ItemCurr->Tag, ToolPrev = ItemPrev->Tag
		ItemPrev->Text(0) = ToolCurr->Name
		ItemPrev->Text(1) = ToolCurr->Path
		ItemPrev->Tag = ToolCurr
		ItemCurr->Text(0) = ToolPrev->Name
		ItemCurr->Text(1) = ToolPrev->Path
		ItemCurr->Tag = ToolPrev
		.SelectedItemIndex = i - 1
	End With
End Sub

Private Sub frmTools.cmdMoveDown_Click(ByRef Sender As Control)
	With fTools.lvTools
		Dim i As Integer = .SelectedItemIndex
		If i < 0 OrElse i >= .ListItems.Count - 1 Then Exit Sub
		Dim As ListViewItem Ptr ItemCurr = .SelectedItem, ItemNext = .ListItems.Item(i + 1)
		Dim As UserToolType Ptr ToolCurr = ItemCurr->Tag, ToolNext = ItemNext->Tag
		ItemNext->Text(0) = ToolCurr->Name
		ItemNext->Text(1) = ToolCurr->Path
		ItemNext->Tag = ToolCurr
		ItemCurr->Text(0) = ToolNext->Name
		ItemCurr->Text(1) = ToolNext->Path
		ItemCurr->Tag = ToolNext
		.SelectedItemIndex = i + 1
	End With
End Sub
