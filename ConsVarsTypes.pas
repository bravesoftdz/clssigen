unit ConsVarsTypes;

interface
uses Windows, SysUtils, Classes, Graphics, Controls, VirtualTrees;

type
  ECSGError = class(Exception);

  PStringList = ^TStringList;
  PPAnsiString = ^PAnsiString;

  TCSGProgressEvent = procedure(Sender: TObject; dProgress: Double) of object;
  TCSGAddLogEvent   = procedure(Sender: TObject; const sLogRec: String) of object;

  TCSGProject = class(TObject)
  private
     // ��������� ������ ������
    FTotalSize: Integer;
     // Prop storage
    FAutorun: Boolean;
    FModified: Boolean;
    FAutorunFile: String;
    FBasePath: String;
    FOutputPath: String;
    FFileName: String;
    FSSIExtensions: TStrings;
    FSelectedFiles: TStringList;
    FOnAddLog: TCSGAddLogEvent;
    FOnFileListChanged: TNotifyEvent;
    FOnGenerationProgress: TCSGProgressEvent;
    FOnStatusChanged: TNotifyEvent;
     // ��������� ������ ��������������� �������
    procedure DoFileListChanged;
    procedure DoGenerationProgress(dProgress: Double);
    procedure DoStatusChanged;
     // ������������ ����� (� �.�. � SSI)
    function ProcessFiles: Boolean;
     // ��������� ������ � Log
    procedure AddToLog(const s: String; const aParams: Array of const);
     // ��������� Autorun-����
    procedure DoAutorun;
     // ��������������� ������������� ���� � ����� � ����������, ��������� ���� �� sOriginalFile
    function  ExpandRelPath(const sRelFile, sOriginalFile: String): String;
     // ���������� True, ���� ���� �������� SSI-������ (������������ �� ��� ����������)
    function  IsSSIFile(const sFileName: String): Boolean;
     // ������ ������� sDir ������ � ������������� ���������� � ������������� (����� � ������ ������)
    function  ForceDir(const sDir: String): Boolean;
     // ������������� � ������� �� ����� ��������� �� ������ � �������� ���������
    procedure GenerationError(const s: String; const aParams: Array of const);
     // Prop handlers
    procedure SetBasePath(const Value: String);
    procedure SetFileName(const Value: String);
    procedure SetModified(Value: Boolean);
    procedure SetOutputPath(const Value: String);
    procedure SetAutorun(const Value: Boolean);
    procedure SetAutorunFile(const Value: String);
    function  GetSelFiles(Index: Integer): String;
    function  GetSelFilesCount: Integer;
    function  GetSelFilesAbsolute(Index: Integer): String;
    function  GetDisplayFileName: String;
    procedure SetSSIExtensions(Value: TStrings);
  public
    constructor Create;
    destructor Destroy; override;
     // ���������� ��� ��������� ������� � ��������������
    procedure MakeNew;
     // ����������� ���������� ���� � ����� � ������������� (������������ �������� ����), ���� ��� ��������. ���� ���,
     //   �������� Exception
    function  AbsPathToRelative(const sFileName: String): String;
     // ��������� ������������ ���� ����� � ������ ������� �����
     // ���������� True ��� �������� ����������, ����� - False
    function  CheckGenerationPossible: Boolean;
     // ���������� ��������� �����
    procedure Generate;
     // ���������� � ������ �� �����
    procedure SaveToFile(const sFileName: String);
    procedure LoadFromFile(const sFileName: String);
     // ����������/�������� ��������� ������ (� ����������� ������)
    procedure AddSelFileAbsolute(const sFileName: String);
    procedure RemoveSelFileAbsolute(const sFileName: String);
     // ����������/�������� ���� ����� �� ��������� ����� � ������ ��������� (� ����������� ������)
    procedure FolderAddSelFilesAbsolute(const sFolder: String);
    procedure FolderRemoveSelFilesAbsolute(const sFolder: String);
     // ���������� ������ ���������� �����
    function  IndexOfSelFile(const sFileName: String): Integer;
     // ������� ������ �� ��������� �����, � ���������������� �� ������������
    procedure ValidateSelFiles;
     // Props
     // -- True, ���� ��������� ���� AutorunFile ����� ���������
    property Autorun: Boolean read FAutorun write SetAutorun;
     // -- ���� ��� ����������� ��� Autorun=True
    property AutorunFile: String read FAutorunFile write SetAutorunFile;
     // -- ������� ������� �������� ������ �������
    property BasePath: String read FBasePath write SetBasePath;
     // -- ��� ����� ��� ����������� (�� ������)
    property DisplayFileName: String read GetDisplayFileName;
     // -- �������� ��� ����� �������
    property FileName: String read FFileName write SetFileName;
     // -- True, ���� ������ ��� ������ � ������� ���������� ����������
    property Modified: Boolean read FModified;
     // -- ������� �������� �������
    property OutputPath: String read FOutputPath write SetOutputPath;
     // -- ���������� ���� � ��������� ������ ������������ ��������� �������� BasePath
    property SelFiles[Index: Integer]: String read GetSelFiles;
     // -- ���������� ���������� ���� � ��������� ������
    property SelFilesAbsolute[Index: Integer]: String read GetSelFilesAbsolute;
     // -- ���������� ��������� �������� ������
    property SelFilesCount: Integer read GetSelFilesCount;
     // -- ���������� ������, ����������� ������������ SSI-������ (���������� ���������)
    property SSIExtensions: TStrings read FSSIExtensions write SetSSIExtensions;
     // Events
     // -- ������� �� ���������� ������� � �������� ���������
    property OnAddLog: TCSGAddLogEvent read FOnAddLog write FOnAddLog;
     // -- ������� ��������� ������ ������
    property OnFileListChanged: TNotifyEvent read FOnFileListChanged write FOnFileListChanged;
     // -- ������� ����������� ��������� ���������
    property OnGenerationProgress: TCSGProgressEvent read FOnGenerationProgress write FOnGenerationProgress;
     // -- ������� ��������� ��������� ������� (Modified)
    property OnStatusChanged: TNotifyEvent read FOnStatusChanged write FOnStatusChanged;
  end;

