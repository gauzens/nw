unit ksyntax;

{  @@@@@@   chaines de caracteres   @@@@@@  }

interface

uses Classes,kglobvar;

procedure init_syntax;

function  lowcase(car : char) : char;
function  minuscule(s : string) : string;
function  position(s : string; c : char) : integer;
function  sous_chaine(s : string;i1,long : integer) : string;
function  tronque(s : string) : string;
function  tronque2(s : string; car : char) : string;
procedure coupe(s : string;pos : integer;var s1,s2 : string);
procedure separe(s : string;sep : char);

function  est_entier(s : string;var n : integer) : boolean;
function  est_reel(s : string;var a : extended) : boolean;

function  s_ecri_val(a : extended) : string;
function  s_ecri_val_bad(a : extended) : string;
function  s_ecri_int_bad(i : integer) : string;

function  s_ecri_sommet(g,x : integer) : string;
procedure b_ecri_sommet(g,x : integer);
procedure b_ecri_list_sommets(g : integer);
function  s_ecri_pos_sommet(g,x : integer) : string;
function  s_ecri_graphe(g : integer) : string;
procedure b_ecri_graphe(g : integer);
procedure b_ecri_graphe_mat(g : integer);
procedure b_ecri_graphe_succ(g : integer);
procedure b_ecri_graphe_gml(g : integer);

function  s_ecri(x,tx : integer) : string;
procedure b_ecri_system;

const hortab = chr(9);

var   lines_syntax : TStrings;
      lines_separe : svec_type; { separer une chaine en n_separe morceaux }
      n_separe : integer;
      err_syntax : boolean;

implementation

uses  SysUtils,kutil,klist,kgestiong,f_graph;

procedure init_syntax;
begin
  lines_syntax := TStringList.Create;
  DecimalSeparator := '.';
end;

{procedure fin_syntax;
begin
  lines_syntax.Free;
end;}

procedure erreur_syntaxe(s : string);
begin
  s := 'Syntax - ' + s;
  erreur_(s);
  err_syntax := true;
end;

{ ------ chaines de caracteres ------ }

function  lowcase(car : char) : char;
var icar : integer;
begin
  icar := ord(car);
  if ( ( icar <= ord('Z') ) and ( icar >= ord('A') ) ) then 
    begin
      icar := icar + ord('a') - ord('A');
      car  := chr(icar);
    end;
  lowcase := car;
end;

function  minuscule(s : string) : string;
var i : integer;
    t : string;
begin
  t := '';
  for i := 1 to length(s) do t := t + lowcase(s[i]);
  minuscule := t;
end;
 
function  position(s : string; c : char) : integer;
begin
  position := pos(c,s);
end;

function  sous_chaine(s : string;i1,long : integer) : string;
begin
  sous_chaine := copy(s,i1,long);
end; 

function  tronque(s : string) : string;
{ supprime les blancs superflus de chaque cote de la chaine s }
var i,pos1,pos2,ls : integer;
    t : string;
begin
  ls  := length(s);
  if ( ls = 0 ) then
    begin
      tronque := '';
      exit;
    end;
  pos1 := ls;
  for i := 1 to ls do
    if ( s[i] <> ' ' ) then
      begin
        pos1 := i;
        break;
      end;
   pos2 := 0;
   for i := ls downto 1 do
    if ( s[i] <> ' ' ) then
      begin
        pos2 := i;
        break;
      end;
   t := '';
   for i := pos1 to pos2 do t := t + s[i];
   tronque := t;
end;

function  tronque2(s : string; car : char) : string;
{ idem tronque, mais avec le caractere car en plus }
var i,pos1,pos2,ls : integer;
    t : string;
