unit f_createg;

{ @@@@@@  creation de graphes  @@@@@@ }

interface

uses SysUtils,Types,Classes,QGraphics,QControls,QForms,QDialogs,QStdCtrls,
     QExtCtrls,QComCtrls;

type
  tform_create_graphe = class(TForm)
    edit_nb_sommets: TEdit;
    label_nb_sommets: TLabel;
    StatusBar1: TStatusBar;
    RadioGroup1: TRadioGroup;
    radio_void: TRadioButton;
    radio_random: TRadioButton;
    radio_subgraph: TRadioButton;
    edit_p_random: TEdit;
    edit_subgraphe_pere: TEdit;
    button_ok: TButton;
    button_cancel: TButton;
    button_apply: TButton;
    radio_tree: TRadioButton;
    edit_p_tree: TEdit;
    edit_degree_tree: TEdit;
    edit_nb_niv_tree: TEdit;
    label_degree: TLabel;
    label_nb_niv: TLabel;
    radio_som: TRadioButton;
    edit_g1: TEdit;
    edit_g2: TEdit;
    label_compose: TLabel;
    edit_seed: TEdit;
    label_seed: TLabel;
    radio_unif: TRadioButton;
    edit_nb_links: TEdit;
    radio_smallw: TRadioButton;
    edit_p_smallw: TEdit;
    edit_degree_smallw: TEdit;
    label_p_smallw: TLabel;
    label_degree_smallw: TLabel;
    radio_null_deg: TRadioButton;
    Label5: TLabel;
    edit_null_deg_pere: TEdit;
    radio_null_bit: TRadioButton;
    Label1: TLabel;
    edit_null_bit_pere: TEdit;
    radio_null_niche: TRadioButton;
    label_c: TLabel;
    edit_c: TEdit;
    Label2: TLabel;
    label_p_random: TLabel;
    label_nb_links: TLabel;
    label_p_tree: TLabel;
    radio_root: TRadioButton;
    Label3: TLabel;
    edit_root_pere: TEdit;
    radio_dual: TRadioButton;
    edit_dual_pere: TEdit;
    Label4: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure radio_voidClick(Sender: TObject);
    procedure radio_randomClick(Sender: TObject);
    procedure radio_subgraphClick(Sender: TObject);
    procedure radio_copyClick(Sender: TObject);
    procedure button_cancelClick(Sender: TObject);
    procedure button_okClick(Sender: TObject);
    procedure button_applyClick(Sender: TObject);
    procedure radio_treeClick(Sender: TObject);
    procedure radio_somClick(Sender: TObject);
    procedure radio_null_degClick(Sender: TObject);
    procedure radio_null_bitClick(Sender: TObject);
    procedure radio_null_nicheClick(Sender: TObject);
    procedure radio_unifClick(Sender: TObject);
    procedure radio_smallwClick(Sender: TObject);
    procedure radio_rootClick(Sender: TObject);
    procedure radio_dualClick(Sender: TObject);
  private
    nb_som   : integer;
    nb_a     : integer;
    typ_gra  : integer;
    p_random : extended;
    p_tree   : extended;
    p_smallw : extended;
    nb_niv_tree   : integer;
    degree_tree   : integer;
    degree_smallw : integer;
    procedure erreur(s : string);
  public
  end;

var form_create_graphe: tform_create_graphe;

implementation

uses kglobvar,kutil,kmath,ksyntax,kgestiong,kmanipg,ksimulg,f_nw;

{$R *.xfm}

procedure tform_create_graphe.erreur(s : string);
begin
  erreur_('Create Network - ' + s);
end;

procedure tform_create_graphe.FormCreate(Sender: TObject);
begin
  Left   := 100;
  Top    := 80;
  Height := 800;
  Width  := 380;
  adjust(self);
  typ_gra  := 0;
  p_random := 0.06;
  p_tree   := 1.0;
  p_smallw := 0.1;
  nb_niv_tree   := 3;
  degree_tree   := 3;
  degree_smallw := 3;
  nb_som := 30;
  nb_a   := 54;
end;

procedure tform_create_graphe.FormActivate(Sender: TObject);
begin
  if ( g_select <> 0 ) then
    with graphes[g_select] do
      begin
        nb_som := nb_sommets;
        nb_a   := nb_arcs;
        edit_subgraphe_pere.Text := IntToStr(icre);
        edit_null_deg_pere.Text  := IntToStr(icre);
        edit_null_bit_pere.Text  := IntToStr(icre);
        edit_root_pere.Text      := IntToStr(icre);
        edit_dual_pere.Text      := IntToStr(icre);
        edit_g1.Text := IntToStr(icre);
        edit_g2.Text := edit_g1.Text;
      end;
  edit_nb_sommets.Text := IntToStr(nb_som);
  if ( nb_som > 0 ) then
    edit_c.Text := s_ecri_val(nb_a/(nb_som*nb_som));
  edit_seed.Text       := IntToStr(magraine);
  edit_p_tree.Text     := s_ecri_val(p_tree);
  edit_p_random.Text   := s_ecri_val(p_random);
  edit_p_smallw.Text   := s_ecri_val(p_smallw);
  edit_nb_links.Text   := IntToStr(nb_a);
  edit_degree_tree.Text   := IntToStr(degree_tree);
  edit_degree_smallw.Text := IntToStr(degree_smallw);
  edit_nb_niv_tree.Text   := IntToStr(nb_niv_tree);
