################################################################################
#
#  Visual Leak Detector - NSIS Installation Script
#  Copyright (c) 2006-2009 Dan Moulding
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301, USA
#
#  See COPYING.txt for the full terms of the GNU General Public License.
#
################################################################################

!include "Library.nsh"  # Provides the dynamic link library installation system
!include "LogicLib.nsh" # Provides useable conditional script syntax
!include "MUI.nsh"      # Provides the modern user-interface

# Version number
!define VLD_VERSION "1.9h"

# Define build system paths
!define CRT_PATH     "C:\Program Files\Microsoft Visual Studio 9.0\VC\redist\x86\Microsoft.VC90.CRT"
!define DTFW_PATH    "C:\Program Files\Debugging Tools for Windows (x86)"
!define EDITENV_PATH "editenv"

# Define build system files
!define CRT_DLL      "msvcr90.dll"
!define CRT_MANIFEST "Microsoft.VC90.CRT.manifest"
!define DHL_DLL      "dbghelp.dll"
!define EDITENV_DLL  "editenv.dll"

# Define installer paths
!define BIN_PATH     "$INSTDIR\bin"
!define INCLUDE_PATH "$INSTDIR\include"
!define LIB_PATH     "$INSTDIR\lib"
!define LNK_PATH     "$SMPROGRAMS\$SM_PATH"
!define SRC_PATH     "$INSTDIR\src"

# Define editenv system environment variable scope
!define ES_SYSTEM 1

# Define registry keys
!define REG_KEY_PRODUCT   "Software\Visual Leak Detector"
!define REG_KEY_UNINSTALL "Software\Microsoft\Windows\CurrentVersion\Uninstall\Visual Leak Detector"

# Define page settings
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_FINISHPAGE_SHOWREADME            "$INSTDIR\README.html"
!define MUI_FINISHPAGE_SHOWREADME_TEXT       "View Documentation"
!define MUI_LICENSEPAGE_BUTTON               "Continue"
!define MUI_LICENSEPAGE_TEXT_BOTTOM          "Click the 'Continue' button to continue installing. Remember, you aren't required to (and are not being asked to) agree to anything before using this software."
!define MUI_LICENSEPAGE_TEXT_TOP             "Press Page Down to see the rest of the text."
!define MUI_STARTMENUPAGE_DEFAULTFOLDER      "Visual Leak Detector"
!define MUI_STARTMENUPAGE_REGISTRY_ROOT      HKLM
!define MUI_STARTMENUPAGE_REGISTRY_KEY       "${REG_KEY_PRODUCT}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "LnkPath"
!define MUI_UNFINISHPAGE_NOAUTOCLOSE

# Define installer attributes
InstallDir        "$PROGRAMFILES\Visual Leak Detector"
InstallDirRegKey  HKLM "${REG_KEY_PRODUCT}" "InstallPath"
Name              "Visual Leak Detector ${VLD_VERSION}"
OutFile           "vld-${VLD_VERSION}-setup.exe"
SetCompressor     /SOLID lzma
ShowInstDetails   show
ShowUninstDetails show

# Declare global variables
Var INSTALLED_VERSION
Var SM_PATH
        
# Define the installer pages
!insertmacro MUI_PAGE_WELCOME
!define MUI_PAGE_HEADER_TEXT    "No License Required for Use"
!define MUI_PAGE_HEADER_SUBTEXT "This software is provided 'AS IS' without warranty of any kind."
!insertmacro MUI_PAGE_LICENSE   "license-free.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_STARTMENU "Shortcuts" $SM_PATH
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

# Define the uninstaller pages
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

# Set the modern UI language
!insertmacro MUI_LANGUAGE "English"

################################################################################
#
# Installation
#
Function .onInit
    ReadRegStr $INSTALLED_VERSION HKLM "${REG_KEY_PRODUCT}" "InstalledVersion"
    ${UNLESS} $INSTALLED_VERSION == ""
        ${IF} $INSTALLED_VERSION == ${VLD_VERSION}
            MessageBox MB_ICONINFORMATION|MB_OKCANCEL "Setup has detected that Visual Leak Detector version $INSTALLED_VERSION is already installed on this computer.$\n$\nClick 'OK' if you want to continue and repair the existing installation. Click 'Cancel' if you want to abort installation." \
                IDOK continue IDCANCEL abort
        ${ELSE}
            MessageBox MB_ICONEXCLAMATION|MB_YESNO "Setup has detected that a different version of Visual Leak Detector is already installed on this computer.$\nIt is highly recommended that you first uninstall the version currently installed before proceeding.$\n$\nAre you sure you want to continue installing?" \
                IDYES continue IDNO abort
        ${ENDIF}
