{$mode objfpc}
unit zul_file_system;
interface
 uses dos;
 var
  _file:text;
 function fileexist(fnm:ansistring):boolean;
 function filesize(fnm:ansistring):longint;//2GB or less
 function createfile(fnm:ansistring):boolean;
 function destroyfile(fnm:ansistring):boolean;
 procedure createdir(dnm:ansistring);
 procedure destroydir(dnm:ansistring);
 function loadfromfile(fnm:ansistring):ansistring;
 function writetofile(fnm,msg:ansistring):boolean;
 function copyfile(fnmfrom,fnmto:ansistring):boolean;
 function movefile(fnmfrom,fnmto:ansistring):boolean;
implementation
 function fileexist(fnm:ansistring):boolean;
 begin
{  try
   assign(_file,fnm);
   reset(_file);
   close(_file);
   exit(true);
  except
   exit(false);
  end;}
  {$I-}
  system.Assign(_file,fnm);
  FileMode:=0;
  Reset(_file);
  CloseFile(_file);
  {$I+}
  exit(IOResult=0);
 end;
 function filesize(fnm:ansistring):longint;
 var
  ans:longint;
 begin
  if not fileexist(fnm) then
   exit(-1);
  ans:=filesize(fnm);
  exit(ans);
 end;
 function createfile(fnm:ansistring):boolean;
 begin
  assign(_file,fnm);
  rewrite(_file);
  close(_file);
  exit(fileexist(fnm));
 end;
 function destroyfile(fnm:ansistring):boolean;
 begin
  if not fileexist(fnm) then
   exit(false);
  assign(_file,fnm);
  erase(_file);
  close(_file);
  exit(true);
 end;
 procedure createdir(dnm:ansistring);
 begin
//  mkdir(dnm);
  writetofile('tmp.bat','mkdir '+dnm);
  exec('tmp.bat','');
 end;
 procedure destroydir(dnm:ansistring);
 begin
//  rmdir(dnm);
  writetofile('tmp.bat','rmdir '+dnm);
  exec('tmp.bat','');
 end;
 function loadfromfile(fnm:ansistring):ansistring;
 var
  sz,i:longint;
  ch:char;
  _fileofchar:file of char;
 begin
  loadfromfile:='';
  if not fileexist(fnm) then
   exit('');
  assign(_fileofchar,fnm);
  reset(_fileofchar);
  sz:=system.filesize(_fileofchar);
  close(_fileofchar);
  assign(_file,fnm);
  reset(_file);
  for i:=1 to sz do
   begin
    read(_file,ch);
    loadfromfile:=loadfromfile+ch;
   end;
  close(_file);
 end;
 function writetofile(fnm,msg:ansistring):boolean;
 begin
  if not createfile(fnm) then
   exit(false);
  assign(_file,fnm);
  rewrite(_file);
  write(_file,msg);
  close(_file);
  exit(true);
 end;
 function copyfile(fnmfrom,fnmto:ansistring):boolean;
 begin
  if not fileexist(fnmfrom) or createfile(fnmto) or not writetofile(fnmto,loadfromfile(fnmfrom)) then
   exit(false);
  exit(true);
 end;
 function movefile(fnmfrom,fnmto:ansistring):boolean;
 begin
  if not copyfile(fnmfrom,fnmto) or not destroyfile(fnmfrom) then
   exit(false);
  exit(true);
 end;
end.
