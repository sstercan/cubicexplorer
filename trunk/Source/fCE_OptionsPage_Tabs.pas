unit fCE_OptionsPage_Tabs;

interface

uses
  // CE Units
  fCE_OptionsCustomPage, fCE_OptionsDialog, CE_LanguageEngine, CE_Utils,
  CE_CommonObjects,
  // Tnt
  TntStdCtrls, TntFileCtrl,
  // System Units
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, CE_SettingsIntf, MPShellUtilities, ShlObj,
  StrUtils;

type
  TCEOptionsPage_Tabs = class(TCEOptionsCustomPage)
    NewTabGroup: TTntGroupBox;
    radio_newtab_1: TTntRadioButton;
    radio_newtab_2: TTntRadioButton;
    radio_newtab_3: TTntRadioButton;
    edit_newtab: TTntEdit;
    but_newtab: TTntButton;
    check_newtab_switch: TTntCheckBox;
    check_opentab_switch: TTntCheckBox;
    check_reusetabs_switch: TTntCheckBox;
    procedure radio_newtab_1Click(Sender: TObject);
    procedure but_newtabClick(Sender: TObject);
    procedure HandleChange(Sender: TObject);
  private
    fNewTabNamespace: TNamespace;
    { Private declarations }
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplySettings; override;
    procedure LoadFromStorage(Storage: ICESettingsStorage); override; stdcall;
    procedure SaveToStorage(Storage: ICESettingsStorage); override; stdcall;
    { Public declarations }
  end;

implementation

uses
  Main;

{$R *.dfm}

{-------------------------------------------------------------------------------
  Create an instance of TCEOptionsPage_General
-------------------------------------------------------------------------------}
constructor TCEOptionsPage_Tabs.Create(AOwner: TComponent);
begin
  inherited;
  PageName:= _('Tabs');
  PageTitle:= _('Tabs Settings');
  PagePath:= 'Tabs';
  ImageIndex:= 1;
end;

{-------------------------------------------------------------------------------
  Destroy
-------------------------------------------------------------------------------}
destructor TCEOptionsPage_Tabs.Destroy;
begin
  if assigned(fNewTabNamespace) then
  FreeAndNil(fNewTabNamespace);
  inherited;
end;

{-------------------------------------------------------------------------------
  Apply Settings
-------------------------------------------------------------------------------}
procedure TCEOptionsPage_Tabs.ApplySettings;
var
  new_path: WideString;
  pidl: PItemIDList;
begin
  if radio_newtab_2.Checked then
  MainForm.TabSet.NewTabType:= 2
  else if radio_newtab_3.Checked then
  MainForm.TabSet.NewTabType:= 3
  else
  MainForm.TabSet.NewTabType:= 1;

  if assigned(fNewTabNamespace) then
  begin
    if CE_SpecialNamespaces.GetSpecialID(fNewTabNamespace.AbsolutePIDL) > -1 then
    pidl:= nil
    else
    pidl:= PathToPIDL(fNewTabNamespace.NameForParsing);

    if not assigned(pidl) then
    new_path:= 'PIDL:' + SavePIDLToMime(fNewTabNamespace.AbsolutePIDL)
    else
    new_path:= fNewTabNamespace.NameForParsing;
    PIDLMgr.FreePIDL(pidl);
  end
  else
  new_path:= '';
  
  MainForm.TabSet.NewTabPath:= new_path;

  MainForm.TabSet.NewTabSelect:= check_newtab_switch.Checked;
  MainForm.TabSet.OpenTabSelect:= check_opentab_switch.Checked;
  MainForm.TabSet.ReuseTabs:= check_reusetabs_switch.Checked;
end;

{-------------------------------------------------------------------------------
  radio_newtab button click
-------------------------------------------------------------------------------}
procedure TCEOptionsPage_Tabs.radio_newtab_1Click(Sender: TObject);
begin
  edit_newtab.Enabled:= radio_newtab_3.Checked;
  but_newtab.Enabled:= radio_newtab_3.Checked;
  HandleChange(Sender);
end;

{-------------------------------------------------------------------------------
  buttonh_newtab click
-------------------------------------------------------------------------------}
procedure TCEOptionsPage_Tabs.but_newtabClick(Sender: TObject);
var
  pidl: PItemIDList;
