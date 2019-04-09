unit f_choose_crit;

interface

uses SysUtils,Types,Classes,QGraphics,QControls,QForms,QDialogs,QStdCtrls;

type
  Tform_choose_crit = class(TForm)
    list_crit: TListBox;
    button_ok: TButton;
    procedure FormActivate(Sender: TObject);
    procedure button_okClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var form_choose_crit : Tform_choose_crit;
    strlist : TStringList;

implementation

uses kglobvar,klump,kutil;

{$R *.xfm}

procedure Tform_choose_crit.FormCreate(Sender: TObject);
begin
  StrList := Tstringlist.Create;
end;

procedure Tform_choose_crit.FormActivate(Sender: TObject);
var i: integer;
begin
  list_crit.Clear;
  for i := 1 to graphes[g_select].nb_infos do
    list_crit.Items.Add(graphes[g_select].name_info[i]);
end;

procedure maj_infobio;
var i,j: integer;
begin
  for i := 1 to nb_choix do
    for j := 1 to infomax do
      if graphes[g_select].name_info[j] = StrList[i-1] then
        info_bio[i] := j;
end;

procedure Tform_choose_crit.button_okClick(Sender: TObject);
var i: integer;
begin
  StrList.Clear;
  for i := 0 to graphes[g_select].nb_infos-1 do
    if list_crit.selected[i] then
      StrList.Add(list_crit.Items[i]);
  nb_choix := Strlist.Count;
  maj_infobio;
  Close;
end;

end.
