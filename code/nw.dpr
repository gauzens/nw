program nw;

uses
  QForms,
  f_nw in 'f_nw.pas' {form_nw},
  f_graph in 'f_graph.pas' {form_graph},
  f_graphset in 'f_graphset.pas' {form_graphset},
  f_about in 'f_about.pas' {form_about},
  f_edit in 'f_edit.pas' {form_edit},
  f_view in 'f_view.pas' {form_view},
  f_createg in 'f_createg.pas' {form_create_graphe},
  f_pad in 'f_pad.pas' {form_pad},
  f_cluster in 'f_cluster.pas' {form_cluster},
  f_import in 'f_import.pas' {form_import},
  f_lump in 'f_lump.pas' {form_lump},
  f_choose_crit in 'f_choose_crit.pas' {form_choose_crit},
  kmarkov in 'kmarkov.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tform_nw, form_nw);
  Application.CreateForm(Tform_graph, form_graph);
  Application.CreateForm(Tform_graphset, form_graphset);
  Application.CreateForm(Tform_about, form_about);
  Application.CreateForm(Tform_edit, form_edit);
  Application.CreateForm(Tform_view, form_view);
  Application.CreateForm(Tform_create_graphe, form_create_graphe);
  Application.CreateForm(Tform_pad, form_pad);
  Application.CreateForm(Tform_cluster, form_cluster);
  Application.CreateForm(Tform_import, form_import);
  Application.CreateForm(Tform_lump, form_lump);
  Application.CreateForm(Tform_choose_crit, form_choose_crit);
  Application.Run;
end.
