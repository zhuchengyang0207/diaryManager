unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtDlgs,
  Menus, StdCtrls, Spin, ExtCtrls, Dos, Md5, zul_file_system;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    MainMenu1: TMainMenu;
    Memo1: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    SpinEdit3: TSpinEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure SpinEdit2Change(Sender: TObject);
    procedure SpinEdit3Change(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  dates_:array[1..12]of longint=(31,28,31,30,31,30,31,31,30,31,30,31);

implementation

{$R *.lfm}

{ TForm1 }

function IsLeapYear(a:longint):boolean;
begin
  if(a mod 400=0)or((a mod 100<>0)and(a mod 4=0)) then
    exit(true)
  else
    exit(false);
end;

procedure TForm1.SpinEdit1Change(Sender: TObject);
begin
  if SpinEdit1.Value>SpinEdit1.MaxValue then
    SpinEdit1.Value:=SpinEdit1.MaxValue;
  if SpinEdit1.Value<SpinEdit1.MinValue then
    SpinEdit1.Value:=SpinEdit1.MinValue;
  if not IsLeapYear(SpinEdit1.Value) then
    if SpinEdit2.Value=2 then
      begin
        if SpinEdit3.Value=29 then
          SpinEdit3.Value:=28;
        SpinEdit3.MaxValue:=28;
      end;
  if IsLeapYear(SpinEdit1.Value) then
    if SpinEdit2.Value=2 then
      SpinEdit3.MaxValue:=29;
end;

function crypt(const plaintext,key:ansistring):ansistring;
var
  i:longint;
begin
  crypt:='';
  for i:=1 to length(plaintext) do
    crypt:=crypt+chr(ord(plaintext[i])xor ord(key[(i-1)mod length(key)+1]));
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  s,psw:ansistring;
begin
  s:=SpinEdit1.Value.ToString+'\'+
     SpinEdit2.Value.ToString+'\'+
     SpinEdit3.Value.ToString;
  if zul_file_system.fileexist(s+'\password.ini') then
    begin
      showmessage('Diary already exist!');
      exit;
    end;
  psw:=Edit1.Text;
  if psw='' then
    begin
      showmessage('Password empty!');
      exit;
    end;
  zul_file_system.createdir(s);
  zul_file_system.
    writetofile(s+'\password.ini',
                mdprint(md5string(s+'\'+psw)));
  zul_file_system.
    writetofile(s+'\context.ini',
                crypt(Memo1.Lines.Text,psw));
  Memo1.Lines.Text:='';
  showmessage('Success!');
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  s,psw:ansistring;
begin
  s:=SpinEdit1.Value.ToString+'\'+
     SpinEdit2.Value.ToString+'\'+
     SpinEdit3.Value.ToString;
  if not zul_file_system.fileexist(s+'\password.ini') then
    begin
      showmessage('Diary not exist!');
      exit;
    end;
  psw:=Edit1.Text;
  if zul_file_system.loadfromfile(s+'\password.ini')<>
     mdprint(md5string(s+'\'+psw)) then
    begin
      showmessage('Password wrong!');
      exit;
    end;
  if Memo1.Lines.Text<>'' then
    begin
      showmessage('In order to ensure safety, please make the memo empty.');
      exit;
    end;
  Memo1.Lines.Text:=crypt(zul_file_system.loadfromfile(s+'\context.ini'),psw);
  showmessage('Success!');
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  s,psw:ansistring;
begin
  s:=SpinEdit1.Value.ToString+'\'+
     SpinEdit2.Value.ToString+'\'+
     SpinEdit3.Value.ToString;
  if not zul_file_system.fileexist(s+'\password.ini') then
    begin
      showmessage('Diary not exist!');
      exit;
    end;
  psw:=Edit1.Text;
  if zul_file_system.loadfromfile(s+'\password.ini')<>
     mdprint(md5string(s+'\'+psw)) then
    begin
      showmessage('Password wrong!');
      exit;
    end;
  zul_file_system.
    writetofile(s+'\context.ini',
                crypt(Memo1.Lines.Text,psw));
  showmessage('Success!');
end;

procedure TForm1.SpinEdit2Change(Sender: TObject);
begin
  if SpinEdit2.Value>SpinEdit2.MaxValue then
    SpinEdit2.Value:=SpinEdit2.MaxValue;
  if SpinEdit2.Value<SpinEdit2.MinValue then
    SpinEdit2.Value:=SpinEdit2.MinValue;
  if IsLeapYear(SpinEdit1.Value) then
    dates_[2]:=29
  else
    dates_[2]:=28;
  if SpinEdit3.Value>dates_[SpinEdit2.Value] then
    SpinEdit3.Value:=dates_[SpinEdit2.Value];
  SpinEdit3.MaxValue:=dates_[SpinEdit2.Value];
end;

procedure TForm1.SpinEdit3Change(Sender: TObject);
begin
  if SpinEdit3.Value>SpinEdit3.MaxValue then
    SpinEdit3.Value:=SpinEdit3.MaxValue;
  if SpinEdit3.Value<SpinEdit3.MinValue then
    SpinEdit3.Value:=SpinEdit3.MinValue;
end;

end.

