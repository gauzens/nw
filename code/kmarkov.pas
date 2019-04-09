unit kmarkov;

{ @@@@@@  chaine de Markov associee au graphe  @@@@@@ }

interface

procedure calcul_prim(g : integer);
procedure calcul_markov(g : integer);

implementation

uses SysUtils,kglobvar,kmath,kutil,kgestiong,kmanipg;

procedure matvalvecd1_sparse(g : integer;var w : rvecvec_type;var lambda1 : extended);
{ recherche de la valeur propre dominante lambda1 }
{ de la matrice d'adjacence du graphe g }
{ et du vecteur propre a droite w par iteration }
label 1;
const eps = 1.0E-9;
      tmax = 10000;
var n,t,i,u : integer;
    w1 : rvecvec_type;
    sum,lamb,lamb1 : extended;
begin
  with graphes[g] do
    begin
      n := nb_sommets;
      SetLength(w1,n+1);
      for i := 1 to n do w[i] := 1.0/n;
      lamb := 1.0;
      t := 0;
      repeat
        t := t + 1;
        lamb1 := lamb;
        for i := 1 to n do with ggg[i] do
          begin
            sum := 0.0;
            u := succ;
            while ( u <> 0 ) do with lis[u] do
              begin
                sum := sum + w[car];
                u := cdr;
              end;
            w1[i] := sum;
          end;
        sum := 0.0;
        for i := 1 to n do sum := sum + w1[i];
        if ( sum > 0.0 ) then
          for i := 1 to n do w[i] := w1[i]/sum
        else
          goto 1;
        lamb := sum;
      until ( abs(lamb1 - lamb) < eps ) or ( t >= tmax );
      lambda1 := lamb;
      //iwriteln('matvalvecd1  t = ' + IntToStr(t) + ' d = ' + s_ecri_val(abs(lamb1 - lamb)));
1 :
    end;
end;

procedure matvalvecd1_sparse_val(g : integer;var w : rvecvec_type;var lambda1 : extended);
{ recherche de la valeur propre dominante lambda1 }
{ de la matrice d'adjacence du graphe value g }
{ et du vecteur propre a droite w par iteration }
label 1;
const eps = 1.0E-9;
      tmax = 10000;
var n,t,i,u : integer;
    w1 : rvecvec_type;
    sum,lamb,lamb1 : extended;
begin
  with graphes[g] do
    begin
      n := nb_sommets;
      SetLength(w1,n+1);
      for i := 1 to n do w[i] := 1.0/n;
      lamb := 1.0;
      t := 0;
      repeat
        t := t + 1;
        lamb1 := lamb;
        for i := 1 to n do with ggg[i] do
          begin
            sum := 0.0;
            u := succ;
            while ( u <> 0 ) do with lis[u] do
              begin
                sum := sum + val*w[car];
                u := cdr;
              end;
            w1[i] := sum;
          end;
        sum := 0.0;
        for i := 1 to n do sum := sum + w1[i];
        if ( sum > 0.0 ) then
          for i := 1 to n do w[i] := w1[i]/sum
        else
          goto 1;
        lamb := sum;
      until ( abs(lamb1 - lamb) < eps ) or ( t >= tmax );
      lambda1 := lamb;
      //iwriteln('matvalvecd1  t = ' + IntToStr(t) + ' d = ' + s_ecri_val(abs(lamb1 - lamb)));
1 :
    end;
end;

procedure matkovvecd_sparse(g : integer;var w : rvecvec_type);
{ recherche du vecteur propre a droite w par iteration }
{ de la matrice d'adjacence du graphe g, }
{ chaine de Markov irreductible (lambda = 1) }
const eps = 1.0E-9;
      tmax = 10000;
var i,t,u,n : integer;
    w1 : rvecvec_type;
    sum,d : extended;
begin
  with graphes[g] do
    begin
      n := nb_sommets;
      SetLength(w1,n+1);
      for i := 1 to n do w[i] := 1.0/n;
      t := 0;
      repeat
        t := t + 1;
        for i := 1 to n do with ggg[i] do
          begin
            sum := 0.0;
            u := succ;
            while ( u <> 0 ) do with lis[u] do
              begin
                sum := sum + w[car];
                u := cdr;
              end;
            w1[i] := sum;
          end;
        d := 0.0;
        for i := 1 to n do d := d + abs(w1[i] - w[i]);
        for i := 1 to n do w[i] := w1[i];
      until ( d < eps ) or ( t >= tmax);
    end;
end;

procedure matkovvecd_sparse_val(g : integer;var w : rvecvec_type);
{ recherche du vecteur propre a droite w par iteration }
{ de la matrice d'adjacence du graphe value g, }
{ chaine de Markov irreductible (lambda = 1) }
const eps = 1.0E-9;
      tmax = 10000;
var i,t,u,n : integer;
    w1 : rvecvec_type;
    sum,d : extended;
begin
  with graphes[g] do
    begin
      n := nb_sommets;
      SetLength(w1,n+1);
      for i := 1 to n do w[i] := 1.0/n;
      t := 0;
      repeat
        t := t + 1;
        for i := 1 to n do with ggg[i] do
          begin
            sum := 0.0;
            u := succ;
            while ( u <> 0 ) do with lis[u] do
              begin
                sum := sum + val*w[car];
                u := cdr;
              end;
            w1[i] := sum;
          end;
        d := 0.0;
        for i := 1 to n do d := d + abs(w1[i] - w[i]);
        for i := 1 to n do w[i] := w1[i];
      until ( d < eps ) or ( t >= tmax);
    end;
end;

procedure matkovvecg_sparse(g : integer;var v : rvecvec_type);
{ recherche du vecteur propre a gauche v par iteration }
{ de la matrice d'adjacence du graphe g, }
{ chaine de Markov irreductible (lambda = 1) }
const eps = 1.0E-9;
      tmax = 10000;
var j,t,u,n : integer;
    v1 : rvecvec_type;
    sum,d : extended;
begin
  with graphes[g] do
    begin
      n := nb_sommets;
      SetLength(v1,n+1);
      for j := 1 to n do v[j] := 1.0/n;
      t := 0;
      repeat
        t := t + 1;
        for j := 1 to n do with ggg[j] do
          begin
            sum := 0.0;
            u := pred;
            while ( u <> 0 ) do with lis[u] do
              begin
                sum := sum + v[car];
                u := cdr;
              end;
            v1[j] := sum;
          end;
        d := 0.0;
        for j := 1 to n do d := d + abs(v1[j] - v[j]);
        for j := 1 to n do v[j] := v1[j];
      until ( d < eps ) or ( t >= tmax);
      //iwriteln('matkovvecg  t = ' + IntToStr(t) + ' d = ' + s_ecri_val(d));
    end;
end;

procedure matkovvecg_sparse_val(g : integer;var v : rvecvec_type);
{ recherche du vecteur propre a gauche v par iteration }
{ de la matrice d'adjacence du graphe value g, }
{ chaine de Markov irreductible (lambda = 1) }
const eps = 1.0E-9;
      tmax = 10000;
var j,t,u,n : integer;
    v1 : rvecvec_type;
    sum,d : extended;
begin
  with graphes[g] do
    begin
      n := nb_sommets;
      SetLength(v1,n+1);
      for j := 1 to n do v[j] := 1.0/n;
      t := 0;
      repeat
        t := t + 1;
        for j := 1 to n do with ggg[j] do
          begin
            sum := 0.0;
            u := pred;
            while ( u <> 0 ) do with lis[u] do
              begin
                sum := sum + v[car]*val;
                u := cdr;
              end;
            v1[j] := sum;
          end;
        d := 0.0;
        for j := 1 to n do d := d + abs(v1[j] - v[j]);
        for j := 1 to n do v[j] := v1[j];
      until ( d < eps ) or ( t >= tmax);
      //iwriteln('matkovvecg  t = ' + IntToStr(t) + ' d = ' + s_ecri_val(d));
    end;
end;

procedure calcul_prim(g : integer);
{ determine l'irreductibilite et l'index d'imprimitivite du graphe }
{ iprim = 0 -> graphe reductible }
{ iprim = 1 -> graphe irreductible et acyclique = primitif }
{ iprim > 1 -> graphe irreductible et cyclique d'index iprim }

var x,x0,maxdeg,niv,maxlencyc,i,n : integer;
    loop : boolean;
    visit,prof : ivec_type;
    sss : imatmat_type; { 0..vecmax, 0..vecmax }
    lens : ivecvec_type; { 0..vecmax+1 }
    lencyc,tablen,tab : ivecvec_type; { 1..2*vecmax }

procedure parc_larg_ar(x : integer);
{ parcours largeur d'abord vers l'arriere a partir du sommet x }
var u,y : integer;
begin
  with graphes[g] do
    begin
      initq;
      loop := false;
      for y := 1 to nb_sommets do
        begin
          visit[y] := 0;
          prof[y]  := -1 {-3};
        end;
      visit[x] := 1;
      prof[x]  := 0;
      pushq(x);
      while not videq do
        begin
          y := popq;
          with ggg[y] do
            begin
              u := pred;
              while ( u <> 0 ) do with lis[u] do
                begin
                  if ( car = y ) then loop := true;
                  if ( visit[car] = 0 ) then
                    begin
                      visit[car] := 1;
                      prof[car]  := prof[y] + 1;
                      pushq(car);
                    end;
                  u := cdr;
                end;
            end;
        end;
    end;
end;

procedure parc_larg_av(x : integer);
{ parcours largeur d'abord vers l'avant a partir du sommet x }
var u,y,i,k,n1 : integer;
begin
  with graphes[g] do
    begin
      for i := 1 to maxlencyc do lencyc[i] := 0;
      for i := 0 to nb_sommets+1 do lens[i] := 0;
      for y := 1 to nb_sommets do visit[y] := 0;
      visit[x] := 1;
      niv := 0;
      sss[niv,lens[niv]] := x;
      lens[niv] := 1;
      while ( lens[niv] > 0 ) do
        begin
          for i := 0 to lens[niv]-1 do
            begin
              y := sss[niv,i];
              with ggg[y] do
                begin
                  u := succ;
                  while ( u <> 0 ) do with lis[u] do
                    begin
                      n1 := niv + 1;
                      if ( visit[car] = 0 ) then
                        begin
                          visit[car] := 1;
                          sss[n1,lens[n1]] := car;
                          lens[n1] := lens[n1] + 1;
                        end;
                      k := prof[car] + n1;
                      if ( k >= 1 ) then
                        if  ( k < maxlencyc ) then
                          lencyc[k] := 1
                        else
                          iwriteln('*** - error prim');
                      u := cdr;
                    end;
                end;
            end;
          niv := niv + 1;
        end;
    end;
end;

function  gcd(a,b : integer) : integer;
begin
  if ( b = 0 ) then
    gcd := a
  else
    gcd := gcd(b,a mod b);
end;

function  multigcd(n : integer) : integer;
{ gcd(x1, ..., xn) }
var m,i,k : integer;
begin
  m := tablen[1];
  if ( n = 0 ) then
    begin
      multigcd := 0;
      exit;
    end;
  if ( n = 1 ) then
    begin
      multigcd := m;
      exit;
    end;
  if ( n = 2 ) then
    begin
      multigcd := gcd(m,tablen[2]);
      exit;
    end;
  for i := 1 to m do tab[i] := 0;
  for i := 1 to n do tab[tablen[i] mod m] := 1;
  k := 0;
  for i := 1 to m do
    if ( tab[i] = 1 ) then
      begin
        k := k + 1;
        tablen[k] := i;
      end;
  if ( k = 0 ) then
    begin
      multigcd := m;
      exit;
    end;
  multigcd := multigcd(k);
end;

begin
  with graphes[g] do
    begin
      maxlencyc := 2*nb_sommets;
      SetLength(sss,nb_sommets+1,nb_sommets+1);
      SetLength(lens,nb_sommets+2);
      SetLength(lencyc,maxlencyc+1);
      SetLength(tablen,maxlencyc+1);
      SetLength(tab,maxlencyc+1);
      { cherche le sommet de plus grand degre out : }
      maxdeg := 0;
      x0 := 1;
      for x := 1 to nb_sommets do with ggg[x] do
        if ( nb_succ > maxdeg ) then
          begin
            x0 := x;
            maxdeg := nb_succ;
          end;
      parc_larg_ar(x0); { parcours arriere }
      parc_larg_av(x0); { parcours avant }
      { irreducible = strongly connected }
      for x := 1 to nb_sommets do
        if ( prof[x] < 0 ) or ( visit[x] = 0 ) then
          begin
            iprim := 0;
            exit;
          end;
      if loop then
        begin
          iprim := 1;
          exit;
        end;
      n := 0;
      for i := 1 to maxlencyc do
        if ( lencyc[i] = 1 ) then
          begin
            n := n + 1;
            tablen[n] := i;
          end;
      iprim := multigcd(n);
    end;
end;

procedure calcul_kemeny(n : integer; mp : rmatmat_type; v : rvecvec_type;var kem : extended);
{ calcul de la constante de Kemeny K de la chaine de Markov associee au graphe }
{ K = mean time from any state to equilibrium }
{ mp = matrice de la chaine de Markov, de taille n }
{ v = vecteur propre a gauche de mp = distribution stationnaire }
const borne = 1.0E100;
var x,y,n1 : integer;
    sum : extended;
    mq,mz : rmatmat_type;
begin
  n1 := n + 1;
  SetLength(mq,n1,n1);
  SetLength(mz,n1,n1);
  for x := 1 to n do
    for y := 1 to n do
      if ( y = x ) then
        mq[x,x] := 1.0 - (mp[x,x] - v[x])
      else
        mq[x,y] := -(mp[x,y] - v[y]);
  { Q = I - (P - P_infini); les lignes de P_infini sont la distribution v }
  matinv(n,mq,mz); { Z = Q^(-1) }
  if err_math then
    begin
      err_math := false;
      kem := bad;
      exit;
    end;
  { test de la validite de l'inverse }
  for x := 1 to n do
    for y := 1 to n do
      if ( abs(mz[x,y]) > borne ) then
        begin
          iwriteln('*** kemeny - no convergence');
          kem := bad;
          exit;
        end;
  for x := 1 to n do
    for y := 1 to n do
      mz[x,y] := mz[x,y] - v[y]; { Z = Q^(-1) - P_infini }
  sum := 0.0;
  for x := 1 to n do sum := sum + mz[x,x];
  kem := sum;
  {for y := 1 to n do
    iwriteln(IntToStr(y) + ' Mwy = ' + s_ecri_val(mz[y,y]/v[y]));}
   { mean time from equilibrium to y }
  {for x := 1 to n do
    for y := 1 to n do
      if ( y = x) then
        ma[x,y] := 1.0/v[y]
      else
        ma[x,y] := (mz[y,y] - mz[x,y])/v[y];}  { voir v[y] = 0 !!! }
      { ma[x,y] = mean time to get from x to y; mean first passage matrix }
  {iwriteln('M');
  for x := 1 to n do
    begin
      s := '';
      for y := 1 to n do s := s + s_ecri_val(ma[x,y]) + hortab;
      iwriteln(s)
    end;}
end;

(*procedure calcul_kemeny2(n : integer; mp : rmatmat_type; v : rvecvec_type);
{ calcul de la constante de Kemeny K de la chaine de Markov associee au graphe }
{ K = mean time from any state to equilibrium }
{ mp = matrice de la chaine de Markov, de taille n }
{ semble pas marcher ... }
const eps = 1.0E-12;
var x,y,z,k,n1 : integer;
    sum,norm,norm1 : extended;
    c : rvecvec_type;
    mq,mh,ma,mb : rmatmat_type;
    s : string;
begin
  n1 := n + 1;
  SetLength(mq,n1,n1);
  SetLength(mh,n1,n1);
  SetLength(ma,n1,n1);
  SetLength(mb,n1,n1);
  SetLength(c,n1);

  for x := 1 to n do
    begin
      s := '';
      for y := 1 to n do s := s + s_ecri_val(mp[x,y]) + hortab;
      iwriteln(s)
    end;

  for y := 1 to n do
    begin
      sum := 0.0;
      for x := 1 to n do sum := sum + mp[x,y];
      c[y] := sum;
      iwriteln(IntToStr(y) + ' c ' + s_ecri_val(c[y]));
    end;
  for x := 1 to n do
    for y := 1 to n do
      mq[x,y] := mp[x,y] - c[y];
      { Q = P - C; C matrice dont les lignes sont les sommes des colonnes de P }
  for x := 1 to n do
    for y := 1 to n do
      if ( x = y ) then
        ma[x,y] := 1.0
      else
        ma[x,y] := 0.0; { A = I }
  for x := 1 to n do
    for y := 1 to n do
      mh[x,y] := ma[x,y]; { H = I }
  norm := 1.0;
  k := 0;
  repeat
      k := k + 1;
      for x := 1 to n do
        for y := 1 to n do
          begin
            sum := 0.0;
            for z := 1 to n do sum := sum + mq[x,z]*ma[z,y];
            mb[x,y] := sum;
          end;
      for x := 1 to n do
        for y := 1 to n do
          ma[x,y] := mb[x,y]; { A = Q^k }
      norm1 := norm;
      norm := 0.0;
      for x := 1 to n do
        for y := 1 to n do
          norm := max(norm,abs(ma[x,y]));
      iwriteln('norm ' + s_ecri_val(norm));
      for x := 1 to n do
        for y := 1 to n do
          mh[x,y] := mh[x,y] + ma[x,y];
      { H = I + Q + ... + Q^k = (I - Q)^(-1) }
  until ( k >= 100 ) or ( norm < eps );
  if ( norm1 = norm ) then { pb convergence }
    begin
      iwriteln('*** kemeny2 - pb convergence');
      exit;
    end;

  iwriteln('H');
  for x := 1 to n do
    begin
      s := '';
      for y := 1 to n do s := s + s_ecri_val(mh[x,y]) + hortab;
      iwriteln(s)
    end;

  sum := 1.0 - 1.0/n;
  for x := 1 to n do sum := sum + mh[x,x];
  iwriteln('kemeny = ' + s_ecri_val(sum));
  for x := 1 to n do
    for y := 1 to n do
      if ( y = x ) then
        ma[x,y] := 1.0/v[y]
      else
        ma[x,y] := (mh[y,y] - mh[x,y])/v[y];
      { ma[x,y] = mean time to get from x to y; mean first passage matrix }
  iwriteln('M');
  for x := 1 to n do
    begin
      s := '';
      for y := 1 to n do s := s + s_ecri_val(ma[x,y]) + hortab;
      iwriteln(s)
    end;
end;*)

procedure calcul_markov(g : integer);
{ Calcul de plusieurs quantites de la chaine de Markov }
{ associee au graphe oriente }
{ 1 - Entropie H - pour une matrice 0/1, H = ln(lambda1) }
{ 2 - Kemeny's constant K }
{ 3 - Cycle time, generation time }
{ 4 - Vecteur d'importance }
{ La matrice est rendue irreductible en ajoutant une racine }
{ connectee a toutes les especes basales }
{ toutes les especes sont connectees a cette racine }
{ Si pas d'especes basales on prend la matrice telle quelle }
var n,x,y,n1,n2,groot,gmarkov,g1,ipri : integer;
    lambda1 : extended;
    err : boolean;
    mp : rmatmat_type;
    w,v : rvecvec_type;

procedure  markov(g : integer);
{ chaine de markov associee au graphe suppose irreductible }
{ -> matrice mp }
var x,y : integer;
begin
  with graphes[g] do
    begin
      matvalvecd1_sparse(g,w,lambda1);
      if ( lambda1 <= 0.0 ) then
        begin
          err := true;
          exit;
        end;
      for x := 1 to nb_sommets do
        if ( w[x] = 0.0 ) then
          begin
            err := true; { reducible matrix - ne doit pas se produire }
            exit;
          end;
      for x := 1 to nb_sommets do
        for y := 1 to nb_sommets do
          mp[x,y] := m_[x,y]*w[y]/(lambda1*w[x]);
    end;
end;

procedure  markov_val(g : integer);
{ chaine de markov associee au graphe value suppose irreductible }
{ -> matrice mp }
var x,y : integer;
begin
  with graphes[g] do
    begin
      matvalvecd1_sparse_val(g,w,lambda1);
      if ( lambda1 <= 0.0 ) then
        begin
          err := true;
          exit;
        end;
      for x := 1 to nb_sommets do
        if ( w[x] = 0.0 ) then
          begin
            err := true; { reducible matrix - ne doit pas se produire }
            exit;
          end;
      for x := 1 to nb_sommets do
        for y := 1 to nb_sommets do
          mp[x,y] := mr_[x,y]*w[y]/(lambda1*w[x]);
    end;
end;

function  calcul_entropy(gmarkov : integer) : extended;
{ suppose la matrice d'adjacence du graphe value gmarkov }
{ construite comme chaine de Markov de la matrice 0/1 de g }
var x,u : integer;
    sum,hx : extended;
begin
  with graphes[gmarkov] do
    begin
      matkovvecg_sparse_val(gmarkov,v);
      sum := 0.0;
      for x := 1 to nb_sommets do sum := sum + v[x];
      for x := 1 to nb_sommets do v[x] := v[x]/sum; { on renormalise pour precision }
      sum := 0.0;
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          hx := 0.0;
          u := succ;
          while ( u <> 0 ) do with lis[u] do
            begin
              hx := hx + val*ln0(val);
              u := cdr;
            end;
          sum := sum + v[x]*hx;
        end;
      calcul_entropy := -sum;
    end;
end;

function  calcul_entropy_val(gmarkov : integer) : extended;
{ suppose la matrice d'adjacence du graphe value gmarkov }
{ construite comme chaine de Markov de la matrice valuee de g }
var x,u : integer;
    sum,hx : extended;
begin
  with graphes[gmarkov] do
    begin
      matkovvecg_sparse_val(gmarkov,v);
      sum := 0.0;
      for x := 1 to nb_sommets do sum := sum + v[x];
      for x := 1 to nb_sommets do v[x] := v[x]/sum; { on renormalise pour precision }
      sum := 0.0;
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          hx := 0.0;
          u := succ;
          while ( u <> 0 ) do with lis[u] do
            begin
              hx := hx + val*ln0(val);
              u := cdr;
            end;
          //for y := 1 to n do hx := hx + mp[x,y]*ln0(mp[x,y]);
          sum := sum + v[x]*hx;
        end;
      calcul_entropy_val := -sum;
    end;
end;

procedure calcul_cyctime;
{ Calcul du temps de generation du graphe 0/1 g }
{ et du temps de cycle de chaque sommet }
{ Si pas d'especes basales on prend la matrice telle quelle }
{ Sinon on ajoute un sommet root -> graphe 0/1 g1 }
{ Utilise la distribution stationnaire v de la chaine de Markov }
{ associee au graphe g1 }
{ Dans le cas d'un graphe avec root, gentime T calcule comme }
{ le temps de retour aux arcs root -> basal }
{ consideres comme les arcs reproductifs -- sont values par 1 }
{ sinon gentime pas defini }
{ pitilde(root->i) = pi(root->i)*p_root,i }
var x : integer;
    sum : extended;
begin
  with graphes[g] do
    begin
      if ( nb_b > 0 ) then
        begin
          {if ( v[n1] <> 0.0 ) then
            gentime := 1.0/v[n1];} { temps moyen de parcours root -> root }
          { car n1 est le sommet root de g1, root graphe de g }
          { temps moyen de retour aux arc "reproductifs" : les arcs root -> basal }
          sum := 0.0;
          for x := 1 to nb_sommets do with ggg[x] do
            if ( nb_pred = 0 ) then
              sum := sum + v[x];
          if ( sum > 0.0 ) then gentime := 1.0/sum;
        end
      else
        if ( root > 0 ) then { rooted network }
          begin
            {if ( v[root] <> 0.0 ) then
              gentime := 1.0/v[root];} { temps moyen de parcours root -> root }
            sum := 0.0;
            for x := 1 to nb_sommets do with ggg[x] do
              if ( nb_pred = 0 ) then
                sum := sum + v[x];
            if ( sum > 0.0 ) then gentime := 1.0/sum;
          end;
      for x := 1 to nb_sommets do with ggg[x] do
        if ( v[x] <> 0.0 ) then
          cyctime := 1.0/v[x];
    end;
end;

procedure calcul_cyctime_val;
{ Calcul du temps de generation du graphe value g }
{ et du temps de cycle de chaque sommet }
{ Si pas d'especes basales on prend la matrice telle quelle }
{ Sinon on ajoute un sommet root -> graphe value g1 }
{ Tous les arcs ajoutes sont values 1 }
{ Utilise la distribution stationnaire v de la chaine de Markov }
{ associee au graphe value g1 }
{ Dans le cas d'un graphe avec root, gentime T calcule comme }
{ le temps de retour aux arcs root -> basal }
{ Ces arcs sont consideres comme les arcs reproductifs (values 1) }
{ sinon gentime pas defini }
var x : integer;
    sum : extended;
begin
  with graphes[g] do
    begin
      if ( nb_b > 0 ) then
        begin
          {if ( v[n1] <> 0.0 ) then
            gentime_val := 1.0/v[n1];} { temps moyen de parcours root -> root }
          sum := 0.0;
          for x := 1 to nb_sommets do with ggg[x] do
            if ( nb_pred = 0 ) then
              sum := sum + v[x];
          if ( sum > 0.0 ) then gentime_val := 1.0/sum;
        end
      else
        if ( root > 0 ) then { rooted network }
          begin
            {if ( v[root] <> 0.0 ) then
              gentime_val := 1.0/v[root];} { temps moyen de parcours root -> root }
            sum := 0.0;
            for x := 1 to nb_sommets do with ggg[x] do
              if ( nb_pred = 0 ) then
                sum := sum + v[x];
            if ( sum > 0.0 ) then gentime_val := 1.0/sum;
          end;
      for x := 1 to nb_sommets do with ggg[x] do
        if ( v[x] <> 0.0 ) then
          cyctime_val := 1.0/v[x];
    end;
end;

procedure calcul_importance(g1 : integer);
{ calcul de l'importance des especes pour les coextinctions }
{ selon la methode d'Allesina & Pascual. 2009. Plos Computational Biology }
{ inspiree de PageRank }
{ On ajoute une espece "root" connectee a toutes les especes basales }
{ toutes les especes sont connectees a cette racine }
{ Cela rend en general la matrice irreductible (mais pas toujours !) }
{ Si pas d'especes basales on prend la matrice telle quelle }
var x,y,n : integer;
    sum : extended;
begin
  graphe2mat(g1); {!!!}
  with graphes[g1] do
    begin
      n := nb_sommets;
      { sommes colonnes }
      for y := 1 to n do
        begin
          sum := 0.0;
          for x := 1 to n do sum := sum + m_[x,y];
          v[y] := sum;
        end;
      for x := 1 to n do
        for y := 1 to n do
          if ( v[y] > 0.0 ) then
            mp[x,y] := m_[x,y]/v[y]
          else
            mp[x,y] := 0.0;
      matkovvecd(n1,mp,v);
    end;
  with graphes[g] do
    for x := 1 to nb_sommets do with ggg[x] do rank := v[x];
end;

begin
  with graphes[g] do
    begin
      n := nb_sommets;
      if ( nb_b = 0 ) then
        n1 := n
      else
        n1 := n + 1;
      n2 := n1 + 1;
      SetLength(mp,n2,n2);
      SetLength(w,n2);
      SetLength(v,n2);
      entropy := bad;
      gentime := bad;
      kemeny  := bad;
      entropy_val := bad;
      gentime_val := bad;
      kemeny_val  := bad;
      for x := 1 to n do with ggg[x] do
        begin
          rank := bad;
          cyctime := bad;
          cyctime_val := bad;
        end;
      if ( nb_b > 0 ) then
        begin
          { creation temporaire du graphe root }
          { graphe irreductible, sauf cas particuliers,
            e.g., espece isolee avec self-loop }
          groot := addroot_graphe_temp(g);
          if ( groot = 0 ) then exit;
          calcul_prim(groot);
          ipri := graphes[groot].iprim;
          g1 := groot;
        end
      else
        begin
          g1 := g;
          ipri := iprim; { deja calcule }
        end;
      if ( ipri = 0 ) then { reducible }
        begin
          if ( g1 = groot ) then dealloc_graphe; { dealloc groot }
          graphe2mat(g); { restaure la matrice du graphe d'origine }
          iwriteln('*** markov - reducible matrix');
          exit;
        end;
      err := false;
      markov(g1); { construit mp }
      if err then
        begin
          if ( g1 = groot ) then dealloc_graphe; { dealloc groot }
          graphe2mat(g); { restaure la matrice du graphe d'origine }
          iwriteln('*** markov - reducible matrix 2');
          exit;
        end;
      { chaine irreductible : }
      gmarkov := markov_graphe_temp(g1,mp);
      if ( gmarkov = 0 ) then
        begin
          if ( g1 = groot ) then dealloc_graphe; { dealloc groot }
          graphe2mat(g); { restaure la matrice du graphe d'origine }
          exit;
        end;
      entropy := calcul_entropy(gmarkov); { construit v }
      calcul_kemeny(n1,mp,v,kemeny);
      if ( ipri = 1 ) then { on exige une chaine primitive }
        begin
          calcul_cyctime; { utilise v }
          calcul_importance(g1);
        end;
      if ( ival = 0 ) then
        begin
          dealloc_graphe; { dealloc gmarkov }
          if ( g1 = groot ) then dealloc_graphe; { dealloc groot }
          graphe2mat(g); { restaure la matrice du graphe d'origine }
          exit;
        end;
      { cas d'un graphe value : }
      markov_val(g1); { construit mp val }
      if err then
        begin
          dealloc_graphe; { dealloc gmarkov precedent }
          if ( g1 = groot ) then dealloc_graphe; { dealloc groot }
          iwriteln('*** markov - reducible matrix 2');
          graphe2mat(g); { restaure la matrice du graphe d'origine }
          exit;
        end;
      { chaine irreductible : }
      dealloc_graphe; { dealloc gmarkov precedent }
      gmarkov := markov_graphe_temp(g1,mp);
      if ( gmarkov = 0 ) then
        begin
          if ( g1 = groot ) then dealloc_graphe; { dealloc groot }
          graphe2mat(g); { restaure la matrice du graphe d'origine }
          exit;
        end;
      entropy_val := calcul_entropy_val(gmarkov); { construit v val }
      calcul_kemeny(n1,mp,v,kemeny_val);
      if ( ipri = 1 ) then calcul_cyctime_val; { utilise v val }
      dealloc_graphe; { dealloc gmarkov }
      if ( g1 = groot ) then dealloc_graphe; { dealloc groot }
      graphe2mat(g); { restaure la matrice du graphe d'origine }
    end;
end;

end.
