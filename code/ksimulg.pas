unit ksimulg;

interface

uses kglobvar;

function  erdos_graphe(n : integer;p : extended): integer;
function  unif_graphe(n,m : integer): integer;
function  smallworld_graphe(n,deg : integer; p : extended): integer;
function  nbs_arb(k,niv : integer): integer;
function  arb_graphe(k,niv : integer;p : extended): integer;
(*function  flow_graphe(g : integer) : integer;*)
function  sub_graphe(g,m : integer): integer;
function  null_bit_graphe(g : integer): integer;
function  chkb_units(g : integer) : integer;
function  null_deg_graphe(g : integer): integer;
function  null_niche_graphe(n : integer;c : extended): integer;
(*function  ford_fulkerson(g,source,sink : integer) : extended;
procedure flow2graphe(g : integer);*)
procedure simul_graphe(g : integer; nb_simul : integer);

{var   flow : rmat_type;}  { matrice du flot }

implementation

uses  SysUtils,kmath,kutil,klist,kgestiong,kcalculg,kmanipg,f_nw,f_pad;

var   tabx : ivec_type; { tableau pour sous-graphe }
      (*mm  : imat_type;
      mmr : rmat_type;*)

procedure erdos2mat(n : integer;p : extended);
{ construct the matrix of a random directed graph with n nodes }
{ p = probability of connection between 2 nodes }
var x,y : integer;
begin
  for x := 1 to n do
    for y := 1 to n do
      m_[x,y] := trunc(ber(p));
  for x := 1 to n do
    for y := 1 to n do
      mr_[x,y] := m_[x,y];
end;

function  erdos_graphe(n : integer;p : extended): integer;
{ create a Erdos-Renyi random directed graph with n nodes }
{ p = probability of connection between 2 nodes }
var g,x : integer;
begin
  g := alloc_graphe(0,n,'Random',type_gra_erdos);
  if err_gestion then
    begin
      err_gestion := false;
      erdos_graphe := 0;
      exit;
    end;
  reset_graine;
  erdos2mat(n,p);
  init_graphe(g);
  if err_gestion then
    begin
      err_gestion := false;
      dealloc_graphe;
      erdos_graphe := 0;
      exit;
    end;
  with graphes[g] do
    begin
      param_p := p;
      for x := 1 to nb_sommets do ggg[x].nom := 'v' + IntToStr(x);
    end;
  calcul_graphe(g);
  erdos_graphe := create_graphe(g);
end;

procedure unif2mat(n,w : integer);
{ construct the matrix of a random directed graph with n nodes and w arcs }
var x,y,nn,k : integer;
    vec,o : ivecvec_type;
begin
  nn := n*n;
  SetLength(vec,nn+1);
  SetLength(o,nn+1);
  for k := 1   to w do vec[k] := 1;
  for k := w+1 to nn do vec[k] := 0;
  permut(nn,o);
  for x := 1 to n do
    for y := 1 to n do
      begin
        k := (x-1)*n + y;
        m_[x,y] := vec[o[k]];
        mr_[x,y] := m_[x,y];
      end;
end;

(*procedure unif2mat(n,m : integer);
{ construct the matrix of a random directed graph with n nodes and m arcs }
var x,y,e,n2,r : integer;
begin
  n2 := n*n;
  for x := 1 to n do
    for y := 1 to n do
      m_[x,y]  := 0;
  for e := 1 to m do
    begin
      repeat
        r := trunc(rand(n2)) + 1;
        coordmat(r,n,x,y);
      until ( m_[x,y] = 0 );
      m_[x,y]  := 1;
      mr_[x,y] := 1.0;
    end;
  for x := 1 to n do
    for y := 1 to n do
      mr_[x,y] := m_[x,y];
end;*)

function  unif_graphe(n,m : integer): integer;
{ create a random directed graph with n nodes and m arcs }
{ drawn uniformly in the set of such graphs }
var g,x : integer;
begin
  g := alloc_graphe(0,n,'Unif',type_gra_unif);
  if err_gestion then
    begin
      err_gestion := false;
      unif_graphe := 0;
      exit;
    end;
  reset_graine;
  unif2mat(n,m);
  init_graphe(g);
  if err_gestion then
    begin
      err_gestion := false;
      dealloc_graphe;
      unif_graphe := 0;
      exit;
    end;
  with graphes[g] do
    for x := 1 to nb_sommets do ggg[x].nom := 'v' + IntToStr(x);
  calcul_graphe(g);
  unif_graphe := create_graphe(g);
end;

procedure smallworld2mat(n,deg : integer; p : extended);
{ construct the matrix of a random small world directed graph with n nodes }
{ deg = , deg <= n-1; p = replacement probability, p < 1 }
var x,y,n1,m,k,i,e,e1,u,v,u1,v1 : integer;
    r : extended;
    replace : ivecvec_type;
