unit f_graph;

{ @@@@@@  graphics  @@@@@@ }

interface

uses   SysUtils,Types,Classes,Variants,QGraphics,QControls,QForms,QDialogs,
       QExtCtrls,QStdCtrls,QComCtrls,QMenus,QTypes,QActnList,QImgList,
       kglobvar;

const  maxvargraph = 4;        { nombre max de graphes simultanes }
       maxgraph = 10000;       { nombre max de cycles representables }
       maxcolors = 16;         { nombre max de couleurs }
       max_arc_en_ciel = 255;  { nombre max de couleurs arc en ciel }
       dd = 0.01;              { chouia graphique }

       graf_efface  = 0;
       graf_distrib = 1;
       graf_graphe_haut   = 3;
       graf_graphe_trolev = 4;
       graf_graphe_eccen  = 5;
       graf_graphe_cercle = 6;
       graf_graphe_matrix = 7;

       label_no  = 0;
       label_nom = 1;
       label_num = 2;

       graf_group_no  = 0;
       graf_group_mod = 1;
       graf_group_aic = 2;
       graf_group_tro = 3;

type   tab_graph_type = array[0..maxgraph] of extended;

type
  tform_graph = class(TForm)
    StatusBar1: TStatusBar;
    ActionList1: TActionList;
    file_save: TAction;
    file_saveas: TAction;
    fileexit: TAction;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Save1: TMenuItem;
    Save2: TMenuItem;
    Exit1: TMenuItem;
    graphset: TAction;
    ToolBar1: TToolBar;
    file_save_button: TToolButton;
    ToolButton4: TToolButton;
    graph_settings_button: TToolButton;
    Settings1: TMenuItem;
    Settings2: TMenuItem;
    PaintBox1: TPaintBox;
    Clear1: TMenuItem;
    Clear2: TMenuItem;
    clear: TAction;
    ToolButton6: TToolButton;
    graph_clear_button: TToolButton;
    ImageList1: TImageList;
    SaveDialog1: TSaveDialog;
    procedure init_graphic;
    procedure tab_col;
    procedure efface(Sender: TObject);
    procedure gdistrib(nb_steps,icol : integer;moy,sigma : extended);
    procedure ggraphe_haut(g : integer);
    procedure ggraphe_haut_val(g : integer);
    procedure ggraphe_trolev(g : integer);
    procedure ggraphe_trolev_val(g : integer);
    procedure ggraphe_eccen(g : integer);
    procedure ggraphe_cercle(g : integer);
    procedure ggraphe_matrix(g : integer);
    procedure ggraphe(g : integer);
    procedure repaint1(Sender: TObject);
    procedure fileexitExecute(Sender: TObject);
    procedure graphsetExecute(Sender: TObject);
    procedure status_graphe(g : integer);
    procedure status_x(s : string);
    procedure status_repr(s : string);
    procedure status_distrib;
    procedure status_groups(g : integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure file_saveExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure graph_clear_buttonClick(Sender: TObject);
    procedure StatusBar1PanelClick(Sender: TObject; Panel: TStatusPanel);
  private
    iax,ibx,iay,iby,imargex,imargey : integer; { bornes cadrage }
    vx : tab_graph_type;    { vecteur graphique courant x }
    vy : tab_graph_type;    { vecteur graphique courant y }
    p  : array[0..maxgraph] of TPoint;
    h_x : ivec_type;        { table des sommets ordonnes par hauteurs (trophic level, eccentricites) croissantes }
    tab_niv : ivec_type;    { table pour representation des niveaux des sommets }
    tab_u : rvec_type;      { coordonnees x des sommets }
    tab_v : rvec_type;      { coordonnees y des sommets }
    nb_steps_sav : integer; { memorisation du nb de points courant }
    icol_sav : integer;     { memorisation indice couleur }
    g_sav : integer;        { memorisation du graphe courant }
    grafgraf : integer;     { memorisation du graphique courant }
    moy_sav : extended;     { memorisation my gdistrib }
    sigma_sav : extended;   { memorisation sigma gdistrib }
    procedure init_marges;
    procedure coord(x,y : extended;var ix,iy : integer);
    procedure coord2(x,y : extended;var ix,iy : integer);
    procedure ligne(x1,y1,x2,y2 : extended;col : integer);
    procedure ligneb(x1,y1,x2,y2 : extended);
    procedure arc1(x1,y1,x2,y2,x3,y3,x4,y4 : extended;col : integer);
    procedure garc(x1,y1,x2,y2 : extended;col : integer);
    procedure garc_courbe(x1,y1,x2,y2 : extended;col : integer);
    procedure gsommet(g,x : integer);
    function  col_arc(g,x,y : integer; a,val : extended) : integer;
    procedure cercle(x,y,r : extended;col : integer);
    procedure disque(x,y,r : extended;colex,colin : integer);
    (*procedure points(n: integer;col : integer);*)
    (*procedure vect(n: integer;col : integer);*)
    procedure rectangle(x1,y1,x2,y2 : extended;col : integer);
    procedure rect2(x1,y1,x2,y2 : extended;col : integer);
    procedure rectfull(x1,y1,x2,y2 : extended;col : integer);
    function  taille_police(pol : extended) : integer;
    procedure texte(x,y : extended;s : string;orien,pol : extended;col : integer);
    procedure axes(xmi,xma,ymi,yma : extended);
    procedure axe_y(ymi,yma : extended);
    function  get_col_aec(a : extended) : integer;
    function  get_col(k : integer) : integer;
    function  get_color(k : integer;a : extended) : integer;
    procedure calcul_bornes(nb_steps : integer);
  public
    colors : array[0..maxcolors] of integer; { table des couleurs }
    xmin,xmax,
    ymin,ymax   : extended;       { bornes courantes du graphique }
    distrib0    : boolean;        { indicateur 0 inclus dans distribution }
    d_distrib   : extended;       { intervalle en mode distribution }
    coeff_aec   : extended;       { coefficient couleurs arc-en-ciel }
    bord        : boolean;        { axes on/off }
    grid        : boolean;        { grid on/off }
    xscale      : boolean;        { echelle definie en x on/off }
    yscale      : boolean;        { echelle definie en y on/off}
    black_on_white : boolean;     { indicateur mode noir sur blanc }
    white_on_black : boolean;     { indicateur mode blanc sur noir }
    affiche_nom : boolean;        { indicateur affichage des noms des sommets }
    thin_links  : boolean;        { indicateur tracer les arcs pas epais }
    no_links    : boolean;        { indicateur pas tracer les arcs }
    haut_val    : boolean;        { indicateur utiliser haut, trolev value }
    nb_niv      : integer;        { nombre de niveaux representation graphe }
    repr_graphe  : integer;       { type de representation du graphe }
    label_graphe : integer;       { option des labels du graphe }
    group_graphe : integer;       { option de representation des groupes }
    rainbow    : boolean;         { indicateur palette arc-en-ciel pour graphe }
    multicol   : boolean;         { indicateur plusieurs couleurs graphe }
    greyscale  : boolean;         { indicateur palette de gris }
    valgraph_x : tab_graph_type;  { tableau des valeurs x }
    valgraph_y : tab_graph_type;  { tableau des valeurs y }
    ifg : integer;                { numero de la forme }
  end;

var   form_graph: tform_graph;

procedure calcul_echelle(amin,amax : extended;var pas,a1 : extended);

implementation

uses  kutil,kmath,ksyntax,kgestiong,f_graphset,f_nw;

{$R *.xfm}

var   arc_en_ciel : array[0..max_arc_en_ciel] of integer;
      { table des couleurs arc-en-ciel }
      aec_nb : integer; {nombre de couleurs arc_en_ciel }
      gris_en_ciel : array[0..max_arc_en_ciel] of integer;
      { la meme chose, en gris }

function rgb(r,g,b : integer) : integer;
begin
  rgb := r + 256*(g + 256*b);
end;

procedure tform_graph.tab_col;
begin
  colors[0]  := rgb(140,140,140);     { gris } {fond}
  colors[1]  := rgb(255,  0,  0);     { rouge }
  colors[2]  := rgb(  0,255,  0);     { vert }
  colors[3]  := rgb(  0,  0,255);     { bleu }
  colors[4]  := rgb(255,255,  0);     { jaune }
  colors[5]  := rgb(255,  0,255);     { magenta }
  colors[6]  := rgb(  0,255,255);     { cyan }
  colors[7]  := rgb(255,140,255);     { rose }
  colors[8]  := rgb(191,  0,  0);     { rouge fonce }
  colors[9]  := rgb(  0,191,  0);     { vert fonce }
  colors[10] := rgb(  0,  0,191);     { bleu fonce }
  colors[11] := rgb(191,191,  0);     { jaune fonce }
  colors[12] := rgb(191,  0,191);     { magenta fonce }
  colors[13] := rgb(  0,191,191);     { cyan fonce }
  colors[14] := rgb(191,191,191);     { gris }
  colors[15] := rgb(128,128,255);     { violet }
  colors[16] := rgb(255,128,  0);     { orange }
end;

procedure tab_arc_en_ciel;
var i,k : integer;
begin
  arc_en_ciel[0] := rgb(0,0,80); { bleu fonce }
  i := 0;
  k := -5;
  repeat
    i := i + 1;
    k := k + 5;
    arc_en_ciel[i] := rgb(255,k,0);
  until ( k = 255 );
  k := -5;
  repeat
    i := i + 1;
    k := k + 5;
    arc_en_ciel[i] := rgb(255-k,255,0);
  until ( k = 255 );
  k := -5;
  repeat
    i := i + 1;
    k := k + 5;
    arc_en_ciel[i] := rgb(0,255,k);
  until ( k = 255 );
  k := -5;
  repeat
    i := i + 1;
    k := k + 5;
    arc_en_ciel[i]:= rgb(0,255-k,255);
  until ( k = 255 );
  k := 0;
  repeat
    i := i + 1;
    k := k + 5;
    arc_en_ciel[i]:= rgb(0,0,255-k);
  until ( k = 255 ) or ( i = 255 );
  aec_nb := 245; { car les dernieres valeurs de bleu sont noires....}
  k := 0;
  gris_en_ciel[0] := clWhite;
  for i := 1 to 255 do
    begin
      gris_en_ciel[i] := rgb(255-k,255-k,255-k);
      k := k + 1;
    end;
end;

function  tform_graph.get_col_aec(a : extended) : integer;
{ 0 < a < 1 }
var k : integer;
begin
  if ( a > 1.0 ) then a := 1.0;
  if greyscale then
    begin
      k := trunc(255*a) + 1;
      get_col_aec := gris_en_ciel[255-k+1];
    end
  else
    begin
      k := trunc(aec_nb*(1.0 - a)) + 1;
      get_col_aec := arc_en_ciel[k];
    end;
end;

function  tform_graph.get_col(k : integer) : integer;
var col : integer;
begin
  if ( k > maxcolors ) then k := k mod maxcolors + 1;
  col := colors[k];
  if black_on_white or greyscale then col := clBlack;
  if white_on_black then col := clWhite;
  if greyscale then col := gris_en_ciel[16*k-1];
  get_col := col;
end;

function  tform_graph.get_color(k : integer;a : extended) : integer;
var col : integer;
    c : extended;
begin
  if rainbow or greyscale then
    if ( a > 0.0 ) then
      begin
        c := exp(ln(a)/coeff_aec);
        col := get_col_aec(c);
      end
    else
      begin
        col := ClBlack;
        if white_on_black then col := ClWhite;
      end
  else
    if multicol then col := get_col(k);
  if black_on_white then col := clBlack;
  if white_on_black then col := clWhite;
  get_color := col;
end;

procedure tform_graph.init_marges;
begin
  with paintbox1 do
    begin
      iax := round(ClientWidth/10.0);
      ibx := round(ClientWidth/10.0);
      iay := round(ClientHeight/10.0);
      iby := round(ClientHeight/10.0);
      imargex := iax + ibx;
      imargey := iay + iby;
    end;
end;

procedure tform_graph.FormCreate(Sender: TObject);
begin
  Left   := 772;
  Top    := 200;
  Height := 576;
  Width  := 500; { paintbox1 = 625x625 }
  adjust(self);
  tab_col;
  tab_arc_en_ciel;
  with paintbox1 do
    begin
      ClientWidth  := form_graph.Width;
      ClientHeight := ClientWidth;
      init_marges;
    end;
  file_save.Enabled := false;
  file_saveas.Enabled := false;
  graphset.Enabled := false;
  efface(nil);
end;

procedure tform_graph.init_graphic;
var i : integer;
begin
  bord   := true;
  grid   := false;
  xmin := 0.0;
  xmax := 1.0;
  ymin := 0.0;
  ymax := 1.0;
  xscale := false;
  yscale := false;
  distrib0  := true;
  d_distrib := 1.0;
  coeff_aec := 2.718;
  nb_niv    := 5;
  affiche_nom := true;
  thin_links := false;
  no_links := false;
  haut_val := false;
  repr_graphe  := graf_graphe_haut;
  label_graphe := label_nom;
  group_graphe := graf_group_no;
  rainbow  := true;
  multicol := false;
  black_on_white := false;
  white_on_black := false;
  greyscale := false;
  for i := 0 to maxgraph do
    begin
      vx[i] := 0.0;
      vy[i] := 0.0;
      valgraph_x[i] := 0.0;
      valgraph_y[i] := 0.0;
    end;
  efface(nil);
  grafgraf := graf_efface;
  file_save.Enabled := true;
  file_saveas.Enabled := true;
  graphset.Enabled := true;
end;

procedure tform_graph.status_graphe(g : integer);
begin
  with graphes[g] do
    begin
      statusbar1.Panels[0].Text := Name;
      statusbar1.Panels[1].Text := '#' + IntToStr(icre);
    end;
end;

procedure tform_graph.status_x(s : string);
begin
  statusbar1.Panels[2].Text := s;
end;

procedure tform_graph.status_repr(s : string);
begin
  statusbar1.Panels[3].Text := s;
  statusbar1.Panels[4].Text := '';
end;

procedure tform_graph.status_distrib;
var s : string;
begin
  s := FloatToStr(d_distrib);
  if distrib0 then
    s := 'Dist0 ' + s
  else
    s := 'Dist ' + s;
  statusbar1.Panels[3].Text := s;
  //statusbar1.Panels[4].Text := '';
  //statusbar1.Panels[5].Text := '';
end;

procedure tform_graph.status_groups(g : integer);
var s : string;
begin
  if ( group_graphe = graf_group_no ) then
    s := ''
  else
    begin
    with graphes[g] do
      case group_graphe of
        graf_group_mod :
          if ( nb_group_mod > 0 ) then s := 'Modules';
        graf_group_aic :
          if ( nb_group_aic > 0 ) then s := 'AIC Groups';
        graf_group_tro :
          if ( nb_group_tro > 0 ) then s := 'Trophic Groups';
      end;
    end;
  statusbar1.Panels[5].Text := s;
  statusbar1.Panels[4].Text := '';
end;

procedure tform_graph.efface(Sender: TObject);
var col : integer;
begin
  col := get_col(0);
  if black_on_white or greyscale then col := ClWhite;
  if white_on_black then col := ClBlack;
  rect2(0.0,0.0,1.0,1.0,col);
end;

procedure tform_graph.coord(x,y : extended;var ix,iy : integer);
begin
  with paintbox1 do
    begin
      ix := round(iax + x*(ClientWidth-imargex));
      iy := round(iby + (1.0-y)*(ClientHeight-imargey));
    end;
end;

procedure tform_graph.coord2(x,y : extended;var ix,iy : integer);
begin
  with paintbox1 do
    begin
      ix := round(x*ClientWidth);
      iy := round((1.0-y)*ClientHeight);
    end;
end;

procedure tform_graph.ligne(x1,y1,x2,y2 : extended;col : integer);
var ix1,iy1,ix2,iy2 : integer;
begin
  coord(x1,y1,ix1,iy1);
  coord(x2,y2,ix2,iy2);
  with paintbox1.Canvas do
    begin
      Pen.Color := col;
      MoveTo(ix1,iy1);
      LineTo(ix2,iy2);
    end;
end;

procedure tform_graph.ligneb(x1,y1,x2,y2 : extended);
var ix1,iy1,ix2,iy2,pp : integer;
begin
  with paintbox1.Canvas do
    begin
      if ( Pen.Width = 1 ) then exit;
      coord(x1,y1,ix1,iy1);
      coord(x2,y2,ix2,iy2);
      pp := Pen.width;
      Pen.Width := 1;
      Pen.Color := clBlack;
      if black_on_white then Pen.Color := clWhite;
      MoveTo(ix1,iy1);
      LineTo(ix2,iy2);
      Pen.Width := pp;
    end;
end;

procedure tform_graph.cercle(x,y,r : extended;col : integer);
var ix1,iy1,ix2,iy2 : integer;
begin
  coord(x-r,y-r,ix1,iy1);
  coord(x+r,y+r,ix2,iy2);
  with paintbox1.Canvas do
    begin
      Pen.Color := col;
      Brush.Style := bsClear;
      Ellipse(ix1,iy1,ix2,iy2);
    end;
end;

procedure tform_graph.disque(x,y,r : extended;colex,colin : integer);
var ix1,iy1,ix2,iy2 : integer;
begin
  coord(x-r,y-r,ix1,iy1);
  coord(x+r,y+r,ix2,iy2);
  with paintbox1.Canvas do
    begin
      Pen.Color   := colex;
      Brush.Style := bsSolid;
      Brush.Color := colin;
      Ellipse(ix1,iy1,ix2,iy2);
    end;
end;

procedure tform_graph.garc(x1,y1,x2,y2 : extended;col : integer);
var xm,ym,u,v,up,vp,r : extended;
begin
  ligne(x1,y1,x2,y2,col);
  xm := 0.5*(x1 + x2);
  ym := 0.5*(y1 + y2);
  u := x2 - x1;
  v := y2 - y1;
  r := sqrt(u*u + v*v);
  if ( r = 0.0 ) then { cas d'une boucle }
    begin
      r := 7*dd;
      xm := x1 + 2.0*r;
      ym := y1;
      if ( xm < 1.0 ) then
        cercle(x1+r,y1,r,col)
      else
        begin
          xm := x1 - 2.0*r;
          cercle(x1-r,y1,r,col);
        end;
      x2 := xm;
      y2 := ym + dd;
      x1 := xm - dd;
      y1 := ym;
      ligne(x1,y1,x2,y2,col);
      ligneb(x1,y1,x2,y2);
      x1 := xm + dd;
      y1 := ym;
      ligne(x1,y1,x2,y2,col);
      ligneb(x1,y1,x2,y2);
      exit;
    end;
  u := u/r;
  v := v/r;
  up := -v;
  vp := u;
  x2 := xm + dd*u;
  y2 := ym + dd*v;
  x1 := xm + dd*up;
  y1 := ym + dd*vp;
  ligne(x1,y1,x2,y2,col);
  ligneb(x1,y1,x2,y2);
  x1 := xm - dd*up;
  y1 := ym - dd*vp;
  ligne(x1,y1,x2,y2,col);
  ligneb(x1,y1,x2,y2);
end;

procedure tform_graph.arc1(x1,y1,x2,y2,x3,y3,x4,y4 : extended;col : integer);
var ix1,iy1,ix2,iy2,ix3,iy3,ix4,iy4 : integer;
begin
  coord(x1,y1,ix1,iy1);
  coord(x2,y2,ix2,iy2);
  coord(x3,y3,ix3,iy3);
  coord(x4,y4,ix4,iy4);
  with paintbox1.Canvas do
    begin
      Pen.Color := col;
      Arc(ix1,iy1,ix2,iy2,ix3,iy3,ix4,iy4);
    end;
end;

procedure tform_graph.garc_courbe(x1,y1,x2,y2 : extended;col : integer);
var u,v,up,vp,xm,ym,x,y,r,xa,ya,xb,yb,ua,ub : extended;
begin
  xm := 0.5*(x1 + x2);
  ym := 0.5*(y1 + y2);
  u := x2 - x1;
  v := y2 - y1;
  r := sqrt(u*u + v*v);
  if ( r = 0.0 ) then { cas d'une boucle }
    begin
      r := 7*dd;
      xm := x1 + 2.0*r;
      ym := y1;
      if ( xm < 1.0 ) then
        cercle(x1+r,y1,r,col)
      else
        begin
          xm := x1 - 2.0*r;
          cercle(x1-r,y1,r,col);
        end;
      x2 := xm;
      y2 := ym + dd;
      x1 := xm - dd;
      y1 := ym;
      ligne(x1,y1,x2,y2,col);
      ligneb(x1,y1,x2,y2);
      x1 := xm + dd;
      y1 := ym;
      ligne(x1,y1,x2,y2,col);
      ligneb(x1,y1,x2,y2);
      exit;
    end;
  u  := u/r;
  v  := v/r;
  up := -v;
  vp := u;
  x  := xm - 0.866*r*up; { sqrt(3)/2 }
  y  := ym - 0.866*r*vp;
  ua := cos(pi/12.0);
  ub := cos(5.0*pi/12.0);
  if ( ua <= u ) and ( u <= ub ) then {kkkkk}
    begin
      xa := x - r;
      ya := y - r;
      xb := x + r;
      yb := y + r;
    end
  else
    begin
      xa := x - r;
      ya := y + r;
      xb := x + r;
      yb := y - r;
    end;
  arc1(xa,ya,xb,yb,x1,y1,x2,y2,col);
  xm := x + r*up;
  ym := y + r*vp;
  x2 := xm + dd*u;
  y2 := ym + dd*v;
  x1 := xm + dd*up;
  y1 := ym + dd*vp;
  ligne(x1,y1,x2,y2,col);
  ligneb(x1,y1,x2,y2);
  x1 := xm - dd*up;
  y1 := ym - dd*vp;
  ligne(x1,y1,x2,y2,col);
  ligneb(x1,y1,x2,y2);
end;

(*procedure tform_graph.points(n: integer; col : integer);
var i,ix,iy : integer;
begin
  with paintbox1.Canvas do
    begin
      Pen.Color := col;
      for i := 0 to n do
        begin
          coord(vx[i],vy[i],ix,iy);
          DrawPoint(ix,iy);
        end;
    end;
end;*)

(*procedure tform_graph.vect(n: integer;col : integer);
var i : integer;
begin
  for i := 0 to n do coord(vx[i],vy[i],p[i].x,p[i].y);
  with paintbox1.Canvas do
    begin
      Pen.Color := col;
      Polyline(p,0,n+1);
    end;
end;*)

procedure tform_graph.rectangle(x1,y1,x2,y2 : extended;col : integer);
begin
  coord(x1,y1,p[0].x,p[0].y);
  coord(x2,y1,p[1].x,p[1].y);
  coord(x2,y2,p[2].x,p[2].y);
  coord(x1,y2,p[3].x,p[3].y);
  coord(x1,y1,p[4].x,p[4].y);
  with paintbox1.Canvas do
    begin
      Pen.Color := col;
      Polyline(p,0,5);
    end;
end;

procedure tform_graph.rect2(x1,y1,x2,y2 : extended;col : integer);
var ix1,iy1,ix2,iy2 : integer;
begin
  coord2(x1,y1,ix1,iy1);
  coord2(x2,y2,ix2,iy2);
  with paintbox1.Canvas do
    begin
      Brush.Color := col;
      Polygon([Point(ix1,iy1),Point(ix2,iy1),Point(ix2,iy2),Point(ix1,iy2)]);
    end;
end;

procedure tform_graph.rectfull(x1,y1,x2,y2 : extended;col : integer);
var ix1,iy1,ix2,iy2 : integer;
begin
  coord(x1,y1,ix1,iy1);
  coord(x2,y2,ix2,iy2);
  with paintbox1.Canvas do
    begin
      Pen.Color   := col;
      Brush.Color := col;
      Polygon([Point(ix1,iy1),Point(ix2,iy1),Point(ix2,iy2),Point(ix1,iy2)]);
    end;
end;

function  tform_graph.taille_police(pol : extended) : integer;
begin
  {taille_police := round(72*pol*imax(ClientHeight,ClientWidth)/PixelsPerInch/60.0); }
  taille_police := round(72*pol*imax(ClientHeight,ClientWidth)/PixelsPerInch/50.0);
end;

procedure tform_graph.texte(x,y : extended;s : string;orien,pol : extended;col : integer);
var ix,iy : integer;
begin
  with paintbox1.Canvas do
    begin
      coord(x,y,ix,iy);
      Font.Size := taille_police(pol);
      Font.Name := 'Times New Roman';
      Font.Color := col;
      TextOut(ix,iy,s);
    end;
end;

function  expo(x : extended) : integer;
var n : integer;
begin
  x := abs(x);
  if ( x >= 1.0 ) then
    begin
      n := -1;
      repeat
        x := x/10.0;
        n := n + 1;
      until x < 1.0;
    end
  else
    begin
      n := 0;
      repeat
        x := x*10.0;
        n := n - 1;
      until x > 1.0;
    end;
  expo := n;
end;

function  puis10(n : integer) : extended;
var i : integer;
    a,d : extended;
begin
  if ( n >= 0 ) then
    d := 10.0
  else
    begin
      n := -n;
      d := 0.1;
    end;
  a := 1.0;
  for i := 1 to n do a := a*d;
  puis10 := a;
end;

procedure calcul_echelle(amin,amax : extended;var pas,a1 : extended);
var  k,id : integer;
     d,coeff : extended;
begin
  d := amax - amin;
  k := expo(d)-1;
  coeff := puis10(k);
  d  := d/coeff;
  id := trunc(d);
  id := (id div 10 + 1)*10;
  if ( id > 50 ) then
    pas := 10.0
  else
    if ( id > 20 ) then
      pas := 5.0
    else
      pas := 2.0;
  pas := pas*coeff;
  a1  := amin/pas;
  if ( abs(a1) < bigint ) then
    begin
      id := trunc(a1);
      a1 := id*pas;
    end
  else
    a1 := amin;
  if ( a1 > amin ) then a1 := a1 - pas;
end;

procedure tform_graph.axes(xmi,xma,ymi,yma : extended);
var col,i : integer;
    x1,xpas,y1,ypas,x,x0,y,y0,xx,yy,ex,ey,dx,dy,xa1,ya1,xa2,ya2,pol,orien : extended;
begin
  calcul_echelle(xmi,xma,xpas,x1);
  calcul_echelle(ymi,yma,ypas,y1);
  pol := 1.0;
  orien := 0.0;
  col := clWhite;
  if black_on_white or greyscale then col := clBlack;
  rectangle(0.0,0.0,1.0,1.0,col);
  ex := xma - xmi;
  xx := x1;
  x0 := (x1 - xmi)/ex;
  x  := x0;
  dx := xpas/ex;
  ya1 := 0.0;
  ya2 := dd;
  if grid then ya2 := 1.0;
  i := 0;
  repeat
    if ( x >= 0.0 ) and ( x <= 1.0 ) then
      begin
        ligne(x,ya1,x,ya2,col);
        texte(x,-dd,Format('%1.6g',[xx]),orien,pol,col);
      end;
    i := i + 1;
    x  := x0 + i*dx;
    xx := x1 + i*xpas;
  until ( x > 1.0 );
  ey := yma - ymi;
  yy := y1;
  y0 := (y1 - ymi)/ey;
  y  := y0;
  dy := ypas/ey;
  xa1 := 0.0;
  xa2 := dd;
  if grid then xa2 := 1.0;
  i := 0;
  repeat
    if ( y >= 0.0 ) and ( y <= 1.0 ) then
      begin
        ligne(xa1,y,xa2,y,col);
        texte(-8*dd,y + 2*dd,Format('%1.6g',[yy]),orien,pol,col);
      end;
    i  := i + 1;
    y  := y0 + i*dy;
    yy := y1 + i*ypas;
  until ( y > 1.0 );
end;

procedure tform_graph.axe_y(ymi,yma : extended);
var col,i : integer;
    y1,ypas,y,y0,yy,ey,dy,xa1,xa2,pol,orien : extended;
begin
  calcul_echelle(ymi,yma,ypas,y1);
  orien := 0.0;
  pol := 1.0;
  col := clWhite;
  if black_on_white or greyscale then col := clBlack;
  ligne(-2*dd,0.0,-2*dd,1.0,col);
  ey := yma - ymi;
  yy := y1;
  y0 := (y1 - ymi)/ey;
  y  := y0;
  dy := ypas/ey;
  xa1 := -3*dd;
  xa2 := -2*dd;
  if grid then xa2 := 1.0;
  i := 0;
  repeat
    if ( y >= 0.0 ) and ( y <= 1.0 ) then
      begin
        ligne(xa1,y,xa2,y,col);
        texte(-9*dd,y + 2*dd,Format('%1.6g',[yy]),orien,pol,col);
      end;
    i  := i + 1;
    y  := y0 + i*dy;
    yy := y1 + i*ypas;
  until ( y > 1.0 );
end;

procedure tform_graph.calcul_bornes(nb_steps : integer);
var i,i0 : integer;
begin
  i0 := 0;
  if ( grafgraf = graf_distrib ) and not distrib0 then i0 := 1;
  if not xscale then
    begin
      xmin :=  maxextended;
      xmax := -maxextended;
      for i := i0 to nb_steps do
        begin
          xmin := min(xmin,valgraph_x[i]);
          xmax := max(xmax,valgraph_x[i]);
        end;
    end;
  if not yscale then
    begin
      ymin :=  maxextended;
      ymax := -maxextended;
      for i := i0 to nb_steps do
        begin
          ymin := min(ymin,valgraph_y[i]);
          ymax := max(ymax,valgraph_y[i]);
        end;
    end;
  if ( xmax = xmin ) then
    begin
      xmax := xmin + 1.0;
      xmin := xmin - 1.0;
    end;
  if ( ymax = ymin ) then
    begin
      ymax := ymin + 1.0;
      ymin := ymin - 1.0;
    end;
end;

procedure tform_graph.gdistrib(nb_steps,icol : integer; moy,sigma : extended);
var i,col,i0,colb : integer;
    ex,ey,y : extended;
begin
  efface(nil);
  nb_steps_sav := nb_steps;
  icol_sav := icol;
  moy_sav := moy;
  sigma_sav := sigma;
  grafgraf := graf_distrib;
  if distrib0 then i0 := 0 else i0 := 1;
  calcul_bornes(nb_steps);
  ex := xmax - xmin;
  ey := ymax - ymin;
  for i := i0 to nb_steps do vx[i] := (valgraph_x[i]-xmin)/ex;
  col := get_col(icol);
  colb := ClBlack;
  if black_on_white then colb := ClWhite;
  for i := i0 to nb_steps-1 do
    begin
      y := (valgraph_y[i]-ymin)/ey;
      if ( y > 0 ) then
         begin
           rectfull(vx[i],0.0,vx[i+1],y,col);
           rectangle(vx[i],0.0,vx[i+1],y,colb);
         end;
    end;
  if bord then axes(xmin,xmax,ymin,ymax);
  statusbar1.Panels[4].Text := 'm ' + s_ecri_val(moy);
  statusbar1.Panels[5].Text := 's ' + s_ecri_val(sigma);
end;

procedure tform_graph.gsommet(g,x : integer);
var colex,colin,col,nb : integer;
    u,v,orien,pol,dg : extended;
    sgroup : string;
begin
  with graphes[g] do with ggg[x] do
    begin
      u := tab_u[x];
      v := tab_v[x];
      orien := 0.0;
      pol := 1.0;
      colin := get_col(0);
      if white_on_black then colin := clWhite;
      if black_on_white or greyscale then colin := clBlack;
      colex := clWhite;
      if black_on_white or greyscale then colex := clBlack;
      dg := dd;
      nb := 0;
      if ( group_graphe <> graf_group_no ) then
         begin
           case group_graphe of
             graf_group_mod :
               if ( nb_group_mod > 0 ) then
                 begin
                   nb := nb_group_mod;
                   colin := get_col(group_mod);
                   sgroup := IntToStr(group_mod);
                   dg := 2.0*dd;
                 end;
             graf_group_aic :
               if ( nb_group_aic > 0 ) then
                 begin
                   nb := nb_group_aic;
                   colin := get_col(group_aic);
                   sgroup := IntToStr(group_aic);
                   dg := 2.0*dd;
                 end;
             graf_group_tro :
               if ( nb_group_tro > 0 ) then
                 begin
                   nb := nb_group_tro;
                   colin := get_col(group_tro);
                   sgroup := IntToStr(group_tro);
                   dg := 2.0*dd;
                 end;
           end;
         end;
      disque(u,v,dg,colex,colin);
      if ( group_graphe <> graf_group_no ) and ( nb > 0 ) then
        begin
          col := clWhite;
          if white_on_black or greyscale then col := clBlack;
          if ( nb < 10 ) then
            texte(u-0.5*dd,v+1.5*dd,sgroup,orien,0.8*pol,col)
          else
            texte(u-dd,v+1.5*dd,sgroup,orien,0.8*pol,col);
        end;
      u := u + 1.5*dd;
      col := clWhite;
      if black_on_white or greyscale then col := clBlack;
      case label_graphe of
        label_no  :;
        label_num : begin
                      orien := 0.0;
                      pol := 1.0;
                      texte(u,v,IntToStr(x),orien,pol,col);
                    end;
        label_nom : begin
                      orien := 0.0;
                      pol := 1.0;
                      if ( nb_pred = 0 ) then orien := -90.0;
                      { comment on fait pour orienter le texte ? }
                      texte(u,v,nom,orien,pol,col);
                    end;
      end;
    end;
end;

function  tform_graph.col_arc(g,x,y : integer; a,val : extended) : integer;
var col,col2 : integer;
    yagroup : boolean;
begin
  with graphes[g] do with ggg[x] do
    begin
      yagroup := false;
      if ( group_graphe <> graf_group_no ) then
      begin
        if rainbow or multicol then col2 := rgb(0,0,120); { bleu fonce }
        if black_on_white or greyscale then col2 := clBlack;
        if white_on_black then col2 := clWhite;
        case group_graphe of
          graf_group_mod :
            if ( nb_group_mod > 0 ) then
              begin
                yagroup := true;
                if ( group_mod = ggg[y].group_mod ) then
                  col := get_col(group_mod)
                else
                  col := col2;
              end;
          graf_group_aic :
            if ( nb_group_aic > 0 ) then
              begin
                yagroup := true;
                if ( group_aic = ggg[y].group_aic ) then
                  col := get_col(group_aic)
                else
                  col := col2;
              end;
          graf_group_tro :
            if ( nb_group_tro > 0 ) then
              begin
                yagroup := true;
                if ( group_tro = ggg[y].group_tro ) then
                  col := get_col(group_tro)
                else
                  col := col2;
              end;
        end;
      end;
      if not yagroup then
        begin
          col := get_color(x,a);
          if ( ival = 1 ) then
            col := get_color(x,abs(val/valmax));
        end;
    end;
  col_arc := col;
end;

procedure tform_graph.ggraphe_haut(g : integer);
var x,y,col,i,j : integer;
    h,hmax,hmin,eh,dh,u1,v1,u2,v2,a : extended;
    tab : rvec_type;
begin
  g_sav := g;
  grafgraf := graf_graphe_haut;
  if haut_val and ( graphes[g].ival = 1 ) then
    begin
      ggraphe_haut_val(g);
      exit;
    end;
  with graphes[g] do
    begin
      for x := 1 to nb_sommets do tab[x] := ggg[x].h_moy;
      tri_r_plus(nb_sommets,tab,h_x);
      { sortir si les hauteurs ne sont pas calculees }
      if ( nb_b = 0 ) or ( ggg[h_x[1]].h_moy < 0.0 {= bad} ) then
        begin
          axe_y(0.0,1.0);
          exit;
        end;
      hmax := ggg[h_x[nb_sommets]].h_moy;
      hmin := ggg[h_x[1]].h_moy; { = 0 pour especes basales }
      eh := hmax - hmin;
      if ( eh = 0.0 ) then
        begin
          eh   := 1.0;
          hmax := 1.0;
          hmin := 0.0;
        end;
      if not yscale then
        begin
          ymax := hmax;
          ymin := hmin;
        end
      else
        eh := ymax - ymin;
      dh := eh/(nb_niv-1);
      for i := 1 to nb_sommets do tab_niv[i] := 0;
      for x := 1 to nb_sommets do
        begin
          y := h_x[x];
          h := ggg[y].h_moy;
          tab_v[y] := (h - ymin)/eh;
          i := trunc((h - ymin)/dh) + 1;
          tab_niv[i] := tab_niv[i] + 1;
        end;
      reset_graine;
      x := 0;
      for i := 1 to nb_niv do
        for j := 1 to tab_niv[i] do { tab_niv[i] peut etre 0 }
          begin
            x := x + 1;
            if ( x <= nb_sommets ) then
              begin
                y := h_x[x];
                if ( i = 1 ) or ( i = nb_niv ) then
                  tab_u[y] := (j - 0.5)/tab_niv[i]
                else
                  tab_u[y] := (j - 0.5 + 0.5*rand(1))/tab_niv[i];
                end;
          end;
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          y := succ;
          while ( y <> 0 ) do with lis[y] do
            begin
              u1 := tab_u[x];
              v1 := tab_v[x];
              u2 := tab_u[car];
              v2 := tab_v[car];
              a := (ggg[car].h_moy - h_moy)/eh;
              col := col_arc(g,x,car,a,val);
              if ( ival <> 0 ) then
                with paintbox1.Canvas do
                  if not thin_links then
                    Pen.Width := trunc(10.0*abs(val/valmax)) + 1
                  else
                    Pen.Width := 1;
              if not no_links then
                if ( v2 > v1 ) then
                  garc(u1,v1,u2,v2,col)
                else
                  garc_courbe(u1,v1,u2,v2,col);
              y := cdr;
              with paintbox1.Canvas do Pen.Width := 1;
            end;
        end;
      for x := 1 to nb_sommets do gsommet(g,x);
    end;
  if bord then axe_y(ymin,ymax);
end;

procedure tform_graph.ggraphe_haut_val(g : integer);
var x,y,col,i,j : integer;
    h,hmax,hmin,eh,dh,u1,v1,u2,v2,a : extended;
    tab : rvec_type;
begin
  with graphes[g] do
    begin
      for x := 1 to nb_sommets do tab[x] := ggg[x].h_moy_val;
      tri_r_plus(nb_sommets,tab,h_x);
      { sortir si les hauteurs ne sont pas calculees }
      if ( nb_b = 0 ) or ( ggg[h_x[1]].h_moy < 0.0 {= bad} ) then
        begin
          axe_y(0.0,1.0);
          exit;
        end;
      hmax := ggg[h_x[nb_sommets]].h_moy_val;
      hmin := ggg[h_x[1]].h_moy_val; { = 0 pour especes basales }
      eh := hmax - hmin;
      if ( eh = 0.0 ) then
        begin
          eh   := 1.0;
          hmax := 1.0;
          hmin := 0.0;
        end;
      if not yscale then
        begin
          ymax := hmax;
          ymin := hmin;
        end
      else
        eh := ymax - ymin;
      dh := eh/(nb_niv-1);
      for i := 1 to nb_sommets do tab_niv[i] := 0;
      for x := 1 to nb_sommets do
        begin
          y := h_x[x];
          h := ggg[y].h_moy_val;
          tab_v[y] := (h - ymin)/eh;
          i := trunc((h - ymin)/dh) + 1;
          tab_niv[i] := tab_niv[i] + 1;
        end;
      reset_graine;
      x := 0;
      for i := 1 to nb_niv do
        for j := 1 to tab_niv[i] do { tab_niv[i] peut etre 0 }
          begin
            x := x + 1;
            if ( x <= nb_sommets ) then
              begin
                y := h_x[x];
                if ( i = 1 ) or ( i = nb_niv ) then
                  tab_u[y] := (j - 0.5)/tab_niv[i]
                else
                  tab_u[y] := (j - 0.5 + 0.5*rand(1))/tab_niv[i];
                end;
          end;
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          y := succ;
          while ( y <> 0 ) do with lis[y] do
            begin
              u1 := tab_u[x];
              v1 := tab_v[x];
              u2 := tab_u[car];
              v2 := tab_v[car];
              a := (ggg[car].h_moy_val - h_moy_val)/eh;
              col := col_arc(g,x,car,a,val);
              with paintbox1.Canvas do
                if not thin_links then
                  Pen.Width := trunc(10.0*abs(val/valmax)) + 1
                else
                  Pen.Width := 1;
              if not no_links then
                if ( v2 > v1 ) then
                  garc(u1,v1,u2,v2,col)
                else
                  garc_courbe(u1,v1,u2,v2,col);
              y := cdr;
              with paintbox1.Canvas do Pen.Width := 1;
            end;
        end;
      for x := 1 to nb_sommets do gsommet(g,x);
    end;
  if bord then axe_y(ymin,ymax);
end;

procedure tform_graph.ggraphe_trolev(g : integer);
var x,y,col,i,j : integer;
    k,kmax,kmin,ek,dk,u1,v1,u2,v2,a : extended;
    tab : rvec_type;
begin
  g_sav := g;
  grafgraf := graf_graphe_trolev;
  if haut_val and ( graphes[g].ival = 1 ) then
    begin
      ggraphe_trolev_val(g);
      exit;
    end;
  with graphes[g] do
    begin
      for x := 1 to nb_sommets do tab[x] := ggg[x].trolev;
      tri_r_plus(nb_sommets,tab,h_x);
      { sortir si les niveaux trophiques ne sont pas calcules }
      if ( nb_b = 0 ) or ( ggg[h_x[1]].trolev < 0.0 {= bad} ) then
        begin
          axe_y(1.0,2.0);
          exit;
        end;
      kmax := ggg[h_x[nb_sommets]].trolev;
      kmin := ggg[h_x[1]].trolev; { = 1 pour especes basales }
      ek   := kmax - kmin;
      if ( ek = 0.0 ) then
        begin
          ek   := 2.0;
          kmax := 2.0;
          kmin := 1.0;
        end;
      if not yscale then
        begin
          ymax := kmax;
          ymin := kmin;
        end
      else
        ek := ymax - ymin;
      dk := ek/(nb_niv-1);
      for i := 1 to nb_sommets do tab_niv[i] := 0;
      for x := 1 to nb_sommets do
        begin
          y := h_x[x];
          k := ggg[y].trolev;
          tab_v[y] := (k - ymin)/ek;
          i := trunc((k - ymin)/dk) + 1;
          tab_niv[i] := tab_niv[i] + 1;
        end;
      reset_graine;
      x := 0;
      for i := 1 to nb_niv do
        for j := 1 to tab_niv[i] do { tab_niv[i] peut etre 0 }
          begin
            x := x + 1;
            if ( x <= nb_sommets ) then
              begin
                y := h_x[x];
                if ( i = 1 ) or ( i = nb_niv ) then
                  tab_u[y] := (j - 0.5)/tab_niv[i]
                else
                  tab_u[y] := (j - 0.5 + 0.5*rand(1))/tab_niv[i];
                end;
          end;
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          y := succ;
          while ( y <> 0 ) do with lis[y] do
            begin
              u1 := tab_u[x];
              v1 := tab_v[x];
              u2 := tab_u[car];
              v2 := tab_v[car];
              a := (ggg[car].trolev - trolev)/ek;
              col := col_arc(g,x,car,a,val);
              if ( ival <> 0 ) then
                with paintbox1.Canvas do
                  if not thin_links then
                    Pen.Width := trunc(10.0*abs(val/valmax)) + 1
                  else
                    Pen.Width := 1;
              if not no_links then
                if ( v2 > v1 ) then
                  garc(u1,v1,u2,v2,col)
                else
                  garc_courbe(u1,v1,u2,v2,col);
              y := cdr;
              with paintbox1.Canvas do Pen.Width := 1;
            end;
        end;
      for x := 1 to nb_sommets do gsommet(g,x);
    end;
  if bord then axe_y(ymin,ymax);
end;

procedure tform_graph.ggraphe_trolev_val(g : integer);
var x,y,col,i,j : integer;
    k,kmax,kmin,ek,dk,u1,v1,u2,v2,a : extended;
    tab : rvec_type;
begin
  with graphes[g] do
    begin
      for x := 1 to nb_sommets do tab[x] := ggg[x].trolev_val;
      tri_r_plus(nb_sommets,tab,h_x);
      { sortir si les niveaux trophiques ne sont pas calcules }
      if ( nb_b = 0 ) or ( ggg[h_x[1]].trolev < 0.0 {= bad} ) then
        begin
          axe_y(1.0,2.0);
          exit;
        end;
      kmax := ggg[h_x[nb_sommets]].trolev_val;
      kmin := ggg[h_x[1]].trolev_val; { = 1 pour especes basales }
      ek   := kmax - kmin;
      if ( ek = 0.0 ) then
        begin
          ek   := 2.0;
          kmax := 2.0;
          kmin := 1.0;
        end;
      if not yscale then
        begin
          ymax := kmax;
          ymin := kmin;
        end
      else
        ek := ymax - ymin;
      dk := ek/(nb_niv-1);
      for i := 1 to nb_sommets do tab_niv[i] := 0;
      for x := 1 to nb_sommets do
        begin
          y := h_x[x];
          k := ggg[y].trolev_val;
          tab_v[y] := (k - ymin)/ek;
          i := trunc((k - ymin)/dk) + 1;
          tab_niv[i] := tab_niv[i] + 1;
        end;
      reset_graine;
      x := 0;
      for i := 1 to nb_niv do
        for j := 1 to tab_niv[i] do { tab_niv[i] peut etre 0 }
          begin
            x := x + 1;
            if ( x <= nb_sommets ) then
              begin
                y := h_x[x];
                if ( i = 1 ) or ( i = nb_niv ) then
                  tab_u[y] := (j - 0.5)/tab_niv[i]
                else
                  tab_u[y] := (j - 0.5 + 0.5*rand(1))/tab_niv[i];
                end;
          end;
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          y := succ;
          while ( y <> 0 ) do with lis[y] do
            begin
              u1 := tab_u[x];
              v1 := tab_v[x];
              u2 := tab_u[car];
              v2 := tab_v[car];
              a := (ggg[car].trolev_val - trolev_val)/ek;
              col := col_arc(g,x,car,a,val);
              with paintbox1.Canvas do
                if not thin_links then
                  Pen.Width := trunc(10.0*abs(val/valmax)) + 1
                else
                  Pen.Width := 1;
              if not no_links then
                if ( v2 > v1 ) then
                  garc(u1,v1,u2,v2,col)
                else
                  garc_courbe(u1,v1,u2,v2,col);
              y := cdr;
              with paintbox1.Canvas do Pen.Width := 1;
            end;
        end;
      for x := 1 to nb_sommets do gsommet(g,x);
    end;
  if bord then axe_y(ymin,ymax);
end;


procedure tform_graph.ggraphe_eccen(g : integer);
var x,y,col,nb_e,i,j,emin,emax : integer;
    e,ee,de,u1,v1,u2,v2,a,rho,coeff : extended;
    tab : rvec_type;
begin
  g_sav := g;
  grafgraf := graf_graphe_eccen;
  with graphes[g] do
    begin
      for x := 1 to nb_sommets do tab[x] := ggg[x].ecc;
      tri_r_plus(nb_sommets,tab,h_x);
      emax := ggg[h_x[nb_sommets]].ecc;
      emin := ggg[h_x[1]].ecc;
      ee := emax - emin;
      if ( ee = 0.0 ) then ee := 1.0;
      nb_e := 0;
      for x := 1 to nb_sommets do
        if ( ggg[h_x[x]].ecc = emin ) then
          nb_e := nb_e + 1; { nombre de sommets dans le centre }
      if ( nb_e <> 0 ) then
        if ( ee = 1.0 ) then
          rho := 1.0
        else
          rho  := 5.0*dd*(nb_e - 1)
      else
        rho := 0.0;
      de := ee/(nb_niv-1);
      for i := 1 to nb_sommets do tab_niv[i] := 0;
      for x := 1 to nb_sommets do
        begin
          y := h_x[x];
          e := ggg[y].ecc;
          tab_u[y] := (e - emin)/ee;
          i := trunc((e - emin)/de) + 1;
          tab_niv[i] := tab_niv[i] + 1;
        end;
      x := 0;
      for i := 1 to nb_niv do
        for j := 1 to tab_niv[i] do
          begin
            x := x + 1;
            if ( x <= nb_sommets ) then
              begin
                y := h_x[x];
                tab_v[y] := dpi*(j - 0.5)/tab_niv[i];
              end;
          end;
      coeff := 0.5/(1.0 + rho);
      for x := 1 to nb_sommets do
        begin
          u1 := 0.5 + coeff*(rho + tab_u[x])*cos(tab_v[x]);
          v1 := 0.5 + coeff*(rho + tab_u[x])*sin(tab_v[x]);
          tab_u[x] := u1;
          tab_v[x] := v1;
        end;
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          y := succ;
          while ( y <> 0 ) do with lis[y] do
            begin
              u1 := tab_u[x];
              v1 := tab_v[x];
              u2 := tab_u[car];
              v2 := tab_v[car];
              a := abs((0.5*ggg[car].ecc - 0.8*ecc)/ee);
              if ( a > 1.0 ) then a := 1.0;
              col := col_arc(g,x,car,a,val);
              if ( ival <> 0 ) then
                with paintbox1.Canvas do
                  if not thin_links then
                    Pen.Width := trunc(10.0*abs(val/valmax)) + 1
                  else
                    Pen.Width := 1;
              if not no_links then
                if ( ggg[car].ecc <= ecc ) then
                  garc(u1,v1,u2,v2,col)
                else
                  garc_courbe(u1,v1,u2,v2,col);
              y := cdr;
            end;
          with paintbox1.Canvas do Pen.Width := 1;
        end;
      for x := 1 to nb_sommets do gsommet(g,x);
    end;
end;

procedure tform_graph.ggraphe_cercle(g : integer);
var x,y,col : integer;
    u1,u2,v1,v2,a,degmax : extended;
begin
  g_sav := g;
  grafgraf := graf_graphe_cercle;
  with graphes[g] do
    begin
      for x := 1 to nb_sommets do
        begin
          tab_u[x] := 0.5 + 0.5*cos(dpi*(x-1)/nb_sommets);
          tab_v[x] := 0.5 + 0.5*sin(dpi*(x-1)/nb_sommets);
        end;
      degmax := 0.0;
      for x := 1 to nb_sommets do with ggg[x] do degmax := max(degmax,deg);
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          y := succ;
          while ( y <> 0 ) do with lis[y] do
            begin
              u1 := tab_u[x];
              v1 := tab_v[x];
              u2 := tab_u[car];
              v2 := tab_v[car];
              if ( degmax > 0.0 ) then a := deg/degmax else a := 0.0;
              col := col_arc(g,x,car,a,val);
              if ( ival <> 0 ) then
                with paintbox1.Canvas do
                  if not thin_links then
                    Pen.Width := trunc(10.0*abs(val/valmax)) + 1
                  else
                    Pen.Width := 1;
              if not no_links then garc(u1,v1,u2,v2,col);
              y := cdr;
            end;
          with paintbox1.Canvas do Pen.Width := 1;
        end;
      for x := 1 to nb_sommets do gsommet(g,x);
    end;
end;

{ representation des couleurs : }
(*procedure tform_graph.ggraphe_matrix(g : integer);
var i,j,k,col,n : integer;
    u1,v1,u2,v2,du,dv : extended;
begin
  g_sav := g;
  grafgraf := graf_graphe_matrix;
  n := 16;
  du := 1.0/n;
  dv := 1.0/n;
  u1 := 0.0;
  u2 := u1 + du;
  v1 := 0.0;
  v2 := v1 + dv;
  k := 0;
  for i := 1 to n do
    begin
      for j := 1 to n do
        begin
          col := arc_en_ciel[k];
          if greyscale then col := gris_en_ciel[k];
          rectfull(u1,v1,u2,v2,col);
          col := clWhite;
          ligne(u1,0.0,u1,1.0,col);
          ligne(0.0,v1,1.0,v1,col);
          if ( u1 < 1.0-du ) then
            u1 := u2
          else
            u1 := 0.0;
          u2 := u1 + du;
          k := k + 1;
        end;
      v1 := v2;
      v2 := v1 + dv;
    end;
  rectangle(0.0,0.0,1.0,1.0,col);
end;*)

procedure tform_graph.ggraphe_matrix(g : integer);
var x,y,col : integer;
    u1,v1,u2,v2,delta,a,pol,orien : extended;
begin
  g_sav := g;
  grafgraf := graf_graphe_matrix;
  with graphes[g] do
    begin
      orien := 0.0;
      graphe2mat(g);
      delta := 1.0/nb_sommets;
      for y := 1 to nb_sommets do
        begin
          u1 := (y-1)*delta;
          u2 := u1 + delta;
          for x := 1 to nb_sommets do
            begin
              v1 := 1.0 - (x-1)*delta;
              v2 := v1 - delta;
              if ( m_[x,y] > 0 ) then
                begin
                  a := ggg[x].deg/(2.0*nb_sommets);
                  col := col_arc(g,x,y,a,mr_[x,y]);
                  rectfull(u1,v1,u2,v2,col);
                end;
              if ( nb_sommets <= 60 ) then
                begin
                  col := clBlack;
                  if white_on_black then col := clWhite;
                  ligne(u1,0.0,u1,1.0,col);
                  ligne(0.0,v1,1.0,v1,col);
                  if ( label_graphe <> label_no ) then
                    begin
                      pol := min(1.0,30/nb_sommets);
                      col := clWhite;
                      if black_on_white or greyscale then col := clBlack;
                      texte(u1 + 0.5*delta,1.0 + 4*dd,IntToStr(y),orien,pol,col);
                      texte(-6*dd,v1 - 0.25*delta,IntToStr(x),orien,pol,col);
                    end;
                end;
            end;
          col := clBlack;
          if white_on_black then col := clWhite;
          rectangle(0.0,0.0,1.0,1.0,col);
        end;
    end;
end;

procedure tform_graph.ggraphe(g : integer);
begin
  efface(nil);
  status_x('NetWork');
  status_graphe(g);
  status_groups(g);
  case repr_graphe of
    graf_graphe_haut   : begin
                           if haut_val then
                             status_repr('Weighted height')
                           else
                             status_repr('Height');;
                           ggraphe_haut(g);
                         end;
    graf_graphe_trolev : begin
                           if haut_val then
                             status_repr('Weighted trolev')
                           else
                             status_repr('Trophic level');
                           ggraphe_trolev(g);
                         end;
    graf_graphe_eccen  : begin
                           status_repr('Eccentricity');
                           ggraphe_eccen(g);
                         end;
    graf_graphe_cercle : begin
                           status_repr('Circle');
                           ggraphe_cercle(g);
                         end;
    graf_graphe_matrix : begin
                           status_repr('Matrix');
                           ggraphe_matrix(g);
                         end;
    else;
  end;
end;

procedure tform_graph.repaint1(Sender: TObject);
begin
  with paintbox1 do init_marges;
  efface(nil);
  case grafgraf of
    graf_efface        :;
    graf_distrib       : gdistrib(nb_steps_sav,icol_sav,moy_sav,sigma_sav);
    graf_graphe_haut,
    graf_graphe_trolev,
    graf_graphe_eccen,
    graf_graphe_cercle,
    graf_graphe_matrix : ggraphe(g_sav);
    else;
  end;
end;

procedure tform_graph.fileexitExecute(Sender: TObject);
begin
  nb_form_graph := nb_form_graph - 1;
  Visible := false;
end;

procedure tform_graph.graphsetExecute(Sender: TObject);
begin
  with form_graphset do
    begin
      fg := Self;
      Show;
    end;
end;

procedure tform_graph.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  fileexitExecute(nil);
end;

procedure tform_graph.file_saveExecute(Sender: TObject);
label 1;
var r1,r2 : TRect;
    bm : TBitmap;
    w1,h1 : integer;
begin
  bm := TBitmap.Create;
  try
    with paintbox1 do
      begin
        w1 := ClientWidth;
        h1 := ClientHeight;
        r1 := Rect(Left,Top,ClientWidth+Left,ClientHeight+Top);
      end;
    r2 := Rect(0,0,w1,h1);
    bm.Width  := w1;
    bm.Height := h1;
    bm.Canvas.CopyRect(r2,paintbox1.Canvas,r1);
    with savedialog1 do
        begin
          FileName := statusbar1.Panels[0].Text + statusbar1.Panels[1].Text + '.bmp';
          Filter := 'Bitmap file (*.bmp)|All files(*)';
          DefaultExt := '.bmp';
          InitialDir := ExtractFilePath(FileName);
          if Execute then
            if FileExists(FileName) then
              if MessageDlg('Overwrite file ' + ExtractFileName(FileName) + '?',
                 mtConfirmation,[mbYes,mbNo],0) <> mrYes then goto 1;
          bm.SaveToFile(FileName);
        end;
1:
  finally
    bm.Free;
  end;
end;

procedure tform_graph.graph_clear_buttonClick(Sender: TObject);
begin
  grafgraf := graf_efface;
  efface(nil);
end;

procedure tform_graph.StatusBar1PanelClick(Sender: TObject;panel: TStatusPanel);
begin
  case panel.Index of
    2 : begin { switch network - distribution VOIR }
          {case repr_graphe of
            graf_distrib : gdistrib(nb_steps_sav,icol_sav);
            else ggraphe(g_sav);
          end;}
        end;
    3 : begin { switch representation network }
          case repr_graphe of
            graf_graphe_haut   : repr_graphe := graf_graphe_trolev;
            graf_graphe_trolev : repr_graphe := graf_graphe_eccen;
            graf_graphe_eccen  : repr_graphe := graf_graphe_cercle;
            graf_graphe_cercle : repr_graphe := graf_graphe_matrix;
            graf_graphe_matrix : repr_graphe := graf_graphe_haut;
            else;
          end;
          if ( g_sav > 0 ) then ggraphe(g_sav) else ggraphe(g_select);
        end;
    4 : begin { switch representation distrib }
          if ( repr_graphe = graf_distrib ) then
            begin
              distrib0 := not distrib0;
              status_distrib;
              gdistrib(nb_steps_sav,icol_sav,moy_sav,sigma_sav);
            end;
        end;
    5 : begin { switch representation groups }
          case group_graphe of
            graf_group_no  : ;
            graf_group_mod : group_graphe := graf_group_aic;
            graf_group_aic : group_graphe := graf_group_tro;
            graf_group_tro : group_graphe := graf_group_mod;
            else;
          end;
          if ( g_sav > 0 ) then ggraphe(g_sav) else ggraphe(g_select);
        end;
    else;
  end;
end;

end.