begin
  ls  := length(s);
  if ( ls = 0 ) then
    begin
      tronque2 := '';
      exit;
    end;
  pos1 := ls;
  for i := 1 to ls do
    if ( s[i] <> car ) and ( s[i] <> ' ' ) then
      begin
        pos1 := i;
        break;
      end;
   pos2 := 0;
   for i := ls downto 1 do
    if ( s[i] <> car ) and ( s[i] <> ' ' ) then
      begin
        pos2 := i;
        break;
      end;
   t := '';
   for i := pos1 to pos2 do t := t + s[i];
   tronque2 := t;
end;

procedure coupe(s : string;pos : integer;var s1,s2 : string);
var ls : integer;
begin
  ls := length(s);
  s1 := sous_chaine(s,1,pos-1);
  s2 := sous_chaine(s,pos+1,ls-pos);
end;

procedure separe(s : string; sep : char);
{ retourne les sous-chaines de la chaine s selon les separateurs sep }
{ dans le tableau lines_separe, en nombre n_separe }
var pos,ns : integer;
    s1  : string;
begin
  ns := 0;
  n_separe := 0;
  s := tronque2(s,sep);
  repeat
    pos := position(s,sep);
    if ( pos = 0 ) then
      begin
        ns := ns + 1;
        if ( ns > vecmax ) then
          begin
            erreur_syntaxe(s);
            exit;
          end;
        lines_separe[ns] := tronque2(s,sep);
        n_separe := ns;
        exit;
      end;
    coupe(s,pos,s1,s);
    ns := ns + 1;
    if ( ns > vecmax ) then
      begin
        erreur_syntaxe(s);
        exit;
      end;
    lines_separe[ns] := tronque2(s1,sep);
  until false;
end;

function  remplace_car(s : string;car : char) : string;
var i : integer;
    s1 : string;
begin
  s1 := '';
  for i := 1 to length(s) do
    if ( s[i] = ' ' ) then
      s1 := s1 + car
    else
      s1 := s1 + s[i];
  remplace_car := s1;
end;

function  est_chiffre(car : char;var val : integer) : boolean;
begin
  val := ord(car) - ord('0');
  est_chiffre := ( val >= 0 ) and ( val <= 9 );
end;

function  est_entier(s : string;var n : integer) : boolean;
var i,j,l : integer;
begin
  est_entier := false;
  l := length(s);
  if ( l = 0 ) then exit;
  n := 0;
  for i := 1 to l do
    begin
      if not est_chiffre(s[i],j) then exit;      n := 10*n + j;
    end;
  est_entier := true;
end;

function  est_nombre(s : string;var r : extended) : boolean;
var i,j,l : integer;
begin
  est_nombre := false;
  l := length(s);
  if ( l = 0 ) then exit;  r := 0;
  for i := 1 to l do
    begin
      if not est_chiffre(s[i],j) then exit;      r := 10.0*r + j;
    end;
  est_nombre := true;
end;

function  est_reel0(s : string;var a : extended) : boolean;
var pos,i : integer;
    s1,s2 : string;
    a1,a2 : extended;
begin
  est_reel0 := false;
  if ( length(s) = 0 ) then exit;  pos := position(s,'.');
  if ( pos = 0 ) then
    begin
      if not est_nombre(s,a1) then exit
      else
        begin
          a := a1;
          est_reel0 := true;
          exit;
        end;
    end;
  coupe(s,pos,s1,s2);
  if ( s1 <> '' ) then
    if not est_nombre(s1,a1) then exit
    else
  else
    a1 := 0.0;
  if ( s2 <> '' ) then
    if not est_nombre(s2,a2) then
      exit
    else
      for i := 1 to length(s2) do a2 := a2/10.0
  else
    a2 := 0.0;
  a := a1 + a2;
  est_reel0 := true;
end;

function  est_reel(s : string;var a : extended) : boolean;
var ls : integer;
begin
  est_reel := false;
  ls := length(s);
  if ( ls = 0 ) then exit;
  if ( s[1] = '-' ) then
    begin
      s := sous_chaine(s,2,ls-1);
      est_reel := est_reel0(s,a);
      a := -a;
    end 
  else
    est_reel := est_reel0(s,a);
