; Galindo Barbershop - Inno Setup Installer Script
; Compilar con: "C:\Program Files\Inno Setup 7\ISCC.exe" installer\galindo_barbershop.iss

#define MyAppName "Galindo Barbershop"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Galindo Barbershop"
#define MyAppURL "https://galindo-barbershop.vercel.app"
#define MyAppExeName "galindo_barbershop.exe"

[Setup]
DefaultDirName={autopf}\Galindo Barbershop
DefaultGroupName=Galindo Barbershop
UninstallDisplayIcon={app}\{#MyAppExeName}
AppId={{B3E4C4D5-6F78-4A9B-8C1D-2E3F4A5B6C7D}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
OutputDir=dist
OutputBaseFilename=GalindoBarbershop-Setup-{#MyAppVersion}
; Imágenes del asistente con el logo
SetupIconFile=galindo.ico
WizardImageFile=wizard.bmp
WizardSmallImageFile=wizard-small.bmp
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
CloseApplications=force
SetupLogging=yes
DisableDirPage=yes

[Languages]
Name: "espanol"; MessagesFile: "compiler:Languages\Spanish.isl"

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"

[Tasks]
Name: "desktopicon"; Description: "Crear acceso directo en el escritorio"; GroupDescription: "Opciones adicionales:"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Iniciar {#MyAppName}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