end;

procedure tform_create_graphe.radio_voidClick(Sender: TObject);
begin
  typ_gra := type_gra_void;
end;

procedure tform_create_graphe.radio_randomClick(Sender: TObject);
begin
  typ_gra := type_gra_erdos;
end;

procedure tform_create_graphe.radio_unifClick(Sender: TObject);
begin
  typ_gra := type_gra_unif;
end;

procedure tform_create_graphe.radio_smallwClick(Sender: TObject);
begin
  typ_gra := type_gra_smallw;
end;

procedure tform_create_graphe.radio_subgraphClick(Sender: TObject);
begin
  typ_gra := type_gra_sub;
end;

procedure tform_create_graphe.radio_null_degClick(Sender: TObject);
begin
  typ_gra := type_null_deg;
end;

procedure tform_create_graphe.radio_null_bitClick(Sender: TObject);
begin
  typ_gra := type_null_bit;
end;

procedure tform_create_graphe.radio_null_nicheClick(Sender: TObject);
begin
  typ_gra := type_null_niche;
end;

procedure tform_create_graphe.radio_copyClick(Sender: TObject);
begin
  typ_gra := type_gra_dup;
end;

procedure tform_create_graphe.radio_treeClick(Sender: TObject);
begin
  typ_gra := type_gra_arb;
end;

procedure tform_create_graphe.radio_rootClick(Sender: TObject);
begin
  typ_gra := type_gra_root;
end;

procedure tform_create_graphe.radio_dualClick(Sender: TObject);
begin
  typ_gra := type_gra_dual;
end;

procedure tform_create_graphe.radio_somClick(Sender: TObject);
begin
  typ_gra := type_gra_som;
end;

procedure tform_create_graphe.button_cancelClick(Sender: TObject);
begin
  Close;
end;

procedure tform_create_graphe.button_okClick(Sender: TObject);
begin
  button_applyClick(nil);
  Close;
end;

procedure tform_create_graphe.button_applyClick(Sender: TObject);
var g,n1,k1,niv1,g1,g2 : integer;
    p1,c1 : extended;