end;

{  @@@@@@   ecritures  @@@@@@  }

function  s_ecri_val(a : extended) : string;
{ ecrit la valeur reelle a }
var s : string;
begin
  s := FloatToStr(a);
  if ( length(s) > 5 ) then s := Format('%1.4g',[a]);
  s_ecri_val := s;
end;

function  s_ecri_val_bad(a : extended) : string;
{ ecrit la valeur reelle a, supposee bad si <= -1.0 }
var s : string;
begin
  if ( a <= bad ) then
    begin
      s_ecri_val_bad := '-';
      exit;
    end;
  s := FloatToStr(a);
  if ( length(s) > 5 ) then s := Format('%1.4g',[a]);
  s_ecri_val_bad := s;
end;

function  s_ecri_int_bad(i : integer) : string;
{ ecrit la valeur entiere i, supposee bad si negative}
begin
  if ( i < 0 ) then
    s_ecri_int_bad := '-'
  else
    s_ecri_int_bad := IntToStr(i);
end;

function  s_ecri_sommet(g,x : integer) : string;
begin
  with graphes[g].ggg[x] do s_ecri_sommet := nom;
end;

procedure b_ecri_info_sommet(g,x : integer);
var i : integer;
begin
  with graphes[g],lines_syntax do
    begin
      if ( nb_infos > 0 ) then
        begin
          Append('');
          Append('Biological information:');
          for i := 1 to nb_infos do
            Append('  ' + name_info[i] + ': ' + s_ecri_val(ggg[x].info[i]));
        end;
      with ggg[x] do
        if ( biom > 0.0 ) then
          begin
            Append('');
            Append('Biom = ' + s_ecri_val(biom));
          end;
    end;
end;

procedure b_ecri_sommet(g,x : integer);
var y  : integer;
    ns : extended;

function ttt : string;
begin
  with graphes[g].ggg[x] do
    if ( nb_pred = 0 ) then
      ttt := 'Basal'
    else
      if ( nb_succ = 0 ) then
        ttt := 'Top'
      else
        ttt := 'Intermediate';
end;

