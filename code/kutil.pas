unit kutil;

{  @@@@@@  procedures utilitaires   @@@@@@  }

interface

uses IdGlobal,SysUtils,Classes,QForms;

procedure iwriteln(s : string);
procedure bwriteln(slist : TStrings);
procedure erreur_(s : string);
function  confirm_(s : string) : boolean;
function  clock : integer;
function  s_ecri_t_exec(ms : integer) : string;
procedure resolution;
procedure adjust(f : TForm);

implementation

uses  QControls,QDialogs,f_nw,f_view,f_pad;

const height_dev = 1024 {768};
      width_dev  = 1280 {1024};
      pixels_per_inch_dev0 = 96;

var   screen_ratio_h : extended;     { rapport hauteur ecran utilisateur/hauteur ecran developpement }
      screen_ratio_w : extended;     { rapport largeur ecran utilisateur/largeur ecran developpement }
      pixels_per_inch_dev : integer; { valeur pixelperinch au developpement }

procedure iwriteln(s : string);
begin
  with form_pad do memo1.Lines.Append(s);
end;

procedure bwriteln(slist : TStrings);
var i : integer;
begin
  with form_pad do with memo1.Lines do
    for i := 0 to slist.Count - 1 do Append(slist[i]);
end;

procedure erreur_(s : string);
begin
  MessageDlg(s,mtError,[mbOk],0,mbOk);
end;

function  confirm_(s : string) : boolean;
begin
  if MessageDlg(s,mtConfirmation,[mbYes,mbNo],0) <> mrYes then
    confirm_ := false
  else
    confirm_ := true;
end;

function  clock : integer;
{ nombre de millisecondes }
begin
  clock := GetTickCount;
end; 

function  s_ecri_t_exec(ms : integer) : string;
var h,mn,sec : integer;
begin
  sec := ms div 1000;
  if ( sec = 0 ) then
    begin
      s_ecri_t_exec := IntToStr(ms) + ' ms';
      exit;
    end;
  if ( sec < 60 ) then
    begin
      s_ecri_t_exec := IntToStr(sec) + ' s';
      exit;
    end;
  mn := sec div 60;
  sec  := sec mod 60;
  if ( mn < 60 ) then
    begin
      s_ecri_t_exec := IntToStr(mn) + ' mn ' + IntToStr(sec) + ' s';
      exit;
    end;
  h  := mn div 60;
  mn := mn mod 60;
  s_ecri_t_exec := IntToStr(h)   + ' h '  + IntToStr(mn)  + ' mn';
end;

procedure resolution;
begin
  screen_ratio_h := Screen.Height/height_dev;
  screen_ratio_w := Screen.Width/width_dev;
  pixels_per_inch_dev := pixels_per_inch_dev0;
end;

procedure adjust(f : TForm);
begin
  if ( Screen.Width < width_dev ) then exit;
  with f do
    begin
      Scaled := true;
      Left   := round(screen_ratio_w*Left);
      Top    := round(screen_ratio_h*Top);
      Width  := round(screen_ratio_w*Width);
      Height := round(screen_ratio_h*Height);
    end;
end;

end.
