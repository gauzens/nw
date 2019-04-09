unit klump;

interface

uses kglobvar;

var  nb_bio,nb_choix : integer;
     info_bio : array[1..infomax] of integer;

function  hier_clust(g,methode,nb : integer) : integer;
function  from_file(g : integer; nomf : string) : integer;

implementation

uses Classes,SysUtils,kmath,kmanipg,kgestiong,kcalculg,
     kutil,ksyntax,kgroup,f_lump;

var  m_sim,m_dist : rmat_type;
     tab_nam : svec_type;

procedure dist_tro_sim(g : integer);
var i,j,k : integer;
    sim,a : extended;
begin
  with graphes[g] do
    begin
      for i := 1 to nb_sommets do
        for j := 1 to nb_sommets do
          begin
            sim := 0.0;
            for k := 1 to nb_sommets do
              begin
                if ((m_[k,j] = 1) and (m_[k,i] = 1)) then sim := sim + 1.0;
                if ((m_[j,k] = 1) and (m_[i,k] = 1)) then sim := sim + 1.0;
              end;
            a := ggg[i].nb_succ + ggg[i].nb_pred +
                 ggg[j].nb_succ + ggg[j].nb_pred - sim;
            if a = 0.0 then
              sim := 0.0
            else
              sim := sim/a;
            m_sim[i,j] := sim;
          end;
    end;
end;

procedure eucl_dist(g : integer);
var i,j,k : integer;
    a : extended;
begin
  with graphes[g] do
    for i := 1 to nb_sommets do
      for j := 1 to nb_sommets do
        begin
          a := 0.0;
          for k := 1 to nb_choix do
            a := a + sqr(ggg[i].info[info_bio[k]] - ggg[j].info[info_bio[k]]);
          m_dist[i,j] := sqrt(a);
        end;
end;