begin
  with graphes[g] do
  begin
  ns := nb_sommets;
  with ggg[x],lines_syntax do
    begin
      Clear;
      Append(IntToStr(x)+ ' - ' + s_ecri_sommet(g,x) + ' - ' + ttt);
      Append('');
      Append('  Out degree [Nb of predators] = '
        + IntToStr(nb_succ) + ' [' + s_ecri_val(100*nb_succ/ns) + '%]');
      Append('  In dedree [Nb of preys] = '
        + IntToStr(nb_pred) + ' [' + s_ecri_val(100*nb_pred/ns) + '%]');
      Append('  Total degree = ' + IntToStr(deg));
      Append('  Generalism = ' + IntToStr(nb_pred));
      if ( ival = 1 ) then
        Append('  Weighted generalism = ' + s_ecri_val(gen_val));
      if ( nb_pred > 0 ) then
        begin
          Append('  Vulnerability = ' + s_ecri_val(nb_succ/nb_pred));
          if ( ival = 1 ) then
            Append('  Weighted vulnerability = ' + s_ecri_val(vul_val));
        end;
      Append('  Height min [Hmin] = ' + s_ecri_int_bad(h_min));
      Append('  Height mean [H] = ' + s_ecri_val_bad(h_moy));
      if ( ival = 1 ) then
        Append('  Weighted height mean [WH] = ' + s_ecri_val_bad(h_moy_val));
      Append('  Height max [Hmax] = ' + s_ecri_int_bad(h_max));
      Append('  Extent [Hmax - Hmin] = ' + s_ecri_int_bad(h_max - h_min));
      Append('  Trophic level = ' + s_ecri_val_bad(trolev));
      if ( ival = 1 ) then
        Append('  Weighted trophic level = ' + s_ecri_val_bad(trolev_val));
      Append('  Omnivory index = ' + s_ecri_val_bad(oi));
      if ( ival = 1 ) then
        Append('  Weighted omnivory index = ' + s_ecri_val_bad(oi_val));
      Append('  Index of connected component = ' + IntToStr(connect));
      Append('  Importance rank = ' + s_ecri_val_bad(rank));
      Append('  Clustering coefficient = ' + s_ecri_val(c));
      Append('  Eccentricity = ' + s_ecri_val(ecc));
      Append('  Cycle time = ' + s_ecri_val_bad(cyctime));
      if ( ival = 1 ) then
        Append('  Weighted Cycle time = ' + s_ecri_val_bad(cyctime_val));
      if ( nb_succ <> 0 ) then
        begin
          Append('');
          Append('List of predators:');
          y := succ;
          while ( y <> 0 ) do with lis[y] do
            begin
              if ( ival = 1 ) then
                Append('   ' + s_ecri_sommet(g,car) + hortab + s_ecri_val(val))
              else
                Append('   ' + s_ecri_sommet(g,car));
              y := cdr;
            end;
        end;
      if ( nb_pred <> 0 ) then
        begin
          Append('');
          Append('List of preys:');
          y := pred;
          while ( y <> 0 ) do with lis[y] do
            begin
              if ( ival = 1 ) then
                Append('   ' + s_ecri_sommet(g,car) + hortab + s_ecri_val(val))
              else
                Append('   ' + s_ecri_sommet(g,car));
              y := cdr;
            end;
        end;
      (*if ( cyc <> 0 ) then
        begin
          Append('');
          Append('Cycle: ' + s_ecri(cyc,type_lis));
        end;*)
      b_ecri_info_sommet(g,x);
    end;
  end;
end;

procedure b_ecri_list_sommets(g : integer);
var x : integer;
begin
  with graphes[g],lines_syntax do
    begin
      Clear;
      for x := 1 to nb_sommets do
        Append(IntToStr(x) + ' ' + s_ecri_sommet(g,x));
    end;
end;

function  s_ecri_pos_sommet(g,x : integer) : string;
begin
  with graphes[g].ggg[x] do
    if ( nb_pred = 0 ) then
      s_ecri_pos_sommet := 'B'
    else
      if ( nb_succ = 0 ) then
        s_ecri_pos_sommet := 'T'
      else
        s_ecri_pos_sommet := 'I';
end;

function  s_ecri_graphe(g : integer) : string;
begin
  with graphes[g] do s_ecri_graphe := name + '#' + IntToStr(icre);
end;

function  s_ecri_type_graphe(g : integer) : string;
var g_pere : integer;
    s,s1 : string;
begin
 with graphes[g] do
   begin
     g_pere := trouve_graphe(i_pere);
     if ( g_pere <> 0 ) then
       s1 := s_ecri_graphe(g_pere)
     else
       s1 := '?';
     case typ of
       type_gra_lu       : s := 'from File';
       type_gra_void     : s := 'Void';
       type_gra_erdos    : s := 'Random - p = ' + s_ecri_val(param_p);
       type_gra_unif     : s := 'Random - nb links = ' + s_ecri_val(nb_arcs);
       type_gra_smallw   : s := 'Random SmallWorld - p = ' + s_ecri_val(param_p) +
                                ' deg = ' + IntToStr(param_deg);
       type_gra_arb      : s := 'Random Tree - p = ' + s_ecri_val(param_p) +
                                ' deg = ' + IntToStr(param_deg) +
                                ' nb niv = ' + IntToStr(param_nb_niv);
       type_gra_sub      : s := 'SubNetwork of ' + s1;
       type_null_bit     : s := 'BIT model from ' + s1;
       type_null_deg     : s := 'Degree model from ' + s1;
       type_null_niche   : s := 'Niche model - L/S^2 = ' + s_ecri_val(param_p);
       type_gra_dup      : s := 'Copy of ' + s1;
       type_gra_root     : s := 'Root added from ' + s1;
       type_gra_som      : s := 'Composed from ' + s1;
       type_gra_groupmod : s := 'Modules from ' + s1;
       type_gra_groupaic : s := 'AIC groups from ' + s1;
       type_gra_grouptro : s := 'Trophic groups from ' + s1;
       type_gra_aggreg   : s := 'Aggregated from ' + s1;
       else s := '?';
     end;
    if ( ival = 1 ) then s := s + ' <Weighted>';
    s_ecri_type_graphe := s;
  end;
