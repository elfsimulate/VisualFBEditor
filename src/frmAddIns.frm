﻿'#########################################################
'#  frmAddIns.bas                                        #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (2018-2019)              #
'#########################################################

#include once "frmAddIns.bi"

Dim Shared fAddIns As frmAddIns
pfAddIns = @fAddIns

Dim Shared AvailableAddIns As List
pAvailableAddIns = @AvailableAddIns

'#Region "Form"
	Constructor frmAddIns
		' frmAddIns
		This.Name = "frmAddIns"
		This.Text = ML("Add-Ins")
		This.OnCreate = @Form_Create
		This.OnClose = @Form_Close
		This.OnShow = @Form_Show
		This.BorderStyle = FormBorderStyle.FixedDialog
		This.FormStyle = FormStyles.fsStayOnTop
		This.ControlBox = True
		This.MinimizeBox = False
		This.MaximizeBox = False
		This.StartPosition = FormStartPosition.CenterParent
		This.SetBounds 0, 0, 484, 357
		' lvAddIns
		lvAddIns.Name = "lvAddIns"
		lvAddIns.Text = "ListView1"
		lvAddIns.SetBounds 12, 12, 366, 198
		lvAddIns.OnSelectedItemChanged = @lvAddIns_SelectedItemChanged
		lvAddIns.OnItemClick = @lvAddIns_ItemClick
		lvAddIns.Parent = @This
		' cmdOK
		cmdOK.Name = "cmdOK"
		cmdOK.Text = ML("OK")
		cmdOK.SetBounds 390, 12, 78, 24
		cmdOK.OnClick = @cmdOK_Click
		cmdOK.Parent = @This
		' cmdCancel
		cmdCancel.Name = "cmdCancel"
		cmdCancel.Text = ML("Cancel")
		cmdCancel.SetBounds 390, 40, 78, 24
		cmdCancel.OnClick = @cmdCancel_Click
		cmdCancel.Parent = @This
		' cmdHelp
		cmdHelp.Name = "cmdHelp"
		cmdHelp.Text = ML("Help")
		cmdHelp.SetBounds 390, 180, 78, 24
		cmdHelp.Parent = @This
		' lblDescription
		lblDescription.Name = "lblDescription"
		lblDescription.Text = ML("Description") & ":"
		lblDescription.SetBounds 12, 216, 162, 18
		lblDescription.Parent = @This
		' txtDescription
		txtDescription.Name = "txtDescription"
		txtDescription.Text = ""
		txtDescription.ReadOnly = True
		txtDescription.SetBounds 12, 234, 264, 84
		txtDescription.BackColor = 15790320
		txtDescription.Parent = @This
		' grbLoadBehavior
		grbLoadBehavior.Name = "grbLoadBehavior"
		grbLoadBehavior.Text = ML("Load Behavior")
		grbLoadBehavior.SetBounds 288, 225, 180, 93
		grbLoadBehavior.Parent = @This
		' chkLoaded
		chkLoaded.Name = "chkLoaded"
		chkLoaded.Text = ML("Loaded/Unloaded")
		chkLoaded.SetBounds 4, 3, 140, 18
		chkLoaded.OnClick = @chkLoaded_Click
		chkLoaded.Caption = ML("Loaded/Unloaded")
		chkLoaded.Parent = @pnlLoadBehavior
		' chkLoadOnStartup
		chkLoadOnStartup.Name = "chkLoadOnStartup"
		chkLoadOnStartup.Text = ML("Load on Startup")
		chkLoadOnStartup.SetBounds 4, 28, 156, 18
		chkLoadOnStartup.OnClick = @chkLoadOnStartup_Click
		chkLoadOnStartup.Caption = ML("Load on Startup")
		chkLoadOnStartup.Parent = @pnlLoadBehavior
		' pnlLoadBehavior
		pnlLoadBehavior.Name = "pnlLoadBehavior"
		pnlLoadBehavior.Text = ""
		pnlLoadBehavior.SetBounds 304, 247, 144, 56
		pnlLoadBehavior.Parent = @This
	End Constructor
	
	#ifndef _NOT_AUTORUN_FORMS_
		fAddIns.Show
		
		App.Run
	#endif
'#End Region

Destructor AddInType
	WDeallocate Description
	WDeallocate Path
End Destructor

Destructor frmAddIns
'	For i As Integer = 0 To AvailableAddIns.Count - 1
'		#ifndef __USE_GTK__
'			Delete Cast(AddInType Ptr, AvailableAddIns.Item(i))
'		#endif
'	Next
'	AvailableAddIns.Clear
End Destructor

Private Sub frmAddIns.cmdOK_Click(ByRef Sender As Control)
	Dim As AddInType Ptr Add_In
	Dim As String AddIn
	For i As Integer = 0 To AvailableAddIns.Count - 1
		Add_In = AvailableAddIns.Item(i)
		AddIn = fAddIns.lvAddIns.ListItems.Item(i)->Text(0)
		If Add_In->LoadOnStartup <> Add_In->LoadOnStartupINI Then
			piniSettings->WriteBool("AddInsOnStartup", AddIn, Add_In->LoadOnStartup)
			Add_In->LoadOnStartupINI = Add_In->LoadOnStartup
		End If
		If Add_In->Loaded <> Add_In->LoadedOriginal Then
			If Add_In->Loaded Then
				ConnectAddIn AddIn
			Else
				DisconnectAddIn AddIn
			End If
			Add_In->LoadedOriginal = Add_In->Loaded
		End If
	Next
	fAddIns.CloseForm
