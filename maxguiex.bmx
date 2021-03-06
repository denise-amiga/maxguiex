Rem
bbdoc: Maxgui Extended Functions
about:
<p>This is a module to add extended functionality to the maxgui module. Most of the functions work for windows and mac (sorry no linux) but please check documentation for each function to confirm support for the platform.</p>
<p><b>Important!</b><br />The module requires the skn3.systemex module and skn3.funcs module.</p>
End Rem
Module skn3.maxguiex
SuperStrict

ModuleInfo "History: 1.06"
ModuleInfo "History: added CreatePanelEx() function which creates an extended panel that can have new cool stuff"
ModuleInfo "History: added SetPanelExGradient() function to set gradient backgrounds for extended panels"
ModuleInfo "History: 1.05"
ModuleInfo "History: added PointOverGadget() function"
ModuleInfo "History: 1.04"
ModuleInfo "History: fixed broken GadgetWindow() function"
ModuleInfo "History: 1.03"
ModuleInfo "History: Added GetAppResourcesPath() and tweaked h files"
ModuleInfo "History: 1.02"
ModuleInfo "History: Added ScrollTextAreaToTop() ScrollTextAreaToBottom() ScrollTextAreaToCursor() functions"
ModuleInfo "History: 1.01"
ModuleInfo "History: Added SetTextAreaLineSpacing() function"
ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release To Public"

'platform stuff
?Win32
Import brl.map
Import brl.linkedlist
Import maxgui.drivers
Import skn3.systemex

Extern "Win32"
	Function skn3_clientToScreen:Int( hwnd:Int, point:Long Var) = "ClientToScreen@8"
	Function skn3_loadCursorFromFile:Int(path$w) = "LoadCursorFromFileW@4"
	Function skn3_destroyCursor:Int(hcursor:Int) = "DestroyCursor@4"
	Function skn3_addFontResourceEx:Int(path$w,fl:Int,pdv:Int) = "AddFontResourceExW@12"
	Function skn3_addFontMemResourceEx:Int(pbFont:Byte Ptr,cbFont:Int,pdv:Int,pcFonts:Byte Ptr) = "AddFontMemResourceEx@16"
	Function skn3_sendMessagePtr:Int(hwnd:Int,MSG:Int,wParam:Byte Ptr,lParam:Byte Ptr) = "SendMessageW@16"
End Extern

Const BCM_GETIDEALSIZE:Int = BCM_FIRST + 1
Const BCM_GETTEXTMARGIN:Int = BCM_FIRST + 5
Const FR_PRIVATE:Int = 16

Private
Rem
bbdoc: A private type to store the state of a locked listbox.
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
</ul>
<b>Info</b>
<p>See #ListBatchLock, #ListBatchAdd and #ListBatchUnlock.</p>
End Rem
Type Skn3ListBatchLock
	Global all:TList
	
	Field refCount:Int
	Field listBox:TWindowsListBox
	Field index:Int
	Field link:TLink
	Field it:LVITEMW
	Field hwnd:Int
	
	Function Find:Skn3ListBatchLock(Gadget:TGadget)
		' --- find existing lock ---
		If all = Null Return Null
		
		Local listBoxLock:Skn3ListBatchLock
		Local listBoxLockLink:TLink = all.FirstLink()
		While listBoxLockLink
			'get lock
			listBoxLock = Skn3ListBatchLock(listBoxLockLink.value())
			
			'check for already locked
			If listBoxLock.listBox = Gadget Return listBoxLock
			
			'next lock
			listBoxLock = Skn3ListBatchLock(listBoxLockLink.value())
		Wend	
	End Function
	
	Function add(Lock:Skn3ListBatchLock)
		' --- add a new lock ---
		If all = Null all = CreateList()
		Lock.link = all.AddLast(Lock)
	End Function
	
	Function remove(Lock:Skn3ListBatchLock)
		' --- remove a lock ---
		If Lock
			Lock.link.remove()
			Lock.listBox = Null
			lock.it = Null
		EndIf
	End Function
End Type
Public

?MacOs
Import "maxguiex.m"
Import brl.map
Import brl.linkedlist
Import maxgui.drivers
Import skn3.systemex

Extern "macos"
	Function skn3_absoluteFrom:Int[](gadget:Int)
	Function skn3_stringDimensions:Int[](Gadget:Int,text:String,Width:Float)
	Function skn3_setWindowAlwaysOnTop(Window:Int,State:Int)
	Function skn3_bringWindowToTop(Window:Int)
	Function skn3_focusWindow(Window:Int)
	Function skn3_setReadOnly(gadget:Int,yes:Int)
	Function skn3_setMaxLength(gadget:Int,length:Int)
	Function skn3_getMaxLength:Int(gadget:Int)
	Function skn3_loadCustomPointer:Int(path:String,cursorX:Int,cursorY:Int)
	Function skn3_setCustomPointer:Int(cursor:Int)
	Function skn3_freeCustomPointer:Int(cursor:Int)
	Function skn3_currentCursor:Int()
	Function skn3_setColorPickerCustomColors(colors:Int[])
	Function skn3_removeScrollViewBorder(Gadget:Int)
	Function skn3_removeTextFieldBorder(Gadget:Int)
	Function skn3_installFontFromFileWithATS:Int(text:String)
	Function skn3_installFontFromFileWithCT:Int(text:String)
	Function skn3_setTextViewLineSpacing:Int(Gadget:Int,spacing:Float)
	Function skn3_scrollTextAreaToTop(Gadget:Int)
	Function skn3_scrollTextAreaToBottom(Gadget:Int)
	Function skn3_scrollTextAreaToCursor(Gadget:Int)
	Function skn3_getBundlePath:String()
	Function skn3_panelExInit(gadget:TNSGadget)
	Function skn3_panelExSetGradient(gadget:TNSGadget,on:Int,r1:Int,g1:Int,b1:Int,r2:Int,g2:Int,b2:Int,vertical:Int)
EndExtern
?


Rem
bbdoc: An object that stores a custom cursor file.
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
	<li>Mac</li>
</ul>
<b>Info</b>
<p>This should be passed to #SetCustomPointer and #FreeCustomPointer.</p>
End Rem
Type Skn3CustomPointer
	Global all:TMap
	Field path:String
	Field pointer:Int
	Field refCount:Int
End Type

Private
Rem
bbdoc: A windows data structure.
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
</ul>
<b>Info</b>
<p>This is for modifying the rich edit control.</p>
End Rem
Type PARAFORMAT2
	Field cbSize:Int
	Field dwMask:Int
	Field wNumbering:Short
	Field wEffects:Short
	Field dxStartIndent:Int
	Field dxRightIndent:Int
	Field dxOffset:Int
	Field wAlignment:Short
	Field cTabCount:Short = 32
	Field rgxTabs00:Int,rgxTabs01:Int,rgxTabs02:Int,rgxTabs03:Int
	Field rgxTabs10:Int,rgxTabs11:Int,rgxTabs12:Int,rgxTabs13:Int
	Field rgxTabs20:Int,rgxTabs21:Int,rgxTabs22:Int,rgxTabs23:Int
	Field rgxTabs30:Int,rgxTabs31:Int,rgxTabs32:Int,rgxTabs33:Int
	Field rgxTabs40:Int,rgxTabs41:Int,rgxTabs42:Int,rgxTabs43:Int
	Field rgxTabs50:Int,rgxTabs51:Int,rgxTabs52:Int,rgxTabs53:Int
	Field rgxTabs60:Int,rgxTabs61:Int,rgxTabs62:Int,rgxTabs63:Int
	Field rgxTabs70:Int,rgxTabs71:Int,rgxTabs72:Int,rgxTabs73:Int
	Field dySpaceBefore:Int
	Field dySpaceAfter:Int
	Field dyLineSpacing:Int
	Field sStyle:Short
	Field bLineSpacingRule:Byte
	Field bOutlineLevel:Byte
	Field wShadingWeight:Short
	Field wShadingStyle:Short
	Field wNumberingStart:Short
	Field wNumberingStyle:Short
	Field wNumberingTab:Short
	Field wBorderSpace:Short
	Field wBorderWidth:Short
	Field wBorders:Short
