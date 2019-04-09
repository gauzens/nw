unit f_nw;

{ @@@@@@  forme principale  @@@@@@ }

interface

uses
  SysUtils,Types,Classes,Variants,QGraphics,QControls,QForms,QDialogs,
  QStdCtrls,QExtCtrls,QComCtrls,QTypes,QMenus,QStdActns,QActnList,QImgList,QGrids,
  f_graph,f_view;

type
  tform_nw = class(TForm)
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    MainMenu1: TMainMenu;
    ActionList1: TActionList;
    filenew: TAction;
    fileopen: TAction;
    filesave: TAction;
    filesaveas: TAction;
    fileexit: TAction;
    filecompile: TAction;
    ImageList1: TImageList;
    File1: TMenuItem;
    Open1: TMenuItem;
    Save1: TMenuItem;
    SaveAs1: TMenuItem;
    nnn1: TMenuItem;
    Exit1: TMenuItem;
    About1: TMenuItem;
    file_open_button: TToolButton;
    file_save_button: TToolButton;
    compil_button: TToolButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Compile1: TMenuItem;
    nnn2: TMenuItem;
    About2: TMenuItem;
    PageControl1: TPageControl;
    stringgrid_graphe: TStringGrid;
    stringgrid_sommet: TStringGrid;
    button_create: TButton;
    button_delete: TButton;
    button_simul: TButton;
    button_reverse: TButton;
    button_loops: TButton;
    button_save_graphe: TButton;
    edit_nb_simul: TEdit;
    button_graphics: TButton;
    stringgrid_arc: TStringGrid;
    button_save_grid: TButton;
    button_edit: TButton;
    button_duplicate: TButton;
    button_view: TButton;
    stringgrid_proba: TStringGrid;
    button_sort_plus: TButton;
    button_sort_moins: TButton;
    button_cycles: TButton;
    button_groups: TButton;
    label_simul: TLabel;
    button_import: TButton;
    button_maxconn: TButton;
    button_aggreg: TButton;
    en_vrac: TButton;
    procedure FormCreate(Sender: TObject);
    procedure pagecontrol_init;
    procedure affiche_graphes;
    procedure affiche_sommets(g : integer);
    procedure affiche_arcs(g : integer);
    procedure affiche;
    procedure init;
    procedure set_actions0;
    procedure set_actions1;
    procedure set_actions_edit0;
    procedure set_actions_edit1;
    procedure status_name(g : integer);
    procedure status_action(s : string);
    procedure status_nbsimul(n : integer);
    procedure status_t_exec(ms : integer);
    procedure init_select;
    procedure select0(g : integer);
    procedure select(g : integer);
    procedure fileexitExecute(Sender: TObject);
    procedure fileopenExecute(Sender: TObject);
    procedure filesaveExecute(Sender: TObject);
    procedure filesaveasExecute(Sender: TObject);
    procedure filecompileExecute(Sender: TObject);
    procedure helpaboutExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure procproc;
    procedure FormDestroy(Sender: TObject);
    procedure stringgrid_grapheMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PageControl1Change(Sender: TObject);
    procedure button_deleteClick(Sender: TObject);
    procedure button_simulClick(Sender: TObject);
    procedure button_reverseClick(Sender: TObject);
    procedure button_loopsClick(Sender: TObject);
    procedure button_save_grapheClick(Sender: TObject);
    procedure button_createClick(Sender: TObject);
    procedure stringgrid_sommetMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure edit_nb_simulChange(Sender: TObject);
    procedure button_graphicsClick(Sender: TObject);
    procedure stringgrid_arcMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure button_save_gridClick(Sender: TObject);
    procedure stringgrid_arcSelectCell(Sender: TObject; ACol,
      ARow: Integer; var CanSelect: Boolean);
    procedure stringgrid_sommetSelectCell(Sender: TObject; ACol,
      ARow: Integer; var CanSelect: Boolean);
    procedure edit_off;
    procedure button_editClick(Sender: TObject);
    procedure stringgrid_arcKeyPress(Sender: TObject; var Key: Char);
    procedure stringgrid_sommetKeyPress(Sender: TObject; var Key: Char);
    procedure button_viewClick(Sender: TObject);
    procedure button_duplicateClick(Sender: TObject);
    procedure button_sort_plusClick(Sender: TObject);
    procedure button_sort_moinsClick(Sender: TObject);
    procedure button_cyclesClick(Sender: TObject);
    procedure button_groupsClick(Sender: TObject);
    procedure button_importClick(Sender: TObject);
    procedure button_maxconnClick(Sender: TObject);
    procedure button_aggregClick(Sender: TObject);
    procedure en_vracClick(Sender: TObject);
  private
    procedure erreur(s : string);
    procedure myIdleHandler(Sender: TObject; var Done: Boolean);
  public
    nomfic : string;           { nom fichier graphe courant }
    ficgraphe_open : boolean;  { indicateur ouverture fichier graphe }
    nomficgrid : string;       { nom fichier resultats }
    runstop : boolean;
  end;

var   form_nw: tform_nw;

const maxform_graph = 10;
      maxform_view  = 10;

type  tab_form_graph_type = array[1..maxform_graph] of tform_graph;
      tab_form_view_type  = array[1..maxform_view]  of tform_view;

var   tab_form_graph : tab_form_graph_type;
      nb_form_graph  : integer;
      tab_form_view  : tab_form_view_type;
      nb_form_view   : integer;

implementation

uses  kglobvar,klist,ksyntax,kmath,kcompil,kutil,
      kgestiong,kcalculg,kmanipg,ksimulg,
      f_edit,f_graphset,f_about,f_createg,f_pad,f_import,f_cluster,f_lump;

{$R *.xfm}

const nb_t_a_select = 6;