procedure regroupe(n,a,b : integer);
{ on regroupe tout dans a et on supprime b }
{ dans les matrices d'adjacence nxn }
var i,j : integer;
begin
  for j := 1 to n do   //uniformisation des liens trophiques binaires
    begin
      if ((m_[a,j] = 1) or (m_[b,j] = 1)) then m_[a,j] := 1;
      if ((m_[j,a] = 1) or (m_[j,b] = 1)) then m_[j,a] := 1;
    end;
  for j := 1 to n do mr_[a,j] := mr_[a,j] + mr_[b,j];
  for j := 1 to n do mr_[j,a] := mr_[j,a] + mr_[j,b];
  for i := 1 to n do
    for j := 1 to n do
      if m_[i,j] = 0 then mr_[i,j] := 0; { ? }
  { supprime ligne et colonne correspondant a b : }
  for i := b to n-1 do
    for j := 1 to n do
      begin
        m_[i,j]  := m_[i+1,j];
        mr_[i,j] := mr_[i+1,j];
      end;
  for i := 1 to n-1 do
    for j := b to n-1 do
      begin
        m_[i,j]  := m_[i,j+1];
        mr_[i,j] := mr_[i,j+1];
      end;
end;

procedure get_max(g : integer;var a,b : integer);
var i,j : integer;
    max : extended;
begin
  max := 0.0;
  for i := 1 to graphes[g].nb_sommets do
    for j := 1 to graphes[g].nb_sommets do
      if ((m_sim[i,j] >= max) and (i <> j)) then
        begin
          max := m_sim[i,j];
          a := i;
          b := j;
        end;
  iwriteln('Max = ' + s_ecri_val(max));
end;

procedure get_min(g : integer;var a,b : integer);
var i,j : integer;
    min : extended;
begin
  min := maxextended;
  for i := 1 to graphes[g].nb_sommets do
    for j := 1 to graphes[g].nb_sommets do
      if ((m_dist[i,j] <= min) and (i <> j)) then
        begin
          min := m_dist[i,j];
          a := i;
          b := j;
        end;
  iwriteln('Min = ' + s_ecri_val(min));
end;

procedure maj_mat_gp(g: integer);
var x,y,k,j : integer;
begin
  with graphes[g] do
    begin
      init_mat_groupe;
      for k := 1 to nb_groups do with group[k] do
        for j := 1 to nb_som do //sp j du groupe k
          begin
            x := sommets[j]; //x: pos ds ggg de la j sp du gpe k
            y := ggg[x].succ;
            while ( y <> 0 ) do with lis[y] do
              begin
                 mgr_[k,ggg_gpe[car]] := mgr_[k,ggg_gpe[car]] + 1;
                 //non necessaire ici
                 y := cdr;
              end;
          end;
    end;
end;

function  graphe_groupe(g: integer) : integer;
var g1,i,j: integer;
    s : string;
begin
  s := '#' + IntToStr(graphes[g].icre) + '_Agg_file';
  g1 := alloc_graphe(g,nb_groups,s,type_gra_aggreg);
  if err_gestion then
    begin
      err_gestion := false;
      graphe_groupe := 0;
      exit;
    end;
  for i := 1 to nb_groups do
    for j := 1 to nb_groups do
        begin
          m_[i,j]  := 0;
          mr_[i,j] := 0.0;
        end;
  for i := 1 to nb_groups do
    for j := 1 to nb_groups do
      if mgr_[i,j] > 0.0 then
        begin
          m_[i,j]  := 1;
          mr_[i,j] := mgr_[i,j];
        end;
  init_graphe(g1);
  if err_gestion then
    begin
      err_gestion := false;
      dealloc_graphe;
      graphe_groupe := 0;
      exit;
    end;
  for i := 1 to nb_groups do graphes[g1].ggg[i].nom := tab_nam[i];
  calcul_graphe(g1);
  graphe_groupe := create_graphe(g1);
end;

function  from_file(g: integer; nomf: string) : integer;
var x,c,nb_fromfile : integer;
    lines_lump : TStringList;
    nomf1 : string;
begin
  nomf1 := ExtractFileName(nomf);
  nb_groups := 0;
  nb_fromfile := 0;
  lines_lump := TStringList.Create;
  lines_lump.LoadFromFile(nomf);
  iwriteln('Open file ' + nomf); 
  for c := 0 to lines_lump.Count-1 do
    begin
      separe(lines_lump[c],hortab);
      if lines_separe[1] <> '>' then
        begin
          add_gp;
          tab_nam[nb_groups] := lines_lump[c]; { nom du groupe aggrege }
        end
      else
        begin
          x := trouve_nom_sommet(g,lines_separe[2]);
          if x <> 0 then
            begin
              add_spgp(x,nb_groups);
              nb_fromfile := nb_fromfile + 1;
            end
          else
            begin
              {erreur_('Unknown species ' + lines_separe[2] + ' in file ' + nomf1);
              from_file := 0;
              exit;}
              iwriteln('Unknown species ' + lines_separe[2] + ' in file ' + nomf1);
            end;
        end;
    end;
  c := graphes[g].nb_sommets - nb_fromfile;
  if ( c > 0 ) then
    begin
      {erreur_(IntToStr(c) + ' species missing in file ' + nomf1);
      from_file := 0;
      exit;}
      iwriteln(IntToStr(c) + ' species missing in file ' + nomf1);
    end;
  if ( c < 0 ) then
    begin
      {erreur_(IntToStr(-c) + ' species in excess in file ' + nomf1);
      from_file := 0;
      exit;}
      iwriteln(IntToStr(-c) + ' species in excess in file ' + nomf1);
    end;
  maj_mat_gp(g);
  recopie_gpes(g,type_group_agg);
  from_file := graphe_groupe(g);
end;

function  hier_clust(g,methode,nb : integer) : integer;
var i,j,n,x,y,fin,a,a_sav,b,gtemp,g1 : integer;
    s : string;
begin
  if nb = 0 then fin := 2 else fin := nb + 1;
  g1 := g;
  n := graphes[g].nb_sommets;
  for i := n downto fin do
    begin
      gtemp := g1;
      graphe2mat(gtemp);
      case methode of
      tro_sim : begin
                  dist_tro_sim(gtemp);
                  get_max(gtemp,a,b);
                  s := '_tsim';
                 end;
      biologic: begin
                  eucl_dist(gtemp);
                  get_min(gtemp,a,b);
                  s := '_biol';
                end;
      random :  begin
                  a := trunc(rand(graphes[gtemp].nb_sommets)+1);
                  repeat
                    b := trunc(rand(graphes[gtemp].nb_sommets)+1);
                  until b <> a;
                  s := '_rand';
                end;
      end;
      with graphes[gtemp] do
        begin
          regroupe(nb_sommets,a,b);
          s := '#' + IntToStr(graphes[g].icre) + '_Agg' + s;
          g1 := alloc_graphe(gtemp,nb_sommets-1,s,type_gra_aggreg);
        end;
      if err_gestion then
        begin
          err_gestion := false;
          hier_clust := 0;
          exit;
        end;
      init_graphe(g1);
      if err_gestion then
        begin
          err_gestion := false;
          dealloc_graphe;
          hier_clust := 0;
          exit;
        end;
      with graphes[g1] do
        begin
          a_sav := a;
          if ( a > b ) then a := a - 1;
          nb_infos := graphes[gtemp].nb_infos;
          for j := 1 to nb_infos do name_info[j] := graphes[gtemp].name_info[j];
          for x := 1 to nb_sommets do
            begin
              if ( x < b ) then y := x else y := x + 1;
              ggg[x].nom := graphes[gtemp].ggg[y].nom;
              for j := 1 to nb_infos do
                ggg[x].info[j] := graphes[gtemp].ggg[y].info[j];
            end;
          ggg[a].nom := graphes[gtemp].ggg[a_sav].nom + '.' + graphes[gtemp].ggg[b].nom;
          for j := 1 to nb_infos do
            ggg[a].info[j] := (graphes[gtemp].ggg[a_sav].info[j] + graphes[gtemp].ggg[b].info[j])/2.0;
          time_out := graphes[gtemp].time_out; { car si gtemp a des cycles, g1 aussi }
        end;
      calcul_graphe_aggreg(g1);
      g1 := create_graphe(g1);
    end;
  hier_clust := g1;
end;

end.
