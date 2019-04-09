unit f_lump;

interface

uses SysUtils,Types,Classes,QGraphics,QControls,QForms,QDialogs,QStdCtrls;

type
  TForm_lump = class(TForm)
    GroupBox1: TGroupBox;
    radio_fromfile: TRadioButton;
    radio_troph_sim: TRadioButton;
    radio_biol_crit: TRadioButton;
    radio_random: TRadioButton;
    button_select_file: TButton;
    button_run: TButton;
    button_crit_choose: TButton;
    OpenDialog1: TOpenDialog;
    edit_nb_lump: TEdit;
    label_nb_lump: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure button_runClick(Sender: TObject);
    procedure button_crit_chooseClick(Sender: TObject);
    procedure button_select_fileClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var form_lump : tform_lump;

{ methodes d'aggregation }
const tro_sim = 1;
      biologic = 2;
      random = 3;

implementation

{$R *.xfm}

uses kutil,kglobvar,kgestiong,klump,f_choose_crit,f_nw;

var nb_lump : integer;
    nomfic : string;

procedure tform_lump.FormCreate(Sender: TObject);
begin
  Left   := 300;
  Top    := 460;
  Height := 305;
  Width  := 306;
  resolution;
  adjust(self);
  nb_lump := 1;
end;

procedure tform_lump.FormActivate(Sender: TObject);
begin
  edit_nb_lump.Text := IntToStr(nb_lump);
end;

procedure TForm_lump.button_runClick(Sender: TObject);
var g,c,ms : integer;
begin
  if ( edit_nb_lump.Text <> '' ) then
    begin
      c := StrToInt(edit_nb_lump.Text);
      if ( c <= 0 ) or ( c >= graphes[g_select].nb_sommets ) then
        begin
          erreur_('Number of nodes out of bounds');
          exit;
        end;
      nb_lump := c;
    end
  else
    nb_lump := 1;
  ms := clock;
  if radio_fromfile.Checked  then g := from_file(g_select,nomfic);
  if radio_troph_sim.Checked then g := hier_clust(g_select,tro_sim,nb_lump);
  if radio_biol_crit.Checked then g := hier_clust(g_select,biologic,nb_lump);
  if radio_random.Checked    then g := hier_clust(g_select,random,nb_lump);
  if ( g <> 0 ) then with form_nw do
    begin
      affiche;
      status_action('Aggregation done');
    end;
  iwriteln('--> ' + s_ecri_t_exec(clock-ms));
  graphe2mat(g_select);
  Close;
end;

procedure TForm_lump.button_crit_chooseClick(Sender: TObject);
begin
  if radio_biol_crit.Checked then with form_choose_crit do
    begin
      if not Visible then Show;
      SetFocus;
    end;
end;

procedure TForm_lump.button_select_fileClick(Sender: TObject);
begin
  if radio_fromfile.Checked  then
    begin
      form_lump.opendialog1.Execute;
      nomfic := opendialog1.FileName;
    end;
end;

end.
