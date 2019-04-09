unit kgestiong;

{ @@@@@@  gestion des graphes  @@@@@@ }

interface

uses kglobvar;

procedure init_gestion;
procedure zeromat;
function  alloc_graphe(g,n : integer; nam : string; tg : integer) : integer;
procedure dealloc_graphe;
function  create_graphe(g : integer) : integer;
procedure delete_graphe(g : integer);
procedure init_graphe(g : integer);
function  trouve_graphe(ic : integer) : integer;
function  trouve_nom_graphe(s : string) : integer;
function  trouve_nom_sommet(g : integer;s : string) : integer;
procedure graphe2mat(g : integer);
procedure initq;
procedure pushq(x : integer);
function  popq : integer;
function  videq : boolean;

var   err_gestion : boolean;

implementation

uses  SysUtils,kmath,klist,kutil,ksyntax,f_nw;

var   nb_cre : integer;  { nombre total de graphes crees }
      qu : ivec_type;    { queue fifo }
      sp1,sp2 : integer; { pointeurs queue }

procedure erreur_gestion(s : string);
begin
  erreur_('Network - ' + s);
  err_gestion := true;
end;

procedure zeromat;
var x,y : integer;
begin
  for x := 1 to vecmax do
    for y := 1 to vecmax do
      begin
        m_[x,y]  := 0;
        mr_[x,y] := 0.0;
      end;
end;

procedure init_gestion;
begin
  nb_graphes := 0;
  nb_cre := 0;
  err_gestion := false;
end;

function  alloc_graphe(g,n : integer; nam : string; tg : integer) : integer;
{ allocation dans le tableau graphes en vue de la creation d'un graphe a n sommets }
{ si g = 0 il s'agit d'un graphe lu dans un fichier, ou cree, par ex aleatoire }
{ si g <> 0 il s'agit d'un graphe cree ou modifie a partir de g, }
{ par ex sous-graphe aleatoire de g, delete cycles... }
begin
  if ( nb_graphes = graphemax ) then
    begin
      erreur_gestion('Too many networks (max ' + IntToStr(graphemax) + ')');
      alloc_graphe := 0;
      exit;
    end;
  nb_graphes := nb_graphes + 1;
  with graphes[nb_graphes] do
    begin
      nb_sommets := n;
      name  := nam;
      typ   := tg;
      simul := 0;
      ival  := 0;
      param_p := 1.0;
      param_deg := 0;
      param_nb_niv := 0;
      if edit_mode then
        icre := graphes[g].icre { cas edit_mode }
      else
        icre := nb_cre + 1; { ne sera valide qu'a la creation }
      i_pere := icre;
      time_out := false;
      root := trouve_nom_graphe('_Root_'); { voir !!! }
      SetLength(ggg,nb_sommets+1); { entree 0 pas utilisee }
      if ( g <> 0 ) then
        begin
          nb_arcs := graphes[g].nb_arcs; { ne sert que pour gra_unif voir }
          i_pere := graphes[g].icre;
          param_p := graphes[g].param_p;  { voir l'utilite }
          param_deg := graphes[g].param_deg;
          param_nb_niv := graphes[g].param_nb_niv;
        end;
    end;
  alloc_graphe := nb_graphes;
end;

procedure dealloc_graphe;
begin
  nb_graphes := nb_graphes - 1;
end;

function  create_graphe(g : integer) : integer;
var s : string;
begin
  nb_cre := nb_cre + 1;
  with graphes[g] do
    begin
      icre := nb_cre;
      s := 'Create #' + IntToStr(icre);
      if ( i_pere <> icre ) then s := s + ' from #' + IntToStr(i_pere);
      iwriteln(s);
    end;
  create_graphe := g;
end;

procedure delete_graphe(g : integer);
var i : integer;
begin
  dealloc_graphe;
  for i := g to nb_graphes do graphes[i] := graphes[i+1];
end;

function  trouve_graphe(ic : integer) : integer;
var g : integer;
begin
  for g := 1 to nb_graphes do with graphes[g] do
    if ( ic = icre ) then
      begin
        trouve_graphe := g;
        exit
      end;
  trouve_graphe := 0;
end;

function  trouve_nom_graphe(s : string) : integer;
var g : integer;
begin
  for g := 1 to nb_graphes do with graphes[g] do
    if ( name = s ) then
      begin
        trouve_nom_graphe := g;
        exit
      end;
  trouve_nom_graphe := 0;
end;

function  trouve_nom_sommet(g : integer;s : string) : integer;
var x : integer;
begin
  with graphes[g] do
    begin
      for x := 1 to nb_sommets do with ggg[x] do
        if ( minuscule(s) = minuscule(nom) ) then
          begin
            trouve_nom_sommet := x;
            exit
          end;
      trouve_nom_sommet := 0;
    end;
end;

procedure graphe2mat(g : integer);
var x,y : integer;
begin
  with graphes[g] do
    begin
      for x := 1 to nb_sommets do
        for y := 1 to nb_sommets do
          begin
            m_[x,y]  := 0;
            mr_[x,y] := 0.0;
          end;
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          y := succ;
          while ( y <> 0 ) do with lis[y] do
            begin
              m_[x,car]  := 1;
              mr_[x,car] := val;
              y := cdr;
            end;
        end;
    end;
end;

procedure init_graphe(g : integer);
{ a partir de la matrice m_ }
var x,y : integer;
begin
  with graphes[g] do
    begin
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          succ := 0;
          for y := nb_sommets downto 1 do
            if ( m_[x,y] = 1 ) then
              begin
                succ := cons(y,type_som,mr_[x,y],succ);
                if ( mr_[x,y] <> 1.0 ) then ival := 1;
                if err_lis then
                  begin
                    iwriteln('pb init lis1');
                    err_lis := false;
                    err_gestion := true;
                    exit;
                  end;
              end;
          pred := 0;
          for y := nb_sommets downto 1 do
            if ( m_[y,x] = 1 ) then
              begin
                pred := cons(y,type_som,mr_[y,x],pred);
                if err_lis then
                  begin
                    iwriteln('pb init lis2');
                    err_lis := false;
                    err_gestion := true;
                    exit;
                  end;
              end;
        end;
    end;
end;

{ ------ pile ------ }

procedure initq;
begin
  sp1 := 0;
  sp2 := 0;
end;

procedure pushq(x : integer);
begin
  sp2 := sp2 + 1;
  if ( sp2 > vecmax ) then sp2 := 1;
  qu[sp2] := x;
end;

function  popq : integer;
begin
  sp1 := sp1 + 1;
  if ( sp1 > vecmax ) then sp1 := 1;
  popq := qu[sp1];
end;

function  videq : boolean;
begin
  videq := sp1 = sp2;
end;

end.