End Sub

Private Sub frmAddIns.cmdCancel_Click(ByRef Sender As Control)
	fAddIns.CloseForm
End Sub

Sub ChangeItem(ItemIndex As Integer)
	If ItemIndex = -1 Then Exit Sub
	Dim Item As ListViewItem Ptr
	Dim Add_In As AddInType Ptr
	Item = fAddIns.lvAddIns.ListItems.Item(ItemIndex)
	Add_In = AvailableAddIns.Item(ItemIndex)
	If Add_In->LoadOnStartup Then
		Item->Text(1) = "Startup / " & IIf(Add_In->Loaded, "Loaded", "Unloaded")
	Else
		Item->Text(1) = IIf(Add_In->Loaded, "Loaded", "")
	End If
End Sub

Private Sub frmAddIns.Form_Create(ByRef Sender As Control)
	With fAddIns
		With .lvAddIns
			.Columns.Add ML("Available Add-Ins"), , 250
			.Columns.Add ML("Load Behavior"), , 100
			Dim As AddInType Ptr Add_In
			Dim As ListViewItem Ptr Item
			Dim As String f, AddIn
			For i As Integer = 0 To AvailableAddIns.Count - 1
				Delete_( Cast(AddInType Ptr, AvailableAddIns.Item(i)))
			Next
			AvailableAddIns.Clear
			#ifdef __FB_WIN32__
				f = Dir(ExePath & "/AddIns/*.dll")
			#else
				f = Dir(ExePath & "/AddIns/*.so")
			#endif
			While f <> ""
				AddIn = ..Left(f, InStrRev(f, ".") - 1)
				Add_In = New_( AddInType)
				Add_In->LoadOnStartupINI = piniSettings->ReadBool("AddInsOnStartup", AddIn, False)
				Add_In->LoadOnStartup = Add_In->LoadOnStartupINI
				Add_In->LoadedOriginal = pAddIns->Contains(AddIn)
				Add_In->Loaded = Add_In->LoadedOriginal
				WLet(Add_In->Path, ExePath & "/AddIns/" & f)
				#ifdef __USE_GTK__
					WLet(Add_In->Description, "")
				#else
					Dim As DWORD ret, discard
					Dim As Any Ptr _vinfo
					ret = GetFileVersionInfoSize(Add_In->Path, @discard)
					If ret <> 0 Then
						_vinfo = Allocate_(ret)
						If GetFileVersionInfo(Add_In->Path, 0, ret, _vinfo) Then
							Dim As Unsigned Short Ptr ulTranslation
							Dim As ULong iret
							Dim As String TranslationString
							If VerQueryValue(_vinfo, $"\VarFileInfo\Translation", @ulTranslation, @iret) Then
								TranslationString = Hex(ulTranslation[0], 4) & Hex(ulTranslation[1], 4)
								Dim As String FullInfoName = $"\StringFileInfo\" & TranslationString & "\FileDescription"
								If VerQueryValue(_vinfo, FullInfoName, @Add_In->Description, @iret) Then
									''~ value = cast( zstring ptr, vqinfo )
								End If
							End If
						End If
					End If
				#endif
				AvailableAddIns.Add Add_In
				Item = .ListItems.Add(AddIn)
				ChangeItem(Item->Index)
				f = Dir()
			Wend
		End With
	End With
End Sub

Private Sub frmAddIns.chkLoaded_Click(ByRef Sender As CheckBox)
	Dim i As Integer = fAddIns.lvAddIns.SelectedItemIndex
	If i < 0 Then Exit Sub
	Dim Add_In As AddInType Ptr = AvailableAddIns.Item(i)
	Add_In->Loaded = Sender.Checked
	ChangeItem i
End Sub

Private Sub frmAddIns.chkLoadOnStartup_Click(ByRef Sender As CheckBox)
	Dim i As Integer = fAddIns.lvAddIns.SelectedItemIndex
	If i < 0 Then Exit Sub
	Dim Add_In As AddInType Ptr = AvailableAddIns.Item(i)
	Add_In->LoadOnStartup = Sender.Checked
	ChangeItem fAddIns.lvAddIns.SelectedItemIndex
End Sub

Private Sub frmAddIns.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	
End Sub

Private Sub frmAddIns.lvAddIns_SelectedItemChanged(ByRef Sender As ListView, ItemIndex As Integer)
	Dim i As Integer = ItemIndex
	If i < 0 Then
		fAddIns.chkLoaded.Checked = False
		fAddIns.chkLoadOnStartup.Checked = False
		fAddIns.chkLoaded.Enabled = False
		fAddIns.chkLoadOnStartup.Enabled = False
		fAddIns.txtDescription.Text = ""
	Else
		Dim Add_In As AddInType Ptr = AvailableAddIns.Item(i)
		fAddIns.chkLoaded.Checked = Add_In->Loaded
		fAddIns.chkLoadOnStartup.Checked = Add_In->LoadOnStartup
		fAddIns.chkLoaded.Enabled = True
		fAddIns.chkLoadOnStartup.Enabled = True
		fAddIns.txtDescription.Text = WGet(Add_In->Description)
	End If
End Sub

Private Sub frmAddIns.Form_Show(ByRef Sender As Form)
	
End Sub

Private Sub frmAddIns.lvAddIns_ItemClick(ByRef Sender As ListView, ByVal ItemIndex As Integer)
	fAddIns.lvAddIns_SelectedItemChanged Sender, ItemIndex
End Sub
