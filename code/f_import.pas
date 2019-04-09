unit f_import;

interface

uses
  SysUtils,Types,Classes,Variants,QGraphics,QControls,QForms,QDialogs,
  QStdCtrls,QExtCtrls,QComCtrls,QTypes,QMenus,QStdActns,QActnList,QImgList,QGrids,
  QButtons;

type
  Tform_import = class(TForm)
    groupbox_import: TGroupBox;
    groupbox_export: TGroupBox;
    CB_species: TCheckBox;
    CB_links: TCheckBox;
    CB_name: TCheckBox;
    CB_intens: TCheckBox;
    CB_connectance: TCheckBox;
    CB_basal: TCheckBox;
    CB_intermediate: TCheckBox;
    CB_top: TCheckBox;
    CB_deg: TCheckBox;
    CB_height: TCheckBox;
    CB_hmax: TCheckBox;
    CB_trolev: TCheckBox;
    CB_tlmax: TCheckBox;
    button_export: TButton;
    button_import: TButton;
    SaveDialog1: TSaveDialog;
    CB_oi: TCheckBox;
    CB_pathlen: TCheckBox;
    CB_loops: TCheckBox;
    CB_charlen: TCheckBox;
    CB_diameter: TCheckBox;
    CB_radius: TCheckBox;
    CB_entropy: TCheckBox;
    CB_scaled_entropy: TCheckBox;
    CB_basal_isol: TCheckBox;
    CB_height_top: TCheckBox;
    CB_long_top: TCheckBox;
    CB_clust: TCheckBox;
    CB_assort: TCheckBox;
    CB_omnivorous: TCheckBox;
    CB_path_top: TCheckBox;
    OpenDialog1: TOpenDialog;
    CB_gentime: TCheckBox;
    CB_kemeny: TCheckBox;
    CB_Wheight: TCheckBox;
    CB_Wtrolev: TCheckBox;
    CB_Wtlmax: TCheckBox;
    CB_Woi: TCheckBox;
    CB_Wgen: TCheckBox;
    CB_Wvul: TCheckBox;
    CB_Wentropy: TCheckBox;
    CB_Wgentime: TCheckBox;
    CB_Wkem: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure button_importClick(Sender: TObject);
    procedure button_exportClick(Sender: TObject);
  private
    { Déclarations privées }
    //procedure import_graphs(rep, ext: string);
  public
    { Déclarations publiques }
  end;

var
  form_import: Tform_import;

implementation

uses kutil,kcompil,kglobvar,ksyntax,kgestiong,kcalculg,f_edit,f_nw;

var dir : string;

{$R *.xfm}

procedure import_graphes(rep,ext: string);
var
  trouve,g:integer;
  Fic:TSearchRec;
  nomfic:string;
begin
  Trouve := FindFirst(rep + ext,faAnyFile,Fic);
  while trouve = 0 do
    begin
        nomfic:=rep+Fic.Name;
        form_edit.memo1.Lines.LoadFromFile(nomfic);
        with form_edit do lines_compil := memo1.Lines;
        form_nw.nomfic:=nomfic;
        g := compilation(nomfic);
        if ( g <> 0 ) then
          begin
            init_graphe(g);
            if err_gestion then
              begin
                err_gestion := false;
                dealloc_graphe;
                iwriteln('Network ' + nomfic  + ' could not be created');
              end
            else
              calcul_graphe(g);
           end
        else
          begin
            iwriteln('File ' + nomfic  + ' could not be compiled');
          end;
        Trouve := Findnext(Fic);
    end;
  if ( nb_graphes > 0 ) then with form_nw do
    begin
      select(nb_graphes);
      set_actions1;
    end;
end;

procedure Tform_import.button_importClick(Sender: TObject);
var ext : string;
begin
  with opendialog1 do
    begin
      Filter :=
'NETWORK files (*.nw0)|NETWORK files (*.nw1)|NETWORK files (*.nw2)|GML files (*.gml)|TXT files (*.txt)';
      FileName := '*.*';
      if Execute then
        begin
          dir := ExtractFilePath(FileName);
          ext := '*' + ExtractFileExt(Filename);
          import_graphes(dir,ext);
        end;
    end;
