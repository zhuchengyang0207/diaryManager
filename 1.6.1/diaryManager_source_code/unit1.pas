unit Unit1;

{$mode objfpc}{$H+}//{$codepage cp1252}

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
    Button4: TButton;
    Button5: TButton;
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
    MenuItem4: TMenuItem;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    SpinEdit3: TSpinEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
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

function int2hex(a:longint):char;
begin
  if(a>=0)and(a<=9) then
    exit(chr(a+48))
  else
    exit(chr(a+55));
end;

function string2hex(a:UnicodeString):AnsiString;
var
  ans:AnsiString;
  i:longint;
begin
  ans:='';
  for i:=1 to length(a) do
    begin
      ans:=ans+int2hex((ord(a[i])and %1111000000000000)>>12)
              +int2hex((ord(a[i])and %0000111100000000)>>8 )
              +int2hex((ord(a[i])and %0000000011110000)>>4 )
              +int2hex((ord(a[i])and %0000000000001111)>>0 );
    end;
  exit(ans);
end;

procedure encrypt(Sender:TObject;const fnm,key:AnsiString);
var
  i,len:longint;
  a:UnicodeString;
begin
  a:=UTF8Decode(Form1.Memo1.Lines.Text);
  len:=length(key);
  for i:=1 to length(a) do
    a[i]:=UnicodeChar(ord(a[i]) xor ord(key[(i-1)mod len+1]));
  zul_file_system.writetofile(fnm,string2hex(a));
end;
                  
function hex2int(a:char):longint;
begin
  if(a>='0')and(a<='9') then
    exit(ord(a)-48)
  else
    exit(ord(a)-55);
end;

function hex2string(a:AnsiString):UnicodeString;
var
  ans:UnicodeString;
  i:longint;
begin
  ans:='';
  for i:=1 to length(a)div 4 do
    begin
      ans:=ans+UnicodeChar(hex2int(a[i*4-3])<<12+
                           hex2int(a[i*4-2])<<8 +
                           hex2int(a[i*4-1])<<4 +
                           hex2int(a[i*4  ])     );
    end;
  exit(ans);
end;

procedure decrypt(Sender:TObject;const fnm,key:AnsiString);
var
  i,len:longint;
  a:AnsiString;
  res:UnicodeString;
begin
  a:=zul_file_system.loadfromfile(fnm);
  res:=hex2string(a);
  len:=length(key);
  for i:=1 to length(res) do
    res[i]:=UnicodeChar(ord(res[i])xor ord(key[(i-1)mod len+1]));
  Form1.Memo1.Lines.Text:=UTF8Encode(res);
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  salt,pth,psw:AnsiString;
begin
  pth:='bin\'+SpinEdit1.Value.ToString+'\'+
              SpinEdit2.Value.ToString+'\'+
              SpinEdit3.Value.ToString;
  salt:=SpinEdit1.Value.ToString+'S'+
        SpinEdit2.Value.ToString+'S'+
        SpinEdit3.Value.ToString+'S';
  if zul_file_system.fileexist(pth+'\password.ini') then
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
  zul_file_system.createdir(pth);
  zul_file_system.
    writetofile(pth+'\password.ini',
                mdprint(md5string(salt+psw)));
