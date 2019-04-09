unit kglobvar;

{  @@@@@@  variables globales   @@@@@@  }

interface

const  pisur2 = pi/2.0;
       dpi    = 2.0*pi;
       bigint = 2147483647; { kmath }
       bigint64 = 9223372036854775807;
       bad = -1; { represente une valeur positive non calculee }

{ ------  types  utilitaires  ------ }

const  maxextended = 1.0e+4932;
       minextended = 4.0e-4932; { f_graph }

const  vecmax = 2000; { max number of species per network }
       big = 2*vecmax; { kcalculg }

type   rmat_type = array[1..vecmax,1..vecmax] of extended;
       imat_type = array[1..vecmax,1..vecmax] of integer;
       rvec_type = array[1..vecmax] of extended;
       ivec_type = array[1..vecmax] of integer;
       svec_type = array[1..vecmax] of string;

{ ------  types internes  ------ }

const  type_lis = 0;
       type_som = 1;

       type_gra_lu      = 10;
       type_gra_void    = 11;
       type_gra_erdos   = 12;
       type_gra_unif    = 13;
       type_gra_smallw  = 14;
       type_gra_arb     = 15;
       type_gra_sub     = 16;

       type_gra_root    = 17;
       type_gra_markov  = 18;

       type_null_bit    = 20;
       type_null_niche  = 21;
       type_null_deg    = 22;
       type_gra_dup     = 30;
       type_gra_som     = 31;
       type_gra_dual    = 32;
       
       type_gra_groupmod = 40;
       type_gra_groupaic = 41;
       type_gra_grouptro = 42;

       type_gra_aggreg  = 50;

       type_group_mod   = 60;
       type_group_aic   = 61;
       type_group_tro   = 62;
       type_group_agg   = 63; { aggregation }

       type_inconnu     = 1000;

{ ------  types fichiers  ------ }

const  type_nw0 = 0;
       type_nw1 = 1;
       type_nw2 = 2;
       type_txt = 10;
       type_paj = 20;
       type_gml = 21;

{ ------  listes  ------ }

const  lis_nb_max = 1000000;

type   lis_type = record
                    car_type : integer;
                    car      : integer;
                    val      : extended;
                    cdr      : integer;
                  end;

var    lis      : array[1..lis_nb_max] of lis_type;
       lis_nb   : integer;
       lis_lib  : integer;

{ ------  graphes ------ }

const  graphemax = 300;
       infomax = 10;

type   ivecvec_type = array of integer;
       info_type = array[1..infomax] of extended;