var   x_select   : integer; { indice sommet selectionne }
      x_a_select : integer; { indice arc selectionne sommet x d'origine }
      y_a_select : integer; { indice arc selectionne sommet y d'extremite }
      r_g_select : integer; { indice ligne selectionnee dans stringgrid_graphe }
      c_g_select : integer; { indice colonne selectionnee dans stringgrid_graphe }
      r_x_select : integer; { indice ligne selectionnee dans stringgrid_sommet }
      c_x_select : integer; { indice colonne selectionnee dans stringgrid_sommet }
      r_a_select : integer; { indice ligne selectionnee dans stringgrid_arc }
      c_a_select : integer; { indice colonne selectionnee dans stringgrid_arc }
      t_a_select : integer; { type d'affichage dans la page des arcs }

      row_select : integer;

procedure tform_nw.erreur(s : string);
begin
  erreur_('Commands - ' + s);
end;

procedure tform_nw.set_actions0;
begin
  button_create.Enabled  := true;
  button_delete.Enabled  := false;
  button_duplicate.Enabled := false;
  button_simul.Enabled   := false;
  button_reverse.Enabled := false;
  button_loops.Enabled   := false;
  button_save_graphe.Enabled := false;
  button_save_grid.Enabled   := false;
  button_graphics.Enabled := false;
  button_view.Enabled    := false;
  button_edit.Enabled    := false;
  button_sort_plus.Enabled  := false;
  button_sort_moins.Enabled := false;
  button_cycles.Enabled   := false;
  button_groups.Enabled   := false;
  button_aggreg.Enabled   := false;
  button_import.Enabled   := true;
  button_maxconn.Enabled  := false;
end;

procedure tform_nw.set_actions1;
begin
  button_create.Enabled  := true;
  button_delete.Enabled  := true;
  button_duplicate.Enabled := true;
  button_simul.Enabled   := true;
  button_reverse.Enabled := true;
  button_loops.Enabled   := true;
  button_save_graphe.Enabled := true;
  button_save_grid.Enabled   := true;
  button_graphics.Enabled := true;
  button_view.Enabled     := true;
  button_edit.Enabled     := true;
  button_sort_plus.Enabled  := true;
  button_sort_moins.Enabled := true;
  button_cycles.Enabled   := true;
  button_groups.Enabled   := true;
  button_aggreg.Enabled   := true;  
  button_import.Enabled   := true;
  button_maxconn.Enabled  := true;
end;

procedure tform_nw.set_actions_edit0;
begin
  file_open_button.Enabled  := false;
  button_sort_plus.Enabled  := false;
  button_sort_moins.Enabled := false;
  button_groups.Enabled   := false;
  button_aggreg.Enabled   := false;
  button_import.Enabled   := false;
end;

procedure tform_nw.set_actions_edit1;
begin
  file_open_button.Enabled  := true;
  button_sort_plus.Enabled  := true;
  button_sort_moins.Enabled := true;
  button_groups.Enabled   := true;
  button_aggreg.Enabled   := true;
  button_import.Enabled   := true;
end;

procedure blank_row(sg : TStringGrid;r : integer);
var x : integer;
begin
  with sg do
    for x := 0 to ColCount-1 do Cells[x,r] := '';
end;

function  affiche_choix_a : string;
begin
  case t_a_select of
    0 : affiche_choix_a := 'Matrix';
    1 : affiche_choix_a := 'Val';
    2 : affiche_choix_a := 'LenMin';
    3 : affiche_choix_a := 'LenMean';
    4 : affiche_choix_a := 'LenMax';
    5 : affiche_choix_a := 'NbPath';
    {5 : affiche_choix_a := 'MaxFlow';}
    {5 : affiche_choix_a := 'LenVar';}
    else affiche_choix_a := '';
  end;
end;

procedure tform_nw.affiche_arcs(g : integer);
var x,y : integer;
begin
  if ( g = 0 ) then
    begin
      stringgrid_arc.RowCount := 2;
      blank_row(stringgrid_arc,0);
      blank_row(stringgrid_arc,1);
      exit;
    end;
  with graphes[g],stringgrid_arc do
    begin
      RowCount := nb_sommets + 1;
      ColCount := nb_sommets + 1;
      for y := 1 to ColCount-1 do ColWidths[y] := 32;
      cells[0,0] := affiche_choix_a;
      for x := 1 to nb_sommets do with ggg[x] do
        if ( x = x_a_select ) then
          cells[0,x] := '*' + nom
        else
          cells[0,x] := nom;
      for x := 1 to nb_sommets do with ggg[x] do
        if ( x = y_a_select ) then
          cells[x,0] := '*' + nom
        else
          cells[x,0] := nom;
      { lmin, lmoy, ... pas a jour si g_select a change... recalculer ! }
      if (*not edit_mode and*) ( g_ <> g ) then { voir !!! }
        begin
          graphe2mat(g);
          calcul_graphe(g);
        end;
      for x := 1 to nb_sommets do
        for y := 1 to nb_sommets do
          begin
            case t_a_select of
              0 : cells[y,x] := IntToStr(m_[x,y]);
              1 : cells[y,x] := s_ecri_val(mr_[x,y]);
              2 : if ( lmin[x,y] < big ) then
                    cells[y,x] := IntToStr(lmin[x,y])
                  else
                    cells[y,x] := '-';
              3 : cells[y,x] := s_ecri_val_bad(lmoy[x,y]);
              (*4 : if ( lmin[x,y] < big ) then
                    cells[y,x] := IntToStr(lmax[x,y])
                  else
                    cells[y,x] := '-';*)
              (*4 : if ( lnb[x,y] <> 0 ) then
                    cells[y,x] := IntToStr(lmax[x,y])
                  else
                    cells[y,x] := '-';*)
              4 : cells[y,x] := s_ecri_int_bad(lmax[x,y]);
              5 : cells[y,x] := s_ecri_val_bad(lnb[x,y]);
              {5 : cells[y,x] := s_ecri_val(flow[x,y]);}
              {5 : cells[y,x] := s_ecri_val(mmm[x,y]);}
              {5 : if ( lmin[x,y] < big ) then
                    cells[y,x] := s_ecri_val(lvar[x,y])
                  else
                    cells[y,x] := '-';}
              else;
            end
          end;
    end;
end;

procedure tform_nw.affiche_sommets(g : integer);
{ procedures impliquees : }
{ pagecontrol_init,button_graphicsClick,button_sort_plusClick,button_sort_moinsClick }
var x : integer;
begin
  if ( g = 0 ) then
    begin
      stringgrid_sommet.RowCount := 2;
      blank_row(stringgrid_sommet,1);
      exit;
    end;
  with graphes[g],stringgrid_sommet do
    begin
      RowCount := nb_sommets + 1;
      for x := 1 to nb_sommets do
        begin
        with ggg[x] do
          begin
            if ( x = x_select ) then
              cells[0,x] := '*' + nom
            else
              cells[0,x] := nom;
            cells[1,x]  := IntToStr(x);
            cells[2,x]  := IntToStr(connect);
            cells[3,x]  := IntToStr(group_mod);
            cells[4,x]  := IntToStr(group_aic);
            cells[5,x]  := IntToStr(group_tro);
            cells[6,x]  := IntToStr(nb_pred);
            cells[7,x]  := IntToStr(nb_succ);
            cells[8,x]  := IntToStr(deg);
            cells[9,x]  := s_ecri_pos_sommet(g,x);
            cells[10,x] := s_ecri_int_bad(h_min);
            cells[11,x] := s_ecri_val_bad(h_moy);
            cells[12,x] := s_ecri_int_bad(h_max);
            cells[13,x] := s_ecri_val_bad(trolev);
            cells[14,x] := s_ecri_val_bad(oi);
            cells[15,x] := s_ecri_val(c);
            cells[16,x] := IntToStr(ecc);
            cells[17,x] := s_ecri_val_bad(rank);
            cells[18,x] := s_ecri_val_bad(cyctime);
          end;
        end;
    end;
end;

procedure tform_nw.affiche_graphes;
var g,h : integer;
begin
  if ( nb_graphes = 0 ) then
    begin
      stringgrid_graphe.RowCount := 3;
      blank_row(stringgrid_graphe,1);
      blank_row(stringgrid_graphe,2);
      exit;
    end;
  with stringgrid_graphe do
    begin
      RowCount := nb_graphes*2 + 1;
      h := 0;
      for g := 1 to nb_graphes do with graphes[g] do
        begin
          h := h + 1;
          if ( g = g_select ) then
            cells[0,h] := '*' + name
          else
            cells[0,h] := name;
          cells[1,h]  := IntToStr(icre);
          cells[2,h]  := IntToStr(nb_sommets);
          cells[3,h]  := IntToStr(nb_arcs);
          if ( nb_sommets > 0 ) then { L/S }
            cells[4,h]  := s_ecri_val(nb_arcs/nb_sommets);
          if ( nb_sommets > 0 ) then { L/S^2 }
            cells[5,h]  := s_ecri_val(nb_arcs/(nb_sommets*nb_sommets));
          cells[6,h]  := IntToStr(nb_connect);
          cells[7,h]  := IntToStr(nb_b);
          cells[8,h]  := IntToStr(nb_i);
          cells[9,h]  := IntToStr(nb_t);
          cells[10,h] := s_ecri_val(deg_moy);
          cells[11,h] := s_ecri_val_bad(haut_moy);
          cells[12,h] := s_ecri_int_bad(haut_max);
          cells[13,h] := s_ecri_val_bad(trolev_moy);
          cells[14,h] := s_ecri_val_bad(trolev_max);
          cells[15,h] := s_ecri_val_bad(o_index);
          cells[16,h] := s_ecri_val_bad(pathlen);
          cells[17,h] := IntToStr(nb_boucles);
          cells[18,h] := s_ecri_int_bad(nb_cycles);
          cells[19,h] := s_ecri_val_bad(cyclen);
          cells[20,h] := IntToStr(diam);
          cells[21,h] := IntToStr(radius);
          cells[22,h] := s_ecri_val(charlen);
          cells[23,h] := s_ecri_val_bad(entropy);
          if ( nb_sommets > 1 ) and ( entropy <> bad ) then
            cells[24,h] := s_ecri_val_bad(entropy/ln(nb_sommets));
          h := h + 1;
          if ( simul <> 0 ) then
            begin
              cells[0,h]  := '>Simul ' + IntToStr(simul);
              cells[2,h]  := s_ecri_val(nb_sommets_simul);
              cells[3,h]  := s_ecri_val(nb_arcs_simul);
              if ( nb_sommets > 0 ) then
                cells[4,h]  := s_ecri_val(nb_arcs_simul/nb_sommets_simul);
              if ( nb_sommets > 0 ) then
                cells[5,h]  := s_ecri_val(nb_arcs_simul/(nb_sommets_simul*nb_sommets_simul));
              cells[6,h]  := s_ecri_val(nb_connect_simul);
              cells[7,h]  := s_ecri_val(nb_b_simul);
              cells[8,h]  := s_ecri_val(nb_i_simul);
              cells[9,h]  := s_ecri_val(nb_t_simul);
              cells[10,h] := s_ecri_val(deg_moy_simul);
              cells[11,h] := s_ecri_val_bad(haut_moy_simul);
              cells[12,h] := s_ecri_val_bad(haut_max_simul);
              cells[13,h] := s_ecri_val_bad(trolev_moy_simul);
              cells[14,h] := s_ecri_val_bad(trolev_max_simul);
              cells[15,h] := s_ecri_val_bad(o_index_simul);
              cells[16,h] := s_ecri_val_bad(pathlen_simul);
              cells[17,h] := s_ecri_val(nb_boucles_simul);
              cells[18,h] := s_ecri_val(nb_cycles_simul);
              cells[19,h] := s_ecri_val(cyclen_simul);
              cells[20,h] := s_ecri_val(diam_simul);
              cells[21,h] := s_ecri_val(radius_simul);
              cells[22,h] := s_ecri_val(charlen_simul);
              cells[23,h] := s_ecri_val_bad(entropy_simul);
              if ( nb_sommets_simul > 1 ) and ( entropy_simul <> bad ) then
                cells[24,h] := s_ecri_val(entropy_simul/ln(nb_sommets_simul));
            end
          else
            blank_row(stringgrid_graphe,h);
        end;
    end;
end;

procedure tform_nw.affiche;
begin
  case pagecontrol1.ActivePage.PageIndex of
    0 : affiche_graphes;
    1 : affiche_sommets(g_select);
    2 : affiche_arcs(g_select);
    else;
  end;
end;

procedure tform_nw.pagecontrol_init;
{ procedures plus particulierement impliquees : }
{ affiche_sommets, button_graphicsClick, button_sort_plusClick, button_sort_moinsClick }
var i : integer;
begin
  r_g_select := 0;
  c_g_select := 0;
  r_x_select := 0;
  c_x_select := 0;
  r_a_select := 0;
  c_a_select := 0;
  pagecontrol1.Parent := Self;
  {pagecontrol1.Align  := alClient; }
  pagecontrol1.Width := form_nw.Width - 2;
  with TTabSheet.Create(nil) do
    begin
      PageControl := pagecontrol1;
      Caption := 'Networks';
    end;
  with pagecontrol1 do ActivePageIndex := 0;
  with stringgrid_graphe do
    begin
      Parent := pagecontrol1.Pages[pagecontrol1.PageCount - 1];
      Options := [goFixedVertLine,goFixedHorzLine,goVertLine,goHorzLine,
        goDrawFocusSelected];
      Align  := alClient;
      ScrollBars := ssAutoVertical;
      RowCount  := 3;
      FixedRows := 1;
      DefaultRowHeight := 24;
      ColCount  := 25;
      FixedCols := 2;
      ColWidths[0] := 80;
      ColWidths[1] := 24;
      for i := 2 to ColCount-1 do ColWidths[i] := 48;
      cells[0,0]  := 'Network';
      cells[1,0]  := '#';
      cells[2,0]  := 'Species S';
      cells[3,0]  := 'Links L';
      cells[4,0]  := 'L/S';
      cells[5,0]  := 'L/S^2';
      cells[6,0]  := 'Connex';
      cells[7,0]  := 'Basal';
      cells[8,0]  := 'Inter';
      cells[9,0]  := 'Top';
      cells[10,0] := 'Deg';
      cells[11,0] := 'Height';
      cells[12,0] := 'Hmax';
      cells[13,0] := 'TroLev';
      cells[14,0] := 'TLmax';
      cells[15,0] := 'OI';
      cells[16,0] := 'PathLen';
      cells[17,0] := 'Loops';
      cells[18,0] := 'Cycles';
      cells[19,0] := 'CycLen';
      cells[20,0] := 'Diameter';
      cells[21,0] := 'Radius';
      cells[22,0] := 'CharLen';
      cells[23,0] := 'Entropy';
      cells[24,0] := 'ScalEnt';
    end;
  with TTabSheet.Create(nil) do
    begin
      PageControl := pagecontrol1;
      Caption := 'Species';
    end;
  with stringgrid_sommet do
    begin
      Parent := pagecontrol1.Pages[pagecontrol1.PageCount - 1];
      Options := [goFixedVertLine,goFixedHorzLine,goVertLine,goHorzLine,
        goDrawFocusSelected,goEditing];
      Align := alClient;
      ScrollBars := ssAutoVertical;
      RowCount  := 3;
      FixedRows := 1;
      DefaultRowHeight := 24;
      ColCount  := 19;
      FixedCols := 2;
      {for i := 2 to ColCount-1 do ColWidths[i] := 48;}
      cells[0,0]    := '*Species';
      ColWidths[0]  := 80;
      cells[1,0]    := '#';
      ColWidths[1]  := 24;
      cells[2,0]    := 'Conx';
      ColWidths[2]  := 30;
      cells[3,0]    := 'Mod';
      ColWidths[3]  := 30;
      cells[4,0]    := 'AicG';
      ColWidths[4]  := 30;
      cells[5,0]    := 'TroG';
      ColWidths[5]  := 30;
      cells[6,0]    := 'In';
      ColWidths[6]  := 30;
      cells[7,0]    := 'Out';
      ColWidths[7]  := 30;
      cells[8,0]    := 'Deg';
      ColWidths[8]  := 30;
      cells[9,0]    := 'Pos';
      ColWidths[9]  := 30;
      cells[10,0]   := 'Hmin';
      ColWidths[10] := 30;
      cells[11,0]   := 'Hmean';
      ColWidths[11] := 44;
      cells[12,0]   := 'Hmax';
      ColWidths[12] := 30;
      cells[13,0]   := 'TroLev';
      ColWidths[13] := 44;
      cells[14,0]   := 'OI';
      ColWidths[14] := 48;
      cells[15,0]   := 'Clust';
      ColWidths[15] := 48;
      cells[16,0]   := 'Eccen';
      ColWidths[16] := 30;
      cells[17,0]   := 'Rank';
      ColWidths[17] := 48;
      cells[18,0]   := 'CycTime';
      ColWidths[17] := 48;
    end;
  with TTabSheet.Create(nil) do
    begin
      PageControl := pagecontrol1;
      Caption := 'Links';
    end;
  with stringgrid_arc do
    begin
      Parent := pagecontrol1.Pages[pagecontrol1.PageCount - 1];
      Options := [goFixedVertLine,goFixedHorzLine,goVertLine,goHorzLine,
        goDrawFocusSelected,goEditing];
      Align  := alClient;
      ScrollBars := ssAutoBoth;
      RowCount  := 10;
      FixedRows := 1;
      DefaultRowHeight := 24;
      ColCount  := 10;
      FixedCols := 1;
      ColWidths[0] := 80;
      for i := 1 to ColCount-1 do ColWidths[i] := 32;
      t_a_select := 0;
      cells[0,0] := affiche_choix_a;
    end;
end;

procedure tform_nw.init;
begin
  init_lis;
  init_syntax;
  init_compilation;
  init_math;
  init_alea;
  init_gestion;
  {Application.OnIdle := myIdleHandler;
  KeyPreview := true;
  runstop := false;}
  init_select;
  nb_simul_ := 100;
  edit_nb_simul.Text := IntToStr(nb_simul_);
  edit_mode := false;
  nomficgrid := 'xxx.txt';
end;

procedure tform_nw.FormCreate(Sender: TObject);
begin
  Left   := 2;
  Top    := 120;
  Height := 700;
  Width  := 760;  {voir resolution 780x1024}
  resolution;
  adjust(self);
  init;
  ficgraphe_open := false;
  nomfic := '';
  if ( ParamCount > 0 ) and FileExists(paramstr(1)) then
    begin
      nomfic := ParamStr(1);
      lines_compil.LoadFromFile(nomfic);
      ficgraphe_open := true;
    end;
  set_actions0;
  pagecontrol_init;
end;

procedure tform_nw.myIdleHandler(Sender: TObject; var Done: Boolean);
begin
end;

procedure tform_nw.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if ( shift = ([ssAlt,ssCtrl]) ) then
    begin
      runstop := true;
      status_action('Stopped');
    end;
end;

procedure tform_nw.procproc;
begin
  Application.ProcessMessages;
end;

procedure create_form_graph;
var i : integer;
begin
  nb_form_graph := 1;
  tab_form_graph[1] := form_graph;
  for i := 2 to maxform_graph do
    tab_form_graph[i] := tform_graph.Create(nil);
  for i := 1 to maxform_graph do with tab_form_graph[i] do
    begin
      ifg := i;
      Caption := 'GRAPHICS <' + IntToStr(ifg) +'>';
      Top := Top + 20*i;
    end;
end;

procedure create_form_view;
var i : integer;
begin
  nb_form_view := 1;
  tab_form_view[1] := form_view;
  for i := 2 to maxform_view do
    tab_form_view[i] := tform_view.Create(nil);
  for i := 1 to maxform_view do with tab_form_view[i] do
    begin
      ifv := i;
      Caption := 'INFO <' + IntToStr(ifv) +'>';
      Top := Top + 20*i;
    end;
end;

procedure tform_nw.FormShow(Sender: TObject);
var f : integer;
begin
  create_form_graph;
  create_form_view;
  form_pad.Show;
  for f := 1 to maxform_graph do with tab_form_graph[f] do init_graphic;
  form_graph.Show;
  if ficgraphe_open then with form_edit do
    begin
      memo1.Lines := lines_compil;
      newpage(nomfic);
      status(nomfic);
      Show;
      filecompileExecute(nil);
    end;
end;

procedure tform_nw.status_name(g : integer);
begin
  if ( g <> 0 ) then with graphes[g] do
    begin
      statusbar1.Panels[0].Text := name;
      statusbar1.Panels[1].Text := '#' + IntToStr(icre);;
    end
  else
    begin
      statusbar1.Panels[0].Text := '';
      statusbar1.Panels[1].Text := '#0';
    end;
end;

procedure tform_nw.status_action(s : string);
begin
  statusbar1.Panels[2].Text := s;
end;

procedure tform_nw.status_nbsimul(n : integer);
begin
  statusbar1.Panels[4].Text := 'Simul = ' + IntToStr(n);
end;

procedure tform_nw.status_t_exec(ms : integer);
begin
  statusbar1.Panels[3].Text := s_ecri_t_exec(ms);
end;

procedure tform_nw.fileopenExecute(Sender: TObject);
begin
  if opendialog1.Execute then with opendialog1,form_edit do
    begin
      nomfic := FileName;
      Filter :=
'NETWORK files (*.nw0)|NETWORK files (*.nw1)|NETWORK files (*.nw2)|GML files (*.gml)|TXT files (*.txt)|All files (*)';
      memo1.Lines.LoadFromFile(nomfic);
      ficgraphe_open := true;
      {typ_fic_nw := opendialog1.FilterIndex - 1;}
      newpage(nomfic);
      status(nomfic);
      if not Visible then Show;
      filecompileExecute(nil);
    end;
end;

procedure tform_nw.filesaveExecute(Sender: TObject);
begin
  if ( nb_graphes = 0 ) then exit;
  with form_edit do
    begin
      memo1.Lines.SaveToFile(nomfic);
      TMemo(pagecontrol1.ActivePage.Controls[0]).Modified := false;
    end;
end;

procedure tform_nw.filesaveasExecute(Sender: TObject);
begin
  if ( nb_graphes = 0 ) then exit;
  with savedialog1 do
    begin
      FileName := nomfic;
      InitialDir := ExtractFilePath(nomfic);
      if Execute then with form_edit do
        begin
          if FileExists(FileName) then
            if MessageDlg('Overwrite file ' + ExtractFileName(FileName) + '?',
               mtConfirmation,[mbYes,mbNo],0) <> mrYes then exit;
          nomfic := FileName;
          memo1.Lines.SaveToFile(nomfic);
          status(nomfic);
          TMemo(pagecontrol1.ActivePage.Controls[0]).Modified := false;
          TMemo(pagecontrol1.ActivePage.Controls[0]).Hint := nomfic;
          pagecontrol1.ActivePage.Caption := ExtractFileName(nomfic);
        end;
    end;
end;

procedure tform_nw.init_select;
begin
  g_ := 0;
  g_select := 0;
  x_select := 0;
  x_a_select := 0;
  y_a_select := 0;
end;

procedure tform_nw.select0(g : integer);
begin
  g_select := g;
  status_name(g);
end;

procedure tform_nw.select(g : integer);
begin
  if ( g <> g_select ) then edit_off;
  g_select := g;
  x_select := 1;
  x_a_select := 1;
  y_a_select := 1;
  status_name(g);
end;

procedure tform_nw.filecompileExecute(Sender: TObject);
var g : integer;
begin
  with form_edit do lines_compil := memo1.Lines;
  g := compilation(nomfic);
  if ( g <> 0 ) then
    begin
      init_graphe(g);
      if err_gestion then
        begin
          err_gestion := false;
          dealloc_graphe;
          exit;
        end;
      status_action('Computing...'); 
      calcul_graphe(g);
      select(g);
      affiche;
      status_action('File compiled');
      if ( nb_graphes = 1 ) then set_actions1;
    end;
end;

procedure tform_nw.helpaboutExecute(Sender: TObject);
begin
  form_about.ShowModal;
end;

procedure tform_nw.fileexitExecute(Sender: TObject);
begin
  Close;
end;

procedure tform_nw.FormClose(Sender: TObject; var action: TCloseAction);
var action1 : TCloseAction;
begin
  action := caFree;
  with form_edit do FormClose(nil,action1);
  if ( action1 = caNone ) then action := caNone else exit;
end;

procedure tform_nw.FormDestroy(Sender: TObject);
var i : integer;
begin
  for i := 2 to maxform_graph do tab_form_graph[i].Free;
  for i := 2 to maxform_view  do tab_form_view[i].Free;
end;

procedure tform_nw.stringgrid_grapheMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; x, y: integer);
var c,r,g : integer;
begin
  with stringgrid_graphe do
    begin
      MouseToCell(x,y,c,r);
      r_g_select := r;
      c_g_select := c;
      if ( c = 0 ) and ( r > 0 ) then
        begin
          if ( Cells[1,r] = '' ) then exit;
          g := trouve_graphe(StrToInt(Cells[1,r])); { # graphe }
          if ( g = 0 ) then exit;
          if ( g = g_select ) then exit;
          select(g);
          affiche_graphes;
        end
      else
      if ( r = 0 ) and ( c > 0 ) then
        begin
          {iwriteln(IntToStr(c));}
        end;
    end;
end;

procedure tform_nw.stringgrid_sommetMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; x, y: Integer);
var c,r : integer;
    s : string;
begin
  with stringgrid_sommet do
    begin
      MouseToCell(x,y,c,r);
      if ( r = 0 ) then { colonne selectionnee }
        if ( c <> c_x_select ) then
          begin
            s := cells[c_x_select,0];
            if ( s[1] = '*' ) then
              cells[c_x_select,0] := sous_chaine(s,2,length(s)-1);
            if ( cells[c,0][1] <> '*' ) then cells[c,0] := '*' + cells[c,0];
            c_x_select := c;
          end
        else
      else
        if ( c = 0 ) then
          begin
            x_select := r; { # sommet }
            r_x_select := r;
          end;
      affiche_sommets(g_select);
    end;
end;

procedure tform_nw.stringgrid_arcMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; x,y: Integer);
var c,r : integer;
begin
  with stringgrid_arc do
    begin
      MouseToCell(x,y,c,r);
      r_a_select := r;
      c_a_select := c;
      if ( c = 0 ) and ( r = 0 ) then
        t_a_select := (t_a_select + 1) mod nb_t_a_select
      else
        if ( c = 0 ) and ( r > 0 ) then
          x_a_select := r
        else
          if ( r = 0 ) and ( c > 0 ) then
            y_a_select := c
          else
            begin
              x_a_select := r;
              y_a_select := c;
            end;
      affiche_arcs(g_select);
    end;
end;

procedure tform_nw.PageControl1Change(Sender: TObject);
begin
  affiche;
end;

procedure tform_nw.button_createClick(Sender: TObject);
var g : integer;
begin
  case pagecontrol1.ActivePageIndex of
    0 :   begin
            with form_create_graphe do
              begin
                if not Visible then Show;
                SetFocus;
                Activate;
              end;
          end;
    1,2 : begin
              if not confirm_('Create species ?') then exit;
              g := create_sommet_graphe(g_select);
              if ( g <> 0 ) then
                begin
                  select0(g);
                  with graphes[g] do
                    begin
                      x_select   := nb_sommets;
                      x_a_select := nb_sommets;
                      y_a_select := nb_sommets;
                    end;
                  affiche;
                  status_action('Species created');
                end;
            end;
    else;
  end;
end;

procedure tform_nw.button_deleteClick(Sender: TObject);
var g : integer;
begin
  case pagecontrol1.ActivePageIndex of
    0 : begin
          if not confirm_('Delete ' + s_ecri_graphe(g_select) + ' ?') then exit;
          delete_graphe(g_select);
          g := nb_graphes;
          if ( g <> 0 ) then
            select(g)
          else
            begin
              init_select;
              set_actions0;
            end;
          affiche;
          status_action('Network deleted');
          edit_off;
        end;
    1 : begin
          if ( graphes[g_select].nb_sommets = 1 ) then exit;
          with graphes[g_select] do
            if not confirm_('Delete species ' + ggg[x_select].nom + ' ?') then exit;
          g := delete_sommet_graphe(g_select,x_select);
          if ( g <> 0 ) then
            begin
              select(g);
              affiche;
              status_action('Species deleted');
            end;
        end;
    2 : begin
          if ( graphes[g_select].nb_sommets = 1 ) then exit;
          with graphes[g_select] do
            if not confirm_('Delete species ' + ggg[x_a_select].nom + ' ?') then exit;
          g := delete_sommet_graphe(g_select,x_a_select);
          if ( g <> 0 ) then
            begin
              select(g);
              affiche;
              status_action('Species deleted');
            end;
        end;
    else;
  end;
end;

procedure tform_nw.button_duplicateClick(Sender: TObject);
var g,x : integer;
begin
  case pagecontrol1.ActivePageIndex of
    0 : begin
          g := dup_graphe(g_select);
          if ( g <> 0 ) then
          with graphes[g_select] do
            begin
              graphes[g].nb_group_mod := nb_group_mod;
              for x := 1 to nb_sommets do
                graphes[g].ggg[x].group_mod := ggg[x].group_mod;
              graphes[g].nb_group_aic := nb_group_aic;
              for x := 1 to nb_sommets do
                graphes[g].ggg[x].group_aic := ggg[x].group_aic;
              graphes[g].nb_group_tro := nb_group_tro;
              for x := 1 to nb_sommets do
                graphes[g].ggg[x].group_tro := ggg[x].group_tro;
              select(g);
              affiche_graphes;
              status_action('Network duplicated');
            end;
        end;
    1,2   : begin
              if ( x_select = 0 ) then exit;
              with graphes[g_select] do
                if not confirm_('Duplicate species ' + ggg[x_select].nom + ' ?') then exit;
              g := dup_sommet_graphe(g_select,x_select);
              if ( g <> 0 ) then
                begin
                  select0(g);
                  with graphes[g] do
                    begin
                      x_select   := nb_sommets;
                      x_a_select := nb_sommets;
                      y_a_select := nb_sommets;
                    end;
                  affiche;
                  status_action('Species duplicated');
                end;
          end;
    else;
  end;
end;

procedure tform_nw.edit_nb_simulChange(Sender: TObject);
var n1 : integer;
begin
  if not est_entier(edit_nb_simul.Text,n1) then
    begin
      edit_nb_simul.Text := IntToStr(nb_simul_);
      erreur('Nb simul: integer expected');
      exit;
    end;
  nb_simul_ := n1;
end;

procedure tform_nw.button_simulClick(Sender: TObject);
var ms : integer;
begin
  status_action('Simul ' + IntToStr(nb_simul_));
  {runstop := false;}
  ms := clock;
  simul_graphe(g_select,nb_simul_);
  status_t_exec(clock - ms);
  affiche;
end;

procedure tform_nw.button_reverseClick(Sender: TObject);
var g,x : integer;
    s : string;
begin
  case pagecontrol1.ActivePageIndex of
    0 :  begin
          if not confirm_('Reverse network  ' + s_ecri_graphe(g_select) + ' ?') then exit;
          g := reverse_graphe(g_select);
          s := 'Network reversed';
         end;
    1 : begin
         with graphes[g_select] do
           if not confirm_('Reverse species ' + ggg[x_select].nom + ' ?') then exit;
          g := reverse_sommet_graphe(g_select,x_select);
          s := 'Species reversed';
          end;
    2 : begin
          if ( m_[x_a_select,y_a_select] = 0.0 ) then exit;
          with graphes[g_select] do
            if not confirm_('Reverse link <' + ggg[x_a_select].nom
                            + ',' + ggg[y_a_select].nom + '> ?') then exit;
          g := reverse_arc_graphe(g_select,x_a_select,y_a_select);
          s := 'Link reversed';
        end;
    else;
  end;
  if ( g <> 0 ) then
    with graphes[g_select] do
      begin
        graphes[g].nb_group_mod := nb_group_mod;
        for x := 1 to nb_sommets do
          graphes[g].ggg[x].group_mod := ggg[x].group_mod;
        graphes[g].nb_group_aic := nb_group_aic;
        for x := 1 to nb_sommets do
          graphes[g].ggg[x].group_aic := ggg[x].group_aic;
        graphes[g].nb_group_tro := nb_group_tro;
        for x := 1 to nb_sommets do
          graphes[g].ggg[x].group_tro := ggg[x].group_tro;
        select(g);
        affiche;
        status_action(s);
      end;
end;

procedure tform_nw.button_loopsClick(Sender: TObject);
var g : integer;
begin
  if ( graphes[g_select].nb_boucles = 0 ) then exit;
  if not confirm_('Delete self-loops in graph ' + s_ecri_graphe(g_select) + ' ?') then exit;
  g := delete_boucles_graphe(g_select);
  if ( g <> 0 ) then
    begin
      select0(g);
      affiche;
      status_action('Loops deleted');
    end;
end;

procedure tform_nw.button_cyclesClick(Sender: TObject);
var g : integer;
begin
  if ( graphes[g_select].nb_cycles = 0 ) then exit;
  if not confirm_('Delete cycles in network ' + s_ecri_graphe(g_select) + ' ?') then exit;
  g := delete_cycles_graphe(g_select);
  if ( g <> 0 ) then
    begin
      select0(g);
      affiche;
      status_action('Cycles deleted');
    end;
end;

procedure tform_nw.button_save_grapheClick(Sender: TObject);
begin
  with savedialog1 do
    begin
      FileName := s_ecri_graphe(g_select);
      savedialog1.Filter :=
        'NETWORK files (*.nw0)|NETWORK files (*.nw1)|GML files (*.gml)|TXT files (*.txt)';
      InitialDir := ExtractFilePath(nomfic);
      {if ( InitialDir = '' ) then InitialDir := 'c:/';}
      if Execute then
        begin
          if FileExists(FileName) then
            if not confirm_('Overwrite file ' + ExtractFileName(FileName) + '?') then exit;
          case FilterIndex of
            1,4 : b_ecri_graphe_mat(g_select);
            2   : b_ecri_graphe_succ(g_select);
            3   : b_ecri_graphe_gml(g_select);
            else;
          end;
          lines_syntax.SaveToFile(FileName);
          status_action('Network saved');
        end;
    end;
end;

procedure tform_nw.button_save_gridClick(Sender: TObject);

procedure sav(sg : TStringGrid);
var r,c : integer;
    s : string;
begin
  with sg do
    begin
      lines_syntax.Clear;
      for r := 0 to RowCount-1 do
        if ( Cells[0,r] <> '' ) then
          begin
            s := Cells[0,r] + hortab;
            for c := 1 to ColCount-1 do
              s := s + Cells[c,r] + hortab;
            lines_syntax.Append(s);
          end;
    end;
end;

begin
  with savedialog1 do
    begin
      FileName := nomficgrid;
      savedialog1.Filter := 'Result text file (*.txt)|All files (*)';
      InitialDir := ExtractFilePath(nomfic);
      if Execute then with stringgrid_graphe do
        begin
          if FileExists(FileName) then
            if not confirm_('Overwrite file ' + ExtractFileName(FileName) + '?') then exit;
          nomficgrid := FileName;
          case pagecontrol1.ActivePage.PageIndex of
            0 : sav(stringgrid_graphe);
            1 : sav(stringgrid_sommet);
            2 : sav(stringgrid_arc);
            else;
          end;
          lines_syntax.SaveToFile(nomficgrid);
          status_action('Grid saved');
        end;
    end;
end;

procedure nwdistrib(fg : tform_graph;n : integer;tab : rvec_type;icol : integer);
var v,imax,i,i0 : integer;
    moy,sum,a2,sigma : extended;
begin
  with fg do
    begin
      for i := 0 to maxgraph do
        begin
          valgraph_x[i] := i*d_distrib;
          valgraph_y[i] := 0.0;
        end;
      for i := 1 to n do
        begin
          v := trunc(tab[i]/d_distrib);
          if ( v < 0.0 ) then exit; { !!! bad }
          if ( v <= maxgraph ) then
            if distrib0 then
              valgraph_y[v] := valgraph_y[v] + 1.0
            else
              if ( v > 0 ) then
                valgraph_y[v] := valgraph_y[v] + 1.0;
        end;
      if distrib0 then i0 := 0 else i0 := 1;
      imax := 1+i0;
      for i := maxgraph downto i0 do
        if ( valgraph_y[i] <> 0 ) then
          begin
            imax := i;
            break;
          end;
      { moyenne }
      moy := 0.0;
      sum := 0.0;
      for i := i0 to imax+1 do
        begin
          sum := sum + valgraph_y[i];
          moy := moy + i*valgraph_y[i]*d_distrib;
        end;
      if ( sum > 0.0 ) then moy := moy/sum;
      { variance }
      a2 := 0.0;
      for i := i0 to imax+1 do
        a2 := a2 + i*i*valgraph_y[i]*d_distrib*d_distrib;
      if ( sum > 0.0 ) then a2 := a2/sum;
      a2 := a2 - moy*moy;
      if ( a2 >= 0.0 ) then
        sigma := sqrt(a2)
      else
        sigma := 0.0;
      gdistrib(imax+1,icol,moy,sigma);
    end;
end;

procedure eval_d_distrib(n : integer;tab : rvec_type;var delta : extended);
var i : integer;
    mintab,maxtab,a,pas : extended;
begin
  mintab := maxextended;
  maxtab := 0.0;
  for i := 1 to n do
    begin
      a := tab[i];
      if ( a > maxtab ) then maxtab := a;
      if ( a < mintab ) then mintab := a;
    end;
  if ( maxtab = 0.0 ) or ( maxtab = mintab ) then exit;
  calcul_echelle(mintab,maxtab,pas,a);
  delta := pas/5.0;
end;

procedure tform_nw.button_graphicsClick(Sender: TObject);
var x,i,icol : integer;
    tab : rvec_type;
begin
 i := g_select;
 if ( graphes[i].nb_sommets = 0 ) then exit;
 if ( g_select > maxform_graph ) then
   i := g_select mod maxform_graph + 1;
 with tab_form_graph[i] do
   begin
     if not Visible then Show;
     SetFocus;
     with graphes[g_select] do case pagecontrol1.ActivePageIndex of
       0,2 : begin
               ggraphe(g_select);
             end;
       1 : begin
             case c_x_select of
               2  : begin
                      distrib0  := false;
                      d_distrib := 1.0;
                      for x := 1 to nb_sommets do tab[x] := ggg[x].connect;
                      status_x('Connect');
                    end;
               3  : begin
                      distrib0  := false;
                      d_distrib := 1.0;
                      for x := 1 to nb_sommets do tab[x] := ggg[x].group_mod;
                      status_x('Modules');
                    end;
               4  : begin
                      distrib0  := false;
                      d_distrib := 1.0;
                      for x := 1 to nb_sommets do tab[x] := ggg[x].group_aic;
                      status_x('AIC groups');
                    end;
               5  : begin
                      distrib0  := false;
                      d_distrib := 1.0;
                      for x := 1 to nb_sommets do tab[x] := ggg[x].group_tro;
                      status_x('Trophic groups');
                    end;
               6  : begin
                      distrib0  := true;
                      d_distrib := 1.0;
                      for x := 1 to nb_sommets do tab[x] := ggg[x].nb_pred;
                      status_x('In degree');
                    end;
               7  : begin
                      distrib0  := true;
                      d_distrib := 1.0;
                      for x := 1 to nb_sommets do tab[x] := ggg[x].nb_succ;
                      status_x('Out degree');
                    end;
               8  : begin
                      distrib0  := true;
                      d_distrib := 1.0;
                      for x := 1 to nb_sommets do tab[x] := ggg[x].deg;
                      status_x('Total Degree');
                    end;
               9  : begin
                      distrib0  := true;
                      d_distrib := 1.0;
                      for x := 1 to nb_sommets do with ggg[x] do
                        if ( nb_pred = 0 ) then
                          tab[x] := 0.0
                        else
                          if ( nb_succ = 0 ) then
                            tab[x] := 2.0
                          else
                            tab[x] := 1.0;
                      status_x('Position');
                    end;
               10 : begin
                      distrib0  := true;
                      d_distrib := 1.0;
                      for x := 1 to nb_sommets do tab[x] := ggg[x].h_min;
                      eval_d_distrib(nb_sommets,tab,d_distrib);
                      status_x('Height min');
                    end;
               11 : begin
                      distrib0  := true;
                      d_distrib := 0.1;
                      for x := 1 to nb_sommets do tab[x] := ggg[x].h_moy;
                      eval_d_distrib(nb_sommets,tab,d_distrib);
                      status_x('Height mean');
                    end;
               12 : begin
                      distrib0 := true;
                      d_distrib := 1.0;
                      for x := 1 to nb_sommets do tab[x] := ggg[x].h_max;
                      eval_d_distrib(nb_sommets,tab,d_distrib);
                      status_x('Height max');
                    end;
               13 : begin
                      distrib0 := false;
                      d_distrib := 0.1;
                      for x := 1 to nb_sommets do tab[x] := ggg[x].trolev;
                      eval_d_distrib(nb_sommets,tab,d_distrib);
                      status_x('Trophic level');
                    end;
               14 : begin
                      distrib0 := true;
                      d_distrib := 0.1;
                      for x := 1 to nb_sommets do tab[x] := ggg[x].oi;
                      status_x('Omnivory');
                    end;
               15 : begin
                      distrib0  := false;
                      d_distrib := 0.1;
                      for x := 1 to nb_sommets do tab[x] := ggg[x].c;
                      eval_d_distrib(nb_sommets,tab,d_distrib);
                      status_x('Clustering');
                    end;
               16 : begin
                      distrib0 := true;
                      d_distrib := 1.0;
                      for x := 1 to nb_sommets do tab[x] := ggg[x].ecc;
                      status_x('Eccentricity');
                    end;
               17 : begin
                      distrib0 := true;
                      d_distrib := 0.001;
                      for x := 1 to nb_sommets do tab[x] := ggg[x].rank;
                      eval_d_distrib(nb_sommets,tab,d_distrib);
                      status_x('Rank');
                    end;
               18 : begin
                      distrib0 := true;
                      d_distrib := 1.0;
                      for x := 1 to nb_sommets do tab[x] := ggg[x].cyctime;
                      eval_d_distrib(nb_sommets,tab,d_distrib);
                      status_x('CycTime');
                    end;
               else exit;
             end;
             icol := c_x_select;
             nwdistrib(tab_form_graph[i],nb_sommets,tab,icol);
             status_distrib;
             status_graphe(g_select);
           end;
       else;
     end;
   end;
end;

procedure tform_nw.button_viewClick(Sender: TObject);
var i : integer;
begin
 i := g_select;
 if ( g_select > maxform_view ) then
   i := g_select mod maxform_view + 1;
 with tab_form_view[i] do
   begin
     g_view := g_select;
     if not Visible then Show;
     SetFocus;
   end;
end;

procedure tform_nw.button_sort_plusClick(Sender: TObject);
var x,g  : integer;
    tabs : svec_type;
    tabr : rvec_type;
    tabi,ord_x : ivec_type;
begin
  case pagecontrol1.ActivePageIndex of
    1 : begin
          with graphes[g_select] do case c_x_select of
            0 : begin
                  if not confirm_('Reindex species of '
                                  + s_ecri_graphe(g_select) + ' alphabetically (+) ?') then exit;
                  for x := 1 to nb_sommets do tabs[x] := ggg[x].nom;
                  tri_a_plus(nb_sommets,tabs,ord_x);
                end;
            2 : begin
                  if not confirm_('Reindex species of '
                                  + s_ecri_graphe(g_select) + ' according to Connected component (+) ?') then exit;
                  for x := 1 to nb_sommets do tabi[x] := ggg[x].connect;
                  tri_i_plus(nb_sommets,tabi,ord_x);
                end; { attention recalcul des composantes connexes... }
            3 : begin
                  if not confirm_('Reindex species of '
                                  + s_ecri_graphe(g_select) + ' according to Module index (+) ?') then exit;
                  for x := 1 to nb_sommets do tabi[x] := ggg[x].group_mod;
                  tri_i_plus(nb_sommets,tabi,ord_x);
                end;  { attention groupes pas recalcule dans le graphe reindexe ... }
            4 : begin
                  if not confirm_('Reindex species of '
                                  + s_ecri_graphe(g_select) + ' according to AIC group index (+) ?') then exit;
                  for x := 1 to nb_sommets do tabi[x] := ggg[x].group_aic;
                  tri_i_plus(nb_sommets,tabi,ord_x);
                end;
            5 : begin
                  if not confirm_('Reindex species of '
                                  + s_ecri_graphe(g_select) + ' according to Trophic group index (+) ?') then exit;
                  for x := 1 to nb_sommets do tabi[x] := ggg[x].group_tro;
                  tri_i_plus(nb_sommets,tabi,ord_x);
                end;
            6 : begin
                  if not confirm_('Reindex species of '
                                  + s_ecri_graphe(g_select) + ' according to In-egree (+) ?') then exit;
                  for x := 1 to nb_sommets do tabi[x] := ggg[x].nb_pred;
                  tri_i_plus(nb_sommets,tabi,ord_x);
                end;
            7 : begin
                  if not confirm_('Reindex species of '
                                  + s_ecri_graphe(g_select) + ' according to Out-degree (+) ?') then exit;
                  for x := 1 to nb_sommets do tabi[x] := ggg[x].nb_succ;
                  tri_i_plus(nb_sommets,tabi,ord_x);
                end;
            8 : begin
                  if not confirm_('Reindex species of '
                                  + s_ecri_graphe(g_select) + ' according to Degree (+) ?') then exit;
                  for x := 1 to nb_sommets do tabi[x] := ggg[x].deg;
                  tri_i_plus(nb_sommets,tabi,ord_x);
                end;
            9 : begin
                  if not confirm_('Reindex species of '
                                  + s_ecri_graphe(g_select) + ' according to trophic position (+) ?') then exit;
                  for x := 1 to nb_sommets do tabs[x] := s_ecri_pos_sommet(g_select,x);
                  tri_a_plus(nb_sommets,tabs,ord_x);
                 end;
            10 : begin
                   if not confirm_('Reindex species of '
                                   + s_ecri_graphe(g_select) + ' according to Height min (+) ?') then exit;
                   for x := 1 to nb_sommets do tabi[x] := ggg[x].h_min;
                   tri_i_plus(nb_sommets,tabi,ord_x);
                 end;
            11 : begin
                   if not confirm_('Reindex species of '
                                   + s_ecri_graphe(g_select) + ' according to Height (+) ?') then exit;
                   for x := 1 to nb_sommets do tabr[x] := ggg[x].h_moy;
                   tri_r_plus(nb_sommets,tabr,ord_x);
                 end;
            12 : begin
                   if not confirm_('Reindex species of '
                                    + s_ecri_graphe(g_select) + ' according to Height max (+) ?') then exit;
                   for x := 1 to nb_sommets do tabi[x] := ggg[x].h_max;
                   tri_i_plus(nb_sommets,tabi,ord_x);
                 end;
            13 : begin
                   if not confirm_('Reindex species of '
                                   + s_ecri_graphe(g_select) + ' according to Trophic Level (+) ?') then exit;
                   for x := 1 to nb_sommets do tabr[x] := ggg[x].trolev;
                   tri_r_plus(nb_sommets,tabr,ord_x);
                 end;
            14 : begin
                   if not confirm_('Reindex species of '
                                   + s_ecri_graphe(g_select) + ' according to Omnivory index (+) ?') then exit;
                   for x := 1 to nb_sommets do tabr[x] := ggg[x].oi;
                   tri_r_plus(nb_sommets,tabr,ord_x);
                 end;
            15 : begin
                   if not confirm_('Reindex species of '
                                   + s_ecri_graphe(g_select) + ' according to Clustering (+) ?') then exit;
                   for x := 1 to nb_sommets do tabr[x] := ggg[x].c;
                   tri_r_plus(nb_sommets,tabr,ord_x);
                 end;
            16 : begin
                   if not confirm_('Reindex species of '
                                   + s_ecri_graphe(g_select) + ' according to Eccentricity (+) ?') then exit;
                   for x := 1 to nb_sommets do tabr[x] := ggg[x].ecc;
                   tri_r_plus(nb_sommets,tabr,ord_x);
                 end;
            17 : begin
                   if not confirm_('Reindex species of '
                                   + s_ecri_graphe(g_select) + ' according to Rank (+) ?') then exit;
                   for x := 1 to nb_sommets do tabr[x] := ggg[x].rank;
                   tri_r_plus(nb_sommets,tabr,ord_x);
                 end;
            18 : begin
                   if not confirm_('Reindex species of '
                                   + s_ecri_graphe(g_select) + ' according to CycTime (+) ?') then exit;
                   for x := 1 to nb_sommets do tabr[x] := ggg[x].cyctime;
                   tri_r_plus(nb_sommets,tabr,ord_x);
                 end;
            else exit;
          end;
        end;
    else
      exit;
  end;
  g := reindex_graphe(g_select,ord_x);
  if ( g <> 0 ) then
    with graphes[g_select] do
      begin
        case c_x_select of
          2 : begin { je remets les composantes connexes }
               for x := 1 to nb_sommets do
                 graphes[g].ggg[x].connect := ggg[ord_x[x]].connect;
              end;
          else;
        end;
        graphes[g].nb_group_mod := nb_group_mod;
        for x := 1 to nb_sommets do
          graphes[g].ggg[x].group_mod := ggg[ord_x[x]].group_mod;
        graphes[g].nb_group_aic := nb_group_aic;
        for x := 1 to nb_sommets do
          graphes[g].ggg[x].group_aic := ggg[ord_x[x]].group_aic;
        graphes[g].nb_group_tro := nb_group_tro;
        for x := 1 to nb_sommets do
          graphes[g].ggg[x].group_tro := ggg[ord_x[x]].group_tro;
        select0(g);
        affiche;
        status_action('Species sorted+');
      end;
end;

procedure tform_nw.button_sort_moinsClick(Sender: TObject);
var x,g  : integer;
    tabs : svec_type;
    tabr : rvec_type;
    tabi,ord_x : ivec_type;
begin
  case pagecontrol1.ActivePageIndex of
    1 : begin
              with graphes[g_select] do case c_x_select of
                0 : begin
                      if not confirm_('Reindex species of '
                                      + s_ecri_graphe(g_select) + ' alphabetically (-) ?') then exit;
                      for x := 1 to nb_sommets do tabs[x] := ggg[x].nom;
                      tri_a_moins(nb_sommets,tabs,ord_x);
                    end;
                2 : begin
                      if not confirm_('Reindex species of '
                                      + s_ecri_graphe(g_select) + ' according to Connected component (-) ?') then exit;
                      for x := 1 to nb_sommets do tabi[x] := ggg[x].connect;
                      tri_i_moins(nb_sommets,tabi,ord_x);
                    end;
                    { attention recalcul des composantes connexes... }
                3 : begin
                      if not confirm_('Reindex species of '
                                      + s_ecri_graphe(g_select) + ' according to Module index (-) ?') then exit;
                      for x := 1 to nb_sommets do tabi[x] := ggg[x].group_mod;
                      tri_i_moins(nb_sommets,tabi,ord_x);
                    end;
                    { attention groupes pas recalcule dans le graphe reindexe ... }
                4 : begin
                      if not confirm_('Reindex species of '
                                      + s_ecri_graphe(g_select) + ' according to AIC group index (-) ?') then exit;
                      for x := 1 to nb_sommets do tabi[x] := ggg[x].group_aic;
                      tri_i_moins(nb_sommets,tabi,ord_x);
                    end;
                5 : begin
                      if not confirm_('Reindex species of '
                                      + s_ecri_graphe(g_select) + ' according to Trophic group index (-) ?') then exit;
                      for x := 1 to nb_sommets do tabi[x] := ggg[x].group_tro;
                      tri_i_moins(nb_sommets,tabi,ord_x);
                    end;
                6 : begin
                      if not confirm_('Reindex species of '
                                      + s_ecri_graphe(g_select) + ' according to In-egree (-) ?') then exit;
                      for x := 1 to nb_sommets do tabi[x] := ggg[x].nb_pred;
                      tri_i_moins(nb_sommets,tabi,ord_x);
                    end;
                7 : begin
                      if not confirm_('Reindex species of '
                                      + s_ecri_graphe(g_select) + ' according to Out-degree (-) ?') then exit;
                      for x := 1 to nb_sommets do tabi[x] := ggg[x].nb_succ;
                      tri_i_moins(nb_sommets,tabi,ord_x);
                    end;
                8 : begin
                      if not confirm_('Reindex species of '
                                      + s_ecri_graphe(g_select) + ' according to Degree (-) ?') then exit;
                      for x := 1 to nb_sommets do tabi[x] := ggg[x].deg;
                      tri_i_moins(nb_sommets,tabi,ord_x);
                    end;
                9 : begin
                      if not confirm_('Reindex species of '
                                      + s_ecri_graphe(g_select) + ' according to trophic position (-) ?') then exit;
                      for x := 1 to nb_sommets do tabs[x] := s_ecri_pos_sommet(g_select,x);
                      tri_a_moins(nb_sommets,tabs,ord_x);
                    end;
               10 : begin
                      if not confirm_('Reindex species of '
                                      + s_ecri_graphe(g_select) + ' according to Height min (-) ?') then exit;
                      for x := 1 to nb_sommets do tabi[x] := ggg[x].h_min;
                      tri_i_moins(nb_sommets,tabi,ord_x);
                    end;
               11 : begin
                      if not confirm_('Reindex species of '
                                      + s_ecri_graphe(g_select) + ' according to Height (-) ?') then exit;
                      for x := 1 to nb_sommets do tabr[x] := ggg[x].h_moy;
                      tri_r_moins(nb_sommets,tabr,ord_x);
                    end;
               12 : begin
                      if not confirm_('Reindex species of '
                                      + s_ecri_graphe(g_select) + ' according to Height max (-) ?') then exit;
                      for x := 1 to nb_sommets do tabi[x] := ggg[x].h_max;
                      tri_i_moins(nb_sommets,tabi,ord_x);
                    end;
               13 : begin
                      if not confirm_('Reindex species of '
                                      + s_ecri_graphe(g_select) + ' according to Trophic Level (-) ?') then exit;
                      for x := 1 to nb_sommets do tabr[x] := ggg[x].trolev;
                      tri_r_moins(nb_sommets,tabr,ord_x);
                    end;
               14 : begin
                      if not confirm_('Reindex species of '
                                      + s_ecri_graphe(g_select) + ' according to Omnivory index (-) ?') then exit;
                      for x := 1 to nb_sommets do tabr[x] := ggg[x].oi;
                      tri_r_moins(nb_sommets,tabr,ord_x);
                    end;
               15 : begin
                      if not confirm_('Reindex species of '
                                      + s_ecri_graphe(g_select) + ' according to Clustering (-) ?') then exit;
                      for x := 1 to nb_sommets do tabr[x] := ggg[x].c;
                      tri_r_moins(nb_sommets,tabr,ord_x);
                    end;
               16 : begin
                      if not confirm_('Reindex species of '
                                      + s_ecri_graphe(g_select) + ' according to Eccentricity (-) ?') then exit;
                      for x := 1 to nb_sommets do tabr[x] := ggg[x].ecc;
                      tri_r_moins(nb_sommets,tabr,ord_x);
                    end;
               17 : begin
                      if not confirm_('Reindex species of '
                                      + s_ecri_graphe(g_select) + ' according to Rank (-) ?') then exit;
                      for x := 1 to nb_sommets do tabr[x] := ggg[x].rank;
                      tri_r_moins(nb_sommets,tabr,ord_x);
                    end;
               18 : begin
                      if not confirm_('Reindex species of '
                                      + s_ecri_graphe(g_select) + ' according to CycTime (-) ?') then exit;
                      for x := 1 to nb_sommets do tabr[x] := ggg[x].cyctime;
                      tri_r_moins(nb_sommets,tabr,ord_x);
                    end;
                else exit;
              end;
        end;
    else
      exit;
  end;
  g := reindex_graphe(g_select,ord_x);
  if ( g <> 0 ) then
    with graphes[g_select] do
      begin
        case c_x_select of
          2 : begin { je remets les composantes connexes }
               for x := 1 to nb_sommets do
                 graphes[g].ggg[x].connect := ggg[ord_x[x]].connect;
              end;
          else;
        end;
        graphes[g].nb_group_mod := nb_group_mod;
        for x := 1 to nb_sommets do
          graphes[g].ggg[x].group_mod := ggg[ord_x[x]].group_mod;
        graphes[g].nb_group_aic := nb_group_aic;
        for x := 1 to nb_sommets do
          graphes[g].ggg[x].group_aic := ggg[ord_x[x]].group_aic;
        graphes[g].nb_group_tro := nb_group_tro;
        for x := 1 to nb_sommets do
          graphes[g].ggg[x].group_tro := ggg[ord_x[x]].group_tro;
        select0(g);
        affiche;
        status_action('Species sorted-');
      end;
end;

procedure tform_nw.button_maxconnClick(Sender: TObject);
var g : integer;
begin
  if ( graphes[g_select].nb_connect = 1 ) then exit;
  if not confirm_('Get maximum connected component of network '
                   + s_ecri_graphe(g_select) + ' ?') then exit;
  g := comp_conn_graphe(g_select);
  if ( g <> 0 ) then
    begin
      select0(g);
      affiche;
      status_action('Conn Comp extracted');
    end;
end;

procedure tform_nw.stringgrid_sommetSelectCell(Sender: TObject; acol,
  arow: integer; var canselect: boolean);
begin
  canselect := edit_mode and ( acol = 0 ) and ( arow > 0 )
end;

procedure tform_nw.stringgrid_arcSelectCell(Sender: TObject; acol,
  arow: integer; var canselect: boolean);
begin
  canselect := edit_mode and ( arow > 0 ) and ( t_a_select = 0 );
end;

procedure tform_nw.stringgrid_sommetKeyPress(Sender: TObject;var key: char);
var x : integer;
    s : string;
begin
  if edit_mode and ( key = chr(13) ) then
    begin
      s := stringgrid_arc.Cells[c_x_select,r_x_select];
      s := tronque(minuscule(stringgrid_sommet.Cells[0,x_select]));
      x := trouve_nom_sommet(g_select,s);
      if ( x <> 0 ) then
        begin
          erreur('Species name already exists');
          exit;
        end
      else
        graphes[g_select].ggg[x_select].nom := s;
      affiche_sommets(g_select);
      status_action('Species name modified');
    end;
end;

procedure tform_nw.stringgrid_arcKeyPress(Sender: TObject;var key: char);
var g : integer;
    a : extended;
    s : string;
begin
  if not edit_mode then exit;
  if ( key <> chr(13) ) then exit;
  s := tronque(minuscule(stringgrid_arc.Cells[c_a_select,r_a_select]));
  if est_reel(s,a) then
    if ( a < 0.0 ) then
      begin
        erreur('non negative value expected');
        exit;
      end
    else
      begin
        g := modif_arc_mat_graphe(g_select,x_a_select,y_a_select,a);
        if ( g <> 0 ) then
          begin
            affiche_arcs(g);
            status_action('Link modified');
          end;
      end
  else
    erreur('numerical value expected');
end;

procedure tform_nw.edit_off;
begin
  with button_edit do
    begin
      edit_mode := false;
      Font.Color := clBlack;
      Caption := 'EDIT';
      stringgrid_sommet.FixedCols := 2;
      affiche;
    end;
end;

procedure tform_nw.button_editClick(Sender: TObject);
begin
  with button_edit do
    if edit_mode then
      begin
        edit_mode := false;
        Font.Color := clBlack;
        Caption := 'EDIT';
        stringgrid_sommet.FixedCols := 2;
        set_actions_edit1;
        affiche;
      end
    else
      begin
        edit_mode  := true;
        Font.Color := clRed;
        Caption := 'EDIT ON';
        stringgrid_sommet.FixedCols := 0;
        set_actions_edit0;
        affiche;
      end;
end;

procedure tform_nw.button_groupsClick(Sender: TObject);
begin
  if ( g_select = 0 ) then exit;
  with form_cluster do
    begin
      if not Visible then Show;
      SetFocus;
    end;
end;

procedure tform_nw.button_importClick(Sender: TObject);
begin
  if ( pagecontrol1.ActivePageIndex <> 0 ) then
    begin
      erreur('Please select Networks grid');
      exit;
    end;
  with form_import do
    begin
      if not Visible then Show;
      SetFocus;
    end;
end;

procedure tform_nw.button_aggregClick(Sender: TObject);
begin
  if ( g_select = 0 ) then exit;
  with form_lump do
    begin
      if not Visible then Show;
      SetFocus;
    end;
end;

procedure tform_nw.en_vracClick(Sender: TObject);
begin
  //calcul_nb_larg(g_select);
  betweeness(g_select);
end;

end.