begin
  n1 := n*(n-1);
  SetLength(replace,n*n);
  for x := 1 to n do
    for y := 1 to n do
      m_[x,y] := 0;
  r := rand(1);
  k := trunc(ln(1.0 - r)/ln(1.0 - p));
  m := 0;
  for x := 0 to n-1 do
    for i := 1 to deg do
      if ( k > 0 ) then
        begin
          e := x*(x-1) + x + i mod n;
          k := k - 1;
          m := m + 1;
          coordmat(e,n,u,v);
          m_[u,v] := 1;
          coordmat(m,n,u1,v1);
          if ( m_[u1,v1] = 0 ) then
            replace[e] := m
          else
            replace[e] := replace[m];
        end
      else
        begin
          r := rand(1);
          k := trunc(ln(1.0 - r)/ln(1.0 - p));
        end;
  for i := m+1 to n*deg do
    begin
      e := trunc(rand(n1-i)) + i + 1;
      coordmat(e,n,u,v);
      if ( m_[u,v] = 0 ) then
        m_[u,v] := 1
      else
        begin
          coordmat(i,n,u1,v1);
          if ( m_[u1,v1] = 0 ) then
            m_[u1,v1] := 1
          else
            begin
              e1 := replace[e];
              coordmat(e1,n,u1,v1);
              m_[u1,v1] := 1;
            end;
        end;
      coordmat(i,n,u1,v1);
      if ( m_[u1,v1] = 0 ) then
        replace[e] := i
      else
        replace[e] := replace[i];
    end;
  for x := 1 to n do
    for y := 1 to n do
      mr_[x,y] := m_[x,y];
end;

function  smallworld_graphe(n,deg : integer; p : extended): integer;
{ create a random small world directed graph with n nodes  }
{ and parameters deg, p }
var g,x : integer;
begin
  g := alloc_graphe(0,n,'SmallW',type_gra_smallw);
  if err_gestion then
    begin
      err_gestion := false;
      smallworld_graphe := 0;
      exit;
    end;
  reset_graine;
  smallworld2mat(n,deg,p);
  init_graphe(g);
  if err_gestion then
    begin
      err_gestion := false;
      dealloc_graphe;
      smallworld_graphe := 0;
      exit;
    end;
  with graphes[g] do
    begin
      param_p := p;
      param_deg := deg;
      for x := 1 to nb_sommets do ggg[x].nom := 'v' + IntToStr(x);
    end;
  calcul_graphe(g);
  smallworld_graphe := create_graphe(g);
end;

