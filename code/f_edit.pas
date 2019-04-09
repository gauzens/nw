unit f_edit;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  QComCtrls, QExtCtrls, QStdCtrls, QTypes, QMenus, QActnList, QImgList,
  QStdActns;

type
  tform_edit = class(TForm)
    MainMenu1: TMainMenu;
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    ActionList1: TActionList;
    file_compil: TAction;
    File1: TMenuItem;
    Open1: TMenuItem;
    Save1: TMenuItem;
    saveAs1: TMenuItem;
    Compile1: TMenuItem;
    EditCut1: TEditCut;
    EditCopy1: TEditCopy;
    EditPaste1: TEditPaste;
    file_open_button: TToolButton;
    file_save_button: TToolButton;
    ToolButton7: TToolButton;
    edit_cut_button: TToolButton;
    N1: TMenuItem;
    Edit1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    file_open: TAction;
    file_save: TAction;
    file_saveas: TAction;
    memo1: TMemo;
    N2: TMenuItem;
    Exit1: TMenuItem;
    N3: TMenuItem;
    file_exit: TAction;
    edit_copy_button: TToolButton;
    edit_paste_button: TToolButton;
    ToolButton3: TToolButton;
    file_compil_button: TToolButton;
    file_close: TAction;
    Close1: TMenuItem;
    pagecontrol1: TPageControl;
    procedure memoChange(Sender: TObject);
    procedure newpage(filename : string);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure status(filename : string);
    procedure file_openExecute(Sender: TObject);
    procedure file_saveExecute(Sender: TObject);
    procedure file_saveasExecute(Sender: TObject);
    procedure file_exitExecute(Sender: TObject);
    procedure file_compilExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var action1: TCloseAction);
    procedure PageControl1Change(Sender: TObject);
    procedure file_closeExecute(Sender: TObject);
  private
  public
  end;

var  form_edit: tform_edit;

implementation

uses kcompil,kutil,f_nw;

{$R *.xfm}

procedure tform_edit.memoChange(Sender: TObject);
begin
  memo1.Lines := TMemo(pagecontrol1.ActivePage.Controls[0]).Lines;
  status(TMemo(pagecontrol1.ActivePage.Controls[0]).Hint);
end;

procedure tform_edit.newpage(filename : string);
begin
  with TTabSheet.Create(nil) do
    begin
      PageControl := pagecontrol1;
      Caption := ExtractFileName(filename);
    end;
  with TMemo.Create(nil) do
    begin
      Lines := memo1.Lines;
      Parent := pagecontrol1.Pages[pagecontrol1.PageCount - 1];
      Align  := alClient;
      WordWrap := false;
      ScrollBars := ssAutoBoth;
      Modified := false;
      OnChange := memoChange;
      Hint := filename;
    end;
  with pagecontrol1 do ActivePageIndex := PageCount - 1;
  status(filename);
end;

procedure tform_edit.FormCreate(Sender: TObject);
begin
  Left   := 772;
  Top    := 120;
  Height := 600;
  Width  := 500;
  adjust(self);
  memo1.Clear;
  pagecontrol1.Parent := Self;
  pagecontrol1.Align  := alClient;
end;

procedure tform_edit.status(filename : string);
begin
  statusbar1.Panels[0].Text := filename;
end;

procedure tform_edit.FormShow(Sender: TObject);
begin
  status(form_nw.nomfic);
end;

procedure tform_edit.file_openExecute(Sender: TObject);
begin
  form_nw.fileopenExecute(nil);
end;

procedure tform_edit.file_saveExecute(Sender: TObject);
begin
  form_nw.filesaveExecute(nil);
end;

procedure tform_edit.file_saveasExecute(Sender: TObject);
begin
  form_nw.filesaveasExecute(nil);
end;

procedure tform_edit.file_exitExecute(Sender: TObject);
begin
  Close;
end;

procedure tform_edit.file_compilExecute(Sender: TObject);
begin
  form_nw.filecompileExecute(nil);
  status(form_nw.nomfic);
end;

procedure tform_edit.FormClose(Sender: TObject; var action1: TCloseAction);
var i,res : integer;
    cancel : boolean;
begin
  cancel  := false;
  with pagecontrol1 do
    for i := 0 to PageCount - 1 do with Pages[i] do
      begin
        if TMemo(Controls[0]).Modified then
          begin
            form_nw.nomfic := TMemo(Controls[0]).Hint;
            res := MessageDlg('Save file ' + ExtractFileName(form_nw.nomfic) + ' ?',
                      mtConfirmation,[mbYes,mbNo,mbCancel],0);
            case res of
              mrYes    : form_nw.filesaveExecute(nil);
              mrNo     : ;
              mrCancel : cancel := true;
            end;
          end;
      end;
  if cancel then action1 := caNone else action1 := caFree;
end;

procedure tform_edit.pagecontrol1Change(Sender: TObject);
begin
  with pagecontrol1 do
    if ( PageCount > 0 ) then with ActivePage do
      if ( ControlCount > 0 ) then
        begin
          memo1.Lines := TMemo(Controls[0]).Lines;
          form_nw.nomfic := TMemo(Controls[0]).Hint;
          status(form_nw.nomfic);
        end;
end;

procedure tform_edit.file_closeExecute(Sender: TObject);
var res : integer;
begin
  with pagecontrol1.ActivePage do
    begin
      if TMemo(Controls[0]).Modified then
        begin
          res := MessageDlg('Save file ' + ExtractFileName(form_nw.nomfic) + ' ?',
                      mtConfirmation,[mbYes,mbNo,mbCancel],0);
          case res of
            mrYes : form_nw.filesaveExecute(nil);
            mrCancel : exit;
          else
          end;
        end;
      TabVisible := false;
      TMemo(Controls[0]).Clear;
    end;
end;

end.
