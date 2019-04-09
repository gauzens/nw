unit kcalculg;

{ @@@@@@  algorithmes des graphes  @@@@@@ }

interface

uses kglobvar;

procedure calcul_arcs(g : integer);
procedure calcul_cycle(g : integer);
procedure calcul_graphe(g : integer);
procedure calcul_graphe_simul(g : integer);
procedure calcul_graphe_aggreg(g : integer);
procedure are_different(g: integer);
procedure calcul_nb_larg(g : integer);
procedure betweeness(g: integer);

var   lmin : imat_type;  { matrice des longueurs min entre les sommets du graphe }
      lmina : imat_type; { matrice des longueurs min entre les sommets du graphe non oriente }
      lmax : imat_type;  { matrice des longueurs max entre les sommets du graphe }
      lmoy : rmat_type;  { matrice des longueurs moy entre les sommets du graphe }
      {lvar : rmat_type;}  { matrice des carrés des longueurs des chemins - pas utile }
      lnb  : rmat_type;  { matrice du nombre de chemins entre les sommets du graphe }
                         { type reel car debordement en entier, meme int64 }
      lnb_min : rmat_type; { matrice du nombre de chemins minimum entre les sommets }
      lval : rmat_type;  { matrice des longueurs valuees entre les sommets }
      lnbval : rmat_type;{ matrice pour calcul des hauteurs valuees }

      dlc : rvec_type;   { distribution des longueurs des chemins basal -> top }
      dlcmax : integer;  { nombre de classes dans dlc }
      dlcval : rvec_type;  { distribution des longueurs des chemins values basal -> top }
      dlcvalmax : integer; { nombre de classes dans dlcval }
      delta_dlcval : extended; { delta de la distribution dlc dans le cas value }
      pcc_v : imat_type;
const cycmax = 100000;

var   cyc_u,cyc_v : array[1..cycmax] of integer;
     { extremites des arcs a supprimer pour detruire les cycles }

implementation

uses  SysUtils,kmath,klist,kutil,ksyntax,kgestiong,kmanipg,kmarkov,f_nw,f_pad;

var   ms : integer; { temps en ms }

procedure calcul_index_val(g : integer);
var x,u : integer;
    a : extended;
begin
  with graphes[g] do
    begin
      gen_moy_val := 0.0;
      vul_moy_val := 0.0;
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          a := 0.0;
          u := pred;
          while ( u <> 0 ) do with lis[u] do
            begin
              a := a + val;
              u := cdr;
            end;
          vul_val := a;
          (*gen_val := a;*) { alternative definition }
          gen_val := 0.0;
          a := a*a;
          u := pred;
          while ( u <> 0 ) do with lis[u] do
            begin
              gen_val := gen_val + val*val/a;
              u := cdr;
            end;
          if ( pred = 0 ) then { espece basale }
            gen_val := 0.0
          else
            gen_val := 1.0 - gen_val;
          gen_moy_val := gen_moy_val + gen_val;
          a := 0.0;
          u := succ;
          while ( u <> 0 ) do with lis[u] do
            begin
              a := a + val;
              u := cdr;
            end;
          if ( vul_val > 0.0 ) then
            begin
              vul_val := a/vul_val;
              vul_moy_val := vul_moy_val + vul_val;
            end
          else
            vul_val := bad; { !!! voir cas espece basale };
        end;
      if ( nb_sommets > nb_b ) then
        gen_moy_val := gen_moy_val/(nb_sommets - nb_b)
      else
        gen_moy_val := bad;
      if ( nb_i > 0 ) then
        vul_moy_val := vul_moy_val/nb_i
      else
        vul_moy_val := bad;
    end;
end;

procedure calcul_arcs(g : integer);
var x,y : integer;
begin
  with graphes[g] do
    begin
      nb_arcs := 0;
      nb_boucles := 0;
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          nb_succ := 0;
          nb_pred := 0;
          cyc     := 0;
          boucle  := 0;
        end;
      valmax := 0.0;
      for x := 1 to nb_sommets do
        for y := 1 to nb_sommets do
          if ( m_[x,y] = 1 ) then
            begin
              nb_arcs := nb_arcs + 1;
              if ( y = x ) then with ggg[x] do
                begin
                  nb_boucles := nb_boucles + 1;
                  boucle := 1;
                end;
              with ggg[x] do nb_succ := nb_succ + 1;
              with ggg[y] do nb_pred := nb_pred + 1;
              valmax := max(valmax,mr_[x,y]);
            end;
      nb_b := 0;
      nb_b_isol := 0;
      nb_t := 0;
      deg_moy := 0.0;
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          if ( nb_pred = 0 ) then
            begin
              nb_b  := nb_b  + 1;
              if ( nb_succ = 0 ) then nb_b_isol := nb_b_isol + 1;
            end
          else
            if ( nb_succ = 0 ) then nb_t := nb_t + 1;
          deg := nb_pred + nb_succ;
          deg_moy := deg_moy + deg;
        end;
      nb_i := nb_sommets - nb_b - nb_t;
      if ( nb_sommets > 0 ) then deg_moy := deg_moy/nb_sommets;
      if ( ival = 1 ) then calcul_index_val(g);
    end;
end;

procedure calcul_clust(g : integer);
var x : integer;
    tab : ivecvec_type;

