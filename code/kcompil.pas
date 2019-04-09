unit kcompil;

{  @@@@@@   lecture du fichier d'entree   @@@@@@  }

interface

uses  Classes;

var   lines_compil : TStrings;

function  compilation(nomfic : string) : integer;
procedure init_compilation;

implementation

uses SysUtils,f_nw,kglobvar,kutil,ksyntax,kgestiong,kmanipg;

var  line_num : integer;
     etat : integer;
     g_compil : integer; { graphe retourne de compilation }
     x_ : integer;       { nombre de sommets courant }
     nb_som : integer;   { nombre de sommets }
     nb_col : integer;   { nombre de colonnes attendu ( *.nw0 )}
     typ_fic : integer;  { type du fichier d'entree : }
                         { type_nw0 -> *.nw0, *.txt -> mat,
                         { type_nw1 -> *.nw1 -> links }
                         { type_nw2 -> *.nw2 -> ? }
                         { type_paj -> *.paj Pajek }
     nomfic1 : string;   { nom du fichier d'entree sans le chemin }
     erreur_bio : boolean;
     alloc : boolean;    { indicateur que le graphe a ete alloue }

procedure init_compilation;
begin
  lines_compil := TStringList.Create;
end;

procedure erreur_compil(s,st : string);
begin
  s := 'Compile ' + nomfic1 +
       ': ''' + s + ''' '#13#10 + st + #13#10 +
       '-> line number ' + IntToStr(line_num);
  erreur_(s);
  g_compil := 0;
end;

procedure compile_ligne0(s : string; sep : char);
{ fichier *.nw0, type matrice, separateur | = Horizontal Tab }
{ ligne = nom_espece | 0 | 0 | 1 | 0 ..., ou bien }
{ ligne = nom_espece | val1 | val2 | val3 | val4 ...  ou vali sont des reels > 0 }
var y : integer;
    a : extended;
begin
  separe(s,sep);
  if ( n_separe > nb_col ) then
    begin
      erreur_compil(s,'too many entries in line');
      exit;
    end;
  if ( n_separe < nb_col ) then
    begin
      erreur_compil(s,'not enough entries in line');
      exit;
    end;
  x_ := x_ + 1;
  if ( x_ > nb_som ) then
    begin
      erreur_compil(s,'too many lines in file');
      exit;
    end;
  graphes[g_compil].ggg[x_].nom := lines_separe[1];
  for y := 1 to nb_som do
    begin
      try
        a := StrToFloat(lines_separe[y+1]);
      except
        on E: EConvertError do
          begin
            erreur_compil(s,'real number expected');
            exit;
          end;
      end;
      if ( a <> 0.0 ) then m_[x_,y] := 1;
      mr_[x_,y] := a;
    end;
end;

procedure compile_ligne1(s : string);
{ fichier *.nw1, type liste des arcs, separateur | = horizontal tab }
{ ligne = nom_espece1 ( sommet sans successeurs ), ou bien }
{ ligne = nom_espece1 | nom_espece2, ou bien }
{ ligne = nom_espece1 | nom_espece2 | val ou val est un reel }
var x,y : integer;
    a : extended;
    s1,s2,s3 : string;
begin
  separe(s,hortab);
  if ( n_separe > 3 ) then
    begin
      erreur_compil(s,'malformed declaration');
      exit;
    end;
  s1 := tronque(lines_separe[1]);
  x := trouve_nom_sommet(g_compil,s1);
  if ( x = 0 ) then
    begin
      x_ := x_ + 1;
      if ( x_ > nb_som ) then
        begin
          erreur_compil(s,'more species than expected');
          exit;
        end;
      graphes[g_compil].ggg[x_].nom := s1;
      x := x_;
    end;
  if ( n_separe = 1 ) then exit; { sommet isole }
  s2 := tronque(lines_separe[2]);
  y := trouve_nom_sommet(g_compil,s2);
  if ( y = 0 ) then
    begin
      x_ := x_ + 1;
      if ( x_ > nb_som ) then
        begin
          erreur_compil(s,'more species than expected');
          exit;
        end;
      graphes[g_compil].ggg[x_].nom := s2;
      y := x_;
    end;
  m_[x,y]  := 1;
  mr_[x,y] := 1.0;
  if ( n_separe = 3 ) then
    begin
      s3 := tronque(lines_separe[3]);
      try
        a := StrToFloat(s3);
      except
        on E: EConvertError do
          begin
            erreur_compil(s,'real number expected');
            exit;
          end;
      end;
      mr_[x,y] := a;
    end;
end;

procedure compile_ligne2_0(s : string);
{ fichier *.nw2, type matrice + info, separateur | = Horizontal Tab }
{ le debut du fichier est identique au format *.nw0 }
{ et represente la matrice "cumulee" de toutes les especes observees }
{ a la suite sont listes les especes effectivement presentes dans cette instance }
{ i.e., les especes de la matrice "instantanee" }
{ ligne1 = nom_espece1 | val1  ou val1 est 0 (absence) ou un reel > 0 (biomasse) }
{ ligne2 = nom_espece2 | val2  ou val2 est 0 (absence) ou un reel > 0 (biomasse) }
{ ... }
var  nom : string;
     y,i : integer;
     d : extended;
begin
  separe(s,hortab);
  nom := lines_separe[1];
  if ( trouve_nom_sommet(g_compil,nom) = 0 ) then
    begin
      x_ := x_+1;
      graphes[g_compil].ggg[x_].nom := nom;
      for i := 1 to nb_som do
        begin
          m_[x_,i] := StrToInt(lines_separe[i+1]);
          mr_[x_,i] := StrToFloat(lines_separe[i+1]);
        end;
    end
  else
    begin
      y := trouve_nom_sommet(g_compil,nom);
      d := StrToFloat(lines_separe[2]);
      graphes[g_compil].ggg[y].biom := d;
      for i:=1 to nb_som do { voir ponderation par biomasse !!! }
          begin
            mr_[y,i] := d*mr_[y,i];
          end;
    end;
end;

procedure compile_ligne2(s : string);
{ fichier *.nw2, type matrice + info, separateur | = Horizontal Tab }
{ le debut du fichier est identique au format *.nw0 }
{ et represente la matrice "cumulee" de toutes les especes observees }
{ a la suite sont listes les especes effectivement presentes dans cette instance }
{ i.e., les especes de la matrice "instantanee" }
{ ligne1 = nom_espece1 | val1  ou val1 est 0 (absence) ou un reel > 0 (biomasse) }
{ ligne2 = nom_espece2 | val2  ou val2 est 0 (absence) ou un reel > 0 (biomasse) }
{ ... }
var  nom : string;
     y,i : integer;
     d : extended;
begin
  separe(s,hortab);
  nom := lines_separe[1];
  if ( x_ < nb_som ) then
    if ( trouve_nom_sommet(g_compil,nom) = 0 ) then
      begin
        x_ := x_ + 1;
        graphes[g_compil].ggg[x_].nom := nom;
        for i := 1 to nb_som do
          begin
            m_[x_,i]  := StrToInt(lines_separe[i+1]);
            mr_[x_,i] := StrToFloat(lines_separe[i+1]);
          end;
      end
    else
      begin
        erreur_compil(s,'duplicate species');
        exit;
      end
  else
    begin
      y := trouve_nom_sommet(g_compil,nom);
      if ( y = 0 ) then
        begin
          erreur_compil(s,'unknown species');
          exit;
        end;
      d := StrToFloat(lines_separe[2]);
      graphes[g_compil].ggg[y].biom := d;
      for i := 1 to nb_som do { voir ponderation par biomasse !!! }
        begin
          mr_[y,i] := d*mr_[y,i];
        end;
    end;
end;

procedure compile_paj;
{ fichier format paj de PAJEK }
var i,pos,j : integer;
    nam,s : string;
    err : boolean;

procedure compile_ligne_paj(s : string);
var x,y,pos : integer;
    r : extended;
    s1,s2,s3 : string;
begin
  case etat of
    0 : begin
          if ( s[1] = '*' ) then
            begin
              pos := position(s,' ');
              if ( pos = 0 ) then exit;
              coupe(s,pos,s1,s2);
            end;
          if ( minuscule(s1) = '*vertices' ) then
            begin
              s2 := tronque(s2);
              if not est_entier(s2,nb_som) then
                begin
                  erreur_compil(s,'number of vertices - integer expected');
                  err := true;
                  exit;
                end;
              if ( nb_som > vecmax ) then
                begin
                  erreur_compil(s,'max number of vertices exceeded <' +
                                  IntToStr(vecmax) + '>');
                  err := true;
                  exit;
                end;
              g_compil := alloc_graphe(0,nb_som,nam,type_gra_lu);
              if ( g_compil = 0 ) then
                begin
                  err_gestion := false;
                  err := true;
                  exit;
                end;
              alloc := true;
              etat := 2;
              j := 0;
            end;
        end;
    1 : begin
        end;
    2 : begin
          if ( s[1] <> '*' ) then { noms des especes }
            begin
              pos := position(s,' ');
              if ( pos = 0 ) then exit;
              coupe(s,pos,s1,s2);
              s1 := tronque(s1);
              s2 := tronque(s2);
              if not est_entier(s1,x) then
                begin
                  erreur_compil(s,'integer expected');
                  exit;
                end;
              j := j + 1;
              separe(s2,'"');
              s2 := lines_separe[1];
              graphes[g_compil].ggg[x].nom := s2;
              exit;
            end;
          if ( minuscule(s) <> '*arcs' ) and ( minuscule(s) <> '*edges' ) then
            begin
              erreur_compil(s,'*arcs or *edges expected');
              exit;
            end;
          if ( j <> nb_som ) then
            begin
              erreur_compil(s,'number of vertices?');
              exit;
            end;
          etat := 3;
        end;
    3 : begin
          if ( s[1] = '*' ) then
            begin
              etat := 4;
              exit;
            end;
          { lecture des arcs }
          pos := position(s,' ');
          coupe(s,pos,s1,s2);
          s1 := tronque(s1);
          s2 := tronque(s2);
          if not est_entier(s1,x) then
            begin
              erreur_compil(s,'integer expected');
              exit;
            end;
          pos := position(s2,' ');
          coupe(s2,pos,s2,s3);
          s2 := tronque(s2);
          s3 := tronque(s3);
          if not est_entier(s2,y) then
            begin
              erreur_compil(s,'integer expected');
              exit;
            end;
          if ( x > nb_som ) or ( y > nb_som ) then
            begin
              erreur_compil(s,'arc vertices out of bounds');
              exit;
            end;
          try
            r := StrToFloat(s3);
          except
            on E: EConvertError do
              begin
                erreur_compil(s,'real number expected');
                exit;
              end;
          end;
          m_[x,y]  := 1;
          mr_[x,y] := r;
        end;
    4 : begin
          pos := position(s,' ');
          coupe(s,pos,s1,s2);
          s1 := tronque(s1);
          s2 := tronque(s2);
          if ( minuscule(s1) = '*vertices' ) then
            begin
              etat := 5;
              j := 0;
              exit;
            end;
        end;
    5 : begin
          try
            r := StrToFloat(s);
          except
            on E: EConvertError do
              begin
                erreur_compil(s,'real number expected');
                exit;
              end;
          end;
          j := j + 1;
          if ( j > nb_som ) then
            begin
              erreur_compil(s,'vector biomasses: number of entries?');
              exit;
            end;
          graphes[g_compil].ggg[j].biom := r;
          if ( j = nb_som ) then
            begin
              etat := 6;
              exit;
            end;
        end;
    6 : begin
          exit;
        end;
  end;
end;

begin
  err := false;
  zeromat;
  s := ExtractFileName(form_nw.nomfic);
  pos := position(s,'.');
  coupe(s,pos,nam,s); { nom du graphe = nom du fichier sans extension }
  {iwriteln('PAJEK = ' + nam);}
  for i := 0 to lines_compil.Count - 1 do
    begin
      line_num := line_num + 1;
      {iwriteln(IntToStr(i) + ' ' + lines_compil[i] + ' etat = ' + IntToStr(etat));}
      s := tronque(lines_compil[i]);
      if ( s <> '' ) then
        if ( s[1] <> '%' ) then compile_ligne_paj(s);
      if err then exit;
      if ( etat = 2 ) and ( g_compil = 0 ) then exit;
    end;
end;

procedure compile_gml;
{ fichier format gml = Graph Modelling language }
var i,pos,x,y : integer;
    nam,s : string;
    tab_id,tab_label : svec_type;
    err : boolean;

function  trouve_x_id(s : string) : integer;
var x : integer;
begin
  for x := 1 to x_ do
    if ( tab_id[x] = s ) then
      begin
        trouve_x_id := x;
        exit;
      end;
  trouve_x_id := 0;
end;

procedure compile_ligne_gml(s : string);
var pos : integer;
    r : extended;
    s1,s2 : string;
begin
  case etat of
    0 : begin
          if ( s = 'graph' )   then etat := 21;
          if ( s = 'graph [' ) then etat := 2;
        end;
    21 : begin { on attend [ du graph }
          if ( s = '[' ) then etat := 3;
        end;
    {1 : begin
          if ( s = '[' ) then etat := 1 else etat := 2;
        end;}
    2 : begin
          if ( s = 'node' )   then etat := 31;
          if ( s = 'node [' ) then etat := 3;
          if ( s = 'edge' )   then etat := 41;
          if ( s = 'edge [' ) then etat := 4;
          if ( s = ']' )      then etat := 5;
        end;
    31 : begin { on attend [ du node }
          if ( s = '[' ) then etat := 3;
        end;
    3 : begin { node }
         if ( s = ']' ) then
           begin
             etat := 2;
             exit;
           end;
          pos := position(s,' ');
          if ( pos > 0 ) then
            begin
              coupe(s,pos,s1,s2);
              s1 := tronque(s1);
              s2 := tronque(s2);
              if ( s1 = 'id' ) then
                begin
                  x_ := x_ + 1;
                  if ( x_ > vecmax ) then
                    begin
                      erreur_compil(s,'max number of nodes exceeded <' +
                                    IntToStr(vecmax) + '>');
                      err := true;
                      exit;
                    end;
                  tab_id[x_] := s2;
                end;
              if ( s1 = 'label' ) then { label "xxx" }
                begin
                  s2 := tronque2(s2,'"');
                  tab_label[x_] := s2;
                end;
            end;
        end;
    41 : begin { on attend [ du edge }
          if ( s = '[' ) then etat := 4;
        end;
    4 : begin { edge }
         if ( s = ']' ) then
           begin
             etat := 2;
             exit;
           end;
          pos := position(s,' ');
          if ( pos > 0 ) then
            begin
              coupe(s,pos,s1,s2);
              s1 := tronque(s1);
              s2 := tronque(s2);
              if ( s1 = 'source' ) then
                begin
                  x := trouve_x_id(s2);
                  if ( x = 0 ) then
                    begin
                      erreur_compil(s,'unknown source node');
                      exit;
                    end;
                end;
              if ( s1 = 'target' ) then
                begin
                  y := trouve_x_id(s2);
                  if ( y = 0 ) then
                    begin
                      erreur_compil(s,'unknown target node');
                      exit;
                    end;
                  m_[x,y]  := 1;
                  mr_[x,y] := 1.0;
                end;
              if ( s1 = 'label' ) then;
              if ( s1 = 'value' ) then
                begin
                  try
                    r := StrToFloat(s2);
                  except
                    on E: EConvertError do
                      begin
                        erreur_compil(s,'real number expected');
                        exit;
                      end;
                  end;
                  mr_[x,y] := r;
                end;
            end;
        end;
    5 : begin
          exit;
        end;
  end;
end;

begin
  err := false;
  zeromat;
  for x := 1 to vecmax do
    begin
      tab_id[x] := '';
      tab_label[x] := '';
    end;
  s := ExtractFileName(form_nw.nomfic);
  pos := position(s,'.');
  coupe(s,pos,nam,s); { nom du graphe = nom du fichier sans extension }
  {iwriteln('GML = ' + nam);}
  for i := 0 to lines_compil.Count - 1 do
    begin
      line_num := line_num + 1;
      {iwriteln(IntToStr(i) + ' ' + lines_compil[i]);}
      s := tronque(lines_compil[i]);
      if ( s <> '' ) then compile_ligne_gml(s);
      if err then exit;
    end;
  nb_som := x_;
  g_compil := alloc_graphe(0,nb_som,nam,type_gra_lu);
  if ( g_compil = 0 ) then
    begin
      err_gestion := false;
      exit;
    end;
  alloc := true;
  with graphes[g_compil] do
    for x := 1 to nb_sommets do with ggg[x] do
      begin
        s := tab_label[x];
        if ( s <> '' ) then
          nom := tab_label[x]
        else
          nom := tab_id[x];
      end;
end;

procedure compil_infobio(nomfic : string);
var lines : TStrings;
    i,x,y,pos,ls,nb_species : integer;
    nomfic_bio,nomfic_bio1,s,species,info : string;

function case_info(g: integer; info: string): integer;
var k : integer;
begin
  with graphes[g] do
    for k := 1 to nb_infos do
      if name_info[k] = info then
        begin
          case_info := k;
          exit;
        end;
  case_info := 0;
end;

begin
with graphes[g_compil] do
  begin
    nb_species := 0;
    nb_infos := 0;
    lines := TStringList.Create;
    pos := position(nomfic,'.');
    coupe(nomfic,pos,nomfic,s);
    nomfic_bio  := nomfic + '.bio';
    if FileExists(nomfic_bio) then
      begin
        iwriteln('Open file ' + nomfic_bio);
        nomfic_bio1 := ExtractFileName(nomfic_bio);
        lines.LoadFromFile(nomfic_bio);
        for i := 0 to lines.Count-1 do
          begin
            s  := tronque(lines[i]);
            ls := length(s);
            if ( ls > 0 ) and ( s[1] <> '{' ) then { sinon comment line }
              begin
                separe(lines[i],hortab);
                if lines_separe[1] = 'species' then
                  begin
                    species := lines_separe[2];
                    x := trouve_nom_sommet(g_compil,tronque(species));
                    if ( x = 0 ) then
                      begin
                        erreur_bio := true;
                        iwriteln('File ' +  nomfic_bio1 + ': ' +
                          species + ' species unknown');
                      end
                    else
                      nb_species := nb_species + 1;;
                  end
                else
                  begin
                    info := lines_separe[1];
                    y := case_info(g_compil, info);
                    if y = 0 then
                      begin
                        nb_infos := nb_infos + 1;
                        if ( nb_infos > infomax ) then
                          begin
                            erreur_bio := true;
                            erreur_('File ' + nomfic_bio1 + ': ' + info +
                              ' no more than ' + IntToStr(infomax) + ' criteria');
                            exit;
                          end;
                        y := nb_infos;
                        name_info[y] := info;
                      end;
                    if x <> 0 then
                      ggg[x].info[y] := StrToFloat(lines_separe[2]);
                  end;
              end;
          end;
        i :=  graphes[g_compil].nb_sommets - nb_species;
        if ( i > 0 ) then
          begin
            erreur_bio := true;
            iwriteln('File ' + nomfic_bio1 + ': ' + IntToStr(i) + ' missing species');
          end;
        if ( i < 0 ) then
          begin
            erreur_bio := true;
            iwriteln('File ' +  nomfic_bio1 + ': ' + IntToStr(-i) + ' species in excess');
          end;
        if not erreur_bio then iwriteln('File ' +  nomfic_bio1 + ' compiled');
      end;
  end;
end;

procedure compile(s : string);
var pos,ls : integer;
    s1,s2  : string;
begin
  s := tronque(s);
  s := tronque2(s,hortab);
  ls := length(s);
  if ( ls = 0 ) then exit;  { empty line }
  if ( ls > 0 ) and ( s[1] = '{' ) then exit; { comment line }
  if ( etat = 0 ) then
    if ( ls = 0 ) then exit else etat := 1;
  case etat of
  1 : begin
        if not est_entier(s,nb_som) then
          begin
            erreur_compil(s1,'number of species - integer expected');
            exit;
          end;
        if ( nb_som > vecmax ) then
          begin
            erreur_compil(s,'max number of species exceeded <' +
                            IntToStr(vecmax) + '>');
            exit;
          end;
        s1  := ExtractFileName(form_nw.nomfic);
        pos := position(s1,'.');
        coupe(s1,pos,s1,s2); { nom du graphe = nom du fichier sans extension }
        g_compil := alloc_graphe(0,nb_som,s1,type_gra_lu);
        if ( g_compil = 0 ) then
          begin
            err_gestion := false;
            exit;
          end;
        alloc := true;
        nb_col := nb_som + 1;
        zeromat;
        etat := 2;
      end;
  2 : begin
        case typ_fic of
          type_nw0,type_txt : compile_ligne0(s,hortab);
          type_nw1 : compile_ligne1(s);
          type_nw2 : compile_ligne2(s)
          else;
        end;
      end;
  else;
  end;
end;

procedure coherence_compil;
begin
  if ( x_ < nb_som ) then
    erreur_compil('',IntToStr(x_) + ' species found - ' + IntToStr(nb_som) + ' expected');
end;

procedure bad_compil;
begin
  if alloc then dealloc_graphe;
  iwriteln('File ' + nomfic1 + ' could not be compiled');
end;

function  compilation(nomfic : string) : integer;
var i,ms : integer;
begin
  ms := clock;
  iwriteln('Open file ' + nomfic);
  nomfic1 := ExtractFileName(nomfic);
  line_num := 0;
  g_compil := 0;
  compilation := 0;
  alloc := false;
  etat := 0;
  x_   := 0;
  if ( ExtractFileExt(nomfic) = '.nw0' ) then typ_fic := type_nw0;
  if ( ExtractFileExt(nomfic) = '.nw1' ) then typ_fic := type_nw1;
  if ( ExtractFileExt(nomfic) = '.nw2' ) then typ_fic := type_nw2;
  if ( ExtractFileExt(nomfic) = '.txt' ) then typ_fic := type_txt;
  if ( ExtractFileExt(nomfic) = '.paj' ) then typ_fic := type_paj;
  if ( ExtractFileExt(nomfic) = '.gml' ) then typ_fic := type_gml;
  case typ_fic of
  type_paj :
    begin
      compile_paj;
      if ( g_compil <> 0 ) then
        compilation := create_graphe(g_compil)
      else
        bad_compil;
    end;
  type_gml :
    begin
      compile_gml;
      if ( g_compil <> 0 ) then
        compilation := create_graphe(g_compil)
      else
        bad_compil;
    end;
  type_nw0, type_txt, type_nw1, type_nw2 :
    begin
      for i := 0 to lines_compil.Count - 1 do
        begin
          line_num := line_num + 1;
          //iwriteln(IntToStr(line_num) + ' ' + lines_compil[i]);
          compile(lines_compil[i]);
          if ( etat > 0 ) and ( g_compil = 0 ) then
            begin
              bad_compil;
              exit;
            end;
        end;
      coherence_compil;
      if ( g_compil <> 0 ) then
        begin
          g_compil := create_graphe(g_compil);
          if ( typ_fic = type_nw2 ) then g_compil := nettoyage(g_compil);
          iwriteln('File ' + nomfic1 + ' compiled');
          iwriteln('-> ' + s_ecri_t_exec(clock-ms) +
                   ' - ' + IntToStr(line_num) + ' lines');
          erreur_bio := false;
          compil_infobio(nomfic);
        end;
      if ( g_compil = 0 ) then bad_compil;
    end;
  else;
  end;
  compilation := g_compil;
end;

end.