type   s_type = record { sommet }
                  nom : string;      { nom du sommet }
                  nb_succ : integer; { nombre de successeurs = out-degree }
                  nb_pred : integer; { nombre de predecesseurs = in-degree = generalisme }
                  succ  : integer;   { liste des successeurs }
                  pred  : integer;   { liste des predecesseurs }
                  gen_val : extended; { generalisme graphe value }
                  vul_val : extended; { vulnerabilite graphe value }
                  h_min : integer;   { hauteur min }
                  h_moy : extended;  { hauteur moy }
                  h_max : integer;   { hauteur max }
                  h_moy_val : extended; { hauteur moy graphe value }
                  oi    : extended;  { index omnivorie }
                  oi_val : extended; { index omnivorie graphe value }
                  { voir oi base sur trolev }
                  trolev : extended; { trophic level; basal = 1 }
                  trolev_val : extended; { trophic level graphe value; basal = 1 }
                  between : extended;  { betweenness centrality }
                  connect : integer; { numero de composante connexe }
                  group_mod : integer; { numero de module }
                  group_aic : integer; { numero de groupe AIC }
                  group_tro : integer; { numero de groupe trophique }
                  group_agg : integer; { numero de groupe aggregation }
                  deg  : integer;   { degre (nb_pred + nb_succ) }
                  c    : extended;  { coefficient d'aggregation clust }
                  ecc  : integer;   { excentricité }
                  cyc  : integer;   { liste contenant un cycle, s'il existe }
                  boucle : integer; { indicateur de boucle }
                  rank : extended;  { importance au sens Allesina & Pascual }
                  cyctime : extended; { temps de cycle }
                  cyctime_val : extended; { temps de cyle value }
                  biom : extended;  { info sur l'espece, e.g., biomasse }
                  info : info_type; { ensemble d'infos biologiques sur l'espece }
                end;

type   s_vec_type  = array of s_type;
       info_s_type = array[1..infomax] of string;

type   graphe_type = record { graphe }
                       name : string;  { nom du graphe }
                       typ  : integer; { type du graphe }
                       icre : integer; { indice de creation du graphe }
                       i_pere : integer; { # icre du graphe d'origine }
                       ival : integer; { indicateur que les arcs sont values }
                       root : integer; { indice du sommet Root s'il existe, 0 sinon }
                       iprim : integer; { indice d'imprimitivite }
                       time_out : boolean; { indicateur time out sur calcul }
                       nb_sommets : integer; { nombre de sommets (especes) }
                       nb_b : integer; { nombre d'especes basales }
                       nb_i : integer; { nombre d'especes intermediaires }
                       nb_t : integer; { nombre d'especes top }
                       nb_b_isol : integer;  { nombre d'especes basales isolees }
                       nb_arcs    : integer; { nombre d'arcs (links) }
                       nb_connect : integer; { nombre de composantes connexes }
                       nb_boucles : integer; { nombre de boucles (self-loops) }
                       nb_cycles  : integer; { nombre de cycles }
                       (*nb_pathtop : int64;   { nombre de chemins des sommets bas aux sommets hauts } *)
                       nb_pathtop : extended;   { nombre de chemins des sommets bas aux sommets hauts }
                       nb_group_mod : integer;  { nombre de modules }
                       nb_group_aic : integer;  { nombre de groupes AIC }
                       nb_group_tro : integer;  { nombre de groupes trophiques }
                       nb_group_agg : integer;  { nombre de groupes par aggregation }
                       ggg : s_vec_type;
                       diam     : integer;  { diametre }
                       radius   : integer;  { rayon }
                       charlen  : extended; { longueur caracteristique }
                       pathlen  : extended; { longueur moyenne }
                       clust    : extended; { coeff d'aggregation moyen (clustering coeff) }
                       assort   : extended; { assortativite }
                       deg_moy  : extended; { degre moyen, sans orientation }
                       gen_moy_val : extended; { generalisme moyen graphe value }
                       vul_moy_val : extended; { vulnerabilite moyenne graphe value }
                       haut_moy : extended; { hauteur moyenne }
                       longtop_moy : extended; { hauteur moyenne basal -> top }
                       longtop_moy_val : extended; { hauteur moyenne basal -> top }
                       longtop_min : integer;  { longueur min des chemins basal -> top }
                       hauttop_moy : extended; { hauteur moyenne des especes top }
                       haut_max : integer;  { hauteur maximale }
                       haut_moy_val : extended; { hauteur moyenne graphe value }
                       {haut_max_val : extended;} { hauteur max graphe value }
                       hauttop_moy_val : extended; { hauteur moyenne des especes top graphe value }
                       trolev_moy : extended;  { niveau trophique moyen }
                       trolev_max : extended;  { niveau trophique max }
                       trolev_moy_val : extended; { niveau trophique moyen value }
                       trolev_max_val : extended; { niveau trophique max value }
                       cyclen   : extended;    { longueur moyenne des cycles }
                       o_index  : extended;    { index d'omnivorie }
                       o_index_val  : extended;{ index d'omnivorie graphe value }
                       entropy  : extended;    { entropy }
                       entropy_val : extended; { entropy graphe value }
                       valmax   : extended;    { valeur max sur les arcs values }
                       gentime  : extended;    { generation time }
                       gentime_val : extended; { generation time value }
                       kemeny   : extended;    { Kemeny's constant }
                       kemeny_val : extended;  { Kemeny's constant value }
                       simul : integer;        { nb de simulations (0 = pas de simulation }
                       nb_sommets_simul : extended;
                       nb_b_simul : extended;
                       nb_i_simul : extended;
                       nb_t_simul : extended;
                       nb_arcs_simul    : extended;
                       nb_connect_simul : extended;
                       nb_boucles_simul : extended;
                       nb_cycles_simul  : extended;
                       nb_chaines_simul : extended;
                       diam_simul       : extended;
                       radius_simul     : extended;
                       pathlen_simul    : extended;
                       charlen_simul    : extended;
                       clust_simul      : extended;
                       assort_simul     : extended;
                       deg_moy_simul    : extended;
                       trolev_moy_simul : extended;
                       trolev_max_simul : extended;
                       haut_moy_simul   : extended;
                       haut_max_simul   : extended;
                       o_index_simul    : extended;
                       cyclen_simul     : extended;
                       entropy_simul     : extended;
                       entropy_val_simul : extended;
                       param_p          : extended; { proba de connexion (erdos, smallworld graph) }
                       param_deg        : integer;
                       param_nb_niv     : integer;
                       nb_infos  : integer; { nombre d'informations biologiques }
                       name_info : info_s_type; { noms des infos biologiques }
                     end;

var    nb_graphes : integer;  { nombre de graphes }
       graphes  : array[1..graphemax] of graphe_type; { table des graphes }
       g_select : integer;  { indice graphe courant }
       g_       : integer;  { indice dernier graphe calcule }
       m_  : imat_type;     { matrice du graphe courant 0/1 }
       mr_ : rmat_type;     { matrice du graphe courant avec valeurs des arcs }
       nb_simul_ : integer; { nombre courant de simulations }
       simul_    : integer; { numero de simulation courante }
       edit_mode : boolean; { mode edition }

implementation

end.
