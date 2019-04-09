unit kmanipg;

interface

uses kglobvar,kmath;

function  void_graphe(n : integer) : integer;
function  delete_boucles_graphe(g : integer) : integer;
function  delete_cycles_graphe(g : integer) : integer;
function  comp_conn_graphe(g : integer) : integer;
function  reverse_graphe(g : integer) : integer;
function  addroot_graphe(g : integer) : integer;
function  addroot_graphe_temp(g : integer) : integer;
function  markov_graphe_temp(g : integer; mp : rmatmat_type) : integer;
//function  delroot_graphe(g : integer) : integer;
function  reindex_graphe(g : integer;o : ivec_type) : integer;
function  som_graphe(g1,g2 : integer) : integer;
function  dup_graphe(g : integer): integer;
function  dual_graphe(g : integer): integer;
function  reverse_sommet_graphe(g,x : integer) : integer;
function  create_sommet_graphe(g : integer) : integer;
function  dup_sommet_graphe(g,x : integer) : integer;
function  delete_sommet_graphe(g,x : integer) : integer;
function  nettoyage(g : integer) : integer;
function  reverse_arc_graphe(g,x,y : integer) : integer;
function  modif_arc_mat_graphe(g,x,y : integer;a : extended) : integer;

implementation

uses  SysUtils,kutil,ksyntax,kgestiong,kcalculg,ksimulg;

function  void_graphe(n : integer) : integer;
{ graphe sans arcs a n sommets }
var x,y,g : integer;
begin
  g := alloc_graphe(0,n,'Void',type_gra_void);
  if err_gestion then
    begin
      err_gestion := false;
      void_graphe := 0;
      exit;
    end;
  for x := 1 to n do
    for y := 1 to n do
      begin
        m_[x,y]  := 0;
        mr_[x,y] := 0.0;
      end;
  init_graphe(g);
  if err_gestion then
    begin
      err_gestion := false;
      dealloc_graphe;
      void_graphe := 0;
      exit;
    end;
  with graphes[g] do
    for x := 1 to nb_sommets do ggg[x].nom := 'v' + IntToStr(x);
  calcul_graphe(g);
  void_graphe := create_graphe(g);
end;

