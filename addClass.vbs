'============================================================================================
'
'	This script is able to include cpp files from win32 project into android config file
'	@Using: Copy this script to ${YOUR_COCOS2DX_FOLDER}\{THIS_SCRIPT}.vbs and run *.vbs 
'	file as program, or open cmd at current folder and type command=> wscript "addClass.vbs"
'
'============================================================================================

'get name of the project
Dim filesys
Set filesys = CreateObject("Scripting.FileSystemObject")
varPathCurrent = filesys.GetParentFolderName(WScript.ScriptFullName)
varPathParent = filesys.GetParentFolderName(varPathCurrent)
pjName = mid(varPathCurrent, len(varPathParent) + 1 , len(varPathCurrent) - len(varPathParent) + 1)
'open android config file and write first config default
Set accessFile = CreateObject("Scripting.FileSystemObject")
Set androidConfigFile = accessFile.OpenTextFile("proj.android-studio\app\jni\Android.mk", 2)
originTextBegin = "LOCAL_PATH := $(call my-dir)"&vbCRLF&vbCRLF&"include $(CLEAR_VARS)"&vbCRLF&vbCRLF&"$(call import-add-path,$(LOCAL_PATH)/../../../cocos2d)"&vbCRLF&"$(call import-add-path,$(LOCAL_PATH)/../../../cocos2d/external)"&vbCRLF&"$(call import-add-path,$(LOCAL_PATH)/../../../cocos2d/cocos)"&vbCRLF&"$(call import-add-path,$(LOCAL_PATH)/../../../cocos2d/cocos/audio/include)"&vbCRLF&vbCRLF&"LOCAL_MODULE := MyGame_shared"&vbCRLF&vbCRLF&"LOCAL_MODULE_FILENAME := libMyGame"&vbCRLF&vbCRLF&"LOCAL_SRC_FILES := hellocpp/main.cpp \"&vbCRLF
androidConfigFile.Write originTextBegin
'open win32 project to read paths had included, reformat and write path to android config file
Set xmlDoc = CreateObject("Microsoft.XMLDOM")
xmlDoc.Async = "False"
xmlDoc.Load("proj.win32\" + pjName + ".vcxproj")
Set colNodes = xmlDoc.selectNodes("//ItemGroup/ClCompile")
listsIncluded = ""
Dim count
count = 0
For Each objNode in colNodes
	count = count + 1
	fileInclude = objNode.getAttribute("Include")
	listsIncluded = listsIncluded & count & fileInclude & vbCRLF
	fileInclude = Replace(fileInclude,"..\","				   ../../../")
	fileInclude = Replace(fileInclude,"\","/")
	if (count < colNodes.length - 1) then
		fileInclude = fileInclude + "\"
	end if
	if (fileInclude <> "main.cpp") then
		androidConfigFile.WriteLine fileInclude
	end if
Next
'write end config default to android config file
originTextEnd = vbCRLF&"LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../../Classes"&vbCRLF&vbCRLF&"# _COCOS_HEADER_ANDROID_BEGIN"&vbCRLF&"# _COCOS_HEADER_ANDROID_END"&vbCRLF&vbCRLF&vbCRLF&"LOCAL_STATIC_LIBRARIES := cocos2dx_static"&vbCRLF&vbCRLF&"# _COCOS_LIB_ANDROID_BEGIN"&vbCRLF&"# _COCOS_LIB_ANDROID_END"&vbCRLF&vbCRLF&"include $(BUILD_SHARED_LIBRARY)"&vbCRLF&vbCRLF&"$(call import-module,.)"&vbCRLF&vbCRLF&"# _COCOS_LIB_IMPORT_ANDROID_BEGIN"&vbCRLF&"# _COCOS_LIB_IMPORT_ANDROID_END"&vbCRLF
androidConfigFile.Write originTextEnd
androidConfigFile.Close
MsgBox "Included " & count & " cpp files" & vbCRLF & listsIncluded, 0, "DONE"