abort:
        Abort
continue:
    ${ENDUNLESS}
FunctionEnd

Section "Uninstaller"
    SetOutPath "$INSTDIR"
    WriteUninstaller "$INSTDIR\uninstall.exe"
    WriteRegStr HKLM "${REG_KEY_UNINSTALL}" "DisplayName" "Visual Leak Detector ${VLD_VERSION}"
    WriteRegStr HKLM "${REG_KEY_UNINSTALL}" "UninstallString" "$INSTDIR\uninstall.exe"
    WriteRegStr HKLM "${REG_KEY_UNINSTALL}" "InstallLocation" "$INSTDIR"
    WriteRegStr HKLM "${REG_KEY_UNINSTALL}" "Publisher" "Dan Moulding"
    WriteRegStr HKLM "${REG_KEY_UNINSTALL}" "URLInfoAbout" "http://www.danm.net"
    WriteRegStr HKLM "${REG_KEY_UNINSTALL}" "DisplayVersion" "${VLD_VERSION}"
    WriteRegDWORD HKLM "${REG_KEY_UNINSTALL}" "NoModify" 1
    WriteRegDWORD HKLM "${REG_KEY_UNINSTALL}" "NoRepair" 1
SectionEnd

Section "Registry Keys"
    WriteRegStr HKLM "${REG_KEY_PRODUCT}" "IniFile" "$INSTDIR\vld.ini"
    WriteRegStr HKLM "${REG_KEY_PRODUCT}" "InstallPath" "$INSTDIR"
    WriteRegStr HKLM "${REG_KEY_PRODUCT}" "InstalledVersion" "${VLD_VERSION}"
SectionEnd

Section "Header File"
    SetOutPath "${INCLUDE_PATH}"
    File "..\vld.h"
SectionEnd

Section "Import Library"
    SetOutPath "${LIB_PATH}"
    File "..\Release\vld.lib"
SectionEnd

Section "Dynamic Link Libraries"
    SetOutPath "${BIN_PATH}"
    !insertmacro InstallLib DLL NOTSHARED NOREBOOT_NOTPROTECTED "..\Release\vld.dll" "${BIN_PATH}\vld.dll" $INSTDIR
    MessageBox MB_YESNO "Visual Leak Detector needs the location of vld.dll to be added to your 'Path' environment variable.$\n$\nWould you like the installer to add it to the path now? If you select No, you'll need to add it to the path manually." \
        IDYES addtopath IDNO skipaddtopath
addtopath:
    DetailPrint "Adding ${BIN_PATH} to the 'Path' system environment variable."
    InitPluginsDir
    SetOutPath "$PLUGINSDIR"
    File "${EDITENV_PATH}\${EDITENV_DLL}"
    System::Call "editenv::pathAdd(i ${ES_SYSTEM}, t '${BIN_PATH}') ? u"
    Delete "$PLUGINSDIR\${EDITENV_DLL}"
    SetOutPath "${BIN_PATH}"
skipaddtopath:
    !insertmacro InstallLib DLL NOTSHARED NOREBOOT_NOTPROTECTED "${DTFW_PATH}\${DHL_DLL}" "${BIN_PATH}\${DHL_DLL}" $INSTDIR
    !insertmacro InstallLib DLL NOTSHARED NOREBOOT_NOTPROTECTED "${CRT_PATH}\${CRT_DLL}" "${BIN_PATH}\${CRT_DLL}" $INSTDIR
    File "..\Microsoft.DTfW.DHL.manifest"
    File "${CRT_PATH}\${CRT_MANIFEST}"
SectionEnd

Section "Configuration File"
    SetOutPath "$INSTDIR"
    File "..\vld.ini"
SectionEnd

