unit kmath;

{  @@@@@@   mathematiques   @@@@@@  }

interface

uses  kglobvar;

type  rmatmat_type = array of array of extended;
      imatmat_type = array of array of integer;
      rvecvec_type = array of extended;
      ivecvec_type = array of integer;

procedure init_math;

function  imin(a,b : integer) : integer;
function  imax(a,b : integer) : integer;
function  min(a,b : extended) : extended;
function  max(a,b : extended) : extended;
procedure init_alea;
function  magraine : integer;
procedure set_graine(i : integer);
procedure set_graine0(i : integer);
procedure reset_graine;
procedure reset_graine0;
function  rand(a : extended) : extended;
function  ber(a : extended) : extended;
function  gauss(m,sigma : extended) : extended;
function  lognorm(m,sigma : extended) : extended;
function  geom(p : extended) : extended;
function  exponential(a : extended) : extended;
function  betaf(a,b : extended) : extended;
function  beta1f(m,s : extended) : extended;
function  gamm(a : extended) : extended;
function  poisson(xm : extended) : extended;
function  poissonf(n : integer; m : extended) : extended;
function  binomf(n : integer;p : extended) : extended;
function  binom(n: integer; p: extended; k: integer) : extended;
function  hypergeom(n,r,s,k : integer) : extended;
function  nbinom1f(m : extended;s : extended) : extended;
function  nbinomf(r : extended;p : extended) : extended;
function  tabf(tab : rvec_type;nb_arg : integer) : extended;
function  ln0(a : extended) : extended;
function  log(a : extended) : extended;
function  log0(a : extended) : extended;
function  fact(n : integer) : extended;
function  bicof(n,k : integer) : extended;

procedure tri_a_plus(n : integer;tab : svec_type;var trix : ivec_type);
procedure tri_a_moins(n : integer;tab : svec_type;var trix : ivec_type);
procedure tri_r_plus(n : integer;tab : rvec_type;var trix : ivec_type);
procedure tri_r_moins(n : integer;tab : rvec_type;var trix : ivec_type);
procedure tri_i_plus(n : integer;tab : ivec_type;var trix : ivec_type);
procedure tri_i_moins(n : integer;tab : ivec_type;var trix : ivec_type);

procedure permut(n : integer;var tab : ivecvec_type);
procedure coordmat(e,ncol : integer;var x,y : integer);

procedure matvalvecd1(n : integer;a : rmatmat_type;var w : rvecvec_type;var lambda1 : extended);
procedure matvalvec1(n : integer;a : rmatmat_type;var w,v : rvecvec_type;var lambda1 : extended);
{procedure matvecg1(n : integer;a : rmatmat_type;var v : rvecvec_type);}
procedure matkovvecd(n : integer;a : rmatmat_type;var w : rvecvec_type);
procedure matkovvecg(n : integer;a : rmatmat_type;var v : rvecvec_type);

function  matirr(n : integer;a : rmatmat_type) : boolean;
function  matprim(n : integer;a : rmatmat_type) : boolean;

procedure matinv(n : integer;a : rmatmat_type;var y : rmatmat_type);

const  graine00 = 1618;

var    graine0 : integer;
       graine  : integer;

       err_math : boolean;

implementation

//uses   SysUtils,kutil,ksyntax;

const  maxbicoftab = 50;

var    glinext,glinextp : integer;
       glma : array[1..55] of integer; { random generator ran3 }

       gaussflip : integer; { loi normale }
       gaussgg : extended;

       poissonoldm,poissonsq,poissonalxm,poissong : extended; { loi de poisson }

       binomnold : integer;
       binompold,binomoldg,binomen,
       binompc,binomplog,binompclog : extended; { loi binomiale }

       faclntab : array[1..100] of extended; { factorielle }
       bicoftab : array[0..maxbicoftab,0..maxbicoftab] of extended;


{ ------  utilitaires  ------ }

function  min(a,b : extended) : extended;
begin
  if ( a < b ) then min := a else min := b;
end;

function imin(a,b : integer) : integer;
begin
  if ( a < b ) then imin := a else imin := b;
end;

function  max(a,b : extended) : extended;
begin
  if ( a > b ) then max := a else max := b;
end;

function imax(a,b : integer) : integer;
begin
  if ( a > b ) then imax := a else imax := b;
end;


{ ------  variables aleatoires  ------ }

function ran3(idum : integer) : extended;
{ distribution uniforme sur [0, 1] }
const mbig  = 1000000000;
      mseed = 161803398;
      mz    = 0;
      fac   = 1.0e-9;
