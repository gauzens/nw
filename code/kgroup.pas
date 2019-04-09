unit kgroup;

interface

uses kglobvar;
///array ggg is the array of species in the graph
type group_type = record
        sommets : ivec_type;//vector of integer
        nb_som : integer;
        inlinks : integer;  //liens internes //links within a groups
        outlinks : integer;   //liens externes //links from a group to other groups
        out_degree : integer;  //somme des degres sortant des sp
        in_degree : integer;
        ener : extended;  //energie associee au groupe // energy of the group
     end;

type groups = array[1..vecmax] of group_type; //vector of groups

var
  ti,tf,ts,eps : extended;
  mg_: imat_type; // binary adjacency matrix
  mgr_: rmat_type;//valuated adjacency matrix
  nb_groups : integer;
  group : groups;
  ggg_gpe: ivec_type; 
  length_ggg : integer;
  // recopie l'info tout a la fin dans group_tro, group_aic
  //ou group_mod selon type de clustering

procedure init_groupe;
procedure init_mat_groupe;
procedure add_gp;
procedure reactualise_gpes;
function  pos_gpe(sp,gp : integer): integer; // index of a species in the group array
procedure add_spgp(sp,gp : integer);  // add a species to a group
procedure delete_gp(gp : integer);
procedure delete_spgp(sp,gp : integer); //delete a species from a group
procedure deplace_sp(pos,orig,ariv : integer);
procedure recopie_gpes(g,tgroup : integer); //copy groups
function  graphe_groupe(g,tclust : integer) : integer; //create the network of the groups

implementation

uses SysUtils,kutil,kgestiong,kcalculg;

procedure init_groupe;
begin
  ti  := 0.9995;
  tf  := 1.0e-13;
  ts  := 0.95;
  eps := 1.0e-10;
end;

procedure init_mat_groupe;
var i,j : integer;
begin
for i := 1 to nb_groups do
  for j := 1 to nb_groups do
    begin
      mgr_[i,j] := 0.0; //valuated adjacency matrix
      mg_[i,j] := 0;  // binary adjacency matrix
    end;
end;

procedure add_gp;
var i : integer;
begin
  nb_groups := nb_groups + 1;  //tester si nbg < nb_sommets
  with group[nb_groups] do
    begin
      nb_som := 0;
      inlinks := 0;
      outlinks := 0;
      out_degree := 0;
      in_degree := 0;
      ener := 0.0;
    end;
end;

procedure reactualise_gpes; //remet a jour les groupes des sp de ggg
var i,j : integer;
begin
for i := 1 to nb_groups do with group[i] do
  for j := 1 to nb_som do
    ggg_gpe[sommets[j]] := i;
end;

function pos_gpe(sp,gp : integer) : integer;
//trouve la position de l'espece sp dans le groupe gp
var i : integer;
begin
  with group[gp] do
    for i := 1 to nb_som do
      if ( sommets[i] = sp ) then
        begin
          pos_gpe := i;
          exit;
        end;
  iwriteln('POS !!!!');
  pos_gpe := -1;  //fait pour générer une erreur
end;

procedure add_spgp(sp,gp : integer);
//ajoute sp du tableau ggg dans un groupe gp
begin
  with group[gp] do
    begin
      ggg_gpe[sp] := gp;
      nb_som := nb_som + 1;
      sommets[nb_som] := sp;
    end;
end;

procedure delete_gp(gp : integer); // ! si groupe non vide !!!
var i : integer;                  // pas ce cas de figure normalement
begin
  group[gp] := group[nb_groups];
  for i := 1 to length_ggg do
    if ( ggg_gpe[i] = nb_groups ) then
      ggg_gpe[i] := gp;
  nb_groups := nb_groups - 1;
end;

procedure delete_spgp(sp,gp : integer);
// supprime l'espece sp du groupe gp
// attention, ne supprime pas le groupe si on supprime la derniere espece
begin
  with group[gp] do
    begin
      ggg_gpe[sommets[sp]] := 0;
      sommets[sp] := sommets[nb_som];
      nb_som := nb_som - 1;
      if ( nb_som = 0 ) then ener := 0.0;
    end;
end;

procedure deplace_sp(pos,orig,ariv : integer);
// deplace group[orig].sommets[pos] dans ariv
var x : integer;
begin
  x := group[orig].sommets[pos];
  add_spgp(x,ariv);
  delete_spgp(pos,orig);
  ggg_gpe[x] := ariv;
end;

procedure recopie_gpes(g,tgroup : integer);
var i : integer;
begin
  with graphes[g] do
    case tgroup of
      type_group_mod :
        begin
          nb_group_mod := nb_groups;
          for i := 1 to nb_sommets do ggg[i].group_mod := ggg_gpe[i];
        end;
      type_group_aic :
        begin
          nb_group_aic := nb_groups;
          for i := 1 to nb_sommets do ggg[i].group_aic := ggg_gpe[i];
        end;
      type_group_tro :
        begin
          nb_group_tro := nb_groups;
          for i := 1 to nb_sommets do ggg[i].group_tro := ggg_gpe[i];
        end;
      type_group_agg :
        begin
          nb_group_agg := nb_groups;
          for i := 1 to nb_sommets do ggg[i].group_agg := ggg_gpe[i];
        end;
    end;
end;

function  graphe_groupe(g,tclust : integer) : integer;
var g1,i,j,typgra : integer;
    s : string;
begin
  s := '#' + IntToStr(graphes[g].icre);
  case tclust of
    type_group_mod :
      begin
        s := s + '_mod';
        typgra := type_gra_groupmod;
      end;
    type_group_aic :
      begin
        s := s + '_aic';
        typgra := type_gra_groupmod;
      end;
    type_group_tro :
      begin
        s := s + '_tro';
        typgra := type_gra_groupmod;
      end;
  end;
  g1 := alloc_graphe(g,nb_groups,s,typgra);
  if err_gestion then
    begin
      err_gestion := false;
      graphe_groupe := 0;
      exit;
    end;
  for i := 1 to nb_groups do
    for j := 1 to nb_groups do
      if mgr_[i,j] > 0.0 then
        begin
          m_[i,j] := 1;
          mr_[i,j] := mgr_[i,j];
        end
      else
        begin
          m_[i,j] := 0;
          mr_[i,j] := 0.0;
        end;
  init_graphe(g1);
  if err_gestion then
    begin
      err_gestion := false;
      dealloc_graphe;
      graphe_groupe := 0;
      exit;
    end;
  for i := 1 to nb_groups do graphes[g1].ggg[i].nom := IntToStr(i);
  calcul_graphe(g1); //compute metrics on the graph
  graphe_groupe := create_graphe(g1); //create the new graph
end;

end.
