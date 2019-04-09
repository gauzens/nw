unit klist;

{  @@@@@@   gestion des listes   @@@@@@  }

interface

uses kglobvar;

procedure init_lis;
function  cons(ca,typ : integer;va : extended;cd : integer) : integer;

var err_lis : boolean;

implementation

uses SysUtils,
     kutil;

procedure erreur_lis(s : string);
begin
  if not err_lis then erreur_('Lists - ' + s);
  err_lis := true;
end;

procedure init_lis; 
var x : integer; 
begin
  for x := 1 to lis_nb_max do lis[x].cdr := x + 1;
  lis[lis_nb_max].cdr := 0;
  lis_lib := 1; 
  lis_nb  := 0; 
end; 
 
procedure mark_lis(x : integer); 
var z : integer; 
begin 
  while ( x <> 0 ) do with lis[x] do
    begin 
      z := cdr; 
      if ( z < 0 ) then exit; 
      cdr := -z - 1; 
      if ( car_type = type_lis ) then mark_lis(car); 
      x := z; 
    end;  
end; 
 
procedure gc(ca,typ,cd : integer); 
var x,n,g : integer;
begin 
  if ( typ = type_lis ) then mark_lis(ca); 
  if ( cd <> 0 ) then mark_lis(cd);
  for g := 1 to nb_graphes do with graphes[g] do
    for x := 1 to nb_sommets do with ggg[x] do
      begin
        mark_lis(succ);
        mark_lis(pred);
        mark_lis(cyc);
      end;
  n := 0;
  for x := 1 to lis_nb_max do with lis[x] do
    if ( cdr >= 0 ) then 
      begin 
        cdr := lis_lib; 
        lis_lib := x; 
        n := n + 1; 
      end 
    else 
      cdr := -cdr - 1; 
  lis_nb := lis_nb - n; 
  if ( n > 0 ) then
    iwriteln('-> gc : ' + IntToStr(n) + ' cells free');
end; 
 
function  cons(ca,typ : integer;va : extended;cd : integer) : integer;
var x : integer; 
begin 
  if ( lis_lib = 0 ) then gc(ca,typ,cd); 
  if ( lis_lib = 0 ) then 
    begin
      erreur_lis('Out of memory');
      exit;
    end; 
  x := lis_lib; 
  with lis[x] do
    begin 
      lis_lib  := cdr; 
      car_type := typ; 
      car := ca;
      val := va;
      cdr := cd; 
    end; 
  lis_nb := lis_nb + 1; 
  cons := x; 
end;

end.
