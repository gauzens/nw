unit f_view;

interface

uses SysUtils,Types,Classes,Variants,QGraphics,QControls,QForms,QDialogs,
     QComCtrls,QTypes,QMenus,QExtCtrls,QStdCtrls,
     kglobvar;

type
  tform_view = class(TForm)
    TreeView1: TTreeView;
    StatusBar1: TStatusBar;
    Memo1: TMemo;
    procedure tree(g : integer);
    procedure tree_x(g,x : integer);
    procedure display(g : integer);
    procedure TreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure FormCreate(Sender: TObject);
    procedure StatusBar1PanelClick(Sender: TObject; Panel: TStatusPanel);
    procedure FormShow(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    expand : ivec_type;
    procedure status;
  public
    ifv : integer;    { numero de la forme }
    g_view : integer; { numero du graphe que la forme montre }
  end;

var  form_view: tform_view;

implementation

uses kutil,ksyntax,kgestiong;

{$R *.xfm}

procedure tform_view.status;
begin
if ( g_view <> 0 ) then
  with graphes[g_view],statusbar1 do
    begin
      Panels[0].Text := graphes[g_view].name;
      Panels[1].Text := '#' + IntToStr(icre);;
      Panels[2].Text := 'NbSpecies = ' + IntToStr(nb_sommets);
      Panels[3].Text := 'NbLinks = '    + IntToStr(nb_arcs);
    end;
end;

procedure tform_view.tree_x(g,x : integer);
var treenode : TTreeNode;
    y : integer;
begin
  with graphes[g],treeview1 do
    begin
      treenode := Selected;
      with ggg[x] do
        begin
          if ( expand[x] >= treenode.Level ) then exit;
          expand[x] := treenode.Level;
          y := succ;
          while ( y <> 0 ) do with lis[y] do
            begin
              Items.AddChild(treenode,s_ecri_sommet(g,car));
              y := cdr;
            end;
        end;
    end;
end;

procedure tform_view.tree(g : integer);
var treenode : TTreeNode;
    x : integer;
begin
  with graphes[g],treeview1.Items do
    begin
      treenode := nil;
      treenode := Add(treenode,'Network');
      for x := 1 to nb_sommets do
        AddChild(treenode,s_ecri_sommet(g,x));
    end;
end;

procedure tform_view.display(g : integer);
var x : integer;
    s : string;
begin
  with graphes[g],treeview1 do
    if Visible and Assigned(Selected) then
      begin
        s := Selected.Text;
        if ( s = 'Network' ) then
          b_ecri_graphe(g)
        else
          begin
            x := trouve_nom_sommet(g,s);
            if ( x <> 0 ) then
              begin
                b_ecri_sommet(g,x);
                tree_x(g,x);
              end;
          end;
        memo1.Clear;
        memo1.Lines := lines_syntax;
      end;
end;

procedure tform_view.TreeView1Change(Sender: TObject; Node: TTreeNode);
begin
  display(g_view);
end;

procedure tform_view.FormCreate(Sender: TObject);
begin
  Left   := 298;
  Top    := 28;
  Height := 706;
  Width  := 706;
  adjust(self);
  memo1.ReadOnly := true;
  memo1.Clear;
  g_view := 0;
end;

procedure tform_view.StatusBar1PanelClick(Sender: TObject;
          Panel: TStatusPanel);
begin
  {if ( g_view <> 0 ) then b_ecri_graphe(g_view);
  memo1.Clear;
  memo1.Lines := lines_syntax;}
  status;
end;

procedure tform_view.FormShow(Sender: TObject);
var x : integer;
begin
  if ( g_view <> 0 ) then
    begin
      treeview1.Items.Clear;
      tree(g_view);
      with treeview1 do Selected := Items[0];
      for x := 1 to graphes[g_view].nb_sommets do expand[x] := 0;
      display(g_view);
      status;
    end;
end;

procedure tform_view.FormActivate(Sender: TObject);
begin
  display(g_view);
end;

end.