function  dup_graphe(g : integer): integer;
{ creation d'une copie du graphe g }
var g1,x : integer;
begin
  with graphes[g] do
    g1 := alloc_graphe(g,nb_sommets,name,typ);
  if err_gestion then
    begin
      err_gestion := false;
      dup_graphe := 0;
      exit;
    end;
  graphe2mat(g);
  with graphes[g1] do
    for x := 1 to nb_sommets do ggg[x].nom := graphes[g].ggg[x].nom;
  reset_graine;
  init_graphe(g1);
  if err_gestion then
    begin
      err_gestion := false;
      dealloc_graphe;
      dup_graphe := 0;
      exit;
    end;
  calcul_graphe(g1);
  dup_graphe := create_graphe(g1);
end;

(*procedure  entropy_gentime(n : integer; mat : rmat_type);
var i,j,k,l,a,b,nq : integer;
    lambda1,hi,tbi,h : extended;
    w,vp,vq : rvec_type;
begin
  matvalvecd1(n,mat,w,lambda1);
  if ( lambda1 <= 0.0 ) then
    begin
      iwriteln('Entropy: lambda  <= 0 ');
      exit;
    end;
  for i := 1 to n do
    if ( w[i] = 0.0 ) then
      begin
        iwriteln('Entropy: reducible matrix');
        exit;
      end;
  for i := 1 to n do
    for j := 1 to n do
      mp[i,j] := mat[i,j]*w[j]/(lambda1*w[i]);
  matkovvecg(n,mp,vp);
  h := 0.0;
  for i := 1 to n do
    begin
      hi := 0.0;
      for j := 1 to n do hi := hi + mp[i,j]*ln0(mp[i,j]);
      h := h + vp[i]*hi;
    end;
  h := -h;
  { temps moyen de premier retour sur les arcs reproducteurs }
  { on calcule une matrice de Markov sur les arcs a = i->j du graphe d'origine }
  a := 0;
  nq := 0;
  for i := 1 to n do
    for j := 1 to n do
      if ( mp[i,j] > 0.0 ) then
        begin
          a := a + 1;
          nq := nq + 1;
          b := 0;
          for k := 1 to n do
            for l := 1 to n do
              if ( mp[k,l] > 0.0 ) then
                begin
                  b := b + 1;
                  if ( j = k ) then
                    mq[a,b] := mp[j,l]
                  else
                    mq[a,b] := 0.0;
                end;
        end;
  matkovvecg(nq,mq,vq);
  a := 0;
  for i := 1 to n do
    for j := 1 to n do
      if ( mp[i,j] > 0.0 ) then  { arc j -> i }
        begin
          a := a + 1;
          iwriteln(IntToStr(a) + ' ' + IntToStr(j) + '->' + IntToStr(i) + ' ' +
                   s_ecri_val(vq[a]));
        end;
  { Le temps de generation est T = 1/Sum(a in R; vq[a]) }
  { R ensemble des arcs reproductifs }
  { Il existe en fait une formule simple pour vq[a] : }
  a := 0;
  for i := 1 to n do
    for j := 1 to n do
      if ( mp[i,j] > 0.0 ) then { arc j -> i }
        begin
          a := a + 1;
          vq[a] := mp[i,j]*vp[i];
          iwriteln('   ' + IntToStr(a) + '   ' +
                   IntToStr(j) + '->' + IntToStr(i) +
                   '    T'  + IntToStr(a) + ' = ' + s_ecri_val(1.0/vq[a]) + ' ' +
                   '   1/T' + IntToStr(a) + ' = ' + s_ecri_val(vq[a]));
        end;
  iwriteln('Generation time T given by 1/T = 1/Ta + 1/Tb + ... where a, b, ... are the reproductive arcs');
  { Et il y a encore plus simple : 1/T = Sum( (j,i) in R; e[i,j] ) !
    ou e[i,j] est l'elasticite de lambda aux changements de a[i,j] }
end; *)

function  dual_graphe(g : integer): integer;
{ Ceation du graphe dual ("line graph") g* du graphe g.}
{ qui a pour sommets les arcs de g. }
{ Dans g*, il y a un arc entre a = [x -> y] et b = [u -> v] }
{ si et seulemnet si u = y. Dans ce cas, }
{ le poids associe a l'arc  a -> b dans g* est le poids p_yv }
{ associe a l'arc y -> v dans g. }
{ Par construction, dans g*, tous les arcs qui rejoignent }
{ le sommet b = [y -> v] portent le meme poids p_yv. }
var g1,n,n1,x,y,a,b,u,v : integer;
    m1 : imatmat_type;
    mr1 : rmatmat_type;
begin
  with graphes[g] do
    begin
      n  := nb_sommets;
      n1 := nb_arcs;
      g1 := alloc_graphe(g,n1,name+'*',typ);
    end;
  if err_gestion then
    begin
      err_gestion := false;
      dual_graphe := 0;
      exit;
    end;
  graphe2mat(g);
  SetLength(m1,n1+1,n1+1);
  SetLength(mr1,n1+1,n1+1);
  a := 0;
  for x := 1 to n do
    for y := 1 to n do
      if ( m_[x,y] = 1 ) then
        begin
          a := a + 1;
          with  graphes[g] do
            graphes[g1].ggg[a].nom := ggg[x].nom + '->' + ggg[y].nom;
          b := 0;
          for u := 1 to n do
            for v := 1 to n do
              if ( m_[u,v] = 1 ) then
                begin
                  b := b + 1;
                  if ( y = u ) then
                    begin
                      m1[a,b]  := m_[y,v];
                      mr1[a,b] := mr_[y,v];
                    end
                  else
                    begin
                      m1[a,b]  := 0;
                      mr1[a,b] := 0.0;
                    end;
                end;
        end;
  for a := 1 to n1 do
    for b := 1 to n1 do
      begin
        m_[a,b]  := m1[a,b];
        mr_[a,b] := mr1[a,b];
      end;
  reset_graine;
  init_graphe(g1);
  if err_gestion then
    begin
      err_gestion := false;
      dealloc_graphe;
      dual_graphe := 0;
      exit;
    end;
  calcul_graphe(g1);
  dual_graphe := create_graphe(g1);
end;

function  som_graphe(g1,g2 : integer) : integer;
{ union des graphes g1 et g2 }
var x,y,g,n1,n2,n : integer;
    s : string;
begin
  n1 := graphes[g1].nb_sommets;
  n2 := graphes[g2].nb_sommets;
  n  := n1 + n2;
  s  := graphes[g1].name + '.' + graphes[g2].name;
  {g := alloc_graphe(g1,n,graphes[g1].name,type_gra_som);}
  g := alloc_graphe(0,n,s,type_gra_som);
  if err_gestion then
    begin
      err_gestion := false;
      som_graphe := 0;
      exit;
    end;
  for x := 1 to n do
    for y := 1 to n do
      begin
        m_[x,y]  := 0;
        mr_[x,y] := 0.0;
      end;
  with graphes[g1] do
    begin
      for x := 1 to n1 do with ggg[x] do
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
  with graphes[g2] do
    begin
      for x := 1 to n2 do with ggg[x] do
        begin
          y := succ;
          while ( y <> 0 ) do with lis[y] do
            begin
              m_[n1+x, n1+car] := 1;
              mr_[n1+x,n1+car] := val;
              y := cdr;
            end;
        end;
    end;
  reset_graine;
  init_graphe(g);
  if err_gestion then
    begin
      err_gestion := false;
      dealloc_graphe;
      som_graphe := 0;
      exit;
    end;
  with graphes[g] do
    begin
      for x := 1 to n1 do ggg[x].nom := graphes[g1].ggg[x].nom;
      for x := 1 to n2 do ggg[n1+x].nom := graphes[g2].ggg[x].nom + '''';
    end;
  calcul_graphe(g);
  som_graphe := create_graphe(g);
end;

function  reverse_graphe(g : integer) : integer;
{ renverse tous les arcs }
var x,y,g1,i : integer;
    a : extended;
begin
  with graphes[g] do
    begin
      g1 := alloc_graphe(g,nb_sommets,'#' + IntToStr(icre) + '_Rev',typ);
      if err_gestion then
        begin
          err_gestion := false;
          reverse_graphe := 0;
          exit;
        end;
      graphe2mat(g);
      for x := 1 to nb_sommets-1 do
        for y := x+1 to nb_sommets do
          begin
            a := mr_[x,y];
            mr_[x,y] := mr_[y,x];
            mr_[y,x] := a;
            i := m_[x,y];
            m_[x,y] := m_[y,x];
            m_[y,x] := i;
          end;
      for x := 1 to nb_sommets do graphes[g1].ggg[x].nom := ggg[x].nom;
      reset_graine;
      init_graphe(g1);
      if err_gestion then
        begin
          err_gestion := false;
          dealloc_graphe;
          reverse_graphe := 0;
          exit;
        end;
      calcul_graphe(g1);
      if edit_mode then
        begin
          graphes[g] := graphes[g1];
          dealloc_graphe;
          reverse_graphe := g;
        end
      else
        reverse_graphe := create_graphe(g1);
    end;
end;

function  addroot_graphe(g : integer) : integer;
{ ajoute un sommet root qui joint touts les espèces basales }
{ et auquel toutes les especes sont jointes }
{ on suppose que le nombre d'especes basales de g est > 0 }
var x,y,g1,n1 : integer;
begin
  with graphes[g] do
    begin
      n1 := nb_sommets +1 ;
      if ( n1 > vecmax ) then
        begin
          addroot_graphe := 0;
          exit;
        end;
      g1 := alloc_graphe(g,n1,'#' + IntToStr(icre) + '_Rooted',type_gra_root);
      if err_gestion then
        begin
          err_gestion := false;
          addroot_graphe := 0;
          exit;
        end;
      graphe2mat(g);
      { tous les sommets relies a la racine n1 : }
      m_[n1,n1]  := 0;
      mr_[n1,n1] := 0.0;
      for x := 1 to nb_sommets do
        begin
          m_[x,n1]  := 1;
          mr_[x,n1] := 1.0; { voir si ival = 1 !!! }
        end;
      { la racine n1 reliee aux especes basales : }
      for y := 1 to nb_sommets do with ggg[y] do
        if ( nb_pred = 0 ) then
          begin
            m_[n1,y]  := 1;
            mr_[n1,y] := 1.0;
          end
        else
          begin
            m_[n1,y]  := 0;
            mr_[n1,y] := 0.0;
          end;
      for x := 1 to nb_sommets do graphes[g1].ggg[x].nom := ggg[x].nom;
      graphes[g1].ggg[n1].nom := '_Root_';
      graphes[g1].root := n1;
      graphes[g1].ival := ival;
      reset_graine;
      init_graphe(g1);
      if err_gestion then
        begin
          err_gestion := false;
          dealloc_graphe;
          addroot_graphe := 0;
          exit;
        end;
      calcul_graphe(g1);
      if edit_mode then
        begin
          graphes[g] := graphes[g1];
          dealloc_graphe;
          addroot_graphe := g;
        end
      else
        addroot_graphe := create_graphe(g1);
    end;
end;

function  addroot_graphe_temp(g : integer) : integer;
{ ajoute un sommet root qui joint toutes les espèces basales }
{ et auquel toutes les especes sont jointes }
{ on suppose que le nombre d'especes basales de g est > 0 }
{ graphe temporaire pour calcul, faire dealloc apres calcul }
var x,y,g1,n1 : integer;
begin
  with graphes[g] do
    begin
      n1 := nb_sommets + 1;
      if ( n1 > vecmax ) then
        begin
          addroot_graphe_temp := 0;
          exit;
        end;
      g1 := alloc_graphe(g,n1,'#' + IntToStr(icre) + '_Rooted',type_gra_root);
      if err_gestion then
        begin
          err_gestion := false;
          addroot_graphe_temp := 0;
          exit;
        end;
      graphe2mat(g);
      { tous les sommets relies a la racine n1 : }
      m_[n1,n1]  := 0;
      mr_[n1,n1] := 0.0;
      for x := 1 to nb_sommets do
        begin
          m_[x,n1]  := 1;
          mr_[x,n1] := 1.0; { voir si ival = 1 !!! }
        end;
      { la racine n1 reliee aux especes basales : }
      for y := 1 to nb_sommets do with ggg[y] do
        if ( nb_pred = 0 ) then
          begin
            m_[n1,y]  := 1;
            mr_[n1,y] := 1.0;
          end
        else
          begin
            m_[n1,y]  := 0;
            mr_[n1,y] := 0.0;
          end;
      {for x := 1 to nb_sommets do graphes[g1].ggg[x].nom := ggg[x].nom;
      graphes[g1].ggg[n1].nom := '_Root_';}
      graphes[g1].root := n1;
      graphes[g1].ival := ival;
      reset_graine;
      init_graphe(g1);
      if err_gestion then
        begin
          err_gestion := false;
          dealloc_graphe;
          addroot_graphe_temp := 0;
          exit;
        end;
      calcul_arcs(g1);
      addroot_graphe_temp := g1;
    end;
end;

function  markov_graphe_temp(g : integer; mp : rmatmat_type) : integer;
{ construit le graphe g1 dont la matrice d'adjacence est la }
{ chaine de Markov mp associee au graphe g }
{ graphe temporaire pour calcul, faire dealloc apres calcul }
var x,y,g1,n1 : integer;
begin
  with graphes[g] do
    begin
      g1 := alloc_graphe(g,nb_sommets,'#' + IntToStr(icre) + '_Markov',type_gra_markov);
      if err_gestion then
        begin
          err_gestion := false;
          markov_graphe_temp := 0;
          exit;
        end;
      graphe2mat(g);
      for x := 1 to nb_sommets do
        for y := 1 to nb_sommets do
          mr_[x,y] := mp[x,y];
      {for x := 1 to nb_sommets do graphes[g1].ggg[x].nom := ggg[x].nom;}
      graphes[g1].ival := ival;
      reset_graine;
      init_graphe(g1);
      if err_gestion then
        begin
          err_gestion := false;
          dealloc_graphe;
          markov_graphe_temp := 0;
          exit;
        end;
      calcul_arcs(g1);
      markov_graphe_temp := g1;
    end;
end;

function  delroot_graphe(g : integer) : integer;
{ supprime le sommet root qui joint touts les espèces basales }
{ et auquel toutes les especes sont jointes }
begin
  with graphes[g] do delroot_graphe := delete_sommet_graphe(g,root);
end;

function  reindex_graphe(g : integer;o : ivec_type) : integer;
{ re-indexe les sommets selon le tableau o }
var x,y,g1 : integer;
    q : ivec_type;
begin
  with graphes[g] do
    begin
      g1 := alloc_graphe(g,nb_sommets,name,typ);
      if err_gestion then
        begin
          err_gestion := false;
          reindex_graphe := 0;
          exit;
        end;
      for x := 1 to nb_sommets do
        for y := 1 to nb_sommets do
          begin
            m_[x,y]  := 0;
            mr_[x,y] := 0.0;
          end;
      for x := 1 to nb_sommets do q[o[x]] := x;
      for x := 1 to nb_sommets do with ggg[o[x]] do
        begin
          y := succ;
          while ( y <> 0 ) do with lis[y] do
            begin
              m_[x,q[car]]  := 1;
              mr_[x,q[car]] := val;
              y := cdr;
            end;
        end;
      for x := 1 to nb_sommets do graphes[g1].ggg[x].nom := ggg[o[x]].nom;
      reset_graine;
      init_graphe(g1);
      if err_gestion then
        begin
          err_gestion := false;
          dealloc_graphe;
          reindex_graphe := 0;
          exit;
        end;
      calcul_graphe(g1);
      if edit_mode then
        begin
          graphes[g] := graphes[g1];
          dealloc_graphe;
          reindex_graphe := g;
        end
      else
        reindex_graphe := create_graphe(g1);
    end;
end;

function  delete_boucles_graphe(g : integer) : integer;
var x,g1 : integer;
begin
  with graphes[g] do
    begin
      g1 := alloc_graphe(g,nb_sommets,name,typ);
      if err_gestion then
        begin
          err_gestion := false;
          delete_boucles_graphe := 0;
          exit;
        end;
      graphe2mat(g);
      for x := 1 to nb_sommets do
        begin
          m_[x,x]  := 0;
          mr_[x,x] := 0.0;
        end;
      for x := 1 to nb_sommets do graphes[g1].ggg[x].nom := ggg[x].nom;
      reset_graine;
      init_graphe(g1);
      if err_gestion then
        begin
          err_gestion := false;
          dealloc_graphe;
          delete_boucles_graphe := 0;
          exit;
        end;
      calcul_graphe(g1);
      if edit_mode then
        begin
          graphes[g] := graphes[g1];
          dealloc_graphe;
          delete_boucles_graphe := g;
        end
      else
        delete_boucles_graphe := create_graphe(g1);
    end;
end;

function  delete_cycles_graphe(g : integer) : integer;
{ ne delete pas tous les cycles si ceux si sont en nombre > cycmax }
var x,g1 : integer;
begin
  with graphes[g] do
    begin
      g1 := alloc_graphe(g,nb_sommets,name,typ);
      if err_gestion then
        begin
          err_gestion := false;
          delete_cycles_graphe := 0;
          exit;
        end;
      graphe2mat(g);
      calcul_cycle(g);
      for x := 1 to imin(nb_cycles,cycmax) do
        begin
          m_[cyc_u[x],cyc_v[x]]  := 0;
          mr_[cyc_u[x],cyc_v[x]] := 0.0;
        end;
      reset_graine;
      init_graphe(g1);
      if err_gestion then
        begin
          err_gestion := false;
          dealloc_graphe;
          delete_cycles_graphe := 0;
          exit;
        end;
      for x := 1 to nb_sommets do graphes[g1].ggg[x].nom := ggg[x].nom;
      calcul_graphe(g1);
      if edit_mode then
        begin
          graphes[g] := graphes[g1];
          dealloc_graphe;
          delete_cycles_graphe := g;
        end
      else
        delete_cycles_graphe := create_graphe(g1);
    end;
end;

function  comp_conn_graphe(g : integer) : integer;
{ extrait la plus grande composante connexe du graphe non oriente g }
var x,y,g1,i,nb_som,i_connect,u,v : integer;
    tab,inv : ivec_type;
begin
  with graphes[g] do
    begin
      for i := 1 to nb_sommets do tab[i] := 0;
      for x := 1 to nb_sommets do with ggg[x] do
        tab[connect] := tab[connect] + 1;
      nb_som := 0;
      for i := 1 to nb_connect do nb_som := imax(nb_som,tab[i]);
      g1 := alloc_graphe(g,nb_som,name,typ);
      if err_gestion then
        begin
          err_gestion := false;
          comp_conn_graphe := 0;
          exit;
        end;
      for i := 1 to nb_connect do
        if ( tab[i] = nb_som ) then i_connect := i;
      u := 0;
      for x := 1 to nb_sommets do with ggg[x] do
        if ( connect = i_connect ) then
          begin
            u := u + 1;
            tab[u] := x;
            inv[x] := u;
          end;
      for u := 1 to nb_som do
        for v := 1 to nb_som do
          begin
            m_[u,v]  := 0;
            mr_[u,v] := 0.0;
          end;
      for u := 1 to nb_som do
        begin
          x := tab[u];
          with ggg[x] do
            begin
              y := succ;
              while ( y <> 0 ) do with lis[y] do
                begin
                  v := inv[car];
                  m_[u,v]  := 1;
                  mr_[u,v] := val;
                  y := cdr;
                end;
            end;
        end;
      reset_graine;
      init_graphe(g1);
      if err_gestion then
        begin
          err_gestion := false;
          dealloc_graphe;
          comp_conn_graphe := 0;
          exit;
        end;
      for u := 1 to nb_som do
        begin
          x := tab[u];
          graphes[g1].ggg[u].nom := ggg[x].nom;
        end;
      calcul_graphe(g1);
      if edit_mode then
        begin
          graphes[g] := graphes[g1];
          dealloc_graphe;
          comp_conn_graphe := g;
        end
      else
        comp_conn_graphe := create_graphe(g1);
    end;
end;

function  reverse_sommet_graphe(g,x : integer) : integer;
var y,g1,i : integer;
    a : extended;
begin
  with graphes[g] do
    begin
      g1 := alloc_graphe(g,nb_sommets,name,typ);
      if err_gestion then
        begin
          err_gestion := false;
          reverse_sommet_graphe := 0;
          exit;
        end;
      graphe2mat(g);
      for y := 1 to nb_sommets do
        begin
          a := mr_[x,y];
          mr_[x,y] := mr_[y,x];
          mr_[y,x] := a;
          i := m_[x,y];
          m_[x,y] := m_[y,x];
          m_[y,x] := i;
        end;
      for x := 1 to nb_sommets do graphes[g1].ggg[x].nom := ggg[x].nom;
      reset_graine;
      init_graphe(g1);
      if err_gestion then
        begin
          err_gestion := false;
          dealloc_graphe;
          reverse_sommet_graphe := 0;
          exit;
        end;
      calcul_graphe(g1);
      if edit_mode then
        begin
          graphes[g] := graphes[g1];
          dealloc_graphe;
          reverse_sommet_graphe := g;
        end
      else
        reverse_sommet_graphe := create_graphe(g1);
    end;
end;

function  create_sommet_graphe(g : integer) : integer;
var n,x,g1 : integer;
begin
  with graphes[g] do
    begin
      n := nb_sommets + 1;
      g1 := alloc_graphe(g,n,name,typ);
      if err_gestion then
        begin
          err_gestion := false;
          create_sommet_graphe := 0;
          exit;
        end;
      graphe2mat(g);
      for x := 1 to n do
        begin
          m_[x,n]  := 0;
          m_[n,x]  := 0;
          mr_[x,n] := 0.0;
          mr_[n,x] := 0.0;
        end;
      for x := 1 to nb_sommets do graphes[g1].ggg[x].nom := ggg[x].nom;
      graphes[g1].ggg[n].nom := 'v' + IntToStr(n);
      reset_graine;
      init_graphe(g1);
      if err_gestion then
        begin
          err_gestion := false;
          dealloc_graphe;
          create_sommet_graphe := 0;
          exit;
        end;
      calcul_graphe(g1);
      if edit_mode then
        begin
          graphes[g] := graphes[g1];
          dealloc_graphe;
          create_sommet_graphe := g;
        end
      else
        create_sommet_graphe := create_graphe(g1);
    end;
end;

function  dup_sommet_graphe(g,x : integer) : integer;
{ duplication du sommet x et de ses arcs entrants et sortants }
var n,y,g1 : integer;
begin
  with graphes[g] do
    begin
      n  := nb_sommets + 1;
      g1 := alloc_graphe(g,n,name,typ);
      if err_gestion then
        begin
          err_gestion := false;
          dup_sommet_graphe := 0;
          exit;
        end;
      graphe2mat(g);
      for y := 1 to n-1 do
        begin
          m_[n,y]  := m_[x,y];
          m_[y,n]  := m_[y,x];
          mr_[n,y] := mr_[x,y];
          mr_[y,n] := mr_[y,x];
        end;
      m_[x,n]  := 0;
      m_[n,x]  := 0;
      m_[n,n]  := m_[x,x];
      mr_[x,n] := 0.0;
      mr_[n,x] := 0.0;
      mr_[n,n] := mr_[x,x];
      for y := 1 to nb_sommets do graphes[g1].ggg[y].nom := ggg[y].nom;
      graphes[g1].ggg[n].nom := 'v' + IntToStr(n);
      reset_graine;
      init_graphe(g1);
      if err_gestion then
        begin
          err_gestion := false;
          dealloc_graphe;
          dup_sommet_graphe := 0;
          exit;
        end;
      calcul_graphe(g1);
      if edit_mode then
        begin
          graphes[g] := graphes[g1];
          dealloc_graphe;
          dup_sommet_graphe := g;
        end
      else
        dup_sommet_graphe := create_graphe(g1);
    end;
end;

function  delete_sommet_graphe(g,x : integer) : integer;
var n,u,y,g1 : integer;
begin
  with graphes[g] do
    begin
      n := nb_sommets - 1;
      g1 := alloc_graphe(g,n,name,typ);
      if err_gestion then
        begin
          err_gestion := false;
          delete_sommet_graphe := 0;
          exit;
        end;
      graphe2mat(g);
      for u := x to nb_sommets-1 do
        for y := 1 to nb_sommets do
          begin
            m_[u,y]  := m_[u+1,y];
            mr_[u,y] := mr_[u+1,y];
          end;
      for u := 1 to nb_sommets-1 do
        for y := x to nb_sommets-1 do
          begin
            m_[u,y]  := m_[u,y+1];
            mr_[u,y] := mr_[u,y+1];
          end;
      for u := 1 to x-1 do
        graphes[g1].ggg[u].nom := ggg[u].nom;
      for u := x to nb_sommets-1 do
        graphes[g1].ggg[u].nom := ggg[u+1].nom;
      reset_graine;
      init_graphe(g1);
      if err_gestion then
        begin
          err_gestion := false;
          dealloc_graphe;
          delete_sommet_graphe := 0;
          exit;
        end;
      calcul_graphe(g1);
      if edit_mode then
        begin
          graphes[g] := graphes[g1];
          dealloc_graphe;
          delete_sommet_graphe := g;
        end
      else
        delete_sommet_graphe := create_graphe(g1);
    end;
end;

function  nettoyage(g : integer) : integer;
var k : integer;

procedure delete_sommet(j : integer);
var i,n :integer;
begin
with graphes[g] do
  begin
    for i := j to nb_sommets-1 do
      for n := 1 to nb_sommets do
        begin
          m_[i,n] := m_[i+1,n];
          mr_[i,n]:= mr_[i+1,n];
        end;
    for i := 1 to nb_sommets-1 do
      for n := j to nb_sommets-1 do
        begin
          m_[i,n] := m_[i,n+1];
          mr_[i,n] := mr_[i,n+1];
        end;
    for i := j to nb_sommets-1 do
      begin
        ggg[i].nom := ggg[i+1].nom;
        ggg[i].biom := ggg[i+1].biom;
      end;
    nb_sommets := nb_sommets-1;
  end;
end;

begin
  with graphes[g] do
    begin
      k := 1;
      while (k <= nb_sommets) do
        if ggg[k].biom = 0.0 then
          delete_sommet(k)
        else
          k := k+1;
    end;
  nettoyage := g;
end;

function  reverse_arc_graphe(g,x,y : integer) : integer;
var g1,i : integer;
    a : extended;
begin
  with graphes[g] do
    begin
      g1 := alloc_graphe(g,nb_sommets,name,typ);
      if err_gestion then
        begin
          err_gestion := false;
          reverse_arc_graphe := 0;
          exit;
        end;
      graphe2mat(g);
      i := m_[x,y];
      m_[x,y] := 0;
      m_[y,x] := i;
      a := mr_[x,y];
      mr_[x,y] := 0.0;
      mr_[y,x] := a;
      for x := 1 to nb_sommets do graphes[g1].ggg[x].nom := ggg[x].nom;
      reset_graine;
      init_graphe(g1);
      if err_gestion then
        begin
          err_gestion := false;
          dealloc_graphe;
          reverse_arc_graphe := 0;
          exit;
        end;
      calcul_graphe(g1);
      if edit_mode then
        begin
          graphes[g] := graphes[g1];
          dealloc_graphe;
          reverse_arc_graphe := g;
        end
      else
        reverse_arc_graphe := create_graphe(g1);
    end;
end;

function  modif_arc_mat_graphe(g,x,y : integer;a : extended) : integer;
var g1 : integer;
begin
  with graphes[g] do
    begin
      g1 := alloc_graphe(g,nb_sommets,name,typ);
      if err_gestion then
        begin
          err_gestion := false;
          modif_arc_mat_graphe := 0;
          exit;
        end;
      graphe2mat(g);
      mr_[x,y] := a;
      if ( a > 0.0 ) then m_[x,y] := 1 else m_[x,y] := 0;
      for x := 1 to nb_sommets do graphes[g1].ggg[x].nom := ggg[x].nom;
      reset_graine;
      init_graphe(g1);
      if err_gestion then
        begin
          err_gestion := false;
          dealloc_graphe;
          modif_arc_mat_graphe := 0;
          exit;
        end;
      calcul_graphe(g1);
      graphes[g] := graphes[g1];
      dealloc_graphe;
      modif_arc_mat_graphe := g;
    end;
end;

end.
