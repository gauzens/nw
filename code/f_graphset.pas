unit f_graphset;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  QStdCtrls, QExtCtrls,f_graph;

type
  Tform_graphset = class(TForm)
    panel1: TPanel;
    box_axis: TGroupBox;
    xmin_edit: TEdit;
    ymin_edit: TEdit;
    xmin: TLabel;
    ymin: TLabel;
    xmax_edit: TEdit;
    ymax_edit: TEdit;
    xmax: TLabel;
    ymax: TLabel;
    bordoff_check: TCheckBox;
    xscale_check: TCheckBox;
    yscale_check: TCheckBox;
    ok_button: TButton;
    cancel_button: TButton;
    apply_button: TButton;
    grid_check: TCheckBox;
    box_repr: TGroupBox;
    edit_nb_niv: TEdit;
    label_nb_niv: TLabel;
    box_labels: TGroupBox;
    radio_label_no: TRadioButton;
    radio_label_num: TRadioButton;
    radio_label_nom: TRadioButton;
    box_color: TGroupBox;
    radio_rainbow: TRadioButton;
    radio_multicol: TRadioButton;
    radio_grey: TRadioButton;
    radio_blackonwhite: TRadioButton;
    radio_whiteonblack: TRadioButton;
    box_groups: TGroupBox;
    radio_groups_no: TRadioButton;
    radio_groups_mod: TRadioButton;
    radio_groups_aic: TRadioButton;
    radio_groups_tro: TRadioButton;
    checkbox_thin_links: TCheckBox;
    checkbox_no_links: TCheckBox;
    checkbox_haut_val: TCheckBox;
    procedure cancel_buttonClick(Sender: TObject);
    procedure ok_buttonClick(Sender: TObject);
    procedure apply_buttonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure grid_checkClick(Sender: TObject);
    procedure radio_rainbowClick(Sender: TObject);
    procedure radio_multicolClick(Sender: TObject);
    procedure radio_label_noClick(Sender: TObject);
    procedure radio_label_numClick(Sender: TObject);
    procedure radio_label_nomClick(Sender: TObject);
    procedure radio_groups_noClick(Sender: TObject);
    procedure radio_groups_modClick(Sender: TObject);
    procedure radio_groups_aicClick(Sender: TObject);
    procedure radio_groups_troClick(Sender: TObject);
    procedure radio_greyClick(Sender: TObject);
    procedure radio_blackonwhiteClick(Sender: TObject);
    procedure radio_whiteonblackClick(Sender: TObject);
  private
    err_graphset : boolean;
    procedure erreur(s : string);
  public
    fg : tform_graph;
  end;

var  form_graphset: tform_graphset;

implementation

uses kglobvar,kutil,ksyntax;

{$R *.xfm}

procedure tform_graphset.erreur(s : string);
begin
  erreur_('Graph Settings - ' + s);
  err_graphset := true;
end;

procedure Tform_graphset.cancel_buttonClick(Sender: TObject);
begin
  Close;
end;

procedure Tform_graphset.ok_buttonClick(Sender: TObject);
begin
  apply_buttonClick(nil);
  if not err_graphset then Close;
end;

procedure Tform_graphset.apply_buttonClick(Sender: TObject);
var nb_niva : integer;
    xmina,xmaxa,ymina,ymaxa : extended;
    xscalea,yscalea : boolean;
begin
  with fg do
    begin
      if xscale_check.State = cbChecked then
        begin
          if not est_reel(xmin_edit.Text,xmina) then
            begin
              erreur('Xmin: real value expected');
              exit;
            end;
          if not est_reel(xmax_edit.Text,xmaxa) then
            begin
              erreur('Xmin: real value expected');
              exit;
            end;
          if ( xmina >= xmaxa ) then
            begin
              erreur('Xscale: Xmin >= Xmax');
              exit;
            end;
          xscalea := true;
        end
      else
        xscalea := false;
      if yscale_check.state = cbChecked then
        begin
          if not est_reel(ymin_edit.Text,ymina) then
            begin
              erreur('Ymin: real value expected');
              exit;
            end;
          if not est_reel(ymax_edit.Text,ymaxa) then
            begin
              erreur('Ymax: real value expected');
              exit;
            end;
          if ( ymina >= ymaxa ) then
            begin
              erreur('Yscale: Ymin >= Ymax');
              exit;
            end;
          yscalea := true;
        end
      else
        yscalea := false;
      if est_entier(edit_nb_niv.Text,nb_niva) then
        if ( nb_niva < 1 ) then
          begin
            erreur('Nb of levels: integer > 1 expected');
            exit;
          end
        else
      else
        begin
          erreur('Nb of levels: integer > 1 expected');
          exit;
        end;
      nb_niv := nb_niva;
      xscale := xscalea;
      if xscale then
        begin
          xmin := xmina;
          xmax := xmaxa;
        end;
      yscale := yscalea;
      if yscale then
        begin
          ymin := ymina;
          ymax := ymaxa;
        end;
      bord := bordoff_check.state = cbUnchecked;
      grid := grid_check.state    = cbChecked;

      if radio_label_no.Checked  then label_graphe := label_no;
      if radio_label_num.Checked then label_graphe := label_num;
      if radio_label_nom.Checked then label_graphe := label_nom;
      rainbow   := radio_rainbow.Checked;
      multicol  := radio_multicol.Checked;
      greyscale := radio_grey.Checked;
      black_on_white := radio_blackonwhite.Checked;
      white_on_black := radio_whiteonblack.Checked;

      if radio_groups_no.Checked  then group_graphe := graf_group_no;
      if radio_groups_mod.Checked then group_graphe := graf_group_mod;
      if radio_groups_aic.Checked then group_graphe := graf_group_aic;
      if radio_groups_tro.Checked then group_graphe := graf_group_tro;

      thin_links := checkbox_thin_links.Checked;
      no_links   := checkbox_no_links.Checked;
      haut_val   := checkbox_haut_val.Checked;

      repaint1(nil);
    end;
