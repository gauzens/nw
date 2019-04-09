unit f_cluster;

interface

uses SysUtils,Types,Classes,QGraphics,QControls,QForms,QDialogs,
     QStdCtrls,QExtCtrls,QComCtrls;

type
  Tform_cluster = class(TForm)
    tro_radio: TRadioButton;
    mod_radio: TRadioButton;
    aic_radio: TRadioButton;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    initial: TEdit;
    final: TEdit;
    cooling: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    epsilon: TEdit;
    button_run: TButton;
    procedure tro_radioClick(Sender: TObject);
    procedure mod_radioClick(Sender: TObject);
    procedure aic_radioClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure button_runClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var type_clust : integer;
    form_cluster : Tform_cluster;

implementation

{$R *.xfm}

uses kutil,kglobvar,kgestiong,kaic,kmodules,ktrophicg,kgroup,f_nw;

procedure tform_cluster.FormCreate(Sender: TObject);
begin
  Left   := 230;
  Top    := 630;
  Height := 264;
  Width  := 424;
  resolution;
  adjust(self);
  init_groupe;
end;

procedure tform_cluster.FormActivate(Sender: TObject);
begin
  initial.Text := FloatToStr(ti);
  final.Text   := FloatToStr(tf);
  cooling.Text := FloatToStr(ts);
  epsilon.Text := FloatToStr(eps);
end;

procedure Tform_cluster.tro_radioClick(Sender: TObject);
begin
  type_clust := type_group_tro;
end;

procedure Tform_cluster.mod_radioClick(Sender: TObject);
begin
  type_clust := type_group_mod;
end;

procedure Tform_cluster.aic_radioClick(Sender: TObject);
begin
  type_clust := type_group_aic;
end;

function nb_sommets_isoles(g : integer) : integer;
var x,n : integer;
begin
  with graphes[g] do
    begin
      n := 0;
      for x := 1 to nb_sommets do with ggg[x] do
        if ( pred = 0 ) and ( succ = 0) then
          n := n + 1;
    end;
  nb_sommets_isoles := n;
end;

procedure Tform_cluster.button_runClick(Sender: TObject);
var g,ms :integer;
begin
  if ( nb_sommets_isoles(g_select) > 0 ) then
    begin
      erreur_('Network has isolated species (use MaxConn)');
      exit;
    end;
  graphe2mat(g_select);
  ti  := StrToFloat(initial.Text);
  tf  := StrToFloat(final.Text);
  ts  := StrToFloat(cooling.Text);
  eps := StrToFloat(epsilon.Text);
  ms := clock;
  case type_clust of
    type_group_mod : simul_mod(g_select,tf,ti,ts,eps);
    type_group_aic : simul_aic(g_select,tf,ti,ts,eps);
    type_group_tro : simul_tro(g_select,tf,ti,ts,eps);
  end;
  iwriteln('--> ' + s_ecri_t_exec(clock-ms));
  recopie_gpes(g_select,type_clust);
  g := graphe_groupe(g_select,type_clust);
  if ( g <> 0 ) then with form_nw do
    begin
      affiche;
      status_action('Group network created');
    end;
  graphe2mat(g_select);
  Close;
end;

end.

  {//species participation, Guimera and Nunes Amaral 2005
 //je procede de cette facon sur les boucles pour garder le meme ordre de sortie que precedemment...
 for x:=1 to graphes[g].nb_groups do with graphes[g] do
 begin;begin
   if gr[x].nb_sommets>0 then
      for y:=1 to gr[x].nb_sommets do
      begin
        i:=gr[x].sommets[y];
        role:=0;
          for j:=1 to nb_groups do   //pour chaque gpe
          begin
            l:=0;

            if gr[j].nb_sommets>0 then
              begin
                for k:=1 to gr[j].nb_sommets do  //pour chaque sp du gpe j
                  if ((m_[i, gr[j].sommets[k] ]=1) or (m_[gr[j].sommets[k] , i]=1)) then
                    begin
                      l:=l+1;
                      l2:=l2+1;
                    end;
              end; //fin boucle sp
            if ((y<5) and (l>0)) then iwriteln('l: '+inttostr(l));
            role:=role+sqr(l/ggg[i].deg)
          end;//fin boucle gpe
        iwriteln('l2= ' + inttostr(l2) + '  deg: '+ inttostr(ggg[i].deg)+ '  gpe:  '+inttostr(j));
        l2:=0;
        role:=1-role;
        writeln(f, car_hortab+ floattostr(role));
      end;
 end;end; }


