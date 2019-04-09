unit f_about;

interface

uses
  SysUtils,Types,Classes,QGraphics,QControls,QForms,QDialogs,
  QExtCtrls,QButtons,QStdCtrls;

type
  tform_about = class(TForm)
    AboutPanel: TPanel;
    label_version: TLabel;
    label_copyright: TLabel;
    label_adresse1: TLabel;
    OKButton: TButton;
    Image1: TImage;
    label_collab: TLabel;
    label_collab1: TLabel;
    label_authors: TLabel;
    label_adresse2: TLabel;
  private
  public
  end;

var  form_about: tform_about;

implementation

uses kutil;

{$R *.xfm}

end.