function calcul_c(x : integer) : extended;
{ coefficient d'aggregation (clustering coefficient) }
{ calcule le nombre d'arcs entre tous les voisins du sommet x }
{ sans tenir compte de l'orientation des arcs }
var k,y,u,v,q : integer;
begin
  with graphes[g] do with ggg[x] do
    begin
      q := 0;
      k := 0;
      y := succ;
      while ( y <> 0 ) do with lis[y] do
        begin
          k := k + 1;
          tab[k] := car;
          y := cdr;
        end;
      y := pred;
      while ( y <> 0 ) do with lis[y] do
        begin
          k := k + 1;
          tab[k] := car;
          y := cdr;
        end;
      for u := 1 to k-1 do
        for v := u+1 to k do
          begin
            if ( m_[tab[u],tab[v]] <> 0.0 ) then q := q + 1;
            if ( m_[tab[v],tab[u]] <> 0.0 ) then q := q + 1;
          end;
      if ( k > 1 ) then
        calcul_c := 2.0*q/(k*(k - 1))
      else
        calcul_c := 0.0;
    end;
end;

begin
  with graphes[g] do
    begin
      SetLength(tab,2*vecmax+1);
      clust := 0.0;
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          c := calcul_c(x);
          clust := clust + c;
        end;
      if ( nb_sommets > 0 ) then
        clust := clust/nb_sommets
      else
        clust := 0.0;
    end;
end;

procedure calcul_assort(g : integer);
var x,y : integer;
    a,b,c,u,v,w,dx,dy : extended;
begin
  with graphes[g] do
    begin
      a := 0.0;
      b := 0.0;
      c := 0.0;
      for x := 1 to nb_sommets do
        for y := 1 to nb_sommets do
          if ( m_[x,y] = 1 ) then
            begin
              dx := ggg[x].nb_succ + ggg[x].nb_pred;
              dy := ggg[y].nb_succ + ggg[y].nb_pred;
              u := dx*dy;
              v := 0.5*(dx*dx + dy*dy);
              w := 0.5*(dx + dy);
              a := a + u;
              b := b + v;
              c := c + w;
            end;
      if ( nb_arcs > 0 ) then
        a := a/nb_arcs
      else
        a := 0.0;
      if ( nb_arcs > 0 ) then
        b := b/nb_arcs
      else
        b := 0.0;
      if ( nb_arcs > 0 ) then
        c := c/nb_arcs
      else
        c := 0.0;
      c := c*c;
      if ( c <> b ) then
        assort := (a - c)/(b - c)
      else
        assort := 0.0;
    end;
end;

procedure resultat_dist(g : integer);
{ calcul des resultats apres calcul des plus courts chemins }
{ dans le graphe non oriente }
{ lmina[x,y] contient la distance min entre les sommets x et y }
var x,y,k : integer;
begin
  with graphes[g] do
    begin
{ eccentricites }
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          ecc := 0;
          for y := 1 to nb_sommets do
            if ( lmina[x,y] < big ) then
              ecc := imax(ecc,lmina[x,y]);
        end;
{ diametre, rayon }
      diam   := 0;
      radius := big;
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          diam   := imax(diam,ecc);
          radius := imin(radius,ecc);
        end;
{ longueur caracteristique }
      charlen := 0.0;
      k := 0;
      for x := 1 to nb_sommets do
        for y := 1 to nb_sommets do
          begin
            if ( lmina[x,y] < big ) then
             begin
               k := k + 1;
               charlen := charlen + lmina[x,y];
             end;
          end;
       if ( k <> 0 ) then charlen := charlen/k;
    end;
end;

procedure calcul_dist_larg(g : integer);
{ computation of distances, i.e., minimal path length, }
{ between any 2 nodes in the undirected graph, using bread first search }
{ lmina[x,y] = distance[x,y] }
var x : integer;
    visit,d,e : ivec_type;

procedure parc_larg(x : integer);
var u,niv,i,j,nb_niv : integer;
begin
  with graphes[g] do
    begin
      for u := 1 to nb_sommets do visit[u] := 0;
      visit[x] := 1;
      niv := 1;
      nb_niv := 1;
      d[1] := x;
      while ( nb_niv <> 0 ) do
        begin
          j := 0;
          for i := 1 to nb_niv do with ggg[d[i]] do
            begin
              u := succ;
              while ( u <> 0 ) do with lis[u] do
                begin
                  if ( visit[car] = 0 ) then
                    begin
                      lmina[x,car] := niv;
                      visit[car] := 1;
                      j := j + 1;
                      e[j] := car;
                    end;
                  u := cdr;
                end;
              u := pred;
              while ( u <> 0 ) do with lis[u] do
                begin
                  if ( visit[car] = 0 ) then
                    begin
                      lmina[x,car] := niv;
                      visit[car] := 1;
                      j := j + 1;
                      e[j] := car;
                    end;
                  u := cdr;
                end;
            end;
          nb_niv := j;
          for i := 1 to nb_niv do d[i] := e[i];
          niv := niv + 1;
        end;
    end;
end;

procedure init_dist(g : integer);
var x,y : integer;
begin
  with graphes[g] do
    begin
      for x := 1 to nb_sommets do
        for y := 1 to nb_sommets do
          lmina[x,y] := big;
    end;
end;

begin
  with graphes[g] do
    begin
      init_dist(g);
      for x := 1 to nb_sommets do parc_larg(x);
      resultat_dist(g);
    end;
end;

(*procedure largeur(g : integer);
{ schema du parcours largeur d'abord }
var x,niv : integer;
    visit,parent : ivec_type;

procedure parc_larg(x : integer);
{ parcours largeur d'abord }
var u,y : integer;
begin
  with graphes[g] do
    begin
      for y := 1 to nb_sommets do
        begin
          visit[y]  := 0;
          parent[y] := 0;
        end;
      parent[x] := 0;
      visit[x]  := 2; { "decouvert" }
      pushq(x);
      while not videq do
        begin
          y := popq;
          with ggg[y] do
            begin
              { traiter sommet y }
              u := succ;
              while ( u <> 0 ) do with lis[u] do
                begin
                  { traiter arc [y,car] }
                  if ( visit[car] = 0 ) then
                    begin
                      visit[car]  := 2;
                      parent[car] := y;
                      pushq(car);
                    end;
                  u := cdr;
                end;
            end;
          niv := niv + 1;
          visit[y] := 1; { "traite" }
        end;
    end;
end;

begin
  with graphes[g] do
    begin
      initq;
      for x := 1 to nb_sommets do visit[x] := 0; { "non visite" }
      for x := 1 to nb_sommets do
        if ( visit[x] = 0 ) then
          begin
            niv := 0;
            parc_larg(x);
          end;
    end;
end;*)

(*procedure profondeur(g : integer);
{ schema du parcours profondeur d'abord }
var x,niv : integer;
    visit,parent : ivec_type;

procedure parc_prof(x : integer);
var y : integer;
begin
  with graphes[g] do
    begin
      niv := niv + 1;
      visit[x] := 2; { "decouvert" }
      with ggg[x] do
        begin
          y := succ;
          while ( y <> 0 ) do with lis[y] do
            begin
              if ( visit[car] = 2 ) then
                { cycle }
              else
                if ( visit[car] = 0 ) then
                  begin
                    parent[car] := x;
                    parc_prof(car);
                  end;
              y := cdr;
            end;
        end;
      visit[x] := 1; { "traite" }
      niv := niv - 1;
    end;
end;

begin
  with graphes[g] do
    begin
      for x := 1 to nb_sommets do visit[x] := 0; { "non visite" }
      for x := 1 to nb_sommets do
        begin
          if ( visit[x] = 0 ) then
            begin
              niv := 0;
              parc_prof(x);
            end;
        end;
    end;
end;*)

procedure calcul_connect(g : integer);
{ calcul des composantes connexes par parcours profondeur d'abord }
{ du graphe non oriente sous-jacent au graphe oriente }
{ donc ce ne sont pas les composantes fortement connexes }
var x : integer;
    visit : ivec_type;

procedure parc_prof(x : integer);
var y : integer;
begin
  with graphes[g] do
    begin
      visit[x] := 2;
      with ggg[x] do
        begin
          y := succ;
          while ( y <> 0 ) do with lis[y] do
            begin
              if ( visit[car] = 0 ) then parc_prof(car);
              y := cdr;
            end;
          y := pred;
          while ( y <> 0 ) do with lis[y] do
            begin
              if ( visit[car] = 0 ) then parc_prof(car);
              y := cdr;
            end;
        end;
      visit[x] := 1;
      ggg[x].connect := nb_connect;
    end;
end;

begin
  with graphes[g] do
    begin
      nb_connect := 0;
      for x := 1 to nb_sommets do visit[x] := 0;
      for x := 1 to nb_sommets do
        if ( visit[x] = 0 ) then
          begin
            nb_connect := nb_connect + 1;
            parc_prof(x);
          end;
    end;
end;

procedure calcul_cycle(g : integer);
{ detection de cycles }
{ pas tous les cycles, mais ceux dont la suppression  }
{ laisse un graphe sans cycle (DAG) - tableaux cyc_u, cyc_v }
{ ne garantit pas que ces cycles constituent un ensemble minimal }
{ par rapport a cette propriete }
{ les boucles ne sont pas considerees }
{ procedure limitee par le nombre d'arcs que l'on peut memoriser }
var x,niv : integer;
    visit,tab_cyc : ivec_type;
    (*tab_cyc : array[1..10000] of integer;*)

procedure parc_prof(x : integer);
var y,i,j,clen : integer;
begin
  with graphes[g] do
    begin
      niv := niv + 1;
      visit[x] := 2;
      tab_cyc[niv] := x;
      with ggg[x] do
        begin
          y := succ;
          while ( y <> 0 ) do with lis[y] do
            begin
              if ( visit[car] = 2 ) then
                for i := 1 to niv do
                  if ( tab_cyc[i] = car ) then
                    begin
                      clen := niv - i + 1;
                      if ( clen > 1 ) then { cycle qui n'est pas une boucle }
                        begin
                          ggg[car].cyc := 0; { on ne memorise qu'un cycle par sommet }
                          (*if ( nb_cycles <= 50 ) then
                            for j := i to niv do
                              begin
                                ggg[car].cyc := cons(tab_cyc[j],type_som,0.0,ggg[car].cyc);
                                if err_lis then exit;
                              end;*)
                          nb_cycles := nb_cycles + 1;
                          cyclen := cyclen + clen;
                          if ( nb_cycles <= cycmax ) then
                            begin
                              cyc_u[nb_cycles] := x;
                              cyc_v[nb_cycles] := car;
                            end;
                          break;
                        end;
                    end
                  else
              else
                if ( visit[car] = 0 ) then parc_prof(car);
              y := cdr;
            end;
        end;
      visit[x] := 1;
      niv := niv - 1;
    end;
end;

begin
  with graphes[g] do
    begin
      (*if err_lis then
        begin
          nb_cycles := bad;
          cyclen := bad;
          exit;
        end;*){ cas ou on appelle cons }
      for x := 1 to nb_sommets do visit[x] := 0;
      nb_cycles := 0;
      cyclen := 0.0;
      for x := 1 to nb_sommets do
        if ( visit[x] = 0 ) then
          begin
            niv := 0;
            parc_prof(x);
          end;
      if ( nb_cycles <> 0 ) then cyclen := cyclen/nb_cycles;
    end;
end;

procedure top_sort(g : integer;var ord : ivec_type);
{ topological sorting of directed acyclic graph (DAG) }
var x,y,z : integer;
    pre : ivec_type;
begin
  with graphes[g] do
    begin
      initq;
      z := 0;
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          pre[x] := nb_pred;
          if ( nb_pred = 0 ) then pushq(x);
        end;
      while not videq do
        begin
          x := popq;
          z := z + 1;
          ord[z] := x;
          with ggg[x] do
            begin
              y := succ;
              while ( y <> 0 ) do with lis[y] do
                begin
                  pre[car] := pre[car] - 1;
                  if ( pre[car] = 0 ) then pushq(car);
                  y := cdr;
                end;
            end;
        end;
      {if ( z < nb_sommets ) then iwriteln('sort - cycle');}
    end;
end;

{procedure bad_val_trolev(g : integer);
var x : integer;
begin
  with graphes[g] do
    begin
      trolev_moy := bad;
      trolev_max := bad;
      for x := 1 to nb_sommets do with ggg[x] do trolev := bad;
    end;
end;}

procedure calcul_trolev_mat_val(g : integer);
{ calcul des niveaux trophiques par inversion d'une matrice }
{ TL = E.(I - D)^(-1) }
{ ou E est le vecteur ligne dont toutes les entrees valent 1 }
var x,y,n1 : integer;
    sum : extended;
    aaa,sss : rmatmat_type;
    v : rvec_type;
begin
  with graphes[g] do
    begin
      n1 := nb_sommets + 1;
      SetLength(aaa,n1,n1);
      SetLength(sss,n1,n1);
      for x := 1 to nb_sommets do with ggg[x] do
        if ( nb_pred > 0 ) then
          begin
            sum := 0.0;
            y := pred;
            while ( y <> 0 ) do with lis[y] do
              begin
                sum := sum + val;
                y := cdr;
              end;
            v[x] := sum;
          end;
      for x := 1 to nb_sommets do
        for y := 1 to nb_sommets do with ggg[y] do
          if ( nb_pred > 0 ) then
            aaa[x,y] := mr_[x,y]/v[y]
          else
            aaa[x,y] := 0.0;
      for x := 1 to nb_sommets do
        for y := 1 to nb_sommets do
          if ( x = y ) then
            aaa[x,x] := 1.0 - aaa[x,x]
          else
            aaa[x,y] := -aaa[x,y];
      matinv(nb_sommets,aaa,sss);
      if err_math then { pb convergence }
        begin
          err_math := false;
          iwriteln('*** trolev - no convergence0');
          exit;
        end;
      { test de la validite de l'inverse }
      for x := 1 to nb_sommets do
        for y := 1 to nb_sommets do
          if ( sss[x,y] > nb_sommets ) then
            begin
              iwriteln('*** trolev - no convergence');
              exit;
            end;
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          sum := 0.0;
          for y := 1 to nb_sommets do sum := sum + sss[y,x];
          trolev_val := sum;
        end;
      trolev_moy_val := 0.0;
      trolev_max_val := 0.0;
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          trolev_moy_val := trolev_moy_val + trolev_val;
          trolev_max_val := max(trolev_max_val,trolev_val);
        end;
      trolev_moy_val := trolev_moy_val/nb_sommets;
    end;
end;

procedure calcul_trolev_mat(g : integer);
{ calcul des niveaux trophiques par inversion d'une matrice }
{ TL = E.(I - D)^(-1) }
{ ou E est le vecteur ligne dont toutes les entrees valent 1 }
var x,y,n1 : integer;
    sum : extended;
    aaa,sss : rmatmat_type;
begin
  with graphes[g] do
    begin
      n1 := nb_sommets + 1;
      SetLength(aaa,n1,n1);
      SetLength(sss,n1,n1);
      for x := 1 to nb_sommets do
        for y := 1 to nb_sommets do with ggg[y] do
          if ( nb_pred > 0 ) then
            aaa[x,y] := m_[x,y]/nb_pred
          else
            aaa[x,y] := 0.0;
      for x := 1 to nb_sommets do
        for y := 1 to nb_sommets do
          if ( x = y ) then
            aaa[x,x] := 1.0 - aaa[x,x]
          else
            aaa[x,y] := -aaa[x,y];
      matinv(nb_sommets,aaa,sss);
      if err_math then { pb convergence }
        begin
          err_math := false;
          iwriteln('*** trolev - no convergence0');
          exit;
        end;
      { test de la validite de l'inverse }
      for x := 1 to nb_sommets do
        for y := 1 to nb_sommets do
          if ( sss[x,y] > nb_sommets ) then
            begin
              iwriteln('*** trolev - no convergence');
              exit;
            end;
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          sum := 0.0;
          for y := 1 to nb_sommets do sum := sum + sss[y,x];
          trolev := sum;
        end;
      trolev_moy := 0.0;
      trolev_max := 0.0;
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          trolev_moy := trolev_moy + trolev;
          trolev_max := max(trolev_max,trolev);
        end;
      trolev_moy := trolev_moy/nb_sommets;
      if ( ival = 1 ) then calcul_trolev_mat_val(g);
    end;
end;

(*procedure calcul_trolev_mat1(g : integer);
{ calcul des niveaux trophiques par serie d'une matrice }
{ TL = E.(I - D)^(-1) = E.(I + D + D^2 + ...) }
{ ou E est le vecteur ligne dont toutes les entrees valent 1 }
{ il faut verifier que la norme de D, N(D) = max dij, tend vers 0... }
const eps = 1.0E-12;
      kmax = 100;
var x,y,z,k,n1 : integer;
    sum,norm,norm1 : extended;
    aaa,bbb,ddd,sss : rmatmat_type;
begin
  with graphes[g] do
    begin
      n1 := nb_sommets + 1;
      SetLength(aaa,n1,n1);
      SetLength(bbb,n1,n1);
      SetLength(ddd,n1,n1);
      SetLength(sss,n1,n1);
      for x := 1 to nb_sommets do
        for y := 1 to nb_sommets do with ggg[y] do
          if ( nb_pred > 0 ) then
            ddd[x,y] := m_[x,y]/nb_pred
          else
            ddd[x,y] := 0.0;
      for x := 1 to nb_sommets do
        for y := 1 to nb_sommets do
          if ( x = y ) then
            aaa[x,y] := 1.0
          else
            aaa[x,y] := 0.0; { A = I }
      for x := 1 to nb_sommets do
        for y := 1 to nb_sommets do
          sss[x,y] := aaa[x,y]; { S = I }
      norm := 1.0;
      k := 0;
      repeat
          k := k + 1;
          for x := 1 to nb_sommets do
            for y := 1 to nb_sommets do
              begin
                sum := 0.0;
                for z := 1 to nb_sommets do sum := sum + ddd[x,z]*aaa[z,y];
                bbb[x,y] := sum;
              end;
          for x := 1 to nb_sommets do
            for y := 1 to nb_sommets do
              aaa[x,y] := bbb[x,y]; { A = D^k }
          norm1 := norm;
          norm := 0.0;
          for x := 1 to nb_sommets do
            for y := 1 to nb_sommets do
              norm := max(norm,aaa[x,y]);
          for x := 1 to nb_sommets do
            for y := 1 to nb_sommets do
              sss[x,y] := sss[x,y] + aaa[x,y]; { S = I + D + ... + D^k }
      until ( k >= kmax ) or ( norm < eps );
      if ( norm1 = norm ) then { pb convergence }
        begin
          iwriteln('*** trolev - no convergence');
          bad_val_trolev(g);
          exit;
        end;
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          sum := 0.0;
          for z := 1 to nb_sommets do sum := sum + sss[z,x];
          trolev := sum;
        end;
      trolev_moy := 0.0;
      trolev_max := 0.0;
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          trolev_moy := trolev_moy + trolev;
          trolev_max := max(trolev_max,trolev);
        end;
      trolev_moy := trolev_moy/nb_sommets;
    end;
end;*)

procedure resultat_path(g : integer);
{ calcul des resultats apres calcul des longueurs }
{ suppose que lmoy contient la somme des longueurs des chemins (et non pas leur moyenne) }
{ non utilise : et que lvar contient la somme des carres des longueurs }
var x,y,k : integer;
    u,a,nb_pathtop_val : extended;
    hnb,hnbval : rvec_type;
begin
  with graphes[g] do
    begin
{ niveaux trophiques }
      trolev_moy := 0.0;
      {trolev_max := 0.0;}
      trolev_max := bad;  { bof... }
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          trolev_moy := trolev_moy + trolev;
          trolev_max := max(trolev_max,trolev);
        end;
      trolev_moy := trolev_moy/nb_sommets;
{ niveaux trophiques graphe value }
      if ( ival = 1 ) then
        begin
          trolev_moy_val := 0.0;
          trolev_max_val := 0.0;
          for x := 1 to nb_sommets do with ggg[x] do
            begin
              trolev_moy_val := trolev_moy_val + trolev_val;
              trolev_max_val := max(trolev_max_val,trolev_val);
            end;
          trolev_moy_val := trolev_moy_val/nb_sommets;
        end;

{ hauteurs }
      haut_max := 0;
      longtop_moy := 0.0;
      longtop_min := big;
      nb_pathtop := 0.0;
      longtop_moy_val := 0.0;
      nb_pathtop_val := 0.0;
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          h_min := big;
          h_max := 0;
          h_moy := 0.0;
          hnb[x] := 0.0;
          if ( ival = 1 ) then
            begin
              h_moy_val := 0.0;
              hnbval[x] := 0.0;
            end;
        end;
      for x := 1 to nb_sommets do
        if ( ggg[x].nb_pred = 0 ) then
          for y := 1 to nb_sommets do with ggg[y] do
            begin
              h_min := imin(h_min,lmin[x,y]);
              h_max := imax(h_max,lmax[x,y]);
              h_moy := h_moy + lmoy[x,y];
              hnb[y] := hnb[y] + lnb[x,y];
              if ( ival = 1 ) then
                begin
                  h_moy_val := h_moy_val + lval[x,y];
                  hnbval[y] := hnbval[y] + lnbval[x,y];
                end;
              haut_max := imax(haut_max,h_max);
              if ( nb_pred > 0 ) and ( nb_succ = 0 ) then
                begin
                  nb_pathtop  := nb_pathtop + lnb[x,y];
                  longtop_moy := longtop_moy + lmoy[x,y];
                  longtop_min := imin(longtop_min,h_min);
                  if ( ival = 1 ) then
                    begin
                      nb_pathtop_val  := nb_pathtop_val + lnbval[x,y];
                      longtop_moy_val := longtop_moy_val + lval[x,y];
                    end;
                end;
            end;
      for x := 1 to nb_sommets do with ggg[x] do
        if ( hnb[x] <> 0.0 ) then
          begin
            h_moy := h_moy/hnb[x];
            if ( ival = 1 ) then
              if ( hnbval[x] <> 0.0 ) then
                h_moy_val := h_moy_val/hnbval[x];
          end;
      for x := 1 to nb_sommets do with ggg[x] do
        if ( nb_pred = 0 ) then
          begin
            h_min := 0;
            h_moy := 0.0;
            h_max := 0;
          end
        else
          if ( h_min = big ) then h_min := 0;

{ hauteur moyenne = moyenne des hauteurs des especes non basales }
      haut_moy := 0.0;
      hauttop_moy := 0.0;
      for x := 1 to nb_sommets do with ggg[x] do
        if ( nb_pred > 0 ) then
          begin
            haut_moy := haut_moy + h_moy;
            if ( nb_succ = 0 ) then
              hauttop_moy := hauttop_moy + h_moy;
          end;
      if ( nb_b < nb_sommets ) then
        haut_moy := haut_moy/(nb_sommets - nb_b);
      if ( nb_t > 0 ) then
        hauttop_moy := hauttop_moy/nb_t;
      { longueur moyenne des chemins basal -> top }
      if ( nb_pathtop > 0.0 ) then
        longtop_moy := longtop_moy/nb_pathtop;

{ hauteur moyenne valuee }
      if ( ival = 1 ) then
        begin
          haut_moy_val := 0.0;
          for x := 1 to nb_sommets do with ggg[x] do
            if ( nb_pred <> 0 ) then
              haut_moy_val := haut_moy_val + h_moy_val;
          if ( nb_b < nb_sommets ) then
            haut_moy_val := haut_moy_val/(nb_sommets - nb_b);
          { longueur moyenne des chemins values basal -> top }
          if ( nb_pathtop_val > 0.0 ) then
            longtop_moy_val := longtop_moy_val/nb_pathtop_val;
        end;

{ longueurs moyennes }
      for x := 1 to nb_sommets do
        for y := 1 to nb_sommets do
          if ( lnb[x,y] <> 0.0 ) then
            lmoy[x,y] := lmoy[x,y]/lnb[x,y];

{ longueurs moyennes valuees }
      if ( ival = 1 ) then
        for x := 1 to nb_sommets do
          for y := 1 to nb_sommets do
            if ( lnbval[x,y] <> 0.0 ) then
              lval[x,y] := lval[x,y]/lnbval[x,y];

{ index omnivorie }
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          u := 0.0;
          y := pred;
          while ( y <> 0 ) do with lis[y] do
            begin
              u := u + ggg[car].h_moy;
              y := cdr;
            end;
          if ( nb_pred > 0 ) then
            oi := u/nb_pred
          else
            oi := 0.0;
        end;
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          u := 0.0;
          y := pred;
          while ( y <> 0 ) do with lis[y] do
            begin
              u := u + sqr(ggg[car].h_moy - oi);
              y := cdr;
            end;
          if ( nb_pred > 0 ) then
            oi := sqrt(u/nb_pred)
          else
            oi := 0.0;
        end;
      o_index := 0.0;
      for x := 1 to nb_sommets do with ggg[x] do
        o_index := o_index + oi;
      if ( nb_sommets > nb_b ) then
        o_index := o_index/(nb_sommets - nb_b);

{ index omnivorie value }
      if ( ival = 1 ) then
        begin
          for x := 1 to nb_sommets do with ggg[x] do
            begin
              u := 0.0;
              a := 0.0;
              y := pred;
              while ( y <> 0 ) do with lis[y] do
                begin
                  u := u + ggg[car].h_moy_val*val;
                  a := a + val;
                  y := cdr;
                end;
              if ( nb_pred > 0 ) then
                oi_val := u/a
              else
                oi_val := 0.0;
             end;
          for x := 1 to nb_sommets do with ggg[x] do
            begin
              u := 0.0;
              a := 0.0;
              y := pred;
              while ( y <> 0 ) do with lis[y] do
                begin
                  u := u + sqr(ggg[car].h_moy_val - oi_val)*val;
                  a := a + val;
                  y := cdr;
                end;
              if ( nb_pred > 0 ) then
                oi_val := sqrt(u/a)
              else
                oi_val := 0.0;
            end;
          o_index_val := 0.0;
          for x := 1 to nb_sommets do with ggg[x] do
            o_index_val := o_index_val + oi_val;
          if ( nb_sommets > nb_b ) then
            o_index_val := o_index_val/(nb_sommets - nb_b);
      end;

{ longueur moyenne }
      pathlen := 0.0;
      k := 0;
      for x := 1 to nb_sommets do
        for y := 1 to nb_sommets do
          if ( lnb[x,y] <> 0.0 ) then
            begin
              k := k + 1;
              pathlen := pathlen + lmoy[x,y];
            end;
       if ( k > 0 ) then pathlen := pathlen/k;
    end;
end;

(* procedure suivante marche pas toujours *)
(*procedure calcul_ht_pondere(g : integer); //sans boucles...
var x,long : integer;
    a,b : extended;
    ht_pond,th : rvec_type; //th garde la 'hauteur temporaire' d'un point

procedure init ;
var i : integer;
begin
  a := 0.0;
  b := 0.0;
  for i := 1 to graphes[g].nb_sommets do th[i] := 0.0;
end;

procedure hauteur(x1 : integer; h : extended);
var u : integer;
begin
  with graphes[g].ggg[x1] do
    if ( nb_pred = 0 ) then
      begin
        a := a + h*long;
        b := b + h;
      end
    else
      begin
        th[x1] := h;
        u := pred;
        while ( u <> 0 ) do with lis[u] do
          begin
            long := long + 1;
            h := th[x1]*val;
            th[car] := h;
            hauteur(car,th[car]);
            u := cdr;
            long := long - 1;
          end;
      end;
end;

begin
  with graphes[g] do
    begin
      for x := 1 to nb_sommets do with ggg[x] do
        if ( pred = 0 ) then
          ht_pond[x] := 0.0
        else
          begin
            init;
            long := 0;
            hauteur(x,1.0);
            h_moy_val := a/b;
          end;
    end;
end;*)

procedure calcul_path_sort(g : integer);
{ calcul des chemins et des niveaux trophiques par tri topologique }
{ le graphe est supposé acyclique }
var x,y : integer;
    ord : ivec_type;
    //w : rvec_type;

procedure traite_path(x,y : integer);
var u : integer;
begin
  with graphes[g] do with ggg[y] do
    begin
      u := pred;
      while ( u <> 0 ) do with lis[u] do
        begin
          lmin[x,y] := imin(lmin[x,y],lmin[x,car] + 1);
          lmax[x,y] := imax(lmax[x,y],lmax[x,car] + 1);
          lmoy[x,y] := lmoy[x,y] + lmoy[x,car] + lnb[x,car];
          lnb[x,y]  := lnb[x,y]  + lnb[x,car];
          if ( ival = 1 ) then
            begin
              lval[x,y] := lval[x,y] + (lval[x,car] + lnbval[x,car])*val;
              lnbval[x,y] := lnbval[x,y] + lnbval[x,car]*val;
            end;
          {lvar[x,y] := lvar[x,y] + lvar[x,car] + 2.0*lmoy[x,car] + lnb[x,car];}
          u := cdr;
        end;
    end;
end;

{ marche, mais inutile : }
{procedure traite_haut_val(x : integer);
var u : integer;
    b,sum : extended;
begin
  with graphes[g] do with ggg[x] do
    begin
      if ( nb_pred = 0 ) then
        begin
          h_moy_val := 0.0;
          w[x] := 1.0;
          exit;
        end;
      sum := 0.0;
      b := 0.0;
      u := pred;
      while ( u <> 0 ) do with lis[u] do
        begin
          sum := sum + (ggg[car].h_moy_val + w[car])*val;
          b := b + w[car]*val;
          u := cdr;
        end;
      h_moy_val := sum;
      w[x] := b;
    end;
end;}

procedure traite_trolev_val(x : integer);
var u : integer;
    a,sum : extended;
begin
  with graphes[g] do with ggg[x] do
    begin
      if ( nb_pred = 0 ) then
        begin
          trolev_val := 1.0;
          exit;
        end;
      sum := 0.0;
      a := 0.0;
      u := pred;
      while ( u <> 0 ) do with lis[u] do
        begin
          sum := sum + ggg[car].trolev_val*val;
          a := a + val;
          u := cdr;
        end;
      trolev_val := 1.0 + sum/a;
    end;
end;

procedure traite_trolev(x : integer);
var u : integer;
    sum : extended;
begin
  with graphes[g] do with ggg[x] do
    begin
      if ( nb_pred = 0 ) then
        begin
          trolev := 1.0;
          exit;
        end;
      sum := 0.0;
      u := pred;
      while ( u <> 0 ) do with lis[u] do
        begin
          sum := sum + ggg[car].trolev;
          u := cdr;
        end;
      trolev := 1.0 + sum/nb_pred;
    end;
end;

procedure calcul_dlc;
{ calcul de la distribution des longueurs des chemins basal -> top }
{ les sommets sont ordonnes selon topological sort }
{ pour chaque sommet x, }
{ ddd[x,*] est la distribution des longueurs des chemins basal -> x }
{ ldd[x] est le nombre d'elements de la distribution }
var x,y,j,u,n1,max : integer;
    moy,sum,a2,sigma : extended;
    ddd : rmatmat_type;
    ldd : ivecvec_type;
begin
  with graphes[g] do
    begin
      n1 := nb_sommets + 1;
      SetLength(ddd,n1,n1);
      SetLength(ldd,n1);
      for x := 1 to nb_sommets do
        for j := 0 to nb_sommets do
          ddd[x,j] := 0.0;
      for x := 1 to nb_sommets do ldd[x] := 0;
      for j := 1 to nb_sommets do dlc[j] := 0.0;
      dlcmax := 0;
      for y := 1 to nb_sommets do
        begin
          x := ord[y];
          with ggg[x] do
            if ( nb_pred = 0 ) then { espece basale }
              ddd[x,0] := 1.0
            else
              begin
                max := 0;
                u := pred;
                while ( u <> 0 ) do with lis[u] do
                  begin
                    for j := 0 to ldd[car] do
                      ddd[x,j+1] := ddd[x,j+1] + ddd[car,j];
                    max := imax(max,ldd[car]+1);
                    u := cdr;
                  end;
                ldd[x] := max;
                if ( nb_succ = 0 ) then { espece top }
                  for j := 1 to ldd[x] do
                    begin
                      dlc[j] := dlc[j] + ddd[x,j];
                      dlcmax := imax(dlcmax,ldd[x]); { en fait dlcmax = haut_max }
                    end;
              end;
        end;
    end;
  { moyenne }
  moy := 0.0;
  sum := 0.0;
  for j := 1 to dlcmax do
    begin
      sum := sum + dlc[j];
      moy := moy + j*dlc[j];
    end;
  if ( sum > 0.0 ) then moy := moy/sum;
  { variance }
  a2 := 0.0;
  for j := 1 to dlcmax do a2 := a2 + j*j*dlc[j];
  if ( sum > 0.0 ) then a2 := a2/sum;
  a2 := a2 - moy*moy;
  if ( a2 >= 0.0 ) then
    sigma := sqrt(a2)
  else
    sigma := 0.0;

  {iwriteln('Distribution of path lengths basal -> top');
  for j := 1 to dlcmax do
    iwriteln(IntToStr(j) + ' ' + s_ecri_val(dlc[j]));
  iwriteln('moy = ' + s_ecri_val(moy));
  iwriteln('sigma = ' + s_ecri_val(sigma)); }
end;

(*procedure calcul_dlcval;
{ ne fonctionne pas }
{ calcul de la distribution des longueurs des chemins values basal -> top }
{ les sommets sont ordonnes selon topological sort }
{ pour chaque sommet x, }
{ ddd[x,*] est la distribution des longueurs des chemins basal -> x }
{ ldd[x] est le nombre d'elements de la distribution }
var x,y,j,u,n1,max,k : integer;
    moy,sum,a : extended;
    ddv : rmatmat_type;
    ldv : ivecvec_type;
begin
  with graphes[g] do
    begin
      n1 := vecmax+1;
      delta_dlcval := 1.0; {!!!}
      delta_dlcval := exp(nb_sommets*ln(valmax));
      delta_dlcval := vecmax/valmax;
      iwriteln('delta = ' + FloatToStr(delta_dlcval));
      SetLength(ddv,n1,n1);
      SetLength(ldv,n1);
      for x := 1 to n1-1 do
        for j := 0 to n1-1 do
          ddv[x,j] := 0.0;
      for x := 1 to n1-1 do ldv[x] := 0;
      for j := 1 to n1-1 do dlcval[j] := 0.0;
      dlcvalmax := 0;
      for y := 1 to nb_sommets do
        begin
          x := ord[y];
          with ggg[x] do
            if ( nb_pred = 0 ) then { espece basale }
              ddv[x,0] := 1.0
            else
              begin
                max := 0;
                u := pred;
                while ( u <> 0 ) do with lis[u] do
                  begin
                    for j := 0 to ldv[car] do
                      begin
                        k := trunc((j+1)*val{/valmax});
                        if ( k > n1 ) then exit;
                        ddv[x,k] := ddv[x,k] + ddv[car,j];
                        max := imax(max,k);
                      end;
                    u := cdr;
                  end;
                ldv[x] := max;
                if ( nb_succ = 0 ) then { espece top }
                  for j := 1 to ldv[x] do
                    begin
                      dlcval[j] := dlcval[j] + ddv[x,j];
                      dlcvalmax := imax(dlcvalmax,ldv[x]);
                    end;
              end;
        end;
    end;
  { moyenne val }
  moy := 0.0;
  sum := 0.0;
  for j := 1 to dlcvalmax do
    begin
      sum := sum + dlcval[j];
      moy := moy + j*dlcval[j];
    end;
  if ( sum > 0.0 ) then moy := moy/sum;
  iwriteln('Distribution of weighted path lengths basal -> top');
  iwriteln('moy_val = ' + s_ecri_val(moy)); { incorrect }
  for j := 1 to dlcvalmax do
    iwriteln(IntToStr(j) + ' ' + s_ecri_val(dlcval[j]));
end;*)

procedure init_path;
var x,y : integer;
begin
  with graphes[g] do
    for x := 1 to nb_sommets do
      for y := 1 to nb_sommets do
        if ( m_[x,y] = 0 ) then
          begin
            lmin[x,y] := big;
            lmax[x,y] := -big;
            lmoy[x,y] := 0.0;
            lnb[x,y]  := 0.0;
            lval[x,y] := 0.0;
            lnbval[x,y] := 0.0;
            {lvar[x,y] := 0.0;}
          end
        else
          begin
            lmin[x,y] := 1;
            lmax[x,y] := 1;
            lmoy[x,y] := 1.0;
            lnb[x,y]  := 1.0;
            lval[x,y] := mr_[x,y];
            lnbval[x,y] := mr_[x,y];
            {lvar[x,y] := 1.0;}
          end;
end;

begin
  with graphes[g] do
    begin
      top_sort(g,ord);
      init_path;
      for x := 1 to nb_sommets do
        for y := 1 to nb_sommets do
          traite_path(ord[x],ord[y]);
      for x := 1 to nb_sommets do traite_trolev(ord[x]);
      if ( ival = 1 ) then
        begin
          for x := 1 to nb_sommets do traite_trolev_val(ord[x]);
          { inutile : }
          {for x := 1 to nb_sommets do traite_haut_val(ord[x]);
          for x := 1 to nb_sommets do with ggg[x] do
            if ( nb_pred > 0 ) then
              h_moy_val := h_moy_val/w[x];}
        end;
      resultat_path(g);
      calcul_dlc;
      //if ( ival = 1 ) then calcul_dlcval;
    end;
end;

function  t_out : boolean;
{ 1 min = 60000 ms }
{ 6 s = 6000 ms }
begin
  t_out := ( (clock - ms) > 6000 );
end;

procedure calcul_path_recherche(g : integer);
{ calcul des chemins par recherche exhaustive de tous les chemins dans le graphe }
{ les cycles ne sont pas parcourus }
{ l'algorithme est exponentiel... }
var x,y,p,nb0 : integer;
    v : extended;
    visit : ivec_type;

procedure traite(x,y : integer);
var k : integer;
begin
  lmin[x,y] := imin(lmin[x,y],p);
  lmax[x,y] := imax(lmax[x,y],p);
  lmoy[x,y] := lmoy[x,y] + p;
  lnb[x,y]  := lnb[x,y]  + 1.0;
  if ( graphes[g].ival = 1 ) then
    begin
      lval[x,y] := lval[x,y] + p*v;
      lnbval[x,y] := lnbval[x,y] + v;
    end;
  {lvar[x,y] := lvar[x,y] + p*p;}
  with graphes[g] do
    if ( ggg[x].nb_pred = 0 ) then
      if ( ggg[y].nb_pred > 0 ) and ( ggg[y].nb_succ = 0 ) then
        begin
          dlc[p] := dlc[p] + 1.0;
          dlcmax := imax(dlcmax,p);
          {if ( ival = 1 ) then}
            begin
            { ne fonctionne pas : }
            { p*v peut prendre des valeurs tres grandes ou tres petites... }
              //iwriteln('p v '+IntToStr(p)+' '+ FloatToStr(v)+' '+FloatToStr(p*v));
              //k := trunc(p*v/delta_dlcval);
              //k := trunc(v/delta_dlcval);
              //dlcval[k] := dlcval[k] + 1.0;
              //dlcvalmax := imax(dlcvalmax,k);
              //iwriteln('k = ' + IntToStr(k)+' '+FloatToStr(ddv[y,k]));
            end;
        end;
end;

procedure recherche(x0,x : integer); forward;

procedure recherche1(x0,x : integer);
var u : integer;
begin
  with graphes[g] do with ggg[x] do
    begin
      u := succ;
      while ( u <> 0 ) do with lis[u] do
        begin
          if ( visit[car] = 0 ) then
            begin
              visit[car] := 1;
              v := v*val;
              traite(x0,car);
              recherche(x0,car);
              visit[car] := 0;
              v := v/val;
            end;
          u := cdr;
        end;
    end;
end;

procedure recherche(x0,x : integer);
begin
  with graphes[g] do with ggg[x] do
    if ( nb0 = 0 ) then
    else
      if ( nb_succ <> 0 ) then
        begin
          p := p + 1;
          time_out := t_out;
          if time_out then exit;
          recherche1(x0,x);
          p := p - 1;
          if ( p = 0 ) then nb0 := nb0 - 1;
        end;
end;

procedure calcul_dlc;
var j : integer;
    moy,sum,a2,sigma : extended;
begin
  with graphes[g] do
    begin
     { moyenne }
      moy := 0.0;
      sum := 0.0;
      for j := 1 to dlcmax do
        begin
          sum := sum + dlc[j];
          moy := moy + j*dlc[j];
        end;
      if ( sum > 0.0 ) then moy := moy/sum;
      { variance }
      a2 := 0.0;
      for j := 1 to dlcmax do a2 := a2 + j*j*dlc[j];
      if ( sum > 0.0 ) then a2 := a2/sum;
      a2 := a2 - moy*moy;
      if ( a2 >= 0.0 ) then
        sigma := sqrt(a2)
      else
        sigma := 0.0;

      {iwriteln('Distribution of path lengths basal -> top');
      for j := 1 to dlcmax do
        iwriteln(IntToStr(j) + ' ' + s_ecri_val(dlc[j]));
      iwriteln('moy = ' + s_ecri_val(moy));
      iwriteln('sigma = ' + s_ecri_val(sigma));}

     { moyenne val ; calcul incorrect }
      //if ( ival = 0 ) then exit;
      (*moy := 0.0;
      sum := 0.0;
      for j := 1 to dlcvalmax do
        begin
          sum := sum + dlcval[j];
          //moy := moy + j*dlcval[j];
          moy := moy + j*dlc[j]*dlcval[j];
        end;
      if ( sum > 0.0 ) then moy := moy/sum;
      iwriteln('Distribution of weighted path lengths basal -> top');
      for j := 1 to dlcvalmax do
        iwriteln(IntToStr(j) + ' ' + s_ecri_val(dlcval[j]));
      iwriteln('moy val = ' + s_ecri_val(moy));*)
    end;
end;

procedure init_dlc;
var j : integer;
begin
  with graphes[g] do
    begin
      for j := 1 to nb_sommets do dlc[j] := 0.0;
      dlcmax := 0;
      //if ( ival = 0 ) then exit;
      for j := 1 to vecmax do dlcval[j] := 0.0;
      dlcvalmax := 0;
      delta_dlcval := 1.0;
      //delta_dlcval := 1.0/nb_sommets*exp(nb_sommets*ln(valmax));
      //iwriteln('delta = ' + FloatToStr(delta_dlcval));
    end;
end;

procedure init_path_recherche(g : integer);
var x,y : integer;
begin
  with graphes[g] do
    for x := 1 to nb_sommets do
      for y := 1 to nb_sommets do
        begin
          lmin[x,y] := big;
          lmax[x,y] := -big;
          lmoy[x,y] := 0.0;
          {lvar[x,y] := 0.0;}
          lnb[x,y]  := 0.0;
          if ( ival = 1 ) then
            begin
              lval[x,y]   := 0.0;
              lnbval[x,y] := 1.0;
            end;
        end;
  init_dlc;
end;

begin
  with graphes[g] do
    begin
      init_path_recherche(g);
      for x := 1 to nb_sommets do
        begin
          for y := 1 to nb_sommets do visit[y] := 0;
          p := 0;
          v := 1.0;
          nb0 := ggg[x].nb_succ;
          recherche(x,x);
          if time_out then exit;
        end;
      resultat_path(g);
      calcul_dlc;
    end;
end;

procedure bad_val(g : integer);
var x,y : integer;
begin
  with graphes[g] do
    begin
      haut_moy := bad;
      haut_moy_val := bad;
      haut_max := bad;
      {haut_max_val := bad;}
      hauttop_moy := bad;
      hauttop_moy_val := bad;
      trolev_moy := bad;
      trolev_max := bad;
      trolev_moy_val := bad;
      trolev_max_val := bad;
      o_index := bad;
      o_index_val := bad;
      pathlen := bad;
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          h_min := bad;
          h_moy := bad;
          h_moy_val := bad;
          h_max := bad;
          trolev := bad;
          trolev_val := bad;
          oi := bad;
          oi_val := bad;
          nb_pathtop  := bad;
          longtop_moy := bad;
          longtop_moy_val := bad;
          longtop_min := bad;
        end;
      for x := 1 to nb_sommets do
        for y := 1 to nb_sommets do
          begin
            lmax[x,y] := bad;
            lmoy[x,y] := bad;
            {lvar[x,y] := bad;}
            lnb[x,y]  := bad;
            lnbval[x,y] := bad;
          end;
    end;
end;

procedure bad_val_simul(g : integer);
begin
  with graphes[g] do
    begin
      haut_moy := bad;
      haut_moy_val := bad;
      haut_max := bad;
      {haut_max_val := bad;}
      hauttop_moy := bad;
      hauttop_moy_val := bad;
      o_index := bad;
      o_index_val := bad;
      pathlen := bad;
      trolev_moy := bad;
      trolev_max := bad;
    end;
end;

procedure calcul_path(g : integer);
begin
  bad_val(g);
  with graphes[g] do
    if ( nb_cycles = 0 ) and ( nb_boucles = 0 ) then
      begin
        calcul_path_sort(g);
        iwriteln('  path sort');
      end
    else
      if ( nb_b > 0 ) then
          if not time_out then
            begin
              ms := clock;
              calcul_trolev_mat(g);
              calcul_path_recherche(g);
              if time_out then
                begin
                  iwriteln('*** path search - time out');
                  exit;
                end;
              iwriteln('  path search');
              {iwriteln('Path search ' + s_ecri_t_exec(clock-ms));}
            end
          else
            calcul_trolev_mat(g)
      else
        iwriteln('*** path search - no basal species');
end;

procedure calcul_path_simul(g : integer);
begin
  bad_val_simul(g);
  with graphes[g] do
    if ( nb_cycles = 0 ) and ( nb_boucles = 0 ) then
      calcul_path_sort(g)
    else
      if ( nb_b > 0 ) then
          if not time_out then
            begin
              ms := clock;
              calcul_trolev_mat(g);
              calcul_path_recherche(g);
              if time_out then
                begin
                  iwriteln('*** path search - time out');
                  exit;
                end;
            end
          else
            calcul_trolev_mat(g)
      else
        iwriteln('*** path search - no basal species');
end;

procedure calcul_path_aggreg(g : integer);
begin
  bad_val(g);
  with graphes[g] do
    if ( nb_cycles = 0 ) and ( nb_boucles = 0 ) then
      calcul_path_sort(g)
    else
      if ( nb_b > 0 ) then
          if not time_out then
            begin
              ms := clock;
              calcul_trolev_mat(g);
              calcul_path_recherche(g);
              if time_out then
                begin
                  iwriteln('*** path search - time out');
                  exit;
                end;
            end
          else
            calcul_trolev_mat(g)
      else
        iwriteln('*** path search - no basal species');
end;

procedure calcul_graphe(g : integer);
{ suppose que m_ et mr_ sont les matrices du graphe (procedure graphe2mat) }
{ g est l'indice du graphe alloue (procedure alloc_graphe),
{ qui est deja cree s'il a ete lu }
{ mais qui ne sera cree (procedure create_graphe) }
{ qu'a la fin du calcul s'il est synthetique }
var ms1 : integer;
begin
  with form_pad do
    begin
      if not Visible then show;
      SetFocus;
    end;
  if ( graphes[g].nb_sommets = 0 ) then
    begin
      g_ := g;
      exit;
    end;

  ms1 := clock;

  with graphes[g] do
    iwriteln('Compute ' + name + '#' + IntToStr(icre));

  calcul_arcs(g);
    iwriteln('  arcs');
  calcul_connect(g);
    iwriteln('  connect');
  calcul_clust(g);
    iwriteln('  clust');
  calcul_assort(g);
    iwriteln('  assort');
  calcul_dist_larg(g);
    iwriteln('  dist larg');
  calcul_prim(g);
    iwriteln('  prim');
  calcul_markov(g);
    iwriteln('  markov');
  calcul_cycle(g);
    iwriteln('  cycle');
  calcul_path(g);
    iwriteln('  path');
  calcul_nb_larg(g);

  iwriteln('--> ' + s_ecri_t_exec(clock-ms1));

  g_ := g;

end;

procedure calcul_graphe_simul(g : integer);
begin
  calcul_arcs(g);
  calcul_connect(g);
  calcul_clust(g);
  calcul_assort(g);
  calcul_dist_larg(g);
  calcul_prim(g);
  calcul_markov(g);
  calcul_cycle(g);
  calcul_path_simul(g);
end;

procedure calcul_graphe_aggreg(g : integer);
begin
  calcul_arcs(g);
  calcul_connect(g);
  calcul_clust(g);
  calcul_assort(g);
  calcul_dist_larg(g);
  calcul_prim(g);
  calcul_markov(g);
  calcul_cycle(g);
  calcul_path_aggreg(g);
end;


procedure are_different(g: integer);

  function sim_tro(g, s1, s2: integer) : integer;
    var i, j, k, sim, sim_trophique: integer;
    begin
      sim_trophique:=0;
      for k := 1 to graphes[g].nb_sommets do
        begin
          if ((m_[k,s1] = 1) and (m_[k,s2] = 1)) then
          begin
            sim_trophique := 1;
            //exit;
          end;
          if ((m_[s1,k] = 1) and (m_[s2,k] = 1)) then
          begin
            sim_trophique := 1;
            //exit;
          end;
        end;
      sim_tro := sim_trophique;
    end;



var gr, i, j, nb_dif_aic, nb_dif_tro : integer;
begin
  with graphes[g] do
  begin
    nb_dif_aic := 0;
    nb_dif_tro := 0;
    for i := 1 to nb_sommets do
      for j := 1 to i-1 do
        begin
          if ggg[i].group_aic = ggg[j].group_aic then
            if sim_tro(g, i, j) = 0 then nb_dif_aic := nb_dif_aic + 1;
          if ggg[i].group_tro = ggg[j].group_tro then
            if sim_tro(g, i, j) = 0 then nb_dif_tro := nb_dif_tro + 1;
        end;
  end;
  iwriteln('species without common links in AIC groups: ' + inttostr(nb_dif_aic));
  iwriteln('species without common links in trophic groups: ' + inttostr(nb_dif_tro));

end;


procedure calcul_nb_larg(g : integer);
{ computation of the number of minimal paths }
{ between any 2 nodes in the directed graph, using breadth first search }
{ lnb_min[x,y] }
var x : integer;
    visit,d,e : ivec_type;


procedure verif(g: integer);

var i,j : integer;
    f: textfile;
    s : string;

begin
  AssignFile(f,'D:\test.txt');
  rewrite(f);
  iwriteln('inside');
  for i:=1 to graphes[g].nb_sommets do
    begin
    s:='';
    for j:= 1 to graphes[g].nb_sommets do
      begin
        s:=s + floattostr(lnb_min[i,j]) + hortab;
        Write(F,floattostr(lnb_min[i,j]));
        write(f, hortab);
      end;
    iwriteln(s);
    writeln(f,hortab);
    end;
  closefile(f);
end;



procedure parc_larg(x : integer);
var u,niv,i,j,nb_niv : integer;
begin
  with graphes[g] do
    begin
      for u := 1 to nb_sommets do visit[u] := 0;
      visit[x] := 1;
      niv := 1;
      nb_niv := 1;
      d[1] := x;
      while ( nb_niv <> 0 ) do
        begin
          j := 0;
          for i := 1 to nb_niv do with ggg[d[i]] do
            begin
              u := succ;
              while ( u <> 0 ) do with lis[u] do
                begin
                  if ( lmina[x,car] = niv ) then
                    lnb_min[x,car] := lnb_min[x,car] + 1;
                  if ( visit[car] = 0 ) then
                    begin
                      visit[car] := 1;
                      j := j + 1;
                      e[j] := car;
                    end;
                  u := cdr;
                end;
            end;
          nb_niv := j;
          for i := 1 to nb_niv do d[i] := e[i];
          niv := niv + 1;
        end;
    end;
end;

procedure init_nb(g : integer);
var x,y : integer;
begin
  with graphes[g] do
    begin
      for x := 1 to nb_sommets do
        for y := 1 to nb_sommets do
          lnb_min[x,y] := 0;
    end;
end;

begin
  with graphes[g] do
    begin
      init_nb(g);
      for x := 1 to nb_sommets do parc_larg(x);
    end;
    verif(g);
end;

procedure betweeness(g: integer);
// calculation of species betweeness centrality

var x,y,v : integer;
    //pcc_v : imat_type; //nb minimal path from i to j going through v (pcc = plus court chemin)
    visit,d,e : ivec_type;

procedure parc_larg(x,v : integer); //x: starting node, v: path from x go through v?
var u,niv,i,j,nb_niv : integer;
    tab_chemin : ivec_type; //to know if we are on a path from x going through v
begin
  with graphes[g] do
    begin
      for u := 1 to nb_sommets do
      begin
        visit[u] := 0;
        tab_chemin[u] := 0;
      end;
      visit[x] := 1;
      //niv := 1;
      nb_niv := 1;
      d[1] := x;
      while ( nb_niv <> 0 ) do
        begin
          j := 0;
          for i := 1 to nb_niv do with ggg[d[i]] do
            begin
              u := succ;
              while ( u <> 0 ) do with lis[u] do
                begin
                  if d[i] = v then
                    if lmina[x,car] = lmina[x,v] + 1 then  // il n'y a pas de chemin plus court que celui qui passe par v pour aller a car
                      begin
                        pcc_v[x,car] := pcc_v[x,car] + 1;
                        tab_chemin[car] :=1;
                      end;
                  if tab_chemin[d[i]] = 1 then
                    if lmina[x,car] = lmina[x,d[i]] + 1 then  // il n'y a pas de chemin plus court que celui qui passe par d[i] (qui est sur le chemin depuis v) pour aller a car
                      begin
                        pcc_v[x,car] := pcc_v[x,car] + 1;
                        tab_chemin[car] :=1;
                      end;
                  if ( visit[car] = 0 ) then
                    begin
                      visit[car] := 1;
                      j := j + 1;
                      e[j] := car;
                    end;
                  u := cdr;
                end;
            end;
          nb_niv := j;
          for i := 1 to nb_niv do d[i] := e[i];
          //niv := niv + 1;
        end;
    end;
end;


procedure init(g: integer);
var k,l : integer;
begin
  for k:=1 to graphes[g].nb_sommets do
    for l:=1 to graphes[g].nb_sommets do
      pcc_v[k,l]:=0;
end;

begin with graphes[g] do begin
  for v:=1 to nb_sommets do
    begin
      init(g);
      for x:=1 to nb_sommets do
        begin
          parc_larg(x,v);
          for y:=1 to nb_sommets do
            if ((lnb_min[x,y] <> 0) and (x <> v) and (x <> y) and (v <> y))  then
              ggg[v].between := ggg[v].between + pcc_v[x,y] / lnb_min[x,y];
        end;
    end;
    for v:=1 to nb_sommets do //verifications
      iwriteln('betweeness de ' + inttostr(v) + ' = ' + floattostr(ggg[v].between));

end; end;



end.