var   i,ii,k,mj,mk : integer;
begin
  if ( idum < 0 ) then
    begin
      mj := mseed + idum;
      mj := mj mod mbig;
      glma[55] := mj;
      mk := 1;
      for i := 1 to 54 do
        begin
          ii := 21*i mod 55;
          glma[ii] := mk;
          mk := mj - mk;
          if ( mk < mz ) then mk := mk + mbig;
          mj := glma[ii];
        end;
      for k := 1 to 4 do
        for i := 1 to 55 do
          begin
            glma[i] := glma[i] - glma[1 + (i + 30) mod 55];
            if ( glma[i] < mz ) then glma[i] := glma[i] + mbig;
          end;
      glinext  := 0;
      glinextp := 31;
    end;
  glinext := glinext + 1;
  if ( glinext = 56 ) then glinext := 1;
  glinextp := glinextp + 1;
  if ( glinextp = 56 ) then glinextp := 1;
  mj := glma[glinext] - glma[glinextp];
  if ( mj < mz ) then mj := mj + mbig;
  glma[glinext] := mj;
  ran3 := mj*fac;
end;

procedure init_alea;
var r : extended;
begin
  gaussflip   := 0;
  poissonoldm := -1.0;
  binomnold   := -1;
  binompold   := -1.0;
  r := ran3(-graine);
end;

function  magraine : integer;
begin
  magraine := graine0 - graine00 + 1;
end;

procedure set_graine(i : integer);
begin
  graine := graine0 + i-1;
  init_alea;
end;

procedure set_graine0(i : integer);
begin
  graine0 := graine00 + i-1;
  init_alea;
end;
procedure reset_graine;
begin
  graine := graine0;
  init_alea;
end;

procedure reset_graine0;
begin
  graine0 := graine00;
  reset_graine;
end;

function  rand(a : extended) : extended;
{ distribution uniforme sur [0, a] }
begin
  rand := ran3(1)*a;
end;

function  ber(a : extended) : extended;
begin
  if ( ran3(1) >= a ) then
    ber := 0.0
  else
    ber := 1.0;
end;