const
  __PATH_DELIMITER            = '\';
  __UNIX_PATH_DELIMITER       = '/';
  __DRIVE_DELIMITER           = ':';
                              
  SIncludeDirectiveOpen       = '<!--#INCLUDE VIRTUAL=';
  SIncludeDirectiveClose      = '-->';
                              
  SAppTitle                   = 'Client SSI Generator';
  SAppVersion                 = '1.11';

  SHelpFileEN                 = 'cssigen-en.chm';
  SHelpFileRU                 = 'cssigen-ru.chm';

   // Default project settings
  SDefaultExt                 = 'cssip';
  SDefaultFileName            = 'untitled.'+SDefaultExt;
  SDefaultSSIExts             =
    'html'#13+                
    'htms'#13+                
    'shtml'#13+               
    'ssi'#13+                 
    'xhtml';                  
  SDefaultAutorunFile         = 'index.html';

  SDefaultFileAssociations    =
    '*.htm*=notepad.exe'#13+
    '*.?htm*=notepad.exe'#13+
    '*.css=notepad.exe'#13+
    '*.txt=notepad.exe'#13+
    '*.ssi=notepad.exe';

  SIniSection_Project         = 'Project';
  SIniSection_SSIExts         = 'SSIExtensions';
  SIniSection_Files           = 'Files';

  SCSGFileFilter              = 'CSSI Generator projects (*.cssip)|*.cssip|All files (*.*)|*.*';

   // Registry paths
  SRegOpenMRU                 = 'OpenMRU';
  SRegPreferences             = 'Preferences';
  SRegFileAssociations        = 'FileAssociations';

   // Dialog titles and texts
  SDlgTitleError              = 'Error';
  SDlgTitleConfirm            = 'Confirm';
  SDlgTitleOpenProject        = 'Open project';
  SDlgTitleSaveProject        = 'Save project as';

  SFileNotSavedMsg            = 'File "%s" is modified. Do you wish to save it?';

   // �������� �������� ������� � ShellExecute
  SOpOpen                     = 'open';

   // ������ � ��������
  SInternetEmail              = 'mailto:devtools@narod.ru';
  SInternetWebsite            = 'http://www.dk-soft.org/';

   // ��������� �� �������
  SErrWrongFormat             = 'The file is not a valid Client SSI Generator project file';
  SErrFoldersRecurse          = 'Output folder cannot contain base one, and vice versa.';
  SErrBaseDirDoesntExist      = 'Base folder doesn''t exist.';
  SErrWrongAutorunFile        = 'Run-upon-completion file doesn''t exist.';
  SErrCannotOpenFile          = 'Cannot execute "%s":'#13'%s';
  SErrUnableToAutorun         = 'Unable to run file "%s": %s.';
  SErrUnableToCreateFolder    = 'Unable to create folder "%s": %s.';
  SErrUnableToOpenSrcFile     = 'Unable to open source file "%s":'#13#10'%s';
  SErrUnableToOpenTgtFile     = 'Unable to create output file "%s":'#13#10'%s';
  SErrSrcFileTooLarge         = 'Source file "%s" is too large (%d bytes).';
  SErrUnclosedInclude         = 'Error in INCLUDE (file "%s"): closing tag ("-->") missing.';
  SErrNoIncludeFileSpec       = 'Error in INCLUDE (file "%s"): file name missing.';
  SErrUnableToOpenIncludeFile = 'Unable to open INCLUDE-file "%s" (file "%s"):'#13#10'%s';

  SErrMsg_CannotTranslateAbsPath = 'Cannot translate absolute path to relative one: it doesn''t start with "%s" (absolute path: "%s")';

   // ��������� � ���������
  SLogMsgStart                = 'Base folder: "%s"; output folder: "%s"; process started at %s.';
  SLogMsgEnd                  = 'Process finished %s at %s; elapsed time: %s. Total output file size: %d bytes.';
  SLogMsgAutorunning          = 'Executing "%s"...';
  SLogMsgSuccessfully         = 'successfully';
  SLogMsgWithErrors           = 'with errors';
  SLogMsgFolderCreated        = 'Created folder "%s".';
  SLogMsgIncludeInserted      = '   + INCLUDE-file inserted: "%s" (%d bytes).';
  SLogMsgFileProcessed        = 'File "%s" processed (%d bytes).';
   // ������ ������ ������� � ���������
  SLogTimeFormat              = 'hh:mm:ss.zzz';

   // Image indices
  iiGlobe                     =  0;
  iiFolder                    =  1;
  iiNew                       =  2;
  iiOpen                      =  3;
  iiSave                      =  4;
  iiSaveAs                    =  5;
  iiExit                      =  6;
  iiProjectOptions            =  7;
  iiSettings                  =  8;
  iiEditFile                  =  9;
  iiRun                       = 10;
  iiRefresh                   = 11;
  iiAbout                     = 12;
  iiHelpContents              = 13;
  iiUpFolder                  = 14;

  IiiFolderID                 = $0FFFFFFF;

  aClr: Array[Boolean] of TColor = (clBtnFace, clWindow);