end;

procedure b_ecri_groups(g : integer);
var x,i,j : integer;
    s : string;
    tab : ivec_type;
begin
  with graphes[g],lines_syntax do
    begin
      if ( nb_group_mod > 0 ) then
        begin
          Append('');
          for x := 1 to nb_sommets do tab[x] := 0;
          for x := 1 to nb_sommets do with ggg[x] do
            tab[group_mod] := tab[group_mod] + 1;
          for i := 1 to nb_group_mod do
            begin
              s := 'Module ' + IntToStr(i) + ' [' + IntToStr(tab[i]) + ']: ';
              j := 0;
              for x := 1 to nb_sommets do with ggg[x] do
                if ( group_mod = i ) then
                  begin
                    j := j + 1;
                    if ( j < tab[i] ) then
                      s := s + nom + ','
                    else
                      s := s + nom;
                  end;
              Append(s);
            end;
        end;
      if ( nb_group_aic > 0 ) then
        begin
          Append('');
          for x := 1 to nb_sommets do tab[x] := 0;
          for x := 1 to nb_sommets do with ggg[x] do
            tab[group_aic] := tab[group_aic] + 1;
          for i := 1 to nb_group_aic do
            begin
              s := 'AIC group ' + IntToStr(i) + ' [' + IntToStr(tab[i]) + ']: ';
              j := 0;
              for x := 1 to nb_sommets do with ggg[x] do
                if ( group_aic = i ) then
                  begin
                    j := j + 1;
                    if ( j < tab[i] ) then
                      s := s + nom + ','
                    else
                      s := s + nom;
                  end;
              Append(s);
            end;
        end;
      if ( nb_group_tro > 0 ) then
        begin
          Append('');
          for x := 1 to nb_sommets do tab[x] := 0;
          for x := 1 to nb_sommets do with ggg[x] do
            tab[group_tro] := tab[group_tro] + 1;
          for i := 1 to nb_group_tro do
            begin
              s := 'Trophic group ' + IntToStr(i) + ' [' + IntToStr(tab[i]) + ']: ';
              j := 0;
              for x := 1 to nb_sommets do with ggg[x] do
                if ( group_tro = i ) then
                  begin
                    j := j + 1;
                    if ( j < tab[i] ) then
                      s := s + nom + ','
                    else
                      s := s + nom;
                  end;
              Append(s);
            end;
        end;
      if ( nb_group_agg > 0 ) then
        begin
          Append('');
          for x := 1 to nb_sommets do tab[x] := 0;
          for x := 1 to nb_sommets do with ggg[x] do
            if ( group_agg = 0 ) then
              exit
            else
              tab[group_agg] := tab[group_agg] + 1;
          for i := 1 to nb_group_agg do
            begin
              s := 'Aggregation group ' + IntToStr(i) + ' [' + IntToStr(tab[i]) + ']: ';
              j := 0;
              for x := 1 to nb_sommets do with ggg[x] do
                if ( group_agg = i ) then
                  begin
                    j := j + 1;
                    if ( j < tab[i] ) then
                      s := s + nom + ','
                    else
                      s := s + nom;
                  end;
              Append(s);
            end;
        end;
    end;
end;

