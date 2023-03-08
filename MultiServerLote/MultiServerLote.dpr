program MultiServerLote;
{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Types,
  IPPeerServer,
  IPPeerAPI,
  IdHTTPWebBrokerBridge,
  Web.WebReq,
  Web.WebBroker,
  Datasnap.DSSession,
  ServerMethods.Lote in 'ServerMethods.Lote.pas' {ServerMethodsLote: TDSServerModule},
  ServerContainer in 'ServerContainer.pas' {ServerContainer1: TDataModule},
  WebModule in 'WebModule.pas' {WebModule1: TWebModule},
  ServerConst in 'ServerConst.pas',
  Model.Connection in '..\MultiTierServer\Model\Connection\Model.Connection.pas',
  Model.DAO.Endereco in '..\MultiTierServer\Model\DAO\Model.DAO.Endereco.pas',
  Model.DAO.Pessoa in '..\MultiTierServer\Model\DAO\Model.DAO.Pessoa.pas',
  DataSetConverter4D.Helper in '..\MultiTierServer\Model\Lib\DataSetConverter4D.Helper.pas',
  DataSetConverter4D.Impl in '..\MultiTierServer\Model\Lib\DataSetConverter4D.Impl.pas',
  DataSetConverter4D in '..\MultiTierServer\Model\Lib\DataSetConverter4D.pas',
  DataSetConverter4D.Util in '..\MultiTierServer\Model\Lib\DataSetConverter4D.Util.pas',
  Model.Format.Result in '..\MultiTierServer\Model\Format\Model.Format.Result.pas',
  Bird.Socket.Connection in '..\MultiTierServer\Model\Lib\Bird.Socket.Connection.pas',
  Bird.Socket.Consts in '..\MultiTierServer\Model\Lib\Bird.Socket.Consts.pas',
  Bird.Socket.Helpers in '..\MultiTierServer\Model\Lib\Bird.Socket.Helpers.pas',
  Bird.Socket in '..\MultiTierServer\Model\Lib\Bird.Socket.pas',
  Bird.Socket.Server in '..\MultiTierServer\Model\Lib\Bird.Socket.Server.pas',
  Bird.Socket.Types in '..\MultiTierServer\Model\Lib\Bird.Socket.Types.pas',
  Model.Socket in 'Src\Model\Model.Socket.pas';

{$R *.res}

procedure TerminateThreads;
begin
  if TDSSessionManager.Instance <> nil then
    TDSSessionManager.Instance.TerminateAllSessions;
end;

function BindPort(APort: Integer): Boolean;
var
  LTestServer: IIPTestServer;
begin
  Result := True;
  try
    LTestServer := PeerFactory.CreatePeer('', IIPTestServer) as IIPTestServer;
    LTestServer.TestOpenPort(APort, nil);
  except
    Result := False;
  end;
end;

function CheckPort(APort: Integer): Integer;
begin
  if BindPort(APort) then
    Result := APort
  else
    Result := 0;
end;

procedure SetPort(const AServer: TIdHTTPWebBrokerBridge; APort: String);
begin
  if not AServer.Active then
  begin
    APort := APort.Replace(cCommandSetPort, '').Trim;
    if CheckPort(APort.ToInteger) > 0 then
    begin
      AServer.DefaultPort := APort.ToInteger;
      Writeln(Format(sPortSet, [APort]));
    end
    else
      Writeln(Format(sPortInUse, [APort]));
  end
  else
    Writeln(sServerRunning);
  Write(cArrow);
end;

procedure StartServer(const AServer: TIdHTTPWebBrokerBridge);
begin
  if not AServer.Active then
  begin
    if CheckPort(AServer.DefaultPort) > 0 then
    begin
      Writeln(Format(sStartingServer, [AServer.DefaultPort]));
      AServer.Bindings.Clear;
      AServer.Active := True;
    end
    else
      Writeln(Format(sPortInUse, [AServer.DefaultPort.ToString]));
  end
  else
    Writeln(sServerRunning);
  Write(cArrow);
end;

procedure StopServer(const AServer: TIdHTTPWebBrokerBridge);
begin
  if AServer.Active then
  begin
    Writeln(sStoppingServer);
    TerminateThreads;
    AServer.Active := False;
    AServer.Bindings.Clear;
    Writeln(sServerStopped);
  end
  else
    Writeln(sServerNotRunning);
  Write(cArrow);
end;

procedure WriteCommands;
begin
  Writeln(sCommands);
  Write(cArrow);
end;

procedure WriteStatus(const AServer: TIdHTTPWebBrokerBridge);
begin
  Writeln(sIndyVersion + AServer.SessionList.Version);
  Writeln(sActive + AServer.Active.ToString(TUseBoolStrs.True));
  Writeln(sPort + AServer.DefaultPort.ToString);
  Writeln(sSessionID + AServer.SessionIDCookieName);
  Write(cArrow);
end;

procedure RunServer(APort: Integer);
var
  LServer: TIdHTTPWebBrokerBridge;
  LResponse: string;
begin
  WriteCommands;
  LServer := TIdHTTPWebBrokerBridge.Create(nil);
  try
    LServer.DefaultPort := APort;
    while True do
    begin
      Readln(LResponse);
      LResponse := LowerCase(LResponse);
      if LResponse.StartsWith(cCommandSetPort) then
        SetPort(LServer, LResponse)
      else if sametext(LResponse, cCommandStart) then
        StartServer(LServer)
      else if sametext(LResponse, cCommandStatus) then
        WriteStatus(LServer)
      else if sametext(LResponse, cCommandStop) then
        StopServer(LServer)
      else if sametext(LResponse, cCommandHelp) then
        WriteCommands
      else if sametext(LResponse, cCommandExit) then
        if LServer.Active then
        begin
          StopServer(LServer);
          break
        end
        else
          break
      else
      begin
        Writeln(sInvalidCommand);
        Write(cArrow);
      end;
    end;
    TerminateThreads();
  finally
    LServer.Free;
  end;
end;

begin
  try
  if WebRequestHandler <> nil then
    WebRequestHandler.WebModuleClass := WebModuleClass;
    RunServer(8081);
    TModelSocket.GetInstance.Socket.Start;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end
end.
