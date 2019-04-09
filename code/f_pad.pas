unit f_pad;

interface

uses SysUtils,Types,Classes,QGraphics,QControls,QForms,QDialogs,QStdCtrls,
     QExtCtrls,QComCtrls;

type
  tform_pad = class(TForm)
    Memo1: TMemo;
    StatusBar1: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure StatusBar1PanelClick(Sender: TObject; Panel: TStatusPanel);
  private
  public
  end;

var form_pad : tform_pad;

implementation

uses kutil,ksyntax;

{$R *.xfm}

procedure tform_pad.FormCreate(Sender: TObject);
begin
  Left   := 780;
  Top    := 250;
  Height := 705;
  Width  := 400;
  adjust(self);
  memo1.ReadOnly := true;
  memo1.Clear;
end;

procedure tform_pad.StatusBar1PanelClick(Sender: TObject;Panel: TStatusPanel);
begin
  if ( panel.Index = 0 ) then b_ecri_system;
end;

end.