End Type
Public

'internal functions
Private
Function TrimAndFixPath:String(path:String,slash:String="/",keepRootSlash:Int=False)
	'--- fix a path ---
	'check for no path
	If path.Length = 0 Return ""
	
	'fix slashes
	path = path.Replace("\","/")
	If slash <> "/" path = path.Replace("/",slash)
	
	'trim slashes
	Local index:Int
	Local startIndex:Int = 0
	Local hasRootSlash:Int = False
	Local slashAsc:Int = Asc(slash)
	
	For index = 0 Until path.length
		If path[index] <> 32 And path[index] <> slashAsc Exit
		startIndex = index+1
		hasRootSlash = True
	Next
	
	Local length:Int = path.length-startIndex
	For index = path.Length-1 To 0 Step -1
		If path[index] <> 32 And path[index] <> slashAsc Exit
		length :- 1
	Next
	If length <= 0 Return ""
	
	'build new path
	path = path[startIndex..startIndex+Length]
	If hasRootSlash And keepRootSlash path = slash+path
	
	'return the result
	Return path
End Function

Function IncBinToDisk:String(path:String)
	' --- just a helper function for copying an incbin to disk ---
	If path[0..8].Tolower() = "incbin::"
		'setup real path
		Local pathBase:String = TrimAndFixPath(GetTempDirectory(),"/",True)+"/"
		Local pathCount:String = ""
		Local pathFile:String = StripDir(path[8..])
		
		While FileType(pathBase+pathCount+pathFile)
			pathCount = Int(pathCount)+1
		Wend
		
		'create final path
		Local path2:String = pathBase+pathCount+pathFile

		'copy file to temporary location
		Local in:TStream = ReadStream(path)
		If in = Null Return ""
		Local out:TStream = WriteStream(path2)
		If out = Null
			CloseStream(in)
			Return ""
		EndIf
		CopyStream(in,out)
		CloseFile(out)
		CloseStream(in)
		
		'return temp path
		Return path2
	EndIf
	
	'Return fail
	Return ""
End Function

Function PointInRect:Int(pointX:Float,pointY:Float,rectX:Float,rectY:Float,rectWidth:Float,rectHeight:Float)
	' --- returns true if point is inside rect ---
	Return pointX >= rectX And pointX < rectX + rectwidth And pointY >= rectY And pointY < rectY + rectHeight
End Function
Public


'api functions
Rem
bbdoc: Request the size of the scrollbars for the current operating system. <b>[Win Mac Linux]</b>
returns: An int.
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
	<li>Mac</li>
	<li>Linux</li>
</ul>
<b>Info</b>
<p>This function currently uses a hard coded value.</p>
End Rem
Function RequestScrollbarSize:Int()
	' --- return the scrollbar size ---
	'just hardcode this for now
	Return 18
End Function

Rem
bbdoc: Change the height of a combobox. <b>[Win]</b>
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
</ul>
<b>Info</b>
<p>This changes the height of the combobox gadget.</p>
End Rem
Function SetComboBoxHeight(comboBox:TGadget,Height:Int)
	' --- resize a combo box to exact proportions ---
	?Win32
		'windows 7 + vista combobox height should be -6 (not tested on XP)
		SendMessageA(QueryGadget(comboBox,1),CB_SETITEMHEIGHT,-1,Height-6)
		RedrawGadget(comboBox)
	?
End Function

Rem
bbdoc: Get the screen position of a gadget. <b>[Win Mac]</b>
returns: An int array with 2 elements. 0 = x, 1 = y
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
	<li>Mac</li>
</ul>
<b>Info</b>
<p>This function gets the desktop x,y position of a given gadget.</p>
End Rem
Function GadgetScreenPosition:Int[](gadget:TGadget,client:Int=False)
	' --- get the screen position of a gadget ---
	?Win32
		Local point:Long
		If client
			skn3_clientToScreen(Gadget.Query(QUERY_HWND_CLIENT),point)
		Else
			skn3_clientToScreen(Gadget.Query(QUERY_HWND),point)
		EndIf
		
		Local Position:Int[2]
		Position[0] = Int Ptr( Varptr point)[0]
		Position[1] = Int Ptr( Varptr point)[1]
	?MacOs
		Local Position:Int[] = skn3_absoluteFrom(QueryGadget(gadget,QUERY_NSVIEW_CLIENT))
	?
	Return Position
End Function

Rem
bbdoc: Determin if a point is over a gadget. <b>[Win]</b>
returns: True if over the target gadget.
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
	<li>Mac</li>
</ul>
<b>Info</b>
<p>If a source gadget is provided it is assumed that the pointX and pointY are local coordinates for that source gadget (for example: local coordinates given in EVENT_MOUSEMOVE).</p>
<p>If no source is provided teh function will assume the point is already in screen coordinates.</p>
End Rem
Function PointOverGadget:Int(pointX:Int,pointY:Int,targetGadget:TGadget,sourceGadget:TGadget=Null)
	' --- returns true if the point is over the gadget ---
	'check for skipping
	If targetGadget = Null Or GadgetHidden(targetGadget) Return False
	
	'calculate point if source gadget is provided
	If sourceGadget
		Local sourcePosition:Int[] = GadgetScreenPosition(sourceGadget)
		pointX = sourcePosition[0] + pointX
		pointY = sourcePosition[1] + pointY
	EndIf
	
	'get dimensions for gadget
	Local targetPosition:Int[] = GadgetScreenPosition(targetGadget)
	'test
	Return PointInRect(pointX,pointY,targetPosition[0],targetPosition[1],GadgetWidth(targetGadget),GadgetHeight(targetGadget))
End Function

Rem
bbdoc: Disable redrawing of a gadget. <b>[Win]</b>
returns: True if operation was supported by system.
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
</ul>
<b>Info</b>
<p>This will disable any redraw operations on the gadget. This call must be followed by #EnableGadgetRedraw to reenable painting.</p>
<p>It is not required to disable gadget redrawing on mac as this is partly handled by the operating system anyway!</p>
End Rem
Function DisableGadgetRedraw:Int(gadget:TGadget)
	' --- change a gadget repaint ability ---
	'returns true if the system allowed the operation
	?Win32
		SendMessageW(QueryGadget(gadget,QUERY_HWND),WM_SETREDRAW,False,0)
		Return True
	?
End Function

Rem
bbdoc: Enable redraw of the specified gadget. <b>[Win]</b>
returns: True if operation was supported by system.
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
</ul>
<b>Info</b>
<p>This will renable redraw operations on a gadget. Remember to call RedrawGadget(gadget) after this so that your gadget paints any changes you have made. A good way to code this in a cross platform fashion is to see if #EnableGadgetRedraw returns true in which case the operating system allowed the operation and the gadget needs repainting. Redrawing can be disabled using #DisableGadgetRedraw.</p>
End Rem
Function EnableGadgetRedraw:Int(gadget:TGadget)
	' --- change a gadget repaint ability ---
	'returns true if the system allowed the operation
	?Win32
		SendMessageW(QueryGadget(gadget,QUERY_HWND),WM_SETREDRAW,True,0)
		Return True
	?
End Function

Rem
bbdoc: Open a system message box with title and message. <b>[Win Mac Linux]</b>
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
	<li>Mac</li>
	<li>Linux</li>
</ul>
<b>Info</b>
<p>This uses the built in blitzmax Notify command but changes the apptitle to enable custom titles.</p>
End Rem
Function MessageBox(title:String,message:String,parent:TGadget=Null)
	' --- create a system message box ---
	'For now we will just fake it
	Local oldTitle:String = AppTitle
	AppTitle = title
	Notify(message,False)
	AppTitle = oldTitle
End Function

Rem
bbdoc: Get the size a gadget should be with the given text and max width. <b>[Win Mac]</b>
returns: An int array with 2 elements. 0 = x,  1 = y
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
	<li>Mac</li>
</ul>
<b>Info</b>
<p>This function is very powerful and will let you resize your gadgets according to the text within! If you provide a max width then the function will work out the width and height for your gadget confined to that max width. If no max width is provided then the function will return a very wide gadget dimension</p>
<p>If this function is used with a button that has images then this will be taken into account. The function currently is well supported for buttons and labels! Other gadgets may not work as well!</p>
End Rem
Function GadgetSizeForString:Int[](gadget:TGadget,text:String,maxWidth:Int=0)
	' --- get dimensions of a string using the gadget as a context ---
	?Win32
		'get device context to the gadget
		Local hwnd:Int = QueryGadget(gadget,QUERY_HWND)
				
		'do stuff based on gadget class
		Select GadgetClass(gadget)
			Case GADGET_BUTTON
				'button, we can use the windows ideal button size message which incorporates images as well!
				Local size:Int[] = [maxWidth,0]
				
				'disable redraw on gadget
				SendMessageW(hwnd,WM_SETREDRAW,False,0)
				
				'change text of gadget
				Local oldText:String = GadgetText(gadget)
				SetGadgetText(gadget,text)
				
				'test for ideal size
				SendMessageW(hwnd,BCM_GETIDEALSIZE,0,Int Byte Ptr(size))
				
				'restore the gadget
				SetGadgetText(Gadget,oldText)
				SendMessageW(hwnd,WM_SETREDRAW,True,0)
				
				'return the result
				Return size
			Default
				'default action is to use the DrawText operation to figure out size
				Local dc :Int = GetDC(hwnd)
				
				'get and set font used by the control
				Local font:Int = SendMessageW(hwnd,WM_GETFONT,0,0)
				SelectObject(dc,font)
				
				'get the client rect (doing this just because its worth it)
				Local rect:Int[] = [0,0,maxWidth,0]
				'text rect flags
				Local flags:Int = DT_CALCRECT | DT_NOCLIP
				If maxWidth > 0 flags :| DT_WORDBREAK
				
				'calculate the bounding
				DrawTextW(dc,text,-1,rect,flags)
				
				'release device context
				ReleaseDC(hwnd,dc)
				
				'return the result
				Return [rect[2],rect[3]]
		End Select
		
	?MacOs
		Local result:Int[] = skn3_stringDimensions(QueryGadget(gadget,QUERY_NSVIEW_CLIENT),text,maxWidth)
		Return result
	?
End Function

Rem
bbdoc: This is mainly for use with custom proxy gadget constructor functions to get the real parent gadget/proxy of a given gadget/proxy. <b>[Win Mac Linux]</b>
returns: A TGadget.
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
	<li>Mac</li>
	<li>Linux</li>
</ul>
<b>Info</b>
<p>This is just a copy of the private function in maxgui.</p>
End Rem
Function GetCreationGroup:TGadget(Gadget:TGadget)
	Local tmpProxy:TProxyGadget = TProxyGadget(gadget)
	If tmpProxy Then Return GetCreationGroup(tmpProxy.proxy)
	Return gadget
EndFunction

Rem
bbdoc: Change a gadget to be readonly. <b>[Win Mac]</b>
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
	<li>Mac</li>
</ul>
<b>Info</b>
<p>This currently works on textfields and textareas and sets the gadgets to be readonly without having a disabled style.</p>
End Rem
Function SetGadgetReadOnly(gadget:TGadget,yes:Int)
	' --- set a gadget readonly state ---
	'this only works for text entry gadgets
	Select GadgetClass(gadget)
		Case GADGET_TEXTAREA,GADGET_TEXTFIELD
			?Win32
				Local hwnd:Int = QueryGadget(gadget,QUERY_HWND)
				SendMessageW(hwnd,EM_SETREADONLY,yes,0)
			?MacOs
				skn3_setReadOnly(QueryGadget(gadget,QUERY_NSVIEW),yes = False)
			?
	End Select
End Function

Rem
bbdoc: Set the maximum number of characters a gadget can contain. <b>[Win Mac]</b>
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
	<li>Mac</li>
</ul>
<b>Info</b>
<p>This function currently works with textfields and textareas and allows you to specify a maximum number of characters the user can enter. This will work on the os level so you dont have to manually limit text with blitz events. Use #GetGadgetMaxLength to get the current max length value.</p>
End Rem
Function SetGadgetMaxLength(gadget:TGadget,length:Int=0)
	' --- change the max length of a gadget ---
	Select GadgetClass(gadget)
		Case GADGET_TEXTFIELD,GADGET_TEXTAREA
			?Win32
				If length < 0 length = 0
				SendMessageW(QueryGadget(gadget,QUERY_HWND),EM_SETLIMITTEXT,length,0)
			?MacOs
				If length < 0 length = 0
				skn3_setMaxLength(QueryGadget(gadget,QUERY_NSVIEW),length)
			?
	End Select
End Function

Rem
bbdoc: Get the maximum number of characters a gadget can contain. <b>[Win Mac]</b>
returns: An int.
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
	<li>Mac</li>
</ul>
<b>Info</b>
<p>This function currently works with textfields and text areas.</p>
End Rem
Function GetGadgetMaxLength:Int(gadget:TGadget)
	' --- get the max length of a gadget ---
	Select GadgetClass(gadget)
		Case GADGET_TEXTFIELD,GADGET_TEXTAREA
			?Win32
				Return SendMessageW(QueryGadget(gadget,QUERY_HWND),EM_GETLIMITTEXT,0,0)
			?MacOs
				Return skn3_getMaxLength(QueryGadget(gadget,QUERY_NSVIEW))
			?
		Default
			Return 0
	End Select
End Function

Rem
bbdoc: Load a custom pointer file from disk or incbin. <b>[Win Mac]</b>
returns: A #Skn3CustomPointer object.
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
	<li>Mac</li>
</ul>
<b>Info</b>
<p>This will attempt to load a <b>.cur</b> file and return an object to represent it. The cursor file should contain a single cursor and be of the <b>.cur</b> filetype. A cursor hotspot is supported on both windows and mac so you can have a center that is not 0,0. You must use your cursor creation software to set a hotspot. Use #SetCustomPointer to set the current pointer to this and #FreeCustomPointer() to free it.</p>
End Rem
Function LoadCustomPointer:Skn3CustomPointer(path:String)
	' --- this will load a cursor ---
	Local pointer:Skn3CustomPointer
	Local path2:String = IncBinToDisk(path)
	Local deletePath2:Int = False
	If path2.length = 0
		path2 = path
	Else
		deletePath2 = True
	EndIf
	
	'check for cache
	If Skn3CustomPointer.all = Null
		' make sure the cursor store is created
		Skn3CustomPointer.all = CreateMap()
	Else
		'check existance
		pointer = Skn3CustomPointer(Skn3CustomPointer.all.ValueForKey(path))
	EndIf
	
	'create new pointer
	If pointer = Null
		'create custom pointer
		pointer = New Skn3CustomPointer
		pointer.path = path
		Skn3CustomPointer.all.Insert(path,pointer)

		'load in os (using path2)
		?Win32
		pointer.pointer = skn3_loadCursorFromFile(path2)
		?MacOs
		'first get the offset
		Local offset:Int[] = ExtractCursorHotspot(path2)
		'now load the pointer
		pointer.pointer = skn3_loadCustomPointer(path2,offset[0],offset[1])
		?
	End If
	
	'delete temp file?
	If deletePath2 DeleteFile(path2)
		
	'return pointer
	If pointer.pointer <> 0
		'increase reference count
		pointer.refCount :+ 1
		Return pointer
	EndIf
End Function

Rem
bbdoc: Set the current pointer to a custom pointer loaded with LoadCustomPointer. <b>[Win Mac]</b>
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
	<li>Mac</li>
</ul>
<b>Info</b>
<p>On mac please make sure you do not call this function at the start of execution as it will not work. Calling this function must be done in response to something else happening for example when the mouse enters a canvas. Use #LoadCustomCursor to load a cursor file and #FreeCustomCursor to free your loaded cursor.</p>
End Rem
Function SetCustomPointer(pointer:Skn3CustomPointer)
	' --- set the pointer up in os ---
	If pointer
		lastPointer = -1
		?Win32
		SetCursor(pointer.pointer)
		TWindowsGUIDriver._cursor = pointer.pointer
		If TWindowsTextArea._oldCursor Then TWindowsTextArea._oldCursor = pointer.pointer
		?MacOs
		skn3_setCustomPointer(pointer.pointer)
		?
	EndIf
End Function

Rem
bbdoc: Free a Skn3CustomCursor custom cursor object. <b>[Win Mac]</b>
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
	<li>Mac</li>
</ul>
<b>Info</b>
<p>Frees a custom cursor previously loaded with #LoadCustomCursor.</p>
End Rem
Function FreeCustomPointer(pointer:Skn3CustomPointer)
	' --- free the pointer ---
	If pointer
		'decrease ref coutn then check
		pointer.refCount :- 1
		If pointer.refCount = 0
			'free in maxguiex
			Skn3CustomPointer.all.remove(pointer.path)
			
			'free in os
			?Win32
			'check if we need to reset in maxgui
			If TWindowsGUIDriver._cursor = pointer.pointer SetPointer(POINTER_DEFAULT)
			
			skn3_destroyCursor(pointer.pointer)
			pointer.pointer = 0
			?MacOs
			If skn3_currentCursor() = pointer.pointer SetPointer(POINTER_DEFAULT)
			skn3_freeCustomPointer(pointer.pointer)
			?
		EndIf
	EndIf
End Function

Rem
bbdoc: Utility for extracting x,y representing the hotspot of a .cur file. <b>[Win Mac Linux]</b>
returns: An int array with 2 elements. 0 = x, 1 = y
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
	<li>Mac</li>
	<li>Linux</li>
</ul>
<b>Info</b>
<p>This function will open the <b>.cur</b> file and extract the x,y offset from the file data.</p>
End Rem
Function ExtractCursorHotspot:Int[](path:String,index:Int=0)
	' --- function to extract the hotspot x,y from a cursor ---
	Local result:Int[2]
	
	Local file:TStream = ReadFile("littleendian::"+path)
	If file
		'reserved
		file.seek(2)
		
		'only process cursor types
		Local temp:Int = file.ReadShort()
		If temp = 2
			'only process if valid index
			temp = file.ReadShort()
			If index < temp
				'only process if offset isnt beyond file length
				temp = 6+(12*index)+4
				If temp < file.size()
					file.seek(temp)
					result[0] = file.ReadShort()
					result[1] = file.ReadShort()
				EndIf
			EndIf
		EndIf
		
		'close the stream
		file.close()
	EndIf
	
	'return the result
	Return result
End Function

Rem
bbdoc: Lock a listbox and start a batch add operation. <b>[Win]</b>
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
</ul>
<b>Info</b>
<p>This function is used to prepare a locking session and lock a listbox gadget so items can be added to it in batch. See #ListBatchAdd and #ListBatchUnlock for additional info.</p>
End Rem
Function ListBatchLock(Gadget:TGadget)
	' --- lock a particular gadget for mass item update ---
	?Win32
		'check if already locked
		Local Lock:Skn3ListBatchLock = Skn3ListBatchLock.Find(Gadget)
		If Lock
			'increase ref count only!
			Lock.refCount :+ 1
			Return
		EndIf
		
		'check this is a windows listbox
		Local listBox:TWindowsListBox = TWindowsListBox(Gadget)
		If listBox = Null Return
		
		'creat a new lock
		Lock = New Skn3ListBatchLock
		Lock.refCount = 1
		Lock.listBox = listBox
		Lock.index = listBox.items.Length
		Lock.it = New LVITEMW 
		Lock.hwnd = QueryGadget(listBox,QUERY_HWND)
		
		'prepare the listbox
		listBox.DeSensitize()
		
		'add to locks
		Skn3ListBatchLock.add(Lock)
	?
End Function

Rem
bbdoc: Add an item to a listbox in batch mode. <b>[Win]</b>
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
</ul>
<b>Info</b>
<p>If you call this in an unsupported platform then the default maxgui behaviour will be used</p>
<p>When a lsitbox has been locked with #ListBatchLock you can then use this function to add gadget items. The items wont properly appear in the listbox until #ListBatchUnlock is called. Lock attempts are reference counted so can be nested</p>
End Rem
Function ListBatchAdd(Gadget:TGadget,text:String,flags:Int,icon:Int,tip:String,extra:Object=Null)
	' --- add an item to a locked gadget ---
	?Win32
		'check if the gadget is locked
		Local Lock:Skn3ListBatchLock = Skn3ListBatchLock.Find(Gadget)
		
		'check for maxgui action (as not locked)
		If Lock = Null
			AddGadgetItem(Gadget,text,flags,icon,tip,extra)
			Return
		End If
		
		'so now lets do the add operation
		'create the gadget item
		Local item:TGadgetItem = New TGadgetItem
		item.Set(text,tip,icon,extra,flags)
		
		'add item to maxgui gadget
		Gadget.items = Gadget.items[..Lock.index+1]
		Gadget.items[Lock.index] = item
				
		'add item to os
		Lock.it.Mask = LVIF_TEXT|LVIF_DI_SETITEM
		Lock.it.iItem = Lock.index
		Lock.it.pszText = item.text.toWString()
				
		'If icon>=0 Then
			Lock.it.mask:|LVIF_IMAGE
			Lock.it.iImage = item.icon
		'EndIf
				
		SendMessageW(Lock.hwnd,LVM_INSERTITEMW,0,Int Byte Ptr(Lock.it))
		MemFree(Lock.it.pszText)
		
		'increase index for next item
		Lock.index :+ 1
		
	?Not Win32
		'revert to built in maxgui action
		AddGadgetItem(Gadget,text,flags,icon,tip,extra)
	?
End Function

Rem
bbdoc: Unlock a listbox and update for any items that were added with #ListBatchAdd. <b>[Win]</b>
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
</ul>
<b>Info</b>
<p>The locking is reference counted so the listbox will only unlock when its reference count reaches 0. Each call to #ListBatchLock must be matched with #ListbatchUnlock. See #ListBatchLock and #ListBatchLock for more info.</p>
End Rem
Function ListBatchUnlock(Gadget:TGadget)
	' --- unlock a particular item for mass item update ---
	?Win32
		'check if locked
		Local Lock:Skn3ListBatchLock = Skn3ListBatchLock.Find(Gadget)
		If Lock = Null Return
		
		'decrease refcount
		Lock.refCount :- 1
		
		'check if ref count means proper unlock
		If Lock.refCount = 0
			'do the unlock in os
			SendMessageW(Lock.hwnd,LVM_SETCOLUMNWIDTH,0,-2)
			If Not Lock.listBox.IsSingleSelect() Then Lock.listBox.SelectionChanged()
			Lock.listBox.Sensitize()
			
			'remove the lock
			Skn3ListBatchLock.remove(Lock)
		EndIf
	?
End Function

Rem
bbdoc: Find the first parent window the provided gadget belongs to. <b>[Win Mac Linux]</b>
returns: A TGadget or Null.
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
	<li>Mac</li>
	<li>Linux</li>
</ul>
<b>Info</b>
<p>This function will walk the parent tree to find the window the given gadget belogns to.</p>
End Rem
Function GadgetWindow:TGadget(Gadget:TGadget)
	' --- this will locate a gadgets window ---
	Local parent:TGadget = GadgetGroup(Gadget)
	While parent
		If GadgetClass(parent) = GADGET_WINDOW Return parent
		parent = GadgetGroup(parent)
	Wend
End Function

Rem
bbdoc: Force a window to always be on the top of other windows. <b>[Win Mac]</b>
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
	<li>Mac</li>
</ul>
<b>Info</b>
<p>This is like sticking a post it note on your monitor and will make your window stay above any other running applications.</p>
End Rem
Function SetWindowAlwaysOnTop(Window:TGadget,State:Int=False)
	' --- set a window to stay on top ---
	?Win32
		Local hwnd:Int = QueryGadget(Window,QUERY_HWND)
		If hwnd
			If State
				'on top
				SetWindowPos(hwnd,HWND_TOPMOST,0,0,0,0,SWP_NOSIZE | SWP_NOMOVE | SWP_NOACTIVATE)
			Else
				SetWindowPos(hwnd,HWND_NOTOPMOST,0,0,0,0,SWP_NOSIZE | SWP_NOMOVE | SWP_NOACTIVATE)
			EndIf
		EndIf
	?MacOs
		skn3_setWindowAlwaysOnTop(QueryGadget(Window,QUERY_NSVIEW),State)
	?
End Function

Rem
bbdoc: Bring the provided window to the top of the screen (but dont stick it there). <b>[Win Mac]</b>
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
	<li>Mac</li>
</ul>
<b>Info</b>
<p>This is useful if you need to force focus your window to the top of the desktop.</p>
End Rem
Function BringWindowToTop(Window:TGadget)
	' --- brings the window to the top of the z order ---
	?Win32
		Local hwnd:Int = QueryGadget(Window,QUERY_HWND)
		If hwnd SetWindowPos(hwnd,HWND_TOP,0,0,0,0,SWP_NOSIZE | SWP_NOMOVE | SWP_NOACTIVATE)
	?MacOs
		skn3_bringWindowToTop(QueryGadget(Window,QUERY_NSVIEW))
	?	
End Function

Rem
bbdoc: Forces a window to be focused. <b>[Win Mac]</b>
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
	<li>Mac</li>
</ul>
<b>Info</b>
<p>This forces the provided window to be set to focused via HWND or NSVIEW and bypasses the maxgui internals. There are sometimes issues with the built in maxgui gadget focus/activation commands so this is a clean way of solving it.</p>
End Rem
Function FocusWindow(Window:TGadget)
	' --- set a window to focus and bypass weird maxgui stuff---
	?Win32
		Local hwnd:Int = QueryGadget(Window,QUERY_HWND)
		If hwnd SetFocus(hwnd)
	?MacOs
		'cocoa maxgui already does this alright...
		skn3_focusWindow(QueryGadget(Window,QUERY_NSVIEW))
	?
End Function

Rem
bbdoc: Helper function to turn a gadget into its respective os handle. <b>[Win Mac Linux]</b>
returns: An int.
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
	<li>Mac</li>
	<li>Linux</li>
</ul>
<b>Info</b>
<p>Just a shortcut for when developing cross-platform apps.</p>
End Rem
Function GadgetToInt:Int(Gadget:TGadget)
	' --- return a gadget as an int ---
	?Win32
		Return QueryGadget(Gadget,QUERY_HWND)
	?MacOs
		Return QueryGadget(Gadget,QUERY_NSVIEW)
	?Linux
		Return QueryGadget(GadgetX,QUERY_FLWIDGET)
	?
End Function

Rem
bbdoc: Change the custom colors for the color picker dialogue. <b>[Win Mac]</b>
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
	<li>Mac (not fully)</li>
</ul>
<b>Info</b>
<p>This function lets you specify the custom colors that will be displayed on the color picker dialogue. The function doesn't seem to fully work on the mac mode yet, if you change one of the custom colors via the dialogue then further changes by calling #SetcolorPickercustomColors to that particular color box will not work.</p>
<p>On windows you can pass in upto 15 colors in hex <b>ffffff</b> format</p>
<p>On mac you can pass in upto 14 colors in hex <b>ffffff</b> format</p>
<p>Depending on your platform this function will speak to the os and also the maxgui driver. See also #ClearColorPickerCustomColors</p>
End Rem
Function SetColorPickerCustomColors(colors:Int[])
	' --- this will modify the built in values in maxgui class ---
	?Win32
		If colors.length < 16
			Local index:Int = colors.length
			colors = colors[..16]
			For index = index Until 16
				colors[index] = $ffffff
			Next
		EndIf
		
		TWindowsGUIDriver._customcolors = colors
	?MacOs
		If colors And colors.Length > 0
			'fill in blanks
			If colors.length < 15
				Local index:Int = colors.length
				colors = colors[..15]
				For index = index Until 15
					colors[index] = $ffffff
				Next
			EndIf
			skn3_setColorPickerCustomColors(colors)
		EndIf
		
	?
End Function

Rem
bbdoc: Reset all color picker dialogue custom colors to white. <b>[Win Mac]</b>
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
</ul>
<b>Info</b>
<p>Currently windows only it is a shortcut for changing all custom colors to white. See also #SetColorPickercustomColors</p>
End Rem
Function ClearColorPickerCustomColors()
	' --- reset the custom colors in color picker ---
	?Win32
		For Local index:Int = 0 Until 16
			TWindowsGUIDriver._customcolors[index] = $FFFFFF
		Next		
	?MacOs
		
	?
End Function

Rem
bbdoc: Redraw the frame/border/non-client part of a given gadget. <b>[Win]</b>
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
</ul>
<b>Info</b>
<p>If you are extending maxgui there are times you need to send a more detailed Redraw message to a speciffic gadget.</p>
End Rem
Function RedrawGadgetFrame(Gadget:TGadget)
	?Win32
		Local hwnd:Int = QueryGadget(Gadget,QUERY_HWND)
		If hwnd
			SetWindowPos( hwnd,0, 0,0,0,0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE | SWP_FRAMECHANGED)
			RedrawWindow( hwnd, Null,Null, RDW_INVALIDATE | RDW_NOCHILDREN | RDW_UPDATENOW | RDW_FRAME)
		EndIf
	?
End Function

Rem
bbdoc: Hide default os borders for gadgets. <b>[Win]</b>
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
	<li>Mac</li>
</ul>
<b>Info</b>
<p>This will let you turn off borders for certain gadgets. It currently works for textareas and textfields only.</p>
End Rem
Function HideGadgetBorder(Gadget:TGadget)
	' --- this will hide the border on certain gadgets ---
	?Win32
		Select GadgetClass(Gadget)
			Case GADGET_TEXTAREA,GADGET_TEXTFIELD,GADGET_LISTBOX
				Local hwnd:Int = QueryGadget(Gadget,QUERY_HWND)
				If hwnd
					Local Style:Int = GetWindowLongW(hwnd,GWL_STYLE)
					Local styleEx:Int = GetWindowLongW(hwnd,GWL_EXSTYLE)
					
					'remove border
					Local changed:Int = False
					If Style & WS_BORDER
						SetWindowLongW(hwnd,GWL_STYLE,Style & ~WS_BORDER)
						changed = True
					EndIf
					If styleEx & WS_EX_CLIENTEDGE
						SetWindowLongW(hwnd,GWL_EXSTYLE,styleEx & ~WS_EX_CLIENTEDGE)
						changed = True
					EndIf
					
					'repaint
					If changed RedrawGadgetFrame(Gadget)
				EndIf
		EndSelect
	?MacOs
		Select GadgetClass(Gadget)
			Case GADGET_TEXTFIELD
				Local nsview:Int = QueryGadget(Gadget,QUERY_NSVIEW)
				If nsview skn3_removeTextFieldBorder(nsview)
		EndSelect
	?
End Function

Rem
bbdoc: Install a custom font file from disk or incbin. <b>[Win Mac]</b>
returns: An int if successful.
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
	<li>Mac</li>
</ul>
<b>Info</b>
<p>This function will install the provided font file for the time the application is running. The font can then be loaded as normal with the LoadGuiFont() function. this function is confirmed to work with ttf on mac and windows but has not be confirmed with other font formats. It is important that when using LoadGuiFont that you are using the correct font face name. The font face name wont match the fonts file name so please double check this!</p>
<p>Due to an issue with loading resources from a memory pointer on the mac the font will be saved to disk in a temp file. The temp file is handled via system calls so you should not face any security problems!</p>
End Rem
Function InstallGuiFont:Int(path:String)
	' --- this allows temporary font installation ---
	?Win32
		'is this an inc bin or from disk?
		If path[0..8].ToLower() = "incbin::"
			'install the font from incbin
			path = path[8..]
			Local installed:Int
			Return skn3_addFontMemResourceEx(IncbinPtr(path),IncbinLen(path),0,Varptr(installed)) <> 0
		Else
			'install the font from disk
			Print "path = "+path
			Return skn3_addFontResourceEx(path,FR_PRIVATE,0) <> 0
		EndIf
	?MacOs
		'unforuntately seems to be a bug outside of my knowledge with incbin files
		'instead we will copy to a temp folder
		'make should use app bundle instead of incbins anyway
		
		Local result:Int = False
		
		'get temp file path if this is an incbin
		Local path2:String = IncBinToDisk(path)
		
		'check for incbin or normal path
		Local deletePath2:Int = False
		If path2.length = 0
			path2 = path
		Else
			deletePath2 = True
		EndIf
		
		'install the font from disk
		If FileType(path2) = FILETYPE_FILE
			If GetOsVersion() < OSX_SNOW_LEOPARD
				'use depreciated api
				result = skn3_installFontFromFileWithATS(path2)
			Else
				'use api for snow leopard and over
				result = skn3_installFontFromFileWithCT(path2)
			EndIf
		EndIf
		
		'delete temp file if needed
		If deletePath2 DeleteFile(path2)
		
		Return result
	?
End Function

Rem
bbdoc: change the linespacing for a textarea. <b>[Win Mac]</b>
returns: True if success.
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
	<li>Mac</li>
</ul>
<b>Info</b>
<p>The value for spacing is the current line height multiple so if you provide a value of 1.0 the line spacing will be normal. If you provide a value of 2.0 the line spacing will be doubled!</p>
End Rem
Function SetTextareaLineSpacing:Int(Gadget:TGadget,lineSpacing:Float)
	' --- change the line spacing of a textarea ---
	If GadgetClass(Gadget) = GADGET_TEXTAREA
		?Win32
			'use a paraformat2 object to message teh text area
			Local hwnd:Int = QueryGadget(Gadget,QUERY_HWND)
			If hwnd
				Local P:PARAFORMAT2 = New PARAFORMAT2
				P.cbSize = SizeOf(P)
				P.dwMask = PFM_LINESPACING
				P.bLineSpacingRule = 5
				P.dyLineSpacing = lineSpacing * 20
				Return skn3_sendMessagePtr(hwnd,EM_SETPARAFORMAT,Null,P) <> 0
			EndIf
		?MacOs
			'call glue code to do the hard work
			'fix line spacing value for mac
			lineSpacing = lineSpacing - 1
			If lineSpacing < 0 lineSpacing = 0.0
			
			Local nsView:Int = QueryGadget(Gadget,QUERY_NSVIEW)
			Return nsView <> 0 And skn3_setTextViewLineSpacing(nsView,lineSpacing) = True
		?
	EndIf
End Function

Rem
bbdoc: Scroll a textarea to the top. <b>[Win Mac]</b>
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
	<li>Mac</li>
</ul>
<b>Info</b>
<p>This will scroll a text area to the top without changing the cursor position!</p>
End Rem
Function ScrollTextAreaToTop(Gadget:TGadget)
	' --- change the scroll position of the textarea to top ---
	If GadgetClass(Gadget) = GADGET_TEXTAREA
		?Win32
			Local hwnd:Int = QueryGadget(Gadget,QUERY_HWND)
			If hwnd SendMessageW(hwnd,EM_SCROLL,SB_TOP,0)
		?MacOs
			Local nsView:Int = QueryGadget(Gadget,QUERY_NSVIEW)
			If nsView skn3_scrollTextAreaToTop(nsView)
		?
	EndIf
End Function

Rem
bbdoc: Scroll a textarea to the bottom. <b>[Win Mac]</b>
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
	<li>Mac</li>
</ul>
<b>Info</b>
<p>This will scroll a text area to the bottom without changing the cursor position!</p>
End Rem
Function ScrollTextAreaToBottom(Gadget:TGadget)
	' --- change the scroll position of the textarea to bottom ---
	If GadgetClass(Gadget) = GADGET_TEXTAREA
		?Win32
			Local hwnd:Int = QueryGadget(Gadget,QUERY_HWND)
			If hwnd SendMessageW(hwnd,EM_SCROLL,SB_BOTTOM,0)
		?MacOs
			Local nsView:Int = QueryGadget(Gadget,QUERY_NSVIEW)
			If nsView skn3_scrollTextAreaToBottom(nsView)
		?
	EndIf
End Function

Rem
bbdoc: Scroll a textarea to the cursor. <b>[Win Mac]</b>
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
	<li>Mac</li>
</ul>
<b>Info</b>
<p>This will scroll a text area to the current cursor position!</p>
End Rem
Function ScrollTextAreaToCursor(Gadget:TGadget)
	' --- scroll the textarea to the position of the cursor ---
	If GadgetClass(Gadget) = GADGET_TEXTAREA
		?Win32
			Local hwnd:Int = QueryGadget(Gadget,QUERY_HWND)
			If hwnd SendMessageW(hwnd,EM_SCROLLCARET,0,0)
		?MacOs
			Local nsView:Int = QueryGadget(Gadget,QUERY_NSVIEW)
			If nsView skn3_scrollTextAreaToCursor(nsView)
		?
	EndIf
End Function

Rem
bbdoc: Get a path to the resources for this app. <b>[Win Mac]</b>
returns: a string continaing a path.
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
	<li>Mac</li>
</ul>
<b>Info</b>
<p>A path will be returned which will indicate where resources are stored for this app on the speciffic target. In windows the path will always be <i>incbin::</i> and it is expected for you to incbin your resources.</p>
End Rem
Function GetAppResourcesPath:String()
	' --- get the path to resources ---
	'on windows this will assume that you are using incbin
	?Win32
		Return "incbin::"
	?MacOs
		Return skn3_getBundlePath()
	?
End Function


Rem
bbdoc: A class to define the panel ex gadget.
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
	<li>Mac</li>
</ul>
<b>Info</b>
<p>This is the gadget class for an extended panel.</p>
End Rem
?Win32
Type Skn3PanelEx Extends TWindowsPanel
	Field gradientOn:Int = False
	Field gradientVertical:Int = True
	Field gradientStartR:Int = 255
	Field gradientStartG:Int = 255
	Field gradientStartB:Int = 255
	Field gradientEndR:Int = 0
	Field gradientEndG:Int = 0
	Field gradientEndB:Int = 0
	
	'hooks
	Method WndProc:Int(hwnd:Int,MSG:Int,wp:Int,lp:Int)
		' --- check for instant skip
		Select MSG
			Case WM_ERASEBKGND
				If gradientOn = False
					'call default behaviour
					Return Super.WndProc(hwnd,MSG,wp,lp)
				Else
					'this is custom render time
					If _type = PANELCANVAS Then Return 1
					Local hdc:Int=wp,hdcCanvas:Int,hdcBitmap:Int,srcw:Int,srch:Int,x:Int,y:Int,xoffset:Int,yoffset:Int
					Local clientRect:Int[4], UpdateRect:Int[4], clipRect:Int[4], windowRect:Int[4]
					GetClipBox( hdc, clipRect )
					GetWindowRect( hwnd, windowRect)
					GetClientRect( hwnd, clientRect )
					If Not GetUpdateRect( hwnd, UpdateRect, False) Then UpdateRect = clipRect
					If IsRectEmpty(updateRect) Then updateRect = [0,0,windowRect[2]-windowRect[0],windowRect[3]-windowRect[1]]
					
					'If we are drawing a bitmap or using alpha then let's do some double-buffering stuff
					If (hwnd <> _hwndclient) And ((_bitmap And _bitmapwidth And _bitmapheight) Or _alpha<1.0) Then
						hdc = CreateCompatibleDC(wp)
						hdcCanvas = CreateCompatibleBitmap(wp,windowRect[2]-windowRect[0],windowRect[3]-windowRect[1])
						SelectObject( hdc, hdcCanvas )
					EndIf
					
					'----------- draw gradient -----------------
					Local previousBrush:Int
					Local gradientSize:Int
					Local gradientPosition:Int
					Local gradientBrush:Int
					Local gradientRect:Int[] = [UpdateRect[0],UpdateRect[1],UpdateRect[2],UpdateRect[3]]
					Local gradientR:Float
					Local gradientG:Float
					Local gradientB:Float
					Local gradientStepR:Float
					Local gradientStepG:Float
					Local gradientStepB:Float
					
					'which direction
					If gradientVertical
						gradientSize = Abs(clientRect[3]-clientRect[1])
						gradientStepR = Float(gradientEndR - gradientStartR) / gradientSize
						gradientStepG = Float(gradientEndG - gradientStartG) / gradientSize
						gradientStepB = Float(gradientEndB - gradientStartB) / gradientSize
						
						'work out gradient start based on update rect
						'actual gradietn size is based on client
						gradientR = gradientStartR + ((UpdateRect[1]-clientRect[1]) * gradientStepR)
						gradientG = gradientStartG + ((UpdateRect[1]-clientRect[1]) * gradientStepG)
						gradientB = gradientStartB + ((UpdateRect[1]-clientRect[1]) * gradientStepB)
						
						'only render portion of update rect
						For gradientPosition = UpdateRect[1] Until UpdateRect[3]
							'create color brush
							gradientBrush = CreateSolidBrush((Int(gradientB) Shl 16) | (Int(gradientG) Shl 8) | Int(gradientR))
							previousBrush = SelectObject(hdc,gradientBrush)
							
							'update drawing rect
							gradientRect[1] = gradientPosition
							gradientRect[3] = gradientPosition+1
							
							'fill the color
							FillRect(hdc,gradientRect,gradientBrush)
							
							'remove color brush
							SelectObject(hdc,previousBrush)
							DeleteObject(gradientBrush)
							
							'increase gradient counters
							gradientR :+ gradientStepR
							gradientG :+ gradientStepG
							gradientB :+ gradientStepB
						Next
					Else
						gradientSize = Abs(UpdateRect[2]-UpdateRect[0])
						gradientStepR = Float(gradientEndR - gradientStartR) / gradientSize
						gradientStepG = Float(gradientEndG - gradientStartG) / gradientSize
						gradientStepB = Float(gradientEndB - gradientStartB) / gradientSize
						
						'work out gradient start based on update rect
						'actual gradietn size is based on client
						gradientR = gradientStartR + ((UpdateRect[0]-clientRect[0]) * gradientStepR)
						gradientG = gradientStartG + ((UpdateRect[0]-clientRect[0]) * gradientStepG)
						gradientB = gradientStartB + ((UpdateRect[0]-clientRect[0]) * gradientStepB)
						
						For gradientPosition = UpdateRect[0] Until UpdateRect[2]
							'create color brush
							gradientBrush = CreateSolidBrush((Int(gradientB) Shl 16) | (Int(gradientG) Shl 8) | Int(gradientR))
							previousBrush = SelectObject(hdc,gradientBrush)
							
							'update drawing rect
							gradientRect[0] = gradientPosition
							gradientRect[2] = gradientPosition+1
							
							'fill the color
							FillRect(hdc,gradientRect,gradientBrush)
							
							'remove color brush
							SelectObject(hdc,previousBrush)
							DeleteObject(gradientBrush)
							
							'increase gradient counters
							gradientR :+ gradientStepR
							gradientG :+ gradientStepG
							gradientB :+ gradientStepB
						Next
					EndIf
					
					'If we aren't drawing to a bitmap or using alpha, then we can return now.
					If Not ((hwnd <> _hwndclient) And ((_bitmap And _bitmapwidth And _bitmapheight) Or _alpha<1.0)) Then Return 1
					
					'draw teh image
					If _bitmap And _bitmapwidth And _bitmapheight
						hdcBitmap=CreateCompatibleDC(hdc)
						SelectObject(hdcBitmap,_bitmap)
						srcw=_bitmapwidth
						srch=_bitmapheight
						Select (_bitmapflags & (GADGETPIXMAP_ICON-1))
							Case PANELPIXMAP_TILE
								While y<windowRect[RECT_BOTTOM]-windowRect[RECT_TOP]
									x=0
									While x<windowRect[RECT_RIGHT]-windowRect[RECT_LEFT]
										If _hasalpha
											AlphaBlend_ hdc,x,y,srcw,srch,hdcBitmap,0,0,srcw,srch,$01ff0000
										Else
											BitBlt hdc,x,y,srcw,srch,hdcBitmap,0,0,ROP_SRCCOPY
										EndIf
										x:+srcw
									Wend
									y:+srch
								Wend
							Case PANELPIXMAP_CENTER
								x=(windowRect[RECT_RIGHT]-windowRect[RECT_LEFT]-srcw)/2
								y=(windowRect[RECT_BOTTOM]-windowRect[RECT_TOP]-srch)/2
								If _hasalpha
									AlphaBlend_ hdc,x,y,srcw,srch,hdcBitmap,0,0,srcw,srch,$01ff0000
								Else
									BitBlt hdc,x,y,srcw,srch,hdcBitmap,0,0,ROP_SRCCOPY
								EndIf
							
							Case PANELPIXMAP_FIT, PANELPIXMAP_FIT2
							
								Local mx# = Float(windowRect[RECT_RIGHT]-windowRect[RECT_LEFT])/srcw
								Local my# = Float(windowRect[RECT_BOTTOM]-windowRect[RECT_TOP])/srch
								
								If mx>my Then
									If (_bitmapflags&(GADGETPIXMAP_ICON-1)) = PANELPIXMAP_FIT Then mx=my Else my=mx
								EndIf
								Local w:Int=mx*srcw
								Local h:Int=mx*srch
								x=(windowRect[RECT_RIGHT]-windowRect[RECT_LEFT]-w)/2
								y=(windowRect[RECT_BOTTOM]-windowRect[RECT_TOP]-h)/2
								SetStretchBltMode hdc,COLORONCOLOR
	
								If _hasalpha
									AlphaBlend_ hdc,x,y,w,h,hdcBitmap,0,0,srcw,srch,$01ff0000
								Else
									StretchBlt hdc,x,y,w,h,hdcBitmap,0,0,srcw,srch,ROP_SRCCOPY
								EndIf
	
							Case PANELPIXMAP_STRETCH
								SetStretchBltMode hdc,COLORONCOLOR
	
								If _hasalpha
									AlphaBlend_ hdc,0,0,windowRect[RECT_RIGHT]-windowRect[RECT_LEFT],windowRect[RECT_BOTTOM]-windowRect[RECT_TOP],hdcBitmap,0,0,srcw,srch,$01ff0000
								Else
									StretchBlt hdc,0,0,windowRect[RECT_RIGHT]-windowRect[RECT_LEFT],windowRect[RECT_BOTTOM]-windowRect[RECT_TOP],hdcBitmap,0,0,srcw,srch,ROP_SRCCOPY
								EndIf
							
						EndSelect				
						
						DeleteDC(hdcBitmap)
						
					EndIf
					
					If _alpha < 1.0 Then
						DrawParentBackground( wp, hwnd )
						Local blendfunction:Int = ((Int(_alpha*255)&$FF) Shl 16)
						AlphaBlend_(wp,updateRect[0],updateRect[1],updateRect[2]-updateRect[0],updateRect[3]-updateRect[1],hdc,updateRect[0],updateRect[1],updateRect[2]-updateRect[0],updateRect[3]-updateRect[1],blendfunction)
					Else
						BitBlt(wp,0,0,windowRect[2]-windowRect[0],windowRect[3]-windowRect[1],hdc,0,0,ROP_SRCCOPY)
					EndIf
					
					Assert hdc <> wp, "hdc == wp! Please post a MaxGUI bug report."
					
					DeleteObject( hdcCanvas )
					DeleteDC( hdc )
					
					Return 1
				EndIf
		End Select
		
		'call default behaviour
		Return Super.WndProc(hwnd,MSG,wp,lp)
	EndMethod
	
	'api
	Method SetGradient(on:Int,r1:Int=0,b1:Int=0,g1:Int=0,r2:Int=0,b2:Int=0,g2:Int=0,vertical:Int=True)
		' --- set the gradient for this ---
		If on = False
			If gradientOn
				gradientOn = False
				RedrawGadget(Self)
			EndIf
		Else
			If r1 = r2 And g1 = g2 And b1 = b2
				'skip as this is solid
				gradientOn = False
				SetColor(r1,g1,b1)
			Else
				'check for turning gradient on and if it has changed
				If gradientOn = False Or r1 <> gradientStartR Or g1 <> gradientStartG Or b1 <> gradientStartB Or r2 <> gradientEndR Or g2 <> gradientEndG Or b2 <> gradientEndB Or vertical <> gradientVertical
					gradientOn = True
					gradientStartR = r1
					gradientStartG = g1
					gradientStartB = b1
					gradientEndR = r2
					gradientEndG = g2
					gradientEndB = b2
					gradientVertical = vertical
					RedrawGadget(Self)
				EndIf
			EndIf
		EndIf
	End Method
End Type
?MacOs
Type Skn3PanelEx Extends TNSGadget
	'api
	Method SetGradient(on:Int,r1:Int=0,b1:Int=0,g1:Int=0,r2:Int=0,b2:Int=0,g2:Int=0,vertical:Int=True)
		' --- set the gradient for this ---
		skn3_panelExSetGradient(Self,on,r1,g1,b1,r2,g2,b2,vertical)
	End Method	
End Type
?

Rem
bbdoc: Create a new extended panel. <b>[Win Mac]</b>
returns: A Skn3PanelEx object.
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
	<li>Mac</li>
</ul>
<b>Info</b>
<p>This function will create a new #Skn3PanelEx object but will return as TGadget.</p>
End Rem
Function CreatePanelEx:TGadget(x:Int,y:Int,Width:Int,Height:Int,group:TGadget,Style:Int=0,text:String="")
	' --- create a new panel ex gadget ---
	'fix group
	group = GetCreationGroup(group)
	
	'these bits of code are ripped and tweaked versions of maxgui functions.
	'they simply inject some additional stuff in at the right moment.
	?Win32
		'code ripped/modified from win32maxguiex
		Local panel:TGadget = New Skn3PanelEx.Create(group,Style)
		
		If LocalizationMode() & LOCALIZATION_OVERRIDE Then
			LocalizeGadget(panel,text,"")
		Else
			panel.SetText(Text)
		EndIf
		
		If group Then panel._setparent group
		panel.SetShape(x,y,Width,Height)
		
		'v0.51: Gadgets are now only shown when they have been sized, and the text set.
		If TWindowsGadget(panel) Then
			panel.SetFont(TWindowsGUIDriver.GDIFont)
			If TWindowsGadget(group) Then
				TWindowsGadget(panel)._forceDisable = Not( TWindowsGadget(group)._enabled And Not TWindowsGadget(group)._forceDisable )
				panel.SetEnabled(Not (panel.State()&STATE_DISABLED))
			EndIf
			panel.SetShow(True)
		EndIf
		
		If TWindowsGadget(panel) Then TWindowsGadget(panel).Sensitize()
		
		'return it
		Return panel
	?macos
		'code ripped/modified from cocoagui.bmx
		Local panel:Skn3PanelEx = New Skn3PanelEx
	
		'fix group
		If Not group group = Desktop()
		
		'set properties
		panel.origclass = GADGET_PANEL
		panel.internalclass = GADGET_PANEL
		panel.parent = group
		panel.name = text
		panel.SetRect x,y,width,height	'setarea
		panel.style = style
		panel.font = TCocoaMaxGUIDriver.CocoaGUIFont
		
		If TNSGadget(group) Then
			panel.forceDisable = Not (TNSGadget(group).enabled And Not TNSGadget(group).forceDisable)
		EndIf
		
		'-----------------------------------------------------------------
		'this is where we call our own function to init the extended class
		skn3_panelExInit(panel)
		'-----------------------------------------------------------------
		
		panel.name = Null
		
		GadgetMap.Insert TIntWrapper.Create(panel.handle),panel
		If panel.view And panel.handle <> panel.view Then
			GadgetMap.Insert TIntWrapper.Create(panel.view),panel
		EndIf
		
		panel.LockLayout()
		
		If LocalizationMode() & LOCALIZATION_OVERRIDE Then LocalizeGadget(panel,text,"")
		
		panel.SetEnabled(panel.enabled)
		
		panel.SetLayout EDGE_CENTERED,EDGE_CENTERED,EDGE_CENTERED,EDGE_CENTERED
		
		If group Then panel._SetParent group
		panel.SetTextColor(0,0,0)
		panel.LinkView
		
		Return panel
	?
End Function

Rem
bbdoc: Set the gradient properties for a panel. <b>[Win Mac]</b>
about:
<b>Supported Platforms</b>
<ul>
	<li>Windows</li>
	<li>Mac</li>
</ul>
<b>Info</b>
<p>If you turn the gradient off then the panel will act as a normal maxgui panel and show whatever color has been set as the background color.</p>
End Rem
Function SetPanelExGradient(Gadget:TGadget,on:Int,r1:Int=0,b1:Int=0,g1:Int=0,r2:Int=0,b2:Int=0,g2:Int=0,vertical:Int=True)
	' --- modify the gradient for the panel ex ---
	Local panel:Skn3PanelEx = Skn3PanelEx(Gadget)
	If panel panel.SetGradient(on,r1,g1,b1,r2,g2,b2,vertical)
End Function