begin
  pidl:= BrowseForFolderPIDL(_('Select default folder for new tabs.'));
  if assigned(pidl) then
  begin
    if assigned(fNewTabNamespace) then
    FreeAndNil(fNewTabNamespace);
    fNewTabNamespace:= TNamespace.Create(pidl, nil);
    edit_newtab.Text:= fNewTabNamespace.NameParseAddress;
  end;
end;

{-------------------------------------------------------------------------------
  Handle Change
-------------------------------------------------------------------------------}
procedure TCEOptionsPage_Tabs.HandleChange(Sender: TObject);
begin
  inherited;
end;

{-------------------------------------------------------------------------------
  Load From Storage
-------------------------------------------------------------------------------}
procedure TCEOptionsPage_Tabs.LoadFromStorage(Storage: ICESettingsStorage);
var
  ws: WideString;
  pidl: PItemIDList;
  i: Integer;
begin
  // New tab type
  i:= Storage.ReadInteger('/Tabs/NewTabType', 1);
  case i of
    2: radio_newtab_2.Checked:= true;
    3: radio_newtab_3.Checked:= true;
    else
    radio_newtab_1.Checked:= true;
  end;
  // New tab custom path
  ws:= Storage.ReadString('/Tabs/NewTabPath', '');
  if assigned(fNewTabNamespace) then
  FreeAndNil(fNewTabNamespace);

  pidl:= nil;
  if Length(ws) > 5 then
  begin
    if LeftStr(ws, 5) = 'PIDL:' then
    begin
      ws:= Copy(ws, 6, Length(ws)-5);
      pidl:= LoadPIDLFromMime(ws);
    end;
  end;
  if not assigned(pidl) then
  pidl:= PathToPIDL(ws);
  fNewTabNamespace:= TNamespace.Create(pidl, nil);
  edit_newtab.Text:= fNewTabNamespace.NameAddressbar;

  // Switch to new tab
  check_newtab_switch.Checked:= Storage.ReadBoolean('/Tabs/NewTabSelect', true);
  // Switch to opened tab
  check_opentab_switch.Checked:= Storage.ReadBoolean('/Tabs/OpenTabSelect', false);
  // Switch to reuse tab
  check_reusetabs_switch.Checked:= Storage.ReadBoolean('/Tabs/ReuseTabs', false);
end;

{-------------------------------------------------------------------------------
  Save To Storage
-------------------------------------------------------------------------------}
procedure TCEOptionsPage_Tabs.SaveToStorage(Storage: ICESettingsStorage);
var
  i: Integer;
  new_path: WideString;
  pidl: PItemIDList;
begin
  // New tab type
  if radio_newtab_2.Checked then
  i:= 2
  else if radio_newtab_3.Checked then
  i:= 3
  else
  i:= 1;
  Storage.WriteInteger('/Tabs/NewTabType', i);
  // New tab custom path
  if assigned(fNewTabNamespace) then
  begin
    if CE_SpecialNamespaces.GetSpecialID(fNewTabNamespace.AbsolutePIDL) > -1 then
    pidl:= nil
    else
    pidl:= PathToPIDL(fNewTabNamespace.NameForParsing);

    if not assigned(pidl) then
    new_path:= 'PIDL:' + SavePIDLToMime(fNewTabNamespace.AbsolutePIDL)
    else
    new_path:= fNewTabNamespace.NameForParsing;
    PIDLMgr.FreePIDL(pidl);
  end
  else
  new_path:= '';
  Storage.WriteString('/Tabs/NewTabPath', new_path);
  // Switch to new tab
  Storage.WriteBoolean('/Tabs/NewTabSelect', check_newtab_switch.Checked);
  // Switch to open tab
  Storage.WriteBoolean('/Tabs/OpenTabSelect', check_opentab_switch.Checked);
  // Switch to reuse tab
  Storage.WriteBoolean('/Tabs/ReuseTabs', check_reusetabs_switch.Checked);
end;

{##############################################################################}



initialization
  RegisterOptionsPageClass(TCEOptionsPage_Tabs);

finalization

end.