end;

procedure tform_graphset.FormCreate(Sender: TObject);
begin
  Left   := 374;
  Top    := 4;
  Height := 686;
  Width  := 506;
  adjust(self);
end;

procedure Tform_graphset.FormActivate(Sender: TObject);
begin
  err_graphset := false;
  with fg do
    begin
      form_graphset.Caption := 'GRAPHIC SETTINGS <' + IntToStr(ifg) + '>';
      xmin_edit.Text := s_ecri_val(xmin);
      xmax_edit.Text := s_ecri_val(xmax);
      ymin_edit.Text := s_ecri_val(ymin);
      ymax_edit.Text := s_ecri_val(ymax);
      xscale_check.Checked    := xscale;
      yscale_check.Checked    := yscale;
      bordoff_check.Checked   := not bord;
      grid_check.Checked      := grid;

      edit_nb_niv.Text := IntToStr(nb_niv);

      radio_groups_no.Checked  := group_graphe = graf_group_no;
      radio_groups_mod.Checked := group_graphe = graf_group_mod;
      radio_groups_aic.Checked := group_graphe = graf_group_aic;
      radio_groups_tro.Checked := group_graphe = graf_group_tro;

      radio_label_no.Checked  := label_graphe = label_no;
      radio_label_num.Checked := label_graphe = label_num;
      radio_label_nom.Checked := label_graphe = label_nom;

      radio_rainbow.Checked   := rainbow;
      radio_multicol.Checked  := multicol;
      radio_grey.Checked      := greyscale;
      radio_blackonwhite.Checked := black_on_white;
      radio_whiteonblack.Checked := white_on_black;

      checkbox_thin_links.Checked := thin_links;
      checkbox_no_links.Checked   := no_links;
      checkbox_haut_val.Checked   := haut_val;

    end;
end;

procedure Tform_graphset.grid_checkClick(Sender: TObject);
begin
  {with fg do grid := true;}
end;

procedure Tform_graphset.radio_rainbowClick(Sender: TObject);
begin
  {with fg do rainbow := true;}
end;

procedure Tform_graphset.radio_multicolClick(Sender: TObject);
begin
  {with fg do multicol := true;}
end;

procedure Tform_graphset.radio_greyClick(Sender: TObject);
begin
  {with fg do ;}
end;

procedure Tform_graphset.radio_blackonwhiteClick(Sender: TObject);
begin
  {with fg do ;}
end;

procedure Tform_graphset.radio_whiteonblackClick(Sender: TObject);
begin
  {with fg do ;}
end;

procedure Tform_graphset.radio_label_noClick(Sender: TObject);
begin
  {with fg do label_graphe := label_no;}
end;

procedure Tform_graphset.radio_label_numClick(Sender: TObject);
begin
  {with fg do label_graphe := label_num;}
end;

procedure Tform_graphset.radio_label_nomClick(Sender: TObject);
begin
  {with fg do label_graphe := label_nom;}
end;

procedure Tform_graphset.radio_groups_noClick(Sender: TObject);
begin
  {with fg do group_graphe := graf_group_no;}
end;

procedure Tform_graphset.radio_groups_modClick(Sender: TObject);
begin
  {with fg do group_graphe := graf_group_mod;}
end;

procedure Tform_graphset.radio_groups_aicClick(Sender: TObject);
begin
  {with fg do group_graphe := graf_group_aic;}
end;

procedure Tform_graphset.radio_groups_troClick(Sender: TObject);
begin
  {with fg do group_graphe := graf_group_tro;}
end;

end.