begin
  if not est_entier(edit_seed.Text,n1) then
    begin
      erreur('Seed: integer expected');
      edit_seed.Text := IntToStr(magraine);
      exit;
    end;
  if ( n1 <> magraine ) then
    begin
      if ( n1 <= 1 ) then
        reset_graine0
      else
        set_graine0(n1);
      edit_seed.Text := IntToStr(magraine);
    end;
  if not est_entier(edit_nb_sommets.Text,n1) then
    begin
      erreur('Nb of Species: integer expected');
      edit_nb_sommets.Text := IntToStr(nb_som);
      exit;
    end;
  if ( n1 > vecmax ) then
    begin
      erreur('Nb of Species: no more than ' + IntToStr(vecmax) + ' species');
      edit_nb_sommets.Text := IntToStr(nb_som);
      exit;
    end;
  if ( n1 < 0.0 ) then
    begin
      erreur('Nb of Species: positive integer expected');
      edit_nb_sommets.Text := IntToStr(nb_som);
      exit;
    end;
  if ( typ_gra = type_gra_sub ) and ( n1 >= graphes[g_select].nb_sommets ) then
    begin
      erreur('Number of species in SubNetwork too large');
      edit_nb_sommets.Text := IntToStr(nb_som);
      exit;
    end;
  nb_som := n1;
  case typ_gra of
    type_gra_void    : begin
                         g := void_graphe(nb_som);
                       end;
    type_gra_erdos   : begin
                         if not est_reel(edit_p_random.Text,p1) then
                           begin
                             erreur('Random Network: probability, real number expected');
                             edit_p_random.Text := s_ecri_val(p_random);
                             exit;
                           end;
                         if ( p1 < 0.0 ) or ( p1 > 1.0 ) then
                           begin
                             erreur('Random network: probability, range [0,1] expected');
                             edit_p_random.Text := s_ecri_val(p_random);
                             exit;
                           end;
                         p_random := p1;
                         g := erdos_graphe(nb_som,p_random);
                       end;
    type_gra_unif    : begin
                         if not est_entier(edit_nb_links.Text,n1) then
                           begin
                             erreur('Random Uniform Network: number of links, positive integer expected');
                             edit_nb_links.Text := IntToStr(nb_a);
                             exit;
                           end;
                         if ( n1 <= 0.0 ) then
                           begin
                             erreur('Random Uniform Network: number of links, positive integer expected');
                             edit_nb_links.Text := IntToStr(nb_a);
                             exit;
                           end;
                         if ( n1 > nb_som*nb_som ) then
                           begin
                             erreur('Random Uniform Network: too many links');
                             edit_nb_links.Text := IntToStr(nb_a);
                             exit;
                           end;
                         nb_a := n1;
                         g := unif_graphe(nb_som,nb_a);
                       end;
    type_gra_smallw  : begin
                         if not est_reel(edit_p_smallw.Text,p1) then
                           begin
                             erreur('Random SmallWorld Network: real number expected');
                             edit_p_smallw.Text := s_ecri_val(p_smallw);
                             exit;
                           end;
                         if ( p1 < 0.0 ) or ( p1 > 1.0 ) then
                           begin
                             erreur('Random SmallWorld Network: proba, range [0,1] expected');
                             edit_p_smallw.Text := s_ecri_val(p_smallw);
                             exit;
                           end;
                         if not est_entier(edit_degree_smallw.Text,k1) then
                           begin
                             erreur('Random SmallWorld Network: degree, positive integer expected');
                             edit_degree_smallw.Text := IntToStr(degree_smallw);
                             exit;
                           end;
                         if ( k1 < 0.0 ) then
                           begin
                             erreur('Random SmallWorld Network: degree, positive integer expected');
                             edit_degree_smallw.Text := IntToStr(degree_smallw);
                             exit;
                           end;
                         p_smallw := p1;
                         degree_smallw := k1;
                         g := smallworld_graphe(nb_som,degree_smallw,p_smallw);
                       end;
    type_gra_sub     : begin
                         g1 := trouve_graphe(StrToInt(edit_subgraphe_pere.Text));
                         if ( g1 = 0 ) then
                           begin
                             erreur('Random SubNetwork: unknown network');
                             edit_subgraphe_pere.Text := IntToStr(graphes[g_select].icre);
                             exit;
                           end;
                         g := sub_graphe(g1,nb_som);
                       end;
    type_null_deg :    begin
                         if ( edit_null_deg_pere.Text = '' ) then
                           begin
                             erreur('Degree Model: unknown network');
                             exit;
                           end;
                         g1 := trouve_graphe(StrToInt(edit_null_deg_pere.Text));
                         if ( g1 = 0 ) then
                           begin
                             erreur('Degree Model: unknown network');
                             edit_null_deg_pere.Text := IntToStr(graphes[g_select].icre);
                             exit;
                           end;
                         graphe2mat(g1);
                         if ( chkb_units(g1) = 0 ) then
                           begin
                             erreur('Degree Model: non swapable matrix');
                             exit;
                           end;
                         g := null_deg_graphe(g1);
                       end;
    type_null_bit :    begin
                         if ( edit_null_bit_pere.Text = '' ) then
                           begin
                             erreur('BIT Model: unknown network');
                             exit;
                           end;
                         g1 := trouve_graphe(StrToInt(edit_null_bit_pere.Text));
                         if ( g1 = 0 ) then
                           begin
                             erreur('BIT Model: unknown network');
                             edit_null_bit_pere.Text := IntToStr(graphes[g_select].icre);
                             exit;
                           end;
                         g := null_bit_graphe(g1);
                         if ( g = 0 ) then
                           begin
                             erreur('BIT Model: B or I or T is 0');
                             exit;
                           end;
                       end;
    type_null_niche :  begin
                         g1 := 0;
                         if ( g_select <> 0 ) then
                           g1 := trouve_graphe(graphes[g_select].icre);
                         if not est_entier(edit_nb_sommets.Text,n1) then
                           begin
                             if ( g1 <> 0 ) then
                               n1 := graphes[g1].nb_sommets
                             else
                               begin
                                 erreur('Niche Model: nb of Species, integer expected');
                                 exit;
                               end;
                           end;
                         if not est_reel(edit_c.Text,c1) then
                           begin
                             if ( g1 <> 0 ) then with graphes[g1] do
                               if ( nb_arcs <> 0 ) then
                                 c1 := nb_sommets/(nb_arcs*nb_arcs)
                               else
                             else
                               begin
                                 erreur('Niche Model: L/S^2, real number expected');
                                 exit;
                               end;
                           end;
                         g := null_niche_graphe(n1,c1);
                       end;
    type_gra_arb     : begin
                         if not est_reel(edit_p_tree.Text,p1) then
                           begin
                             erreur('Random Tree: proba, real number expected');
                             edit_p_tree.Text := FloatToStr(p_tree);
                             exit;
                           end;
                         if ( p1 < 0.0 ) or ( p1 > 1.0 ) then
                           begin
                             erreur('Random Tree: proba [0,1] expected');
                             edit_p_tree.Text := FloatToStr(p_tree);
                             exit;
                           end;
                         if not est_entier(edit_nb_niv_tree.Text,niv1) then
                           begin
                             erreur('Random Tree: nb of levels, integer >= 2 expected');
                             edit_nb_niv_tree.Text := IntToStr(nb_niv_tree);
                             exit;
                           end;
                         if ( niv1 < 2 ) then
                           begin
                             erreur('Random Tree: nb of levels, integer >= 2 expected');
                             edit_nb_sommets.Text := IntToStr(nb_som);
                             exit;
                           end;
                         if not est_entier(edit_degree_tree.Text,k1) then
                           begin
                             erreur('Random Tree: in-degree, integer >= 1 expected');
                             edit_degree_tree.Text := IntToStr(degree_tree);
                             exit;
                           end;
                         if ( k1 < 1 ) then
                           begin
                             erreur('Random Tree: in-degree, integer >= 1 expected');
                             edit_degree_tree.Text := IntToStr(degree_tree);
                             exit;
                           end;
                         n1 := nbs_arb(k1,niv1);
                         if ( n1 > vecmax ) then
                           begin
                             erreur('Random Tree: too many species (> ' + IntToStr(vecmax) + ')');
                             edit_nb_niv_tree.Text := IntToStr(nb_niv_tree);
                             edit_degree_tree.Text := IntToStr(degree_tree);
                             exit;
                           end;
                         degree_tree := k1;
                         nb_niv_tree := niv1;
                         p_tree := p1;
                         g := arb_graphe(degree_tree,nb_niv_tree,p_tree);
                       end;
    type_gra_root    : begin
                         g1 := trouve_graphe(StrToInt(edit_root_pere.Text));
                         if ( g1 = 0 ) then
                           begin
                             erreur('Rooted Network: unknown network');
                             edit_root_pere.Text := IntToStr(graphes[g_select].icre);
                             exit;
                           end;
                         with graphes[g1] do
                           if ( nb_b = 0 ) then
                             begin
                               erreur('Network has no basal species');
                               exit;
                             end;
                         g := addroot_graphe(g1);
                       end;
    type_gra_dual    : begin
                         g1 := trouve_graphe(StrToInt(edit_dual_pere.Text));
                         if ( g1 = 0 ) then
                           begin
                             erreur('Dual Network: unknown network');
                             edit_dual_pere.Text := IntToStr(graphes[g_select].icre);
                             exit;
                           end;
                         if ( graphes[g1].nb_arcs = 0 ) then
                             begin
                               erreur('Network has 0 links');
                               exit;
                             end;
                         if ( graphes[g1].nb_arcs >  vecmax ) then
                             begin
                               erreur('Network has more than ' + IntToStr(vecmax) + ' links');
                               exit;
                             end;
                         g := dual_graphe(g1);
                       end;
    type_gra_som     : begin
                         g1 := trouve_graphe(StrToInt(edit_g1.Text));
                         if ( g1 = 0 ) then
                           begin
                             erreur('Compose Network: unknown network');
                             edit_g1.Text := IntToStr(graphes[g_select].icre);
                             exit;
                           end;
                         g2 := trouve_graphe(StrToInt(edit_g2.Text));
                         if ( g2 = 0 ) then
                           begin
                             erreur('Compose Network: unknown network');
                             edit_g2.Text := edit_g1.Text;
                             exit;
                           end;
                         n1 := graphes[g1].nb_sommets + graphes[g2].nb_sommets;
                         if ( n1 > vecmax ) then
                           begin
                             erreur('Compose Network: too many species (> ' + IntToStr(vecmax) + ')');
                             exit;
                           end;
                         g := som_graphe(g1,g2);
                       end;
    (*type_gra_flow    : begin
                         g1 := trouve_graphe(StrToInt(edit_flow_graphe_pere.Text));
                         if ( g1 = 0 ) then
                           begin
                             erreur('Unknown network');
                             edit_flow_graphe_pere.Text := IntToStr(graphes[g_select].icre);
                             exit;
                           end;
                         g := flow_graphe(g1);
                       end;*)
    else g := 0;
  end;
  if ( g <> 0 ) then with form_nw do
    begin
      select(g);
      affiche_graphes;
      status_action('Network created');
      if ( nb_graphes = 1 ) then set_actions1;
      if edit_mode then button_editClick(nil);
    end;
end;

end.
