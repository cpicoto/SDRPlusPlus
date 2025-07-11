; SDR++ Installer Script for Inno Setup
; This script creates a Windows installer for SDR++ with HackRF support

#define MyAppName "SDR++"
#define MyAppVersion "1.2.2"
#define MyAppPublisher "SDR++ Community"
#define MyAppURL "https://github.com/cpicoto/SDRPlusPlus"
#define MyAppExeName "sdrpp.exe"
#define MyAppDescription "Cross-Platform SDR Software with HackRF Support"

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{B8F9A5C2-1234-5678-9ABC-DEF012345678}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
LicenseFile=license
OutputDir=installer_output
OutputBaseFilename=SDRPlusPlus-{#MyAppVersion}-Setup
SetupIconFile=root_dev\res\icons\sdrpp.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 6.1

[Files]
; Main executable
Source: "root_dev\sdrpp.exe"; DestDir: "{app}"; Flags: ignoreversion

; Core DLLs (required in main directory)
Source: "root_dev\sdrpp_core.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "root_dev\fftw3f.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "root_dev\glfw3.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "root_dev\volk.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "root_dev\zstd.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "root_dev\rtaudio.dll"; DestDir: "{app}"; Flags: ignoreversion

; HackRF dependencies
Source: "root_dev\hackrf.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "root_dev\libusb-1.0.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "root_dev\pthreadVC2.dll"; DestDir: "{app}"; Flags: ignoreversion

; All modules (including their individual dependencies)
Source: "root_dev\modules\*.dll"; DestDir: "{app}\modules"; Flags: ignoreversion

; Resources (read-only)
Source: "root_dev\res\*"; DestDir: "{app}\res"; Flags: ignoreversion recursesubdirs createallsubdirs

; Configuration files templates (to AppData on first run)
; Only copy config.json if it exists and is not empty
Source: "config.json"; DestDir: "{userappdata}\{#MyAppName}"; Flags: ignoreversion onlyifdoesntexist skipifsourcedoesntexist

; Documentation
Source: "readme.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "license"; DestDir: "{app}"; Flags: ignoreversion

; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Parameters: "-r ""{userappdata}\{#MyAppName}"""; Comment: "{#MyAppDescription}"
Name: "{group}\{cm:ProgramOnTheWeb,{#MyAppName}}"; Filename: "{#MyAppURL}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Parameters: "-r ""{userappdata}\{#MyAppName}"""; Comment: "{#MyAppDescription}"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Parameters: "-r ""{userappdata}\{#MyAppName}"""; Tasks: quicklaunchicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Parameters: "-r ""{userappdata}\{#MyAppName}"" -h"; Description: "Test SDR++ installation (check console for errors)"; Flags: nowait postinstall skipifsilent runasoriginaluser
Filename: "{app}\{#MyAppExeName}"; Parameters: "-r ""{userappdata}\{#MyAppName}"""; Description: "{cm:LaunchProgram,{#MyAppName}}"; Flags: nowait postinstall skipifsilent runasoriginaluser unchecked

[Dirs]
Name: "{userappdata}\{#MyAppName}"; Flags: uninsneveruninstall

[Registry]
Root: HKLM; Subkey: "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\{#MyAppExeName}"; ValueType: string; ValueName: ""; ValueData: "{app}\{#MyAppExeName}"; Flags: uninsdeletekey

[UninstallDelete]
Type: filesandordirs; Name: "{userappdata}\{#MyAppName}"

[Code]
// Check if Visual C++ 2019/2022 Redistributable is installed
function VCRedistNeedsInstall: Boolean;
begin
  // Check for Visual C++ 2019/2022 x64 redistributable
  Result := not RegKeyExists(HKLM, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64');
end;

function GetUninstallString(): String;
var
  sUnInstPath: String;
  sUnInstallString: String;
begin
  sUnInstPath := ExpandConstant('Software\Microsoft\Windows\CurrentVersion\Uninstall\{#emit SetupSetting("AppId")}_is1');
  sUnInstallString := '';
  if not RegQueryStringValue(HKLM, sUnInstPath, 'UninstallString', sUnInstallString) then
    RegQueryStringValue(HKCU, sUnInstPath, 'UninstallString', sUnInstallString);
  Result := sUnInstallString;
end;

function IsUpgrade(): Boolean;
begin
  Result := (GetUninstallString() <> '');
end;

function UnInstallOldVersion(): Integer;
var
  sUnInstallString: String;
  iResultCode: Integer;
begin
  Result := 0;
  sUnInstallString := GetUninstallString();
  if sUnInstallString <> '' then begin
    sUnInstallString := RemoveQuotes(sUnInstallString);
    if Exec(sUnInstallString, '/SILENT /NORESTART /SUPPRESSMSGBOXES','', SW_HIDE, ewWaitUntilTerminated, iResultCode) then
      Result := 3
    else
      Result := 2;
  end else
    Result := 1;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if (CurStep=ssInstall) then
  begin
    if (IsUpgrade()) then
    begin
      UnInstallOldVersion();
    end;
  end;
end;

function InitializeSetup(): Boolean;
begin
  Result := True;
  if VCRedistNeedsInstall then
  begin
    if MsgBox('SDR++ requires Microsoft Visual C++ Redistributable 2019/2022 x64 to run properly.' + #13#10 + 
              'Please download and install it from Microsoft before running SDR++.' + #13#10#13#10 +
              'Continue with installation anyway?', mbConfirmation, MB_YESNO) = IDNO then
    begin
      Result := False;
    end;
  end;
end;

[Messages]
WelcomeLabel2=This will install [name/ver] on your computer.%n%nSDR++ is a cross-platform SDR software with support for HackRF and many other SDR devices. This version includes HackRF support and all necessary dependencies.%n%nIt is recommended that you close all other applications before continuing.