end;

procedure Tform_import.FormCreate(Sender: TObject);
begin
  Left   := 200;
  Top    := 80;
  Height := 829;
  Width  := 468;
  resolution;
  adjust(self);
end;

procedure Tform_import.button_exportClick(Sender: TObject);
var g,i,x,ns,no :integer;
    s : string;
    lines : TStrings;
begin
  if ( nb_graphes = 0 ) then exit;
  i := 0;
  for g := 1 to nb_graphes do
    if graphes[g].ival = 1 then i := i+1; { indicateur val }

  s := '';
  if CB_name.checked    then s := s + 'Network' + hortab;
  if CB_species.checked then s := s + 'S' + hortab;
  if CB_links.checked   then s := s + 'L' + hortab;
  if CB_intens.checked  then s := s + 'L/S' + hortab;
  if CB_connectance.checked  then s := s + 'L/S^2' + hortab;

  if CB_basal.checked   then s := s + 'B' + hortab;
  if CB_intermediate.checked then s := s + 'I' + hortab;
  if CB_top.checked     then s := s + 'T' + hortab;
  if CB_basal_isol.checked   then s := s + 'Bisol' + hortab;
  if CB_loops.checked   then s := s + 'Cann' + hortab;
  if CB_omnivorous.checked   then s := s + 'Omni' + hortab;

  if CB_height.checked  then s := s + 'H' + hortab;
  if CB_hmax.checked    then s := s + 'Hmax' + hortab;
  if CB_height_top.checked   then s := s + 'Htop' + hortab;
  if CB_long_top.checked     then s := s + 'Ltop' + hortab;
  if CB_path_top.checked     then s := s + 'PathTop' + hortab;

  if CB_trolev.checked  then s := s + 'TL' + hortab;
  if CB_tlmax.checked   then s := s + 'TLmax' + hortab;
  if CB_oi.checked      then s := s + 'OI' + hortab;

  if CB_deg.checked     then s := s + 'Deg' + hortab;
  if CB_pathlen.checked then s := s + 'PathLen' + hortab;
  if CB_charlen.checked then s := s + 'CharLen' + hortab;
  if CB_diameter.checked     then s := s + 'Diam' + hortab;
  if CB_radius.checked  then s := s + 'Radius' + hortab;
  if CB_clust.checked   then s := s + 'Clust' + hortab;
  if CB_assort.checked  then s := s + 'Assort' + hortab;
  if CB_entropy.checked then s := s + 'Ent' + hortab;
  if CB_scaled_entropy.checked then s := s + 'ScalEnt' + hortab;
  if CB_gentime.checked then s := s + 'GenT' + hortab;
  if CB_kemeny.checked  then s := s + 'Kem' + hortab;

  if ( i > 0 ) then { au moins un graphe value }
    begin
      if CB_Wheight.checked  then s := s + 'WH' + hortab;
      if CB_Wtrolev.checked  then s := s + 'WTL' + hortab;
      if CB_Wtlmax.checked   then s := s + 'WTLmax' + hortab;
      if CB_Woi.checked      then s := s + 'WOI' + hortab;
      if CB_Wgen.checked     then s := s + 'Wgen' + hortab;
      if CB_Wvul.checked     then s := s + 'Wvul' + hortab;
      if CB_Wentropy.checked then s := s + 'Went' + hortab;
      if CB_Wgentime.checked then s := s + 'WgenT' + hortab;
      if CB_wkem.checked     then s := s + 'Wkem' + hortab;
    end;

  lines := TStringList.Create;
  lines.add(s);

  for g := 1 to nb_graphes do with graphes[g] do
    if ( nb_sommets = 0 ) then
      s := ''
    else
    begin
      ns := nb_sommets;
      s := '';
      if CB_name.checked    then s := s + name + hortab;
      if CB_species.checked then s := s + IntToStr(ns) + hortab;
      if CB_links.checked   then s := s + IntToStr(nb_arcs) + hortab;
      if CB_intens.checked  then s := s + s_ecri_val(nb_arcs/ns) + hortab;
      if CB_connectance.checked  then s := s + s_ecri_val(nb_arcs/(ns*ns)) + hortab;

      if CB_basal.checked   then s := s + IntToStr(nb_b) + hortab;
      if CB_intermediate.checked then s := s + IntToStr(nb_i) + hortab;
      if CB_top.checked     then s := s + IntToStr(nb_t) + hortab;
      if CB_basal_isol.checked   then s := s + IntToStr(nb_b_isol) + hortab;
      if CB_loops.checked   then s := s + IntToStr(nb_boucles) + hortab;
      no := 0;
      for x := 1 to nb_sommets do with ggg[x] do
        if ( h_moy > 0.0 ) and ( h_max > h_moy ) then
          no := no + 1;
      if CB_omnivorous.checked   then s := s + IntToStr(no) + hortab;

      if CB_height.checked  then s := s + s_ecri_val_bad(haut_moy) + hortab;
      if CB_hmax.checked    then s := s + s_ecri_val_bad(haut_max) + hortab;
      if CB_height_top.checked   then s := s + s_ecri_val_bad(hauttop_moy) + hortab;
      if CB_long_top.checked     then s := s + s_ecri_val_bad(longtop_moy) + hortab;
      if CB_path_top.checked     then s := s + s_ecri_val_bad(nb_pathtop) + hortab;

      if CB_trolev.checked  then s := s + s_ecri_val_bad(trolev_moy) + hortab;
      if CB_tlmax.checked   then s := s + s_ecri_val_bad(trolev_max) + hortab;
      if CB_oi.checked      then s := s + s_ecri_val_bad(o_index) + hortab;

      if CB_deg.checked     then s := s + s_ecri_val(deg_moy) + hortab;
      if CB_pathlen.checked then s := s + s_ecri_val_bad(pathlen) + hortab;
      if CB_charlen.checked then s := s + s_ecri_val(charlen) + hortab;
      if CB_diameter.checked     then s := s + s_ecri_val(diam) + hortab;
      if CB_radius.checked  then s := s + s_ecri_val(radius) + hortab;
      if CB_clust.checked   then s := s + s_ecri_val(clust) + hortab;
      if CB_assort.checked  then s := s + s_ecri_val(assort) + hortab;
      if CB_entropy.checked then s := s + s_ecri_val(entropy) + hortab;
      if CB_scaled_entropy.checked then s := s + s_ecri_val(entropy/ln(ns)) + hortab;
      if CB_gentime.checked then s := s + s_ecri_val(gentime) + hortab;
      if CB_kemeny.checked  then s := s + s_ecri_val(kemeny) + hortab;

      if ( i > 0 ) then { au moins un graphe value }
      begin
      if CB_wheight.checked  then s := s + s_ecri_val_bad(haut_moy_val) + hortab;
      if CB_wtrolev.checked  then s := s + s_ecri_val_bad(trolev_moy_val) + hortab;
      if CB_wtlmax.checked   then s := s + s_ecri_val_bad(trolev_max_val) + hortab;
      if CB_woi.checked      then s := s + s_ecri_val_bad(o_index_val) + hortab;
      if CB_Wgen.checked     then s := s + s_ecri_val_bad(gen_moy_val) + hortab;
      if CB_Wvul.checked     then s := s + s_ecri_val_bad(vul_moy_val) + hortab;
      if CB_Wentropy.checked then s := s + s_ecri_val_bad(entropy_val) + hortab;
      if CB_Wgentime.checked then s := s + s_ecri_val_bad(gentime_val) + hortab;
      if CB_wkem.checked     then s := s + s_ecri_val_bad(kemeny_val);
      end;

      lines.add(s)
    end;

    with savedialog1 do
    begin
      FileName := 'export.txt';
      Filter := 'TXT files (*.txt)|All files (*)';
      InitialDir := dir;
      if Execute then
        begin
          if FileExists(FileName) then
            if not confirm_('Overwrite file ' + ExtractFileName(FileName) + '?') then exit;
          lines.SaveToFile(FileName);
          with form_nw do status_action('Networks exported');
        end;
    end;

  Close;
end;

end.