procedure b_ecri_criteria(g : integer);
var i : integer;
begin
  with graphes[g],lines_syntax do
    if ( nb_infos > 0 ) then
      begin
        Append('');
        Append('Biological criteria:');
        for i := 1 to nb_infos do Append('  ' + name_info[i]);
      end;
end;

procedure b_ecri_graphe(g : integer);
var x,no : integer;
    a,ns : extended;
begin
  with graphes[g],lines_syntax do
    begin
      Clear;
      Append('Network - ' + s_ecri_graphe(g) + ' - ' + s_ecri_type_graphe(g));
      Append('');
      Append('  Nb of species S = ' + IntToStr(nb_sommets));
      Append('  Nb of links L = ' + IntToStr(nb_arcs));
      ns := nb_sommets;
      if ( ns = 0 ) then exit;
      Append('  Linking intensity [L/S] = ' + s_ecri_val(nb_arcs/ns));
      if ( ns > 1 ) then
        Append('  Connectance [L/S(S-1)] = ' + s_ecri_val(nb_arcs/(ns*(ns - 1.0))));
      Append('  Connectance [L/S*S] = ' + s_ecri_val(nb_arcs/(ns*ns)));
      Append('  Nb of basal species [B] = '
        + IntToStr(nb_b) + ' [' + s_ecri_val(100*nb_b/ns) + '%]');
      Append('  Nb of isolated basal species = '
        + IntToStr(nb_b_isol) + ' [' + s_ecri_val(100*nb_b_isol/ns) + '%]');
      Append('  Nb of non isolated basal species = '
        + IntToStr(nb_b - nb_b_isol) + ' ['
        + s_ecri_val(100*(nb_b - nb_b_isol)/ns) + '%]');
      Append('  Nb of intermediate species [I] = '
        + IntToStr(nb_i) + ' [' + s_ecri_val(100*nb_i/ns) + '%]');
      Append('  Nb of top species [T] = '
        + IntToStr(nb_t)+ ' [' + s_ecri_val(100*nb_t/ns) + '%]');
      no := 0;
      for x := 1 to nb_sommets do with ggg[x] do
        if ( h_moy > 0.0 ) and ( h_max > h_moy ) then
          no := no + 1;
      Append('  Nb of omnivorous species = '
        + IntToStr(no) + ' [' + s_ecri_val(100*no/ns) + '%]');
      Append('  Nb of self-loops [cannibalistic species] = '
        + IntToStr(nb_boucles) + ' [' + s_ecri_val(100*nb_boucles/ns) + '%]');
      Append('  Nb of connected components = ' + s_ecri_val(nb_connect));
      if ( nb_cycles <> 0 ) then
        Append('  Nb of cycles >= ' + s_ecri_int_bad(nb_cycles))
      else
        Append('  Nb of cycles = 0');
      Append('  Average degree = ' + s_ecri_val(deg_moy));
      Append('  Height = ' + s_ecri_val_bad(haut_moy));
      if ( ival = 1 ) then
        Append('  Weighted height = ' + s_ecri_val_bad(haut_moy_val));
      Append('  Height max = HeightTop max = ' + s_ecri_int_bad(haut_max));
      Append('  Omnivory index = ' + s_ecri_val_bad(o_index));
      if ( ival = 1 ) then
        Append('  Weighted omnivory index = ' + s_ecri_val_bad(o_index_val));
      a := 0.0;
      for x := 1 to nb_sommets do with ggg[x] do a := a + nb_pred;
      a := a/ns;
      Append('  Generalism index = ' + s_ecri_val(a));
      if ( ival = 1 ) then
        Append('  Weighted generalism index = ' + s_ecri_val(gen_moy_val));
      if ( ns > nb_b ) then
        begin
          a := 0.0;
          for x := 1 to nb_sommets do with ggg[x] do
            if ( nb_pred <> 0 ) then
              a := a + nb_succ/nb_pred;
          a := a/(ns - nb_b);
          Append('  Vulnerability index = ' + s_ecri_val(a));
          if ( ival = 1 ) then
            Append('  Weighted vulnerability index = ' + s_ecri_val(vul_moy_val));
        end;
      Append('  Nb of chains basal -> top = ' + s_ecri_val_bad(nb_pathtop));
      Append('  Height basal -> top = ' + s_ecri_val_bad(longtop_moy));
      if ( ival = 1 ) then
        Append('  Weigthed height basal -> top = ' + s_ecri_val_bad(longtop_moy_val));
      if ( longtop_min < big ) then
        Append('  Min chain length basal -> top = ' + s_ecri_int_bad(longtop_min));
      Append('  Trophic level = ' + s_ecri_val_bad(trolev_moy));
      Append('  Trophic level max = ' + s_ecri_val_bad(trolev_max));
      if ( ival = 1 ) then
        begin
          Append('  Weighted trophic level = ' + s_ecri_val_bad(trolev_moy_val));
          Append('  Weighted trophic level max = ' + s_ecri_val_bad(trolev_max_val));
        end;
      Append('  Characteristic Path Length = ' + s_ecri_val(charlen));
      Append('  Average Path Length = ' + s_ecri_val_bad(pathlen));
      if ( nb_cycles > 0 ) then
        Append('  Average Cycle Length >= ' + s_ecri_val(cyclen))
      else
        Append('  Average Cycle Length = 0');
      Append('  Diameter = ' + s_ecri_val(diam));
      Append('  Radius = ' + s_ecri_val(radius));
      Append('  Average clustering coefficient = ' + s_ecri_val(clust));
      Append('  Assortativity = ' + s_ecri_val(assort));
      Append('  Index of primitivity = ' + IntToStr(iprim));
      Append('  Entropy = ' + s_ecri_val_bad(entropy));
      if ( ns > 1.0 ) and ( entropy <> bad ) then
        Append('  Scaled entropy = ' + s_ecri_val_bad(entropy/ln(ns)));
      if ( ival = 1 ) then
        Append('  Weighted entropy = ' + s_ecri_val_bad(entropy_val));
      Append('  Generation time = ' + s_ecri_val_bad(gentime));
      if ( ival = 1 ) then
        Append('  Weighted generation time = ' + s_ecri_val_bad(gentime_val));
      Append('  Kemeny''s constant = ' + s_ecri_val_bad(kemeny));
      if ( ival = 1 ) then
        Append('  Weighted Kemeny''s constant = ' + s_ecri_val_bad(kemeny_val));
      if ( nb_boucles <> 0 ) then
        begin
          Append('');
          Append('Loops:');
          for x := 1 to nb_sommets do with ggg[x] do
            if ( boucle <> 0 ) then
              Append('  ' + nom);
        end;
      (*if ( nb_cycles > 0 ) then
        begin
          Append('');
          Append('Cycles:');
          for x := 1 to nb_sommets do with ggg[x] do
            if ( cyc <> 0 ) then
              Append(s_ecri(cyc,type_lis));
        end;*)
      b_ecri_criteria(g);
      b_ecri_groups(g);
    end;