function  nbs_arb(k,niv : integer): integer;
{ nombre de sommets d'un arbre a niv niveaux et k descendants par sommet }
{ nbs = 1 + k + ... + k^(niv-1) si k > 1 }
{ nbs = niv si k = 1 }
var n,i,q : integer;
begin
  n := 0;
  q := 1;
  for i := 1 to niv do
    begin
      n := n + q;
      q := k*q;
    end;
  nbs_arb := n;
end;

procedure arb2mat(k,niv : integer;p : extended;var n1 : integer);
{ matrice d'un arbre aleatoire a niv niveaux }
{ et k*p "descendants" par sommet en moyenne, max n sommets }
{ retrourne le nombre realise de sommets n1 }
var x,y,i,j,b,b1,ki : integer;
    tab : ivec_type;
begin
  b := nbs_arb(k,niv-1); { nombre de blocs }
  n1 := 1;
  b1 := 0;
  for i := 1 to b do
    begin
      ki := trunc(binomf(k,p)); { nombre realise de "descendants" }
      tab[i] := ki;
      n1 := n1 + ki; { nombre realise de sommets }
      if ( ki > 0 ) then b1 := b1 + 1; { nombre realise de blocs }
    end;
  for x := 1 to n1 do
    for y := 1 to n1 do
      m_[x,y] := 0;
  y := n1 - b1;
  x := 0;
  for i := 1 to b do
    if ( tab[i] > 0 ) then
      begin
        y := y + 1;
        for j := 1 to tab[i] do
          begin
            x := x + 1;
            m_[x,y] := 1;
          end;
      end;
  for x := 1 to n1 do
    for y := 1 to n1 do
      mr_[x,y] := m_[x,y];
end;

function  arb_graphe(k,niv : integer;p : extended): integer;
{ construction d'un arbre a niv niveaux et k descendants par sommet }
{ p = probabilite de connection de 2 sommets }
var g,n,x,n1 : integer;
begin
  n := nbs_arb(k,niv); { nb maximal de sommets }
  g := alloc_graphe(0,n,'Tree',type_gra_arb);
  if err_gestion then
    begin
      err_gestion := false;
      arb_graphe := 0;
      exit;
    end;
  reset_graine;
  arb2mat(k,niv,p,n1);
  with graphes[g] do
    begin
      nb_sommets := n1; { maj nb sommets }
      SetLength(ggg,n1+1);
    end;
  init_graphe(g);
  if err_gestion then
    begin
      err_gestion := false;
      dealloc_graphe;
      arb_graphe := 0;
      exit;
    end;
  with graphes[g] do
    begin
      for x := 1 to nb_sommets do ggg[x].nom := 'v' + IntToStr(x);
      param_p := p;
      param_deg := k;
      param_nb_niv := niv;
    end;
  calcul_graphe(g);
  arb_graphe := create_graphe(g);
end;

procedure permut(n : integer);
{ generate a random permutation of size n }
var x,i,j : integer;
begin
  for i := 1 to n do tabx[i] := i;
  i := n;
  while ( i > 1 ) do
    begin
      j := trunc(rand(i)) + 1;
      x := tabx[i];
      tabx[i] := tabx[j];
      tabx[j] := x;
      i := i - 1;
    end;
end;

procedure sub2mat(g : integer;m : integer);
{ construction de la matrice d'un sous-graphe de g a m sommets }
{ tires de façon aleatoire d'apres le tableau tabx }
{ suppose m < nb_sommets }
var x,y,n1 : integer;
    mm  : imatmat_type;
    mmr : rmatmat_type;
begin
  graphe2mat(g);
  with graphes[g] do
    begin
      n1 := nb_sommets + 1;
      SetLength(mm,n1,n1);
      SetLength(mmr,n1,n1);
      { engendrer une permutation aleatoire des sommets }
      permut(nb_sommets);
      { remplir la sous-matrice avec les m premieres entrees }
      for x := 1 to m do
        for y := 1 to m do
          begin
            mm[x,y]  := m_[tabx[x],tabx[y]];
            mmr[x,y] := mr_[tabx[x],tabx[y]];
          end;
      for x := 1 to m do
        for y := 1 to m do
          begin
            m_[x,y]  := mm[x,y];
            mr_[x,y] := mmr[x,y];
          end;
    end;
end;

function  sub_graphe(g,m : integer): integer;
{ construction d'un sous-graphe aleatoire de g a m sommets }
var g1,x : integer;
begin
  with graphes[g] do
    g1 := alloc_graphe(g,m,'#' + IntToStr(icre) + '_Sub',type_gra_sub);
  if err_gestion then
    begin
      err_gestion := false;
      sub_graphe := 0;
      exit;
    end;
  reset_graine;
  sub2mat(g,m);
  init_graphe(g1);
  if err_gestion then
    begin
      err_gestion := false;
      dealloc_graphe;
      sub_graphe := 0;
      exit;
    end;
  with graphes[g1] do
    for x := 1 to nb_sommets do ggg[x].nom := graphes[g].ggg[tabx[x]].nom;
  calcul_graphe(g1);
  sub_graphe := create_graphe(g1);
end;

procedure null_bit_2mat(g : integer);
{ construction de la matrice d'un graphe aleatoire trophique }
{ ayant les mêmes sommets que g }
{ il faut nb_b > 0, nb_i > 0, nb_t > 0 }
var x,y : integer;
    lbi,lbt,lii,lit : integer;
    cbi,cbt,cii,cit : extended;
begin
  with graphes[g] do
    begin
    { calcul des connectances }
     lbi := 0;
     lbt := 0;
     lii := 0;
     lit := 0;
     for x := 1 to nb_sommets do with ggg[x] do
       begin
         y := succ;
         while ( y <> 0 ) do with lis[y] do
           begin
             if ( pred = 0 ) then { espece x basale }
               if ( ggg[car].pred = 0 ) then { espece y basale }
               else
                 if ( ggg[car].succ = 0 ) then { espece y top }
                   lbt := lbt + 1
                 else { espece y intermediaire }
                   lbi := lbi + 1
             else
               if ( succ = 0 ) then { espece x top }
               else { espece x intermediaire }
                 if ( ggg[car].pred = 0 ) then { espece y basale }
                 else
                   if ( ggg[car].succ = 0 ) then { espece y top }
                     lit := lit + 1
                   else { espece y intermediaire }
                     lii := lii + 1;
             y := cdr;
           end;
       end;
     if ( nb_b = 0 ) or ( nb_i = 0 ) or ( nb_t = 0 ) then
iwriteln('BIT ' + IntToStr(nb_b) + ' ' + IntToStr(nb_i) + ' ' + IntToStr(nb_t));
     cbi := lbi/(nb_b*nb_i);
     cbt := lbt/(nb_b*nb_t);
     cit := lit/(nb_i*nb_t);
     {if ( nb_boucles = 0 ) then}
       cii := lii/(nb_i*nb_i);
     {else
       cii := lii/(nb_i*(nb_i-1));}
      {iwriteln('Lbi ' + IntToStr(lbi));
      iwriteln('Lbt ' + IntToStr(lbt));
      iwriteln('Lii ' + IntToStr(lii));
      iwriteln('Lit ' + IntToStr(lit));
      iwriteln('Cbi ' + FloatToStr(cbi));
      iwriteln('Cbt ' + FloatToStr(cbt));
      iwriteln('Cii ' + FloatToStr(cii));
      iwriteln('Cit ' + FloatToStr(cit));}
     for x := 1 to nb_sommets do
       for y := 1 to nb_sommets do
         m_[x,y] := 0;
     for x := 1 to nb_sommets do
       for y := 1 to nb_sommets do
         if ( ggg[x].pred = 0 ) then { espece x basale }
           if ( ggg[y].pred = 0 ) then { espece y basale }
           else
             if ( ggg[y].succ = 0 ) then { espece y top }
               m_[x,y] := trunc(ber(cbt))
             else { espece y intermediaire }
               m_[x,y] := trunc(ber(cbi))
         else
           if ( ggg[x].succ = 0 ) then { espece x top }
           else { espece x intermediaire }
             if ( ggg[y].pred = 0 ) then { espece y basale }
             else
               if ( ggg[y].succ = 0 ) then { espece y top }
                 m_[x,y] := trunc(ber(cit))
               else { espece y intermediaire }
                 if ( nb_boucles = 0 ) then
                   if ( x <> y ) then m_[x,y] := trunc(ber(cii))
                   else
                 else
                   m_[x,y] := trunc(ber(cii));
     for x := 1 to nb_sommets do
       for y := 1 to nb_sommets do
         mr_[x,y] := m_[x,y];
    end;
end;

function  null_bit_graphe(g : integer): integer;
{ construction d'un graphe aleatoire trophique ayant les mêmes sommets que g }
{ et les memes connectances BxI, BxT, IxI et IxT }
{ on impose qu'il doit exister au moins un arc entrant }
{ pour tous les sommets I, T - A FAIRE }
var g1,x : integer;
begin
  with graphes[g] do
    if ( nb_b = 0 ) or ( nb_i = 0 ) or ( nb_t = 0 ) then
      begin
        null_bit_graphe := 0;
        exit;
      end;
  with graphes[g] do
    g1 := alloc_graphe(g,nb_sommets,'#' + IntToStr(icre) + '_BIT',type_null_bit);
  if err_gestion then
    begin
      err_gestion := false;
      null_bit_graphe := 0;
      exit;
    end;
  null_bit_2mat(g);
  init_graphe(g1);
  if err_gestion then
    begin
      err_gestion := false;
      dealloc_graphe;
      null_bit_graphe := 0;
      exit;
    end;
  with graphes[g1] do
    for x := 1 to nb_sommets do ggg[x].nom := graphes[g].ggg[x].nom;
  calcul_graphe(g1);
  null_bit_graphe := create_graphe(g1);
end;

procedure null_niche_2mat(n1 : integer;c1 : extended);
{ construction de la matrice d'un graphe aleatoire trophique }
{ ayant n1 sommets et de connectance c1 selon le niche model }
var x,y : integer;
    minni : extended;
    ni,ri,ci : rvec_type;
begin
  minni := 1.0;
  for x := 1 to n1 do
    begin
      ni[x] := rand(1.0);
      minni := min(ni[x],minni);
    end;
  for x := 1 to n1 do
    begin
      if ( ni[x] = minni ) then
        ri[x] := 0.0
      else
        ri[x] := betaf(1.0,((n1-1.0)/(2.0*n1*c1) - 1.0))*ni[x];
      if ( ni[x] + ri[x]/2.0  <= 1.0 ) then
        ci[x] := ri[x]/2.0 + rand(ni[x] - ri[x]/2.0)
      else
        ci[x] := ri[x]/2.0 + rand(1.0 - ri[x]);
    end;
  for x := 1 to n1 do
    for y := 1 to n1 do
      if ( abs(ci[y] - ni[x]) <= ri[y]/2.0 ) then
        m_[x,y] := 1
      else
        m_[x,y] := 0;
  for x := 1 to n1 do
    for y := 1 to n1 do
      mr_[x,y] := m_[x,y];
end;

function  null_niche_graphe(n : integer;c : extended): integer;
{ construction d'un graphe aleatoire trophique ayant n sommets }
{ et de connectance c, selon le niche model }
{ Williams RJ & ND Martinez. 2000. Simple rules yield complex food webs. }
{ Nature 404:180-183. }
var g,x : integer;
begin
  g := alloc_graphe(0,n,'Niche',type_null_niche);
  if err_gestion then
    begin
      err_gestion := false;
      null_niche_graphe := 0;
      exit;
    end;
  null_niche_2mat(n,c);
  init_graphe(g);
  if err_gestion then
    begin
      err_gestion := false;
      dealloc_graphe;
      null_niche_graphe := 0;
      exit;
    end;
  with graphes[g] do
    begin
      param_p := c;
      for x := 1 to n do ggg[x].nom := 'v' + IntToStr(x);
    end;
  calcul_graphe(g);
  null_niche_graphe := create_graphe(g);
end;

function  chkb_units(g : integer) : integer;
var x1,x2,y,sum,cu : integer;
begin
  with graphes[g] do
    begin
      cu := 0;
      for x1 := 1 to nb_sommets-1 do
        for x2 := x1+1 to nb_sommets do
          begin
            sum := 0;
            for y := 1 to nb_sommets do
              if ( m_[x1,y] = 1 ) and ( m_[x2,y] = 1 ) then
                sum := sum + 1;
            cu := cu + (ggg[x1].succ - sum)*(ggg[x2].succ - sum);
          end;
    end;
  chkb_units := cu;
end;

procedure null_deg_2mat(g : integer);
{ cree par swap une matrice aleatoire de memes degres que g }
{ et remplace m_ par cette matrice aleatoire }
var x1,x2,y1,y2,nb_mat1,transient : integer;
    swap : boolean;
begin
  graphe2mat(g);
  with graphes[g] do
    begin
      //if ( chkb_units(g) = 0 ) then exit; // teste avant !
      transient := 20*nb_arcs;
      nb_mat1 := 0;
      repeat
        x1 := trunc(rand(nb_sommets)) + 1;
        repeat
          x2 := trunc(rand(nb_sommets)) + 1
        until ( x1 <> x2 );
        repeat
          y1 := trunc(rand(nb_sommets)) + 1
        until ( y1 <> x1 ) and ( y1 <> x2 );
        repeat
          y2 := trunc(rand(nb_sommets)) + 1
        until ( y1 <> y2 ) and ( y2 <> x1 ) and ( y2 <> x2 );
        swap  := false;
        if ( m_[x1,y1] = 1 ) and ( m_[x1,y2] = 0 ) and
           ( m_[x2,y1] = 0 ) and ( m_[x2,y2] = 1 ) then
          begin
            swap := true;
            m_[x1,y1]  := 0;
            m_[x1,y2]  := 1;
            m_[x2,y1]  := 1;
            m_[x2,y2]  := 0;
            mr_[x1,y2] := mr_[x1,y1];
            mr_[x1,y1] := 0.0;
            mr_[x2,y1] := mr_[x2,y2];
            mr_[x2,y2] := 0.0;
          end
        else
          if ( m_[x1,y1] = 0 ) and ( m_[x1,y2] = 1 ) and
             ( m_[x2,y1] = 1 ) and ( m_[x2,y2] = 0 ) then
            begin
              swap := true;
              m_[x1,y1]  := 1;
              m_[x1,y2]  := 0;
              m_[x2,y1]  := 0;
              m_[x2,y2]  := 1;
              mr_[x1,y1] := mr_[x1,y2];
              mr_[x1,y2] := 0.0;
              mr_[x2,y2] := mr_[x2,y1];
              mr_[x2,y1] := 0.0;
            end;
        if swap then nb_mat1 := nb_mat1 + 1;
      until ( nb_mat1 >= transient );
    end;
end;

function  null_deg_graphe(g : integer): integer;
{ construction d'un graphe aleatoire trophique ayant }
{ les mêmes sommets que g avec les memes degres }
var g1,x : integer;
begin
  with graphes[g] do
    g1 := alloc_graphe(g,nb_sommets,'#' + IntToStr(icre) + '_Deg',type_null_deg);
  if err_gestion then
    begin
      err_gestion := false;
      null_deg_graphe := 0;
      exit;
    end;
  null_deg_2mat(g);
  init_graphe(g1);
  if err_gestion then
    begin
      err_gestion := false;
      dealloc_graphe;
      null_deg_graphe := 0;
      exit;
    end;
  with graphes[g1] do
    for x := 1 to nb_sommets do ggg[x].nom := graphes[g].ggg[x].nom;
  calcul_graphe(g1);
  null_deg_graphe := create_graphe(g1);
end;

(*procedure flow2mat(g : integer);
{ creation de la matrice d'un graphe de flot }
var x,y,n : integer;
begin
  with graphes[g] do
    begin
      n := nb_sommets + 2;
      for x := 1 to n do
        for y := 1 to n do
          begin
            m_[x,y]  := 0;
            mr_[x,y] := 0.0;
          end;
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          y := succ;
          while ( y <> 0 ) do with lis[y] do
            begin
              m_[x+1,car+1]  := 1;
              mr_[x+1,car+1] := val;
              y := cdr;
            end;
        end;
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          if ( nb_pred = 0 ) then m_[1,x+1]  := 1;
          if ( nb_pred = 0 ) then mr_[1,x+1] := rand(10);{ rand(1)}
          m_[x+1,n]  := 1;
          mr_[x+1,n] := rand(1);
        end;
    end;
end;*)

(*function  flow_graphe(g : integer) : integer;
{ creation d'un graphe de flot en ajoutant une source et un puits }
{   * la source est reliee a toutes les especes basales -> sommet 1}
{   * les especes top sont rattachées au puits -> sommet n+2 }
{   * les valeurs des arcs de g sont les capacites du graphe construit }
{   * les capacites du puits et de la source sont calculees comme... }
var g1,n,x,y : integer;
begin
  with graphes[g] do
    begin
      n  := nb_sommets + 2;
      g1 := alloc_graphe(g,n,'#' + IntToStr(icre) + '_flow',type_gra_flow);
    end;
  if err_gestion then
    begin
      err_gestion := false;
      flow_graphe := 0;
      exit;
    end;
  flow2mat(g);
  with graphes[g] do
    begin
      for x := 1 to nb_sommets do graphes[g1].ggg[x+1].nom := ggg[x].nom;
      graphes[g1].ggg[1].nom := 'Source';
      graphes[g1].ggg[n].nom := 'Sink';
    end;
  reset_graine;
  init_graphe(g1);
  if err_gestion then
    begin
      err_gestion := false;
      dealloc_graphe;
      flow_graphe := 0;
      exit;
    end;
  calcul_graphe(g1);
  flow_graphe := create_graphe(g1);
end;*)

(*procedure flow2graphe(g : integer);
var x,y : integer;
begin
  graphe2mat(g);
  with graphes[g] do
    for x := 1 to nb_sommets do
      for y := 1 to nb_sommets do
        mr_[x,y] := flow[x+1,y+1];
  init_graphe(g);
end;*)

(*var capa : rmat_type;  { matrice des capacites }

function  ford_fulkerson(g,source,sink : integer) : extended;
{ on suppose que les arcs de g portent les capacites }
{ au retour, les arcs de g portent le flot }
var x,y : integer;
    parent : ivec_type;
    cap : rvec_type;

function  parc_larg : extended;
{ recherche d'un chemin augmentant de la source au puits par parcours largeur d'abord }
var x,u : integer;
begin
  with graphes[g] do
    begin
      initq;
      for x := 1 to nb_sommets do parent[x] := -1;
      parent[source] := -2;
      cap[source] := maxextended;
      pushq(source);
      while not videq do
        begin
          x := popq;
          with ggg[x] do
            begin
              u := succ;
              while ( u <> 0 ) do with lis[u] do
                begin
                  if ( parent[car] = -1 ) and ( capa[x,car] - flow[x,car] > 0.0 ) then
                    begin
                      parent[car] := x;
                      cap[car] := min(cap[x],capa[x,car] - flow[x,car]);
                      if ( car <> sink ) then
                        pushq(car)
                      else
                        begin
                          parc_larg := cap[sink];
                          exit;
                        end;
                    end;
                  u := cdr;
                end;
              u := pred;
              while ( u <> 0 ) do with lis[u] do
                begin
                  if ( parent[car] = -1 ) and ( capa[x,car] - flow[x,car] > 0.0 ) then
                    begin
                      parent[car] := x;
                      cap[car] := min(cap[x],capa[x,car] - flow[x,car]);
                      if ( car <> sink ) then
                        pushq(car)
                      else
                        begin
                          parc_larg := cap[sink];
                          exit;
                        end;
                    end;
                  u := cdr;
                end;
            end;
        end;
      parc_larg := 0;
    end;
end;

function  max_flow(n,source,sink : integer) : extended;
var x,y : integer;
    f,delta : extended;
begin
  f := 0.0;
  for x := 1 to n do
    for y := 1 to n do
      flow[x,y] := 0.0;
  while true do
    begin
      delta := parc_larg;
      if ( delta = 0 ) then break;
      f := f + delta;
      y := sink;
      while ( y <> source ) do
        begin
          x := parent[y];
          flow[x,y] := flow[x,y] + delta;
          flow[y,x] := flow[y,x] - delta;
          y := x;
        end;
    end;
  max_flow := f;
end;

begin
  with graphes[g] do
    begin
      for x := 1 to nb_sommets do
        for y := 1 to nb_sommets do
          capa[x,y] := 0.0;
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          y := succ;
          while ( y <> 0 ) do with lis[y] do
            begin
              capa[x,car] := val;
              y := cdr;
            end;
        end;
      ford_fulkerson := max_flow(nb_sommets,source,sink);
      {valmax := 0.0;
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          y := succ;
          while ( y <> 0 ) do with lis[y] do
            begin
              val := flow[x,car];
              valmax := max(valmax,val);
              y := cdr;
            end;
        end;}
    end;
end;*)

procedure simul_graphe(g : integer; nb_simul : integer);
label 1;
var g1,g_pere,isimul,ms : integer;
    rsimul_hau,rsimul_tro,rsimul_entropy : extended;
    s : string;

procedure simul_graphe1(g1,g,g_pere : integer);
{ g1 est le graphe courant sur lequel on calcule }
{ g est le graphe dont g1 est une realisation }
{ g_pere est le graphe parent de g }
begin
  with graphes[g1] do
    begin
    case typ of
      type_gra_erdos   : begin
                           erdos2mat(nb_sommets,graphes[g].param_p);
                         end;
      type_gra_unif    : begin
                           unif2mat(nb_sommets,graphes[g].nb_arcs);
                         end;
      type_gra_smallw  : begin
                           smallworld2mat(nb_sommets,
                                          graphes[g].param_deg,
                                          graphes[g].param_p);
                         end;
      type_gra_arb     : begin
                           arb2mat(graphes[g].param_deg,
                                   graphes[g].param_nb_niv,
                                   graphes[g].param_p,
                                   nb_sommets);
                           SetLength(ggg,nb_sommets+1); { ! }
                         end;
      type_gra_sub     : begin
                           sub2mat(g_pere,nb_sommets);
                         end;
      type_null_deg    : begin
                           null_deg_2mat(g_pere);
                         end;
      type_null_bit    : begin
                           null_bit_2mat(g_pere);
                         end;
      type_null_niche  : begin
                           null_niche_2mat(nb_sommets,
                                           graphes[g].param_p);
                         end;
      else
                         begin
                           graphe2mat(g_pere);
                           {null_deg_2mat(g_pere);}  { voir !!! }
                         end;
    end;
    end;
end;

procedure maj_graphe_simul(g : integer);
begin
  with graphes[g] do
    begin
      nb_sommets_simul := nb_sommets_simul + nb_sommets;
      nb_arcs_simul    := nb_arcs_simul + nb_arcs;
      nb_connect_simul := nb_connect_simul + nb_connect;
      nb_b_simul       := nb_b_simul + nb_b;
      nb_i_simul       := nb_i_simul + nb_i;
      nb_t_simul       := nb_t_simul + nb_t;
      deg_moy_simul    := deg_moy_simul + deg_moy;
      if ( haut_moy = bad ) then { nb_b = 0 ou time_out }
        rsimul_hau := rsimul_hau - 1.0
      else
        begin
          haut_moy_simul := haut_moy_simul + haut_moy;
          haut_max_simul := haut_max_simul + haut_max;
          o_index_simul  := o_index_simul + o_index;
          pathlen_simul  := pathlen_simul + pathlen;
        end;
      if ( trolev_moy = bad ) then
        rsimul_tro := rsimul_tro - 1.0
      else
        begin
          trolev_moy_simul := trolev_moy_simul + trolev_moy;
          trolev_max_simul := trolev_max_simul + trolev_max;
        end;
      nb_boucles_simul := nb_boucles_simul + nb_boucles;
      nb_cycles_simul  := nb_cycles_simul + nb_cycles;
      cyclen_simul     := cyclen_simul + cyclen;
      diam_simul       := diam_simul + diam;
      radius_simul     := radius_simul + radius;
      clust_simul      := clust_simul + clust;
      charlen_simul    := charlen_simul + charlen;
      assort_simul     := assort_simul + assort;
      if ( entropy = bad ) then
        rsimul_entropy := rsimul_entropy - 1.0
      else
        begin
          entropy_simul     := entropy_simul + entropy;
          entropy_val_simul := entropy_val_simul + entropy_val;
        end;
    end;
end;

procedure fin_graphe_simul(g,g1 : integer);
var rsimul : extended;
begin
  with graphes[g1] do
    begin
      rsimul := nb_simul;
      nb_sommets_simul := nb_sommets_simul/rsimul;
      nb_arcs_simul    := nb_arcs_simul/rsimul;
      nb_connect_simul := nb_connect_simul/rsimul;
      nb_b_simul       := nb_b_simul/rsimul;
      nb_i_simul       := nb_i_simul/rsimul;
      nb_t_simul       := nb_t_simul/rsimul;
      deg_moy_simul    := deg_moy_simul/rsimul;
      if ( rsimul_hau > 0.0 ) then
        begin
          haut_moy_simul := haut_moy_simul/rsimul_hau;
          haut_max_simul := haut_max_simul/rsimul_hau;
          o_index_simul  := o_index_simul/rsimul_hau;
          pathlen_simul  := pathlen_simul/rsimul_hau;
        end
      else
        begin
          haut_moy_simul := bad;
          haut_max_simul := bad;
          o_index_simul  := bad;
          pathlen_simul  := bad;
        end;
      if ( rsimul_tro > 0.0 ) then
        begin
          trolev_moy_simul := trolev_moy_simul/rsimul_tro;
          trolev_max_simul := trolev_max_simul/rsimul_tro;
        end
      else
        begin
          trolev_moy_simul := bad;
          trolev_max_simul := bad;
        end;
      nb_boucles_simul := nb_boucles_simul/rsimul;
      nb_cycles_simul  := nb_cycles_simul/rsimul;
      cyclen_simul     := cyclen_simul/rsimul;
      diam_simul       := diam_simul/rsimul;
      radius_simul     := radius_simul/rsimul;
      clust_simul      := clust_simul/rsimul;
      charlen_simul    := charlen_simul/rsimul;
      assort_simul     := assort_simul/rsimul;
      if ( rsimul_entropy > 0.0 ) then
        begin
          entropy_simul     := entropy_simul/rsimul_entropy;
          entropy_val_simul := entropy_val_simul/rsimul_entropy;
        end
      else
        begin
          entropy_simul     := bad;
          entropy_val_simul := bad;
        end;
      simul := nb_simul;
    end;
  with graphes[g] do
    begin
      nb_sommets_simul := graphes[g1].nb_sommets_simul;
      nb_arcs_simul    := graphes[g1].nb_arcs_simul;
      nb_connect_simul := graphes[g1].nb_connect_simul;
      nb_b_simul       := graphes[g1].nb_b_simul;
      nb_i_simul       := graphes[g1].nb_i_simul;
      nb_t_simul       := graphes[g1].nb_t_simul;
      deg_moy_simul    := graphes[g1].deg_moy_simul;
      haut_moy_simul   := graphes[g1].haut_moy_simul;
      haut_max_simul   := graphes[g1].haut_max_simul;
      trolev_moy_simul := graphes[g1].trolev_moy_simul;
      trolev_max_simul := graphes[g1].trolev_max_simul;
      o_index_simul    := graphes[g1].o_index_simul;
      pathlen_simul    := graphes[g1].pathlen_simul;
      nb_boucles_simul := graphes[g1].nb_boucles_simul;
      nb_cycles_simul  := graphes[g1].nb_cycles_simul;
      cyclen_simul     := graphes[g1].cyclen_simul;
      diam_simul       := graphes[g1].diam_simul;
      radius_simul     := graphes[g1].radius_simul;
      clust_simul      := graphes[g1].clust_simul;
      charlen_simul    := graphes[g1].charlen_simul;
      assort_simul     := graphes[g1].assort_simul;
      entropy_simul      := graphes[g1].entropy_simul;
      entropy_val_simul  := graphes[g1].entropy_val_simul;
      simul := nb_simul;
    end;
end;

procedure init_graphe_simul(g : integer);
begin
  rsimul_hau := nb_simul;
  rsimul_tro := nb_simul;
  rsimul_entropy := nb_simul;
  with graphes[g] do
    begin
      nb_sommets_simul := 0.0;
      nb_arcs_simul    := 0.0;
      nb_connect_simul := 0.0;
      nb_b_simul       := 0.0;
      nb_i_simul       := 0.0;
      nb_t_simul       := 0.0;
      deg_moy_simul    := 0.0;
      haut_moy_simul   := 0.0;
      haut_max_simul   := 0.0;
      trolev_moy_simul := 0.0;
      trolev_max_simul := 0.0;
      o_index_simul    := 0.0;
      pathlen_simul    := 0.0;
      nb_boucles_simul := 0.0;
      nb_cycles_simul  := 0.0;
      cyclen_simul     := 0.0;
      diam_simul       := 0.0;
      radius_simul     := 0.0;
      clust_simul      := 0.0;
      charlen_simul    := 0.0;
      assort_simul     := 0.0;
      entropy_simul      := 0.0;
      entropy_val_simul  := 0.0;
    end;
end;

begin
  with graphes[g] do
    begin
      g1 := alloc_graphe(g,nb_sommets,name,typ);
      g_pere := trouve_graphe(i_pere);
      if ( g_pere = 0 ) then
        if ( typ = type_gra_sub ) or
           ( typ = type_null_deg ) or ( typ = type_null_bit ) then
          begin
            erreur_('No parent network found');
            exit;
          end;
      iwriteln('Simul #' + IntToStr(icre) + '<#' + IntToStr(i_pere) +'>');
    end;
  if err_gestion then  { g1 = 0 }
    begin
      err_gestion := false;
      exit;
    end;
  with form_pad do
    begin
      if not Visible then show;
      SetFocus;
    end;
  ms := clock;
  graphe2mat(g);
  init_graphe_simul(g1);
  s := '';
  for isimul := 1 to nb_simul do
    begin
      {iwriteln('Simul ' + IntToStr(isimul));}
      s := s + IntToStr(isimul) + ' ';
      set_graine(isimul);
      simul_ := isimul;
      if ( simul_ mod 10 = 0 ) then
        begin
          form_nw.status_nbsimul(isimul);
          iwriteln(s);
          s := '';
        end;
      simul_graphe1(g1,g,g_pere);
      init_graphe(g1);
      if err_gestion then
        begin
          err_gestion := false;
          goto 1;
        end;
      calcul_graphe_simul(g1);
      maj_graphe_simul(g1);
    end;
  fin_graphe_simul(g,g1);
1:
  dealloc_graphe;
  reset_graine;
  iwriteln('--> ' + s_ecri_t_exec(clock-ms));
end;

end.