var
   // ��������� ����, �������������� � ������� �������� ��������
  sLastBasePath: String;
   // ���������� ������
  FileAssociations: TStringList;

  procedure CSGError(const sMsg: String); overload;
  procedure CSGError(const sMsg: String; const aParams: Array of const); overload;

  procedure Error(const s: String);

  function iif(b: Boolean; const sTrue, sFalse: String): String; overload;
  function iif(b: Boolean; iTrue, iFalse: Integer): Integer;     overload;
  function iif(b: Boolean; pTrue, pFalse: Pointer): Pointer;     overload;

  procedure EnableWndCtl(Ctl: TWinControl; bEnable: Boolean);

  procedure ActivateVTNode(tv: TBaseVirtualTree; n: PVirtualNode);

implementation
uses Forms, StrUtils, ShellAPI, TypInfo, IniFiles;

   //===================================================================================================================
   //  Common functions
   //===================================================================================================================

  procedure CSGError(const sMsg: String); 
  begin
    raise ECSGError.Create(sMsg);
  end;

  procedure CSGError(const sMsg: String; const aParams: Array of const);
  begin
    raise ECSGError.CreateFmt(sMsg, aParams);
  end;

  procedure Error(const s: String);
  begin
    Application.MessageBox(PChar(s), PChar(SDlgTitleError), MB_OK or MB_ICONERROR);
  end;

  function iif(b: Boolean; const sTrue, sFalse: String): String;
  begin
    if b then Result := sTrue else Result := sFalse;
  end;

  function iif(b: Boolean; iTrue, iFalse: Integer): Integer;
  begin
    if b then Result := iTrue else Result := iFalse;
  end;

  function iif(b: Boolean; pTrue, pFalse: Pointer): Pointer;
  begin
    if b then Result := pTrue else Result := pFalse;
  end;

  procedure EnableWndCtl(Ctl: TWinControl; bEnable: Boolean);
  var pi: PPropInfo;
  begin
    Ctl.Enabled := bEnable;
    pi := GetPropInfo(Ctl, 'Color', [tkInteger]);
    if pi<>nil then SetOrdProp(Ctl, pi, iif(bEnable, clWindow, clBtnFace));
  end;

  procedure ActivateVTNode(tv: TBaseVirtualTree; n: PVirtualNode);
  begin
    tv.FocusedNode := n;
    tv.Selected[n] := True;
    tv.ScrollIntoView(n, False, False);
  end;

   //===================================================================================================================
   //  TCSGProject
   //===================================================================================================================

  function TCSGProject.AbsPathToRelative(const sFileName: String): String;
  begin
    if not AnsiStartsText(FBasePath, sFileName) then CSGError(SErrMsg_CannotTranslateAbsPath, [FBasePath, sFileName]);
     // "���������" ������������� ����, ������� � ������ ������ ����� ������ � ������� ����
    Result := Copy(sFileName, Length(FBasePath)+1, MaxInt);
  end;

  procedure TCSGProject.AddSelFileAbsolute(const sFileName: String);
  var iInitialCount: Integer;
  begin
     // ���������� ���������� ������ � ������
    iInitialCount := FSelectedFiles.Count;
     // ��������� ����
    FSelectedFiles.Add(AbsPathToRelative(sFileName));
     // ���� ���������� ��������� ������ ����������, �������� ������ ��� ���������
    if iInitialCount<>FSelectedFiles.Count then begin
      DoFileListChanged;
      SetModified(True);
    end;
  end;

  procedure TCSGProject.AddToLog(const s: String; const aParams: array of const);
  begin
    if Assigned(FOnAddLog) then FOnAddLog(Self, Format(s, aParams));
  end;

  function TCSGProject.CheckGenerationPossible: Boolean;
  var sBaseDir, sOutDir: String;
  begin
    Result := False;
    sBaseDir := ExcludeTrailingPathDelimiter(FBasePath);
    sOutDir  := ExcludeTrailingPathDelimiter(FOutputPath);
    if AnsiStartsText(sOutDir, sBaseDir) or AnsiStartsText(sBaseDir, sOutDir) then
      Error(SErrFoldersRecurse)
    else if not DirectoryExists(sBaseDir) then
      Error(SErrBaseDirDoesntExist)
    else if FAutorun and not FileExists(FBasePath+FAutorunFile) then
      Error(SErrWrongAutorunFile)
    else
      Result := ForceDirectories(sOutDir);
  end;

  constructor TCSGProject.Create;
  begin
    inherited Create;
    FSSIExtensions := TStringList.Create;
    FSelectedFiles := TStringList.Create;
    FSelectedFiles.Sorted := True;
    FSelectedFiles.Duplicates := dupIgnore;
  end;

  destructor TCSGProject.Destroy;
  begin
    FSSIExtensions.Free;
    FSelectedFiles.Free;
    inherited Destroy;
  end;

  procedure TCSGProject.DoAutorun;
  var
    sFN: String;
    i: Integer;
  begin
    sFN := FOutputPath+FAutorunFile;
    AddToLog(SLogMsgAutorunning, [sFN]);
    i := ShellExecute(Application.Handle, PChar(SOpOpen), PChar(sFN), nil, nil, SW_SHOWDEFAULT);
    if i<=32 then GenerationError(SErrUnableToAutorun, [sFN, SysErrorMessage(i)]);
  end;

  procedure TCSGProject.DoFileListChanged;
  begin
    if Assigned(FOnFileListChanged) then FOnFileListChanged(Self);
  end;

  procedure TCSGProject.DoGenerationProgress(dProgress: Double);
  begin
    if Assigned(FOnGenerationProgress) then FOnGenerationProgress(Self, dProgress);
  end;

  procedure TCSGProject.DoStatusChanged;
  begin
    if Assigned(FOnStatusChanged) then FOnStatusChanged(Self);
  end;

  function TCSGProject.ExpandRelPath(const sRelFile, sOriginalFile: String): String;
  var
    s, s1dir: String;
    i: Integer;
  begin
    s := StringReplace(sRelFile, __UNIX_PATH_DELIMITER, __PATH_DELIMITER, [rfReplaceAll]);
     // ���� ���������� � '\' - ��� ���������� ���� (� �����)
    if s[1]=__PATH_DELIMITER then begin
      Result := FBasePath;
      Delete(s, 1, 1);
     // ����� - ������������� ����
    end else
      Result := ExtractFilePath(sOriginalFile);
    repeat
      i := Pos(__PATH_DELIMITER, s);
      if i=0 then i := Length(s)+1;
      s1dir := Copy(s, 1, i-1);
      if s1dir='..' then Result := ExtractFilePath(ExcludeTrailingPathDelimiter(Result)) else Result := Result+s1dir+'\';
      Delete(s, 1, i);
    until s='';
    Result := ExcludeTrailingPathDelimiter(Result);
  end;

  procedure TCSGProject.FolderAddSelFilesAbsolute(const sFolder: String);
  var iInitialCount: Integer;

    procedure DoAdd(const sRelPath: String);
    var
      sr: TSearchRec;
      iRes: Integer;
    begin
      iRes := FindFirst(FBasePath+sRelPath+'*.*', faAnyFile, sr);
      try
        while iRes=0 do begin
           // ���� ���� - ��������� � ������, ����� ���������� ��������� �������
          if sr.Name[1]<>'.' then
            if sr.Attr and faDirectory=0 then FSelectedFiles.Add(sRelPath+sr.Name) else DoAdd(sRelPath+sr.Name+'\');
          iRes := FindNext(sr);
        end;
      finally
        FindClose(sr);
      end;
    end;

  begin
     // ���������� ���������� ������ � ������
    iInitialCount := FSelectedFiles.Count;
     // ��������� ��� ����� ����� � ��������� �����
    DoAdd(AbsPathToRelative(IncludeTrailingPathDelimiter(sFolder)));
     // ���� ���������� ��������� ������ ����������, �������� ������ ��� ���������
    if iInitialCount<>FSelectedFiles.Count then begin
      DoFileListChanged;
      SetModified(True);
    end;
  end;

  procedure TCSGProject.FolderRemoveSelFilesAbsolute(const sFolder: String);
  var
    sRelPath: String;
    i, iInitialCount: Integer;
  begin
     // ���������� ���������� ������ � ������
    iInitialCount := FSelectedFiles.Count;
     // ������ ������� �� ������ ��� �����, ������������ �� ���� sRelPath
    sRelPath := AbsPathToRelative(IncludeTrailingPathDelimiter(sFolder));
    for i := FSelectedFiles.Count-1 downto 0 do
      if AnsiStartsText(sRelPath, FSelectedFiles[i]) then FSelectedFiles.Delete(i);
     // ���� ���������� ��������� ������ ����������, �������� ������ ��� ���������
    if iInitialCount<>FSelectedFiles.Count then begin
      DoFileListChanged;
      SetModified(True);
    end;
  end;

  function TCSGProject.ForceDir(const sDir: String): Boolean;
  var s: String;
  begin
    s := ExcludeTrailingPathDelimiter(sDir);
    Result := DirectoryExists(s);
    if not Result then begin
      Result := SysUtils.ForceDirectories(s);
      if Result then AddToLog(SLogMsgFolderCreated, [s]) else GenerationError(SErrUnableToCreateFolder, [s, SysErrorMessage(GetLastError)]);
    end;
  end;

  procedure TCSGProject.Generate;
  var
    tStart, tEnd: TDateTime;
    bSuccess: Boolean;
  begin
    Screen.Cursor := crHourGlass;
    try
       // ������������� ������ ������
      tStart := Time;
      AddToLog(SLogMsgStart, [FBasePath, FOutputPath, FormatDateTime(SLogTimeFormat, tStart)]);
       // ������������ �����
      bSuccess := ProcessFiles;
       // ������������� ��������� ������
      tEnd := Time;
      AddToLog(SLogMsgEnd, [iif(bSuccess, SLogMsgSuccessfully, SLogMsgWithErrors), FormatDateTime(SLogTimeFormat, tEnd), FormatDateTime(SLogTimeFormat, tEnd-tStart), FTotalSize]);
        // ��������� Autorun-����
      if bSuccess and FAutorun then DoAutorun;
    finally
      Screen.Cursor := crDefault;
    end;
  end;

  procedure TCSGProject.GenerationError(const s: String; const aParams: array of const);
  begin
    AddToLog(s, aParams);
    Error(Format(s, aParams));
  end;

  function TCSGProject.GetDisplayFileName: String;
  begin
    if FFileName='' then Result := SDefaultFileName else Result := FFileName;
  end;

  function TCSGProject.GetSelFiles(Index: Integer): String;
  begin
    Result := FSelectedFiles[Index];
  end;

  function TCSGProject.GetSelFilesAbsolute(Index: Integer): String;
  begin
    Result := FBasePath+GetSelFiles(Index);
  end;

  function TCSGProject.GetSelFilesCount: Integer;
  begin
    Result := FSelectedFiles.Count;
  end;

  function TCSGProject.IndexOfSelFile(const sFileName: String): Integer;
  begin
    Result := FSelectedFiles.IndexOf(sFileName);
  end;

  function TCSGProject.IsSSIFile(const sFileName: String): Boolean;
  begin
    Result := FSSIExtensions.IndexOf(Copy(ExtractFileExt(sFileName), 2, MaxInt))>=0;
  end;

  procedure TCSGProject.LoadFromFile(const sFileName: String);
  var fi: TIniFile;

    procedure LoadSection(const sSection: String; Strings: TStrings);
    var
      Keys: TStringList;
      i: Integer;
    begin
      Keys := TStringList.Create;
      try
        fi.ReadSection(sSection, Keys);
        for i := 0 to Keys.Count-1 do Strings.Add(fi.ReadString(sSection, Keys[I], ''));
      finally
        Keys.Free;
      end;
    end;

  begin
    fi := TIniFile.Create(sFileName);
    try
       // Project options
      FBasePath    := IncludeTrailingPathDelimiter(fi.ReadString(SIniSection_Project, 'BasePath', ''));
      FOutputPath  := IncludeTrailingPathDelimiter(fi.ReadString(SIniSection_Project, 'OutputPath', ''));
      FAutorun     := fi.ReadInteger(SIniSection_Project, 'Autorun', 0)<>0;
      FAutorunFile := fi.ReadString(SIniSection_Project, 'AutorunFile', 'index.htm');
       // SSI extensions
      LoadSection(SIniSection_SSIExts, FSSIExtensions);
       // Files
      LoadSection(SIniSection_Files, FSelectedFiles);
    finally
      fi.Free;
    end;
     // Adjust Status
    FFileName := sFileName;
    FModified := False;
     // Check that all the files are existing
    ValidateSelFiles;
     // ���������� �� ����������
    DoFileListChanged;
    DoStatusChanged;
  end;

  procedure TCSGProject.MakeNew;
  begin
    FBasePath           := '';
    FOutputPath         := '';
    FAutorun            := False;
    FAutorunFile        := SDefaultAutorunFile;
    FSSIExtensions.Text := SDefaultSSIExts;
    FSelectedFiles.Clear;
    FFileName           := '';
    FModified           := False;
     // ���������� �� ����������
    DoFileListChanged;
    DoStatusChanged;
  end;

  function TCSGProject.ProcessFiles: Boolean;
  var
    sFile: String;
    i: Integer;

    function ProcessFile(const sFile: String): Boolean;
    var
      sOutFile, s, sUp, sIncFile: String;
      fo, fi, finc: TFileStream;
      ip: Integer;
    begin
       // Satisfy the compiler
      fi   := nil;
      fo   := nil;
      finc := nil;
      Result := False;
       // Create input stream
      try
        fi := TFileStream.Create(sFile, fmOpenRead or fmShareDenyWrite);
      except
        on e: Exception do begin
          GenerationError(SErrUnableToOpenSrcFile, [sFile, e.Message]);
          Abort;
        end;
      end;
      try
         // Create output stream
        sOutFile := ExtractRelativePath(FBasePath, sFile);
         // ���� ���� �� �������� ':' - �� ��� ������������� ����
        if Pos(__DRIVE_DELIMITER, sOutFile)=0 then sOutFile := FOutputPath+sOutFile;
        if not ForceDir(ExtractFileDir(sOutFile)) then Exit;
        try
          fo := TFileStream.Create(sOutFile, fmCreate);
        except
          on e: Exception do begin
            GenerationError(SErrUnableToOpenTgtFile, [sOutFile, e.Message]);
            Abort;
          end;
        end;
        try
           // Transfer data
           //  ** ���� ���� �������� SSI-������
          if IsSSIFile(sFile) then begin
            if fi.Size>MaxInt then begin
              GenerationError(SErrSrcFileTooLarge, [sFile, fi.Size]);
              Abort;
            end;
            SetLength(s, fi.Size);
            fi.Read(s[1], Length(s));
            sUp := AnsiUpperCase(s);
             // Search and replace INCLUDE directives
            repeat
               // -- �������� ��������� #INCLUDE
              ip := Pos(SIncludeDirectiveOpen, sUp);
              if ip=0 then Break;
              fo.Write(s[1], ip-1);
              Delete(s,   1, ip+20);
              Delete(sUp, 1, ip+20);
              ip := Pos(SIncludeDirectiveClose, sUp);
              if (ip=0) or (ip>1024) then begin
                GenerationError(SErrUnclosedInclude, [sFile]);
                Abort;
              end else begin
                 // -- �������� ��� INCLUDE-�����
                sIncFile := AnsiDequotedStr(Trim(Copy(s, 1, ip-1)), '"');
                if sIncFile='' then begin
                  GenerationError(SErrNoIncludeFileSpec, [sFile]);
                  Abort;
                end;
                 // -- ��������������� ��� INCLUDE-����� � ��������� ����
                sIncFile := ExpandRelPath(sIncFile, sFile);
                try
                  finc := TFileStream.Create(sIncFile, fmOpenRead or fmShareDenyWrite);
                except
                  on e: Exception do begin
                    GenerationError(SErrUnableToOpenIncludeFile, [sIncFile, sFile, e.Message]);
                    Abort;
                  end;
                end;
                 // -- ��������� ���������� INCLUDE-�����
                try
                  fo.CopyFrom(finc, 0);
                  AddToLog(SLogMsgIncludeInserted, [sIncFile, finc.Size]);
                finally
                  finc.Free;
                end;
              end;
              Delete(s,   1, ip+2);
              Delete(sUp, 1, ip+2);
            until False;
             // Write the rest of the string
            fo.Write(s[1], Length(s));
           //  ** ���� ���� �� �������� SSI-������
          end else
            fo.CopyFrom(fi, 0);
           // Set Result to success
          AddToLog(SLogMsgFileProcessed, [sFile, fo.Size]);
          Result := True;
          Inc(FTotalSize, fo.Size);
        finally
          fo.Free;
        end;
      finally
        fi.Free;
      end;
    end;

  begin
    Result := True;
    FTotalSize := 0;
    for i := 0 to FSelectedFiles.Count-1 do begin
      sFile := FBasePath+FSelectedFiles[i];
      Result := ForceDir(ExtractFileDir(sFile));
      if not Result then Break;
      Result := ProcessFile(sFile);
      if not Result then Break;
      DoGenerationProgress(i/(FSelectedFiles.Count-1));
    end;
  end;

  procedure TCSGProject.RemoveSelFileAbsolute(const sFileName: String);
  var idx: Integer;
  begin
    idx := IndexOfSelFile(AbsPathToRelative(sFileName));
    if idx>=0 then begin
      FSelectedFiles.Delete(idx);
      DoFileListChanged;
      SetModified(True);
    end;
  end;

  procedure TCSGProject.SaveToFile(const sFileName: String);
  var
    fs: TFileStream;
    i: Integer;

    procedure WriteLine(const s: String);
    var sl: String;
    begin
      sl := s+#13#10;
      fs.Write(sl[1], Length(sl));
    end;

  begin
    fs := TFileStream.Create(sFileName, fmCreate);
    try
       // Preamble
      WriteLine('; Client SSI Generator project, created with CSSIGen v'+sAppVersion);
      WriteLine('');
       // Project options
      WriteLine('[Project]');
      WriteLine('BasePath='+FBasePath);
      WriteLine('OutputPath='+FOutputPath);
      WriteLine('Autorun='+IntToStr(Byte(FAutorun)));
      WriteLine('AutorunFile='+FAutorunFile);
      WriteLine('');
       // SSI extensions
      WriteLine('[SSIExtensions]');
      for i := 0 to FSSIExtensions.Count-1 do WriteLine(Format('Item%d=%s', [i, FSSIExtensions[i]]));
      WriteLine('');
       // Files
      WriteLine('[Files]');
      for i := 0 to FSelectedFiles.Count-1 do WriteLine(Format('File%d=%s', [i, FSelectedFiles[i]]));
    finally
      fs.Free;
    end;
     // Adjust Status
    FFileName := sFileName;
    FModified  := False;
     // ���������� �� ����������
    DoStatusChanged;
  end;

  procedure TCSGProject.SetAutorun(const Value: Boolean);
  begin
    if FAutorun<>Value then begin
      FAutorun := Value;
      SetModified(True);
    end;
  end;

  procedure TCSGProject.SetAutorunFile(const Value: String);
  begin
    if FAutorunFile<>Value then begin
      FAutorunFile := Trim(Value);
      SetModified(True);
    end;
  end;

  procedure TCSGProject.SetBasePath(const Value: String);
  begin
    if FBasePath<>Value then begin
      FBasePath := IncludeTrailingPathDelimiter(Trim(Value));
      FSelectedFiles.Clear;
      SetModified(True);
    end;
  end;

  procedure TCSGProject.SetFileName(const Value: String);
  begin
    if FFileName<>Value then begin
      FFileName := Value;
      DoStatusChanged;
    end;
  end;

  procedure TCSGProject.SetModified(Value: Boolean);
  begin
    if FModified<>Value then begin
      FModified := Value;
      DoStatusChanged;
    end;
  end;

  procedure TCSGProject.SetOutputPath(const Value: String);
  begin
    if FOutputPath<>Value then begin
      FOutputPath := IncludeTrailingPathDelimiter(Trim(Value));
      SetModified(True);
    end;
  end;

  procedure TCSGProject.SetSSIExtensions(Value: TStrings);
  begin
    if FSSIExtensions.Text<>Value.Text then begin
      FSSIExtensions.Assign(Value);
      SetModified(True);
    end;
  end;

  procedure TCSGProject.ValidateSelFiles;
  var i: Integer;
  begin
    i := 0;
    while i<FSelectedFiles.Count do
      if FileExists(FBasePath+FSelectedFiles[i]) then Inc(i) else FSelectedFiles.Delete(i);
  end;

initialization
  FileAssociations := TStringList.Create;
  FileAssociations.Text := SDefaultFileAssociations;
finalization
  FileAssociations.Free;
end.