end;

procedure b_ecri_graphe_mat(g : integer);
{ format *.nw0, *.txt }
var x,y : integer;
    s : string;
begin
  with graphes[g],lines_syntax do
    begin
      graphe2mat(g);
      Clear;
      Append(IntToStr(nb_sommets));
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          s := nom;
          if ( ival = 1 ) then
            for y := 1 to nb_sommets do s := s + hortab + s_ecri_val(mr_[x,y])
          else
            for y := 1 to nb_sommets do s := s + hortab + s_ecri_val(m_[x,y]);
          Append(s);
        end;
    end;
end;

procedure b_ecri_graphe_succ(g : integer);
{ format *.nw1 }
var x,y : integer;
begin
  with graphes[g],lines_syntax do
    begin
      Clear;
      Append(IntToStr(nb_sommets));
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          y := succ;
          if ( y = 0 ) then { sommet sans successeurs ! }
            Append(nom)
          else
            while ( y <> 0 ) do with lis[y] do
              begin
                if ( ival = 0 ) then
                  Append(nom + hortab + ggg[car].nom)
                else
                  Append(nom + hortab + ggg[car].nom + hortab + s_ecri_val(val));
                y := cdr;
              end;
        end;
    end;
end;

procedure b_ecri_graphe_gml(g : integer);
{ format *.gml }
var x,y : integer;