Section "Source Code"
    SetOutPath "${SRC_PATH}"
    File "..\*.cpp"
    File "..\*.h"
    File "..\vld.vcproj"
    File "..\*.manifest"
    File "..\*.rc"
SectionEnd

Section "Documentation"
    SetOutPath "$INSTDIR"
    File "..\CHANGES.txt"
    File "..\COPYING.txt"
    File "..\README.html"
SectionEnd

Section "Start Menu Shortcuts"
    !insertmacro MUI_STARTMENU_WRITE_BEGIN "Shortcuts"
    SetOutPath "$INSTDIR"
    SetShellVarContext all
    CreateDirectory "${LNK_PATH}"
    CreateShortcut "${LNK_PATH}\Configure.lnk"     "$INSTDIR\vld.ini"
    CreateShortcut "${LNK_PATH}\Documentation.lnk" "$INSTDIR\README.html"
    CreateShortcut "${LNK_PATH}\License.lnk"       "$INSTDIR\COPYING.txt"
    CreateShortcut "${LNK_PATH}\Uninstall.lnk"     "$INSTDIR\uninstall.exe"
    !insertmacro MUI_STARTMENU_WRITE_END
SectionEnd


################################################################################
#
# Uninstallation
#
Section "un.Header File"
    Delete "${INCLUDE_PATH}\vld.h"
    RMDir "${INCLUDE_PATH}"
SectionEnd

Section "un.Import Library"
    Delete "${LIB_PATH}\vld.lib"
    RMDir "${LIB_PATH}"
SectionEnd

Section "un.Dynamic Link Libraries"
    !insertmacro UnInstallLib DLL NOTSHARED NOREBOOT_NOTPROTECTED "${BIN_PATH}\vld.dll"
    DetailPrint "Removing ${BIN_PATH} from the 'Path' system environment variable."
    InitPluginsDir
    SetOutPath "$PLUGINSDIR"
    File "${EDITENV_PATH}\${EDITENV_DLL}"
    System::Call "editenv::pathRemove(i ${ES_SYSTEM}, t '${BIN_PATH}') ? u"
    Delete "$PLUGINSDIR\${EDITENV_DLL}"
    !insertmacro UnInstallLib DLL NOTSHARED NOREBOOT_NOTPROTECTED "${BIN_PATH}\${DHL_DLL}"
    !insertmacro UnInstallLib DLL NOTSHARED NOREBOOT_NOTPROTECTED "${BIN_PATH}\${CRT_DLL}"
    Delete "${BIN_PATH}\Microsoft.DTfW.DHL.manifest"
    Delete "${BIN_PATH}\${CRT_MANIFEST}"
    RMDir "${BIN_PATH}"
SectionEnd

Section "un.Configuration File"
    Delete "$INSTDIR\vld.ini"
SectionEnd

Section "un.Source Code"
    Delete "${SRC_PATH}\*.cpp"
    Delete "${SRC_PATH}\*.h"
    Delete "${SRC_PATH}\vld.vcproj"
    Delete "${SRC_PATH}\*.manifest"
    Delete "${SRC_PATH}\*.rc"
    RMDir "${SRC_PATH}"
SectionEnd

Section "un.Documentation"
    Delete "$INSTDIR\CHANGES.txt"
    Delete "$INSTDIR\COPYING.txt"
    Delete "$INSTDIR\README.html"
SectionEnd

Section "un.Start Menu Shortcuts"
    !insertmacro MUI_STARTMENU_GETFOLDER "Shortcuts" $SM_PATH
    SetShellVarContext all
    Delete "${LNK_PATH}\Configure.lnk"
    Delete "${LNK_PATH}\Documentation.lnk"
    Delete "${LNK_PATH}\License.lnk"
    Delete "${LNK_PATH}\Uninstall.lnk"
    RMDir "${LNK_PATH}"
SectionEnd

Section "un.Registry Keys"
    DeleteRegKey HKLM "${REG_KEY_PRODUCT}"
SectionEnd

Section "un.Uninstaller"
    Delete "$INSTDIR\uninstall.exe"
    RMDir "$INSTDIR"
    DeleteRegKey HKLM "${REG_KEY_UNINSTALL}"
SectionEnd