//  zul_file_system.
//    writetofile(pth+'\context.ini',
//                crypt(Memo1.Lines.Text,psw));
  encrypt(Sender,pth+'\context.ini',psw);
  Memo1.Lines.Text:='';
  zul_file_system.writetofile('bin\indx.ini',
    zul_file_system.loadfromfile('bin\indx.ini')+
      SpinEdit1.Value.ToString+' '+
      SpinEdit2.Value.ToString+' '+
      SpinEdit3.Value.ToString+#13#10);
  showmessage('Success!');
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  salt,pth,psw:AnsiString;
begin
  pth:='bin\'+SpinEdit1.Value.ToString+'\'+
              SpinEdit2.Value.ToString+'\'+
              SpinEdit3.Value.ToString;
  salt:=SpinEdit1.Value.ToString+'S'+
        SpinEdit2.Value.ToString+'S'+
        SpinEdit3.Value.ToString+'S';
  if not zul_file_system.fileexist(pth+'\password.ini') then
    begin
      showmessage('Diary not exist!');
      exit;
    end;
  psw:=Edit1.Text;
  if zul_file_system.loadfromfile(pth+'\password.ini')<>
     mdprint(md5string(salt+psw)) then
    begin
      showmessage('Password wrong!');
      exit;
    end;
  if Memo1.Lines.Text<>'' then
    begin
      showmessage('In order to ensure safety, please make the memo empty.');
      exit;
    end;
  decrypt(Sender,pth+'\context.ini',psw);
  showmessage('Success!');
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  salt,pth,psw:AnsiString;
begin
  pth:='bin\'+SpinEdit1.Value.ToString+'\'+
              SpinEdit2.Value.ToString+'\'+
              SpinEdit3.Value.ToString;
  salt:=SpinEdit1.Value.ToString+'S'+
        SpinEdit2.Value.ToString+'S'+
        SpinEdit3.Value.ToString+'S';
  if not zul_file_system.fileexist(pth+'\password.ini') then
    begin
      showmessage('Diary not exist!');
      exit;
    end;
  psw:=Edit1.Text;
  if zul_file_system.loadfromfile(pth+'\password.ini')<>
     mdprint(md5string(salt+psw)) then
    begin
      showmessage('Password wrong!');
      exit;
    end;
  encrypt(Sender,pth+'\context.ini',psw);
  Memo1.Lines.Text:='';
  showmessage('Success!');
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  _list,tmps,salt,pth,psw:AnsiString;
begin
  pth:='bin\'+SpinEdit1.Value.ToString+'\'+
              SpinEdit2.Value.ToString+'\'+
              SpinEdit3.Value.ToString;
  salt:=SpinEdit1.Value.ToString+'S'+
        SpinEdit2.Value.ToString+'S'+
        SpinEdit3.Value.ToString+'S';
  if not zul_file_system.fileexist(pth+'\password.ini') then
    begin
      showmessage('Diary not exist!');
      exit;
    end;
  psw:=Edit1.Text;
  if zul_file_system.loadfromfile(pth+'\password.ini')<>
     mdprint(md5string(salt+psw)) then
    begin
      showmessage('Password wrong!');
      exit;
    end;
  if Memo1.Lines.Text<>'ok' then
    begin
      showmessage('In order to ensure safety, please type "ok" in the memo.');
      exit;
    end;
  zul_file_system.destroyfile(pth+'\password.ini');
  zul_file_system.destroyfile(pth+'\context.ini');
  zul_file_system.destroydir(pth);
  _list:=zul_file_system.loadfromfile('bin\indx.ini');
  tmps:=SpinEdit1.Value.ToString+' '+
        SpinEdit2.Value.ToString+' '+
        SpinEdit3.Value.ToString+#13#10;
  delete(_list,pos(tmps,_list),length(tmps));
  zul_file_system.writetofile('bin\indx.ini',_list);
  if pos(SpinEdit1.Value.ToString+' '+
         SpinEdit2.Value.ToString,_list)=0 then
    zul_file_system.destroydir('bin\'+
                                SpinEdit1.Value.ToString+'\'+
                                SpinEdit2.Value.ToString);
  if pos(SpinEdit1.Value.ToString,_list)=0 then
    zul_file_system.destroydir('bin\'+SpinEdit1.Value.ToString);
  Memo1.Lines.Text:='';
  showmessage('Success!');
end;

type
  _date=record
    year,month,day:longint;
  end;

operator <(a,b:_date)c:boolean;
begin
  if a.year<>b.year then
    exit(a.year<b.year);
  if a.month<>b.month then
    exit(a.month<b.month);
  if a.day<>b.day then
    exit(a.day<b.day);
  exit(false);
end;

procedure TForm1.Button5Click(Sender: TObject);
var
  a:array of _date;
  fin:text;
  tmp:_date;
  pth,salt:AnsiString;
  len,i,j:longint;
  y,m,d:array of longint;
  procedure makeMonth(yy,mm:longint);
  var
    res:AnsiString;
    i:longint;
  begin
    res:='<html><head><title>'+yy.ToString+'.'+mm.ToString+
         '</title></head><body><h1>'+yy.ToString+'.'+mm.ToString+'</h1>';
    for i:=0 to length(d)-1 do
      res:=res+'<a href="./'+d[i].ToString+'/index.html">'+
        yy.ToString+'.'+mm.ToString+'.'+d[i].ToString+'</a></br>';
    res:=res+'</body></html>';
    zul_file_system.writetofile('exports\'+yy.ToString+'\'
                                          +mm.ToString+'\index.html',res);
  end;
  procedure makeYear(yy:longint);
  var
    res:AnsiString;
    i:longint;
  begin
    res:='<html><head><title>'+yy.ToString+
         '</title></head><body><h1>'+yy.ToString+'</h1>';
    for i:=0 to length(m)-1 do
      res:=res+'<a href="./'+m[i].ToString+'/index.html">'+
        yy.ToString+'.'+m[i].ToString+'</a><br/>';
    res:=res+'</body></html>';
    zul_file_system.writetofile('exports\'+yy.ToString+'\index.html',res);
  end;                 
  procedure makeMain;
  var
    res:AnsiString;
    i:longint;
  begin
    res:='<html><head><title>Created by diaryManager</title></head><body>';
    for i:=0 to length(y)-1 do
      res:=res+'<a href="./'+y[i].ToString+'/index.html">'+
        y[i].ToString+'</a><br/>';
    res:=res+'</body></html>';
    zul_file_system.writetofile('exports\index.html',res);
  end;
begin
  setlength(y,1);
  setlength(m,1);
  setlength(d,1);
  zul_file_system.destroydirSTRONG('exports');
  zul_file_system.createdir('exports');
  system.assign(fin,'bin\indx.ini');
  reset(fin);
  setlength(a,0);
  while not eof(fin) do
    begin
      setlength(a,length(a)+1);
      with a[length(a)-1] do
        readln(fin,year,month,day);
    end;
  len:=length(a);
  if len=0 then
    begin
      showmessage('No diaries can be export!');
      exit;
    end;
  for i:=1 to len-1 do
    for j:=i+1 to len do
      if a[j-1]<a[i-1] then
        begin
          tmp:=a[i-1];
          a[i-1]:=a[j-1];
          a[j-1]:=tmp;
        end;
  for i:=0 to len-1 do
    begin
      pth:=a[i].year .ToString+'\'+
           a[i].month.ToString+'\'+
           a[i].day  .ToString;
      salt:=a[i].year .ToString+'S'+
            a[i].month.ToString+'S'+
            a[i].day  .ToString+'S';
      zul_file_system.createdir('exports\'+pth);
      zul_file_system.writetofile('exports\'+pth+'\index.html',
        '<html><head><title>'+
          a[i].year .ToString+'.'+
          a[i].month.ToString+'.'+
          a[i].day  .ToString+
        '</title><script src="https://cdn.bootcss.com/blueimp-md5/1.1.0/js/md5.js"></script><script>function H(a){if("0"<=a&&a<="9")return a.charCodeAt()-48;else return a.charCodeAt()-55;}function C(K){const P="'+
          zul_file_system.loadfromfile('bin\'+pth+'\context.ini'){)}+
        '";const L=P.length,M=K.length;var R="";for(var i=0;i<L/4;i++)R+=String.fromCharCode((H(P[i*4])*4096+H(P[i*4+1])*256+H(P[i*4+2])*16+H(P[i*4+3]))^(K[i%M]).charCodeAt());return R;}function check(){var S=document.getElementById("Z").value;if(md5("'+
          salt+
        '"+S)=="'+zul_file_system.loadfromfile('bin\'+pth+'\password.ini')+
        '"){document.getElementById("V").innerHTML=C(S);document.getElementById("D").innerHTML="";}else alert("Password Wrong.\n\rAccess Denied");}</script></head><body><div id="D"><p>Password:</p><input type="password" id="Z"><button onclick="check()">Submit</button></div><div id="V"></div></body></html>');
    end;
  y[0]:=a[0].year;
  m[0]:=a[0].month;
  d[0]:=a[0].day;
  for i:=1 to len-1 do
    begin
      if a[i].year=a[i-1].year then
        if a[i].month=a[i-1].month then
          begin
            setlength(d,length(d)+1);
            d[length(d)-1]:=a[i].day;
          end
        else
          begin
            makeMonth(a[i].year,m[length(m)-1]);
            setlength(d,0);
            setlength(m,length(m)+1);
            m[length(m)-1]:=a[i].month;    
            setlength(d,length(d)+1);
            d[length(d)-1]:=a[i].day;
          end
      else
        begin
          makeMonth(y[length(y)-1],m[length(m)-1]);
          setlength(d,0);
          makeYear(y[length(y)-1]);
          setlength(m,0);
          setlength(y,length(y)+1);
          y[length(y)-1]:=a[i].year;    
          setlength(m,length(m)+1);
          m[length(m)-1]:=a[i].month;   
          setlength(d,length(d)+1);
          d[length(d)-1]:=a[i].day;
        end;
    end;
  makeMonth(y[length(y)-1],m[length(m)-1]);
  setlength(d,0);
  makeYear(y[length(y)-1]);
  setlength(m,0);
  makeMain;
  setlength(y,0);
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
begin
  showmessage('It''s a open source project.'+#13#10+
              'See its source code on Github:'+#13#10+
              'https://github.com/zhuchengyang0207/diaryManager');
end;

procedure TForm1.MenuItem3Click(Sender: TObject);
begin
  showmessage('This project is made by zhuchengyang0207'+#13#10+
              'Visit my Github: https://github.com/zhuchengyang0207'+#13#10+
              '');
end;

procedure TForm1.MenuItem4Click(Sender: TObject);
begin
  showmessage('The code is copyleft. But please indicate the source.'+#13#10+
              'Irresponsible for any bugs.'+#13#10+
              'Do not tamper with files in the directory.');
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