procedure b_graph;
begin
  with graphes[g],lines_syntax do
    begin
      Append('graph [');
    end;
end;

procedure b_node(g,x : integer);
begin
  with graphes[g],lines_syntax do
    begin
      Append('node [');
      Append('id ' + IntToStr(x));
      Append('label ' + '"' + ggg[x].nom + '"');
      Append(']');
    end;
end;

procedure b_edge(g,x,y : integer);
begin
  with graphes[g],lines_syntax do
    begin
      Append('edge [');
      Append('source ' + IntToStr(x));
      Append('target ' + IntToStr(y));
      if ( ival = 1 ) then Append('value ' + s_ecri_val(mr_[x,y]));
      Append(']');
    end;
end;

begin
  with graphes[g],lines_syntax do
    begin
      Clear;
      graphe2mat(g);
      b_graph;
      for x := 1 to nb_sommets do b_node(g,x);
      for x := 1 to nb_sommets do with ggg[x] do
        begin
          y := succ;
          while ( y <> 0 ) do with lis[y] do
            begin
              b_edge(g,x,car);
              y := cdr;
            end;
        end;
      Append(']');
    end;
end;

function  s_ecri_lis(x : integer) : string;
var s : string;
begin
  s := '';
  if ( x = 0 ) then
    begin
      s_ecri_lis := '';
      exit;
    end;
  s := s + '(';
  while ( x <> 0 ) do with lis[x] do
    begin
      s := s + s_ecri(car,car_type);
      x := cdr;
      if ( x <> 0 ) then s := s + ' ';
    end;
  s := s + ')';
  s_ecri_lis := s;
end;

function  s_ecri(x,tx : integer) : string;
begin
  case tx of
    type_lis     : s_ecri := s_ecri_lis(x);
    type_som     : s_ecri := s_ecri_sommet(g_select,x);
    type_inconnu : s_ecri := ' ? ';
    else
      s_ecri := 'ecri? ';
  end;
end;

procedure b_ecri_system;
var truc : packed record case integer of
             0 : ( ii : integer );
             1 : ( c4,c3,c2,c1 : char );
           end;
begin
  iwriteln('lis_nb = ' + IntToStr(lis_nb) +
           ' [' + IntToStr(lis_nb_max) + ']  ' +
               IntToStr(lis_nb_max*SizeOf(lis_type)));
  iwriteln('nb_graphs = ' + IntToStr(nb_graphes) +
           '  [' + IntToStr(graphemax) + ']');
  //iwriteln('maxvargraph = ' + IntToStr(maxvargraph));
  //iwriteln('maxgraph = ' + IntToStr(maxgraph));
  iwriteln('max Species = ' + IntToStr(vecmax));
  iwriteln('max Links = ' + IntToStr(vecmax*vecmax));
  iwriteln('AllocMemSize -> ' + IntToStr(AllocMemSize));
  with truc do
    begin
      ii := 1937007984;
      iwriteln(c1 + c2 + c3 + c4);
      ii := 1751215717;
      iwriteln(c1 + c2 + c3 + c4);
      ii := 1818584933;
      iwriteln(c1 + c2 + c3 + c4);
      ii := 1852076645;
      iwriteln(c1 + c2 + c3 + c4);
    end;
end;

end.