function  gauss0 : extended;
{ distribution gaussienne de moyenne 0 et d'ecart-type 1 }
var v1,v2,fac,r : extended;
begin
  if ( gaussflip = 0 ) then
    begin
      gaussflip := 1;
      repeat
        v1 := 2.0*ran3(1) - 1.0;
        v2 := 2.0*ran3(1) - 1.0;
        r  := sqr(v1) + sqr(v2);
      until r < 1.0;
      fac := sqrt(-2.0*ln(r)/r);
      gaussgg  := v1*fac;
      gauss0  := v2*fac;
    end
  else
    begin
      gaussflip := 0;
      gauss0 := gaussgg;
    end;
end;

function  gauss(m,sigma : extended) : extended;
{ distribution gaussienne de moyenne m et d'ecart-type sigma }
begin
  gauss := m + gauss0*sigma;
end;

function  lognorm(m,sigma : extended) : extended;
{ distribution lognormale de moyenne m et d'ecart-type sigma }
{ m, sigma > 0 }
var c : extended;
begin
  c := sigma/m;
  c := ln(c*c + 1.0);
  lognorm := exp(gauss(ln(m) - 0.5*c,sqrt(c)));
end;

function  geom(p : extended) : extended;
{ distribution geometrique de parametre p }
{ P(X = k) = p(1-p)^k, moyenne = (1-p)/p  }
{ P(X = 0) = p }
begin
  geom := trunc(ln(ran3(1))/ln(1.0 - p));
end;

function  exponential(a : extended) : extended;
{ distribution exponentielle de parametre a }
{ densité f(x) = a*exp(-ax), moyenne = 1/a, variance = 1/a^2}
var u : extended;
begin
  repeat
    u := ran3(1)
  until u > 0;
  exponential := -ln(u)/a;
end;

function  gammln(xx : extended) : extended;
{ ln de la fonction gamma d'Euler }
const stp  = 2.50662827465;
var x,tmp,ser : extended;
begin
  x   := xx - 1.0;
  tmp := x + 5.5;
  tmp := (x + 0.5)*ln(tmp) - tmp;
  ser := 1.0 + 76.18009173/(x+1.0) - 86.50532033/(x+2.0) + 24.01409822/(x+3.0)
         - 1.231739516/(x+4.0) + 0.120858003e-2/(x+5.0) - 0.536382e-5/(x+6.0);
  gammln := tmp + ln(stp*ser);
end;

function  gamm(a : extended) : extended;
{ var aleatoire suivant une loi gamma de parametre a > 0 }
var am,e,s,v1,v2,x,y : extended;
begin
  if ( a > 1 ) then
    begin
      repeat
        repeat
          repeat
            v1 := 2.0*ran3(1) - 1.0;
            v2 := 2.0*ran3(1) - 1.0;
          until ( sqr(v1) + sqr(v2) <= 1.0 );
          y  := v2/v1;
          am := a - 1.0;
          s  := sqrt(2.0*am + 1.0);
          x  := s*y + am;
        until ( x > 0.0 );
        s := am*ln(x/am) - s*y;
        if ( s > -500.0 ) then
          e := (1.0 + sqr(y))*exp(s)
        else
          e := 0.0;
        {e := (1.0 + sqr(y))*exp(am*ln(x/am) - s*y); }
      until ( ran3(1) <= e );
    end
  else
    begin
      s := exp(1);
      s := s/(a+s);
      repeat
        v1 := ran3(1);
        v2 := ran3(1);
        if ( v1 < s ) then
          begin
            x := exp(ln(v2)/a);
            e := exp(-x);
          end
        else
          begin
            x := 1.0 - ln(v2);
            e := exp(ln(x)*(a-1.0));
          end
      until ( ran3(1) < e );
    end;
  gamm := x;
end;

function  betaf(a,b : extended) : extended;
{ var aleatoire suivant une loi beta de parametres a > 0, b > 0 }
var u,v :extended;
begin
  u := gamm(a);
  v := gamm(b);
  betaf := u/(u + v);
  {repeat
    u := exp(ln(ran3(1))/a);
    v := exp(ln(ran3(1))/b);
  until (u + v) <= 1;
  betaf := u/(u + v); }
end;

function  beta1f(m,s : extended) : extended;
{ var aleatoire suivant une loi beta de parametres a, b }
{ calcules de sorte que beta1 ait pour moyenne    m > 0 }
{                              et pour ecart_type s > 0 }
{ on doit avoir 0 < m < 1 et 0 < s^2 < m*(1-m)          }
var a,b : extended;
begin
  a := m*m*(1.0 - m)/(s*s) - m;
  b := a/m - a;
  beta1f := betaf(a,b);
end;

function  tabf(tab : rvec_type;nb_arg : integer) : extended;
{ distribution entiere tabulee              }
{ retourne k avec probabilite pk = tab[k+1] }
{ P(X = k) = pk                             }
{ pour k = 0 a n = nb_arg - 1               }
{ 0 <= pk <= 1, p0 + ... + pn = 1           }
var i : integer;
    x,s : extended;
begin
  x := ran3(1);
  s := 0.0;
  for i := 1 to nb_arg do
    begin
      s := s + tab[i];
      if ( tab[i] <> 0.0 ) then
        if ( x <= s ) then break;
      if ( s > 1.0 ) then break;
    end;
  tabf := i-1;
end;

function  poisson(xm : extended) : extended;
{ distribution de poisson de parametre xm }
{ moyenne = xm = m, variance = m          }
{ P(X = k) = exp(-m)m^k/m!                }
var em,t,y,s : extended;
begin
  if ( xm < 12.0 ) then
    begin
      if ( xm <> poissonoldm ) then
        begin
          poissonoldm := xm;
          poissong := exp(-xm);
        end;
      em := -1.0;
      t  := 1.0;
      repeat
        em := em + 1.0;
        t  := t*ran3(1);
      until ( t <= poissong );
    end
  else
    begin
      if ( xm <> poissonoldm ) then
        begin
          poissonoldm := xm;
          poissonsq   := sqrt(2.0*xm);
          poissonalxm := ln(xm);
          poissong    := xm*poissonalxm - gammln(xm + 1.0);
        end;
      repeat
        repeat
          y  := pi*ran3(1);
          y  := sin(y)/cos(y);
          em := poissonsq*y + xm;
        until ( em >= 0.0 );
        em := trunc(em);
        s := em*poissonalxm - gammln(em + 1.0) - poissong;
        if ( s > -500.0 ) then
          t := 0.9*(1.0 + sqr(y))*exp(s)
        else
          t := 0.0;
        {t  := 0.9*(1.0 + sqr(y))*exp(em*poissonalxm - gammln(em + 1.0) - poissong);}
      until ( ran3(1) <= t );
    end;
  poisson := em;
end;

function  poissonf(n : integer; m : extended) : extended;
{ somme de n tirages selon la loi de Poisson de moyenne m }
var i : integer;
    s : extended;
begin
  s := 0.0;
  for i := 1 to n do s := s + poisson(m);
  poissonf := s;
end;

function  binomf(n : integer;p : extended) : extended;
{ distribution binomiale de parametres n >= 0, 0 <= p <= 1 }
{ P(X = k) = C(k,n)p^k(1-p)^(n-k) }
{ moyenne np, variance np(1-p)    }
var  j : integer;
     u,pp,am,em,g,angle,sq,t,y,s : extended;
begin
  if ( n < 25 ) then
    begin
      if ( p <= 0.5 ) then pp := p else pp := 1.0 - p;
      u := 0.0;
      for j := 1 to n do
        if ( ran3(1) < pp ) then u := u + 1.0;
      if ( p <> pp ) then u := n - u;
      binomf := u;
    end
  else
    begin
      if ( p <= 0.5 ) then pp := p else pp := 1.0 - p;
      am := n*pp;
      if ( am < 1 ) then
        begin
          g := exp(-am);
          t := 1.0;
          j := -1;
          repeat
            j := j + 1;
            t := t*ran3(1);
          until ( t < g ) or ( j = n );
          u := j;
        end
      else
        begin
          if ( n <> binomnold ) then
            begin
              binomen   := n;
              binomoldg := gammln(binomen + 1.0);
              binomnold := n;
            end;
          if ( pp <> binompold ) then
            begin
              binompc    := 1.0 - pp;
              binomplog  := ln(pp);
              binompclog := ln(binompc);
              binompold  := pp;
            end;
          sq := sqrt(2.0*am*binompc);
          repeat
            repeat
              angle := pi*ran3(1);
              if ( angle = pisur2 ) then
                y := 1.0
              else
                y := sin(angle)/cos(angle);
              em := sq*y + am;
            until ( em >= 0.0 ) and ( em < (binomen + 1.0) );
            em := trunc(em);
            s := binomoldg - gammln(em + 1.0)
                 - gammln(binomen - em + 1.0) + em*binomplog + (binomen-em)*binompclog;
            if ( s > -500.0 ) then
              t := 1.2*sq*(1.0 + sqr(y))*exp(s)
            else
              t := 0.0;
            {t := 1.2*sq*(1.0 + sqr(y))*exp(binomoldg - gammln(em + 1.0)
                 - gammln(binomen - em + 1.0) + em*binomplog + (binomen-em)*binompclog);}
          until ( ran3(1) <= t );
          u := em;
        end;
      if ( p <> pp ) then u := n - u;
      binomf := u;
    end;
end;

function  binom(n: integer; p: extended; k: integer) : extended;
{ proba que P(X=k) ou X suit une loi binomiale }
{ de parametres n et p }
begin
  if p=0 then
    if k=0 then binom:=1
      else binom:=0
  else
    if p=1 then
      if k=1 then binom:=1
        else binom:=0
     else binom:= bicof(n,k)* exp(k*ln(p))*exp((n-k)*ln(1-p));
end;

function  hypergeom(n,r,s,k : integer) : extended;
{ proba que P(X = k) ou X suit une loi hypergeometrique }
{ de parametres n, r, s }
begin
  hypergeom := bicof(r,k)*bicof(n-r,s-k)/bicof(n,s);
end;

function  nbinomf(r : extended;p : extended) : extended;
{ distribution binomiale negative       }
{ de parametres r > 0, 0 < p <= 1       }
{ P(X = k) = C(k+r-1,r-1)p^r(1-p)^k     }
{ moyenne r(1-p)/p, variance r(1-p)/p^2 }
var y : extended;
begin
  y := gamm(r);
  nbinomf := poisson(y*(1.0-p)/p);
end;

function  nbinom1f(m : extended;s : extended) : extended;
{ distribution binomiale negative de moyenne m et ecart-type s }{ 0 < m < s^2 }
var p,r : extended;
begin
  p := m/(s*s);
  r := p*m/(1.0-p);
  nbinom1f := nbinomf(r,p);
end;

{ ------  autres fonctions mathematiques  ------ }

function  ln0(a : extended) : extended;
begin
  if ( a <= 0.0 ) then ln0 := 0.0 else ln0 := ln(a);
end;

function  log(a : extended) : extended;
begin
  log := ln(a)/ln(10.0);
end;

function  log0(a : extended) : extended;
begin
  if ( a <= 0.0 ) then log0 := 0.0 else log0 := log(a);
end;

function  facln(n : integer) : extended;
begin
  if ( n <= 99 ) then
    begin
      if ( faclntab[n+1] < 0.0 ) then
        faclntab[n+1] := gammln(n + 1.0 );
      facln := faclntab[n+1];
    end
  else
    facln := gammln(n + 1.0);
end;

function  fact(n : integer) : extended;
{ factorielle n! }
begin
  if ( n <= 0 ) then
    fact := 1.0
  else
    fact := exp(facln(n));
end;

function  bicof(n,k : integer) : extended;
{ coefficients binomiaux C(n,k) }
var r : extended;
begin
  if ( k > n ) then
    begin
      bicof := 0.0;
      exit;
    end;
  if ( n <= maxbicoftab ) and ( k <= maxbicoftab ) then
    begin
      if ( bicoftab[n,k] < 0.0 ) then
        begin
          r := exp(facln(n) - facln(k) - facln(n-k));
          if ( r < bigint ) then
            bicoftab[n,k] := round(r)
          else
            bicoftab[n,k] := r;
        end;
      bicof := bicoftab[n,k];
    end
  else
    begin
      r := exp(facln(n) - facln(k) - facln(n-k));
      if ( r < bigint ) then
        bicof := round(r)
      else
        bicof := r;
    end;
end;

{ ------ procedures de tri ------ }

procedure tri_a_plus(n : integer;tab : svec_type;var trix : ivec_type);
{ trie le tableau de strings tab par ordre lexicographique croissant }
{ et met l'ordre dans le tableau trix }
{ heapsort }
var x,z,i,j,k : integer;
    u : string;
begin
  for x := 1 to n do trix[x] := x;
  if ( n <= 1 ) then exit;
  z := n div 2 + 1;
  x := n;
  while true do
    begin
      if ( z > 1 ) then
        begin
          z := z - 1;
          i := trix[z];
          u := tab[i];
        end
      else
        begin
          i := trix[x];
          u := tab[i];
          trix[x] := trix[1];
          x := x - 1;
          if ( x = 1 ) then
            begin
              trix[1] := i;
              exit;
            end;
        end;
      j := z;
      k := z + z;
      while ( k <= x ) do
        begin
          if ( k < x ) then
            if ( tab[trix[k]] < tab[trix[k+1]] ) then k := k + 1;
          if ( u < tab[trix[k]] ) then
            begin
              trix[j] := trix[k];
              j := k;
              k := k + k;
            end
          else
            k := x + 1;
        end;
      trix[j] := i;
    end;
end;

procedure tri_a_moins(n : integer;tab : svec_type;var trix : ivec_type);
{ trie le tableau de strings tab par ordre lexicographique decroissant }
{ et met l'ordre dans le tableau trix }
{ heapsort }
var x,z,i,j,k : integer;
    u : string;
begin
  for x := 1 to n do trix[x] := x;
  if ( n <= 1 ) then exit;
  z := n div 2 + 1;
  x := n;
  while true do
    begin
      if ( z > 1 ) then
        begin
          z := z - 1;
          i := trix[z];
          u := tab[i];
        end
      else
        begin
          i := trix[x];
          u := tab[i];
          trix[x] := trix[1];
          x := x - 1;
          if ( x = 1 ) then
            begin
              trix[1] := i;
              exit;
            end;
        end;
      j := z;
      k := z + z;
      while ( k <= x ) do
        begin
          if ( k < x ) then
            if ( tab[trix[k]] > tab[trix[k+1]] ) then k := k + 1;
          if ( u > tab[trix[k]] ) then
            begin
              trix[j] := trix[k];
              j := k;
              k := k + k;
            end
          else
            k := x + 1;
        end;
      trix[j] := i;
    end;
end;

procedure tri_r_plus(n : integer;tab : rvec_type;var trix : ivec_type);
{ trie le tableau reel tab par ordre croissant et met l'ordre dans le tableau trix }
{ heapsort }
var x,z,i,j,k : integer;
    u : extended;
begin
  for x := 1 to n do trix[x] := x;
  if ( n <= 1 ) then exit;
  z := n div 2 + 1;
  x := n;
  while true do
    begin
      if ( z > 1 ) then
        begin
          z := z - 1;
          i := trix[z];
          u := tab[i];
        end
      else
        begin
          i := trix[x];
          u := tab[i];
          trix[x] := trix[1];
          x := x - 1;
          if ( x = 1 ) then
            begin
              trix[1] := i;
              exit;
            end;
        end;
      j := z;
      k := z + z;
      while ( k <= x ) do
        begin
          if ( k < x ) then
            if ( tab[trix[k]] < tab[trix[k+1]] ) then k := k + 1;
          if ( u < tab[trix[k]] ) then
            begin
              trix[j] := trix[k];
              j := k;
              k := k + k;
            end
          else
            k := x + 1;
        end;
      trix[j] := i;
    end;
end;

procedure tri_r_moins(n : integer;tab : rvec_type;var trix : ivec_type);
{ trie le tableau reel tab par ordre decroissant et met l'ordre dans le tableau trix }
{ heapsort }
var x,z,i,j,k : integer;
    u : extended;
begin
  for x := 1 to n do trix[x] := x;
  if ( n <= 1 ) then exit;
  z := n div 2 + 1;
  x := n;
  while true do
    begin
      if ( z > 1 ) then
        begin
          z := z - 1;
          i := trix[z];
          u := tab[i];
        end
      else
        begin
          i := trix[x];
          u := tab[i];
          trix[x] := trix[1];
          x := x - 1;
          if ( x = 1 ) then
            begin
              trix[1] := i;
              exit;
            end;
        end;
      j := z;
      k := z + z;
      while ( k <= x ) do
        begin
          if ( k < x ) then
            if ( tab[trix[k]] > tab[trix[k+1]] ) then k := k + 1;
          if ( u > tab[trix[k]] ) then
            begin
              trix[j] := trix[k];
              j := k;
              k := k + k;
            end
          else
            k := x + 1;
        end;
      trix[j] := i;
    end;
end;

procedure tri_i_plus(n : integer;tab : ivec_type;var trix : ivec_type);
{ trie le tableau entier tab par ordre croissant et met l'ordre dans le tableau trix }
{ heapsort }
var x,z,i,j,k,u : integer;
begin
  for x := 1 to n do trix[x] := x;
  if ( n <= 1 ) then exit;
  z := n div 2 + 1;
  x := n;
  while true do
    begin
      if ( z > 1 ) then
        begin
          z := z - 1;
          i := trix[z];
          u := tab[i];
        end
      else
        begin
          i := trix[x];
          u := tab[i];
          trix[x] := trix[1];
          x := x - 1;
          if ( x = 1 ) then
            begin
              trix[1] := i;
              exit;
            end;
        end;
      j := z;
      k := z + z;
      while ( k <= x ) do
        begin
          if ( k < x ) then
            if ( tab[trix[k]] < tab[trix[k+1]] ) then k := k + 1;
          if ( u < tab[trix[k]] ) then
            begin
              trix[j] := trix[k];
              j := k;
              k := k + k;
            end
          else
            k := x + 1;
        end;
      trix[j] := i;
    end;
end;

procedure tri_i_moins(n : integer;tab : ivec_type;var trix : ivec_type);
{ trie le tableau entier tab par ordre decroissant et met l'ordre dans le tableau trix }
{ heapsort }
var x,z,i,j,k,u : integer;
begin
  for x := 1 to n do trix[x] := x;
  if ( n <= 1 ) then exit;
  z := n div 2 + 1;
  x := n;
  while true do
    begin
      if ( z > 1 ) then
        begin
          z := z - 1;
          i := trix[z];
          u := tab[i];
        end
      else
        begin
          i := trix[x];
          u := tab[i];
          trix[x] := trix[1];
          x := x - 1;
          if ( x = 1 ) then
            begin
              trix[1] := i;
              exit;
            end;
        end;
      j := z;
      k := z + z;
      while ( k <= x ) do
        begin
          if ( k < x ) then
            if ( tab[trix[k]] > tab[trix[k+1]] ) then k := k + 1;
          if ( u > tab[trix[k]] ) then
            begin
              trix[j] := trix[k];
              j := k;
              k := k + k;
            end
          else
            k := x + 1;
        end;
      trix[j] := i;
    end;
end;

{ ------ permutation ------ }

procedure permut(n : integer;var tab : ivecvec_type);
{ generate a random permutation of size n -> tab }
var x,i,j : integer;
begin
  for i := 1 to n do tab[i] := i;
  i := n;
  while ( i > 1 ) do
    begin
      j := trunc(rand(i)) + 1;
      x := tab[i];
      tab[i] := tab[j];
      tab[j] := x;
      i := i - 1;
    end;
end;

{ ------ utilitaire matrice ------ }

procedure coordmat(e,ncol : integer;var x,y : integer);
{ associate entries (x,y) in matrix (nrow,ncol) to entry of index e }
begin
  x := e div ncol;
  y := e mod ncol;
  if ( y = 0 ) then
    y := ncol
  else
    x := x + 1;
end;

{ ------ recherche valeur propre dominante ------ }

procedure matvalvecd1(n : integer;a : rmatmat_type;var w : rvecvec_type;var lambda1 : extended);
{ a matrice non negative }
{ recherche de la valeur propre dominante lambda1 }
{ et du vecteur propre a droite w par iteration }
label 1;
const eps = 1.0E-9;
      tmax = 10000;
var t,i,j : integer;
    w1 : rvecvec_type;
    sum,lamb,lamb1 : extended;
begin
  SetLength(w1,n+1);
  for i := 1 to n do w[i] := 1.0/n;
  lamb := 1.0;
  t := 0;
  repeat
    t := t + 1;
    lamb1 := lamb;
    for i := 1 to n do
      begin
        sum := 0.0;
        for j := 1 to n do sum := sum + a[i,j]*w[j];
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

procedure matvalvec1(n : integer;a : rmatmat_type;var w,v : rvecvec_type;var lambda1 : extended);
{ a matrice non negative }
{ recherche de la valeur propre dominante lambda1 }
{ et des vecteurs propres a gauche v et a droite w, par iteration }
label 1;
const eps = 1.0E-9;
      tmax = 10000;
var t,i,j : integer;
    w1,v1 : rvecvec_type;
    sum,lamb,lamb1 : extended;
begin
  SetLength(w1,n+1);
  SetLength(v1,n+1);
  for i := 1 to n do w[i] := 1.0/n;
  for j := 1 to n do v[j] := 1.0/n;
  lamb := 1.0;
  t := 0;
  repeat
    t := t + 1;
    lamb1 := lamb;
    for i := 1 to n do
      begin
        sum := 0.0;
        for j := 1 to n do sum := sum + a[i,j]*w[j];
        w1[i] := sum;
      end;
    for j := 1 to n do
      begin
        sum := 0.0;
        for i := 1 to n do sum := sum + v[i]*a[i,j];
        v1[j] := sum;
      end;
    sum := 0.0;
    for i := 1 to n do sum := sum + w1[i];
    if ( sum > 0.0 ) then
      for i := 1 to n do w[i] := w1[i]/sum
    else
      goto 1;
    sum := 0.0;
    for j := 1 to n do sum := sum + v1[j];
    if ( sum > 0.0 ) then
      for j := 1 to n do v[j] := v1[j]/sum
    else
      goto 1;
    lamb := sum;
  until ( abs(lamb1 - lamb) < eps ) or ( t >= tmax );
  lambda1 := lamb;
1 :
end;

procedure matvecg1(n : integer;a : rmatmat_type;var v : rvecvec_type);
{ a matrice non negative }
{ recherche du vecteur propre a gauche v par iteration }
label 1;
const tmax = 10000;
var t,i,j : integer;
    v1 : rvecvec_type;
    sum : extended;
begin
  SetLength(v1,n+1);
  for j := 1 to n do v[j] := 1.0/n;
  t := 0;
  repeat
    t := t + 1;
    for j := 1 to n do
      begin
        sum := 0.0;
        for i := 1 to n do sum := sum + v[i]*a[i,j];
        v1[j] := sum;
      end;
    sum := 0.0;
    for j := 1 to n do sum := sum + v1[j];
    if ( sum > 0.0 ) then
      for j := 1 to n do v[j] := v1[j]/sum
    else
      goto 1;
  until ( t > tmax );
1 :
end;

procedure matkovvecd(n : integer;a : rmatmat_type;var w : rvecvec_type);
{ recherche du vecteur propre a droite w par iteration }
{ a matrice chaine de Markov irreductible (lambda = 1) }
const eps = 1.0E-9;
      tmax = 10000;
var i,j,t : integer;
    w1 : rvecvec_type;
    sum,d : extended;
begin
  SetLength(w1,n+1);
  for i := 1 to n do w[i] := 1.0/n;
  t := 0;
  repeat
    t := t + 1;
    for i := 1 to n do
      begin
        sum := 0.0;
        for j := 1 to n do sum := sum + a[i,j]*w[j];
        w1[i] := sum;
      end;
    d := 0.0;
    for i := 1 to n do d := d + abs(w1[i] - w[i]);
    for i := 1 to n do w[i] := w1[i];
  until ( d < eps ) or ( t >= tmax);
end;

procedure matkovvecg(n : integer;a : rmatmat_type;var v : rvecvec_type);
{ recherche du vecteur propre a gauche v par iteration }
{ a matrice chaine de Markov irreductible (lambda = 1) }
const eps = 1.0E-9;
      tmax = 10000;
var i,j,t : integer;
    v1 : rvecvec_type;
    sum,d : extended;
begin
  SetLength(v1,n+1);
  for j := 1 to n do v[j] := 1.0/n;
  t := 0;
  repeat
    t := t + 1;
    for j := 1 to n do
      begin
        sum := 0.0;
        for i := 1 to n do sum := sum + v[i]*a[i,j];
        v1[j] := sum;
      end;
    d := 0.0;
    for j := 1 to n do d := d + abs(v1[j] - v[j]);
    for j := 1 to n do v[j] := v1[j];
  until ( d < eps ) or ( t >= tmax);
  //iwriteln('matkovvecg  t = ' + IntToStr(t) + ' d = ' + s_ecri_val(d));
end;

{ ------ irreductibilite, primitivite ------ }

(*procedure ecri_mat(n : integer; a : rmatmat_type);
var i,j : integer;
    s : string;
begin
  for i := 1 to n do
    begin
      s := '';
      for j := 1 to n do s := s + s_ecri_val(a[i,j]) + hortab;
      iwriteln(s);
    end;
end;*)

procedure matprod(n : integer;a,b : rmatmat_type;var c : rmatmat_type);
{ produit matriciel c = ab }
var i,j,k : integer;
    x : extended;
begin
  for i := 1 to n do
    for j := 1 to n do
      begin
        x := 0.0;
        for k := 1 to n do x := x + a[i,k]*b[k,j];
        c[i,j] := x;
      end;
end;

function  matpos(n : integer;a : rmatmat_type) : boolean;
{ teste si a est une matrice positive, i.e., a_ij > 0 pour tous i,j }
var i,j : integer;
begin
  for i := 1 to n do
    for j := 1 to n do
      if ( a[i,j] <= 0.0 ) then
        begin
          matpos := false;
          exit;
        end;
  matpos := true;
end;

function  matirr(n : integer;a : rmatmat_type) : boolean;
{ teste si la matrice non negative a est irreductible }
var i,j,p,n1 : integer;
    b,c : rmatmat_type;
begin
  n1 := n + 1;
  SetLength(b,n1,n1);
  SetLength(c,n1,n1);
  for i:= 1 to n do
    for j := 1 to n do
      if ( j <> i ) then b[i,j] := a[i,j] else b[i,j] := a[i,j] + 1.0;
  p := 1;
  repeat
    matprod(n,b,b,c);
    for i:= 1 to n do
      for j := 1 to n do
        b[i,j] := c[i,j];
    p := 2*p;
  until ( p >= n-1 );
  matirr := matpos(n,b);
end;

procedure matnormalise(n : integer;var a : rmatmat_type);
{ normalisation }
var i,j : integer;
    sum : extended;
begin
  sum := 0.0;;
  for i := 1 to n do
    for j := 1 to n do
      sum := sum + a[i,j];
  for i := 1 to n do
    for j := 1 to n do
      a[i,j] := a[i,j]/sum;
end;

function  matprim(n : integer;a : rmatmat_type) : boolean;
{ teste si la matrice non negative a est primitive }
{ inefficace pour n > 200, et pb debordement }
var p,m,n1,i,j : integer;
    b : rmatmat_type;
begin
  n1 := n + 1;
  SetLength(b,n1,n1);
  p := 1;
  m := (n-1)*(n-2);
  repeat
    matprod(n,a,a,b);
    for i := 1 to n do
      for j := 1 to n do
        a[i,j] := b[i,j];
    p := 2*p;
  until ( p >= m );
  matprim := matpos(n,a);
end;

{ ------ calcul de l'inverse d'une matrice ------ }

procedure matlu(n : integer;var a : rmatmat_type;var indx : ivecvec_type);
{ a est decomposee en une matrice lu }
{ indx decrit les permutations effectuees sur les lignes de a }
const tiny = 1.0e-20;
var i,j,k,imax : integer;
    sum,dum,big : extended;
    vv : rvecvec_type;
begin
  SetLength(vv,n+1);
  for i := 1 to n do
    begin
      big := 0.0;
      for j := 1 to n do 
        if ( abs(a[i,j]) > big ) then
          big := abs(a[i,j]);
      if ( big = 0.0 ) then
        begin
          err_math := true;
          exit;
        end;
      vv[i] := 1.0/big; 
    end;
  for j := 1 to n do
    begin
      for i := 1 to j-1 do
        begin
          sum := a[i,j];
          for k := 1 to i-1 do sum := sum - a[i,k]*a[k,j];
          a[i,j] := sum;
        end;
      big := 0.0;
      for i := j to n do
        begin
          sum := a[i,j];
          for k := 1 to j-1 do sum := sum - a[i,k]*a[k,j];
          a[i,j] := sum;
          dum := vv[i]*abs(sum);
          if ( dum >= big ) then 
            begin
              big := dum;
              imax := i;
            end;
        end;
      if ( j <> imax ) then
        begin
          for k := 1 to n do
            begin
              dum := a[imax,k];
              a[imax,k] := a[j,k];
              a[j,k] := dum;
            end;
          vv[imax] := vv[j];
        end;
        indx[j] := imax;
        if ( a[j,j] = 0.0 ) then a[j,j] := tiny;
        if ( j <> n ) then
          begin
            dum := 1.0/a[j,j];
            for i := j+1 to n do a[i,j] := a[i,j]*dum;
          end;
    end;
end;

procedure matlusolv(n : integer;var a : rmatmat_type;indx : ivecvec_type;var b : rvecvec_type);
{ resolution du systeme lineaire ax = b            }
{ a decomposition lu en provenance de matlu        }
{ b transforme en le vecteur solution x            }
{ ref : "Numerical Recipes" pp 33-38 et pp 683-684 }
var i,j,ii,ip : integer;
    sum : extended;
begin
  ii := 0;
  for i := 1 to n do
    begin
      ip := indx[i];
      sum := b[ip];
      b[ip] := b[i];
      if ( ii <> 0 ) then
        for j := ii to i-1 do sum := sum - a[i,j]*b[j]
      else
        if ( sum <> 0.0 ) then ii := i;
      b[i] := sum;
    end;
  for i := n downto 1 do
    begin
      sum := b[i];
      if ( i < n ) then
        for j := i+1 to n do sum := sum - a[i,j]*b[j];
      b[i] := sum/a[i,i];
    end;
end;

procedure matinv(n : integer;a : rmatmat_type;var y : rmatmat_type);
{ calcul de l'inverse y de la matrice a, qui est detruite }
{ resolution du systeme lineaire ax = b, b colonne de y }
var i,j,n1 : integer;
    indx : ivecvec_type;
    yj : rvecvec_type;
begin
  n1 := n + 1;
  SetLength(indx,n1);
  SetLength(yj,n1);
  for i := 1 to n do
    for j := 1 to n do
      if ( i = j ) then
        y[i,j] := 1.0
      else
        y[i,j] := 0.0;
  matlu(n,a,indx);
  if err_math then exit;
  for j := 1 to n do
    begin
      for i := 1 to n do yj[i] := y[i,j];
      matlusolv(n,a,indx,yj);
      for i := 1 to n do y[i,j] := yj[i];
    end;
end;

{ ------ init ------ }

procedure init_math;
var i,j : integer;
begin
  graine0  := graine00;
  graine   := graine00;
  RandSeed := graine00;
  for i := 1 to 100 do faclntab[i] := -1.0;
  for i := 0 to maxbicoftab do
    for j := 0 to maxbicoftab do bicoftab[i,j] := -1.0;
end;

end.
