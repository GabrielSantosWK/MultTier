unit Model.Connection;

interface
  uses FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  Data.DB, FireDAC.Comp.Client,FireDAC.Phys.PGDef,FireDAC.Phys.IBBase,
  FireDAC.Phys.PG,System.IniFiles,System.SysUtils;
  type
  TModelConnection = class
    private
    class var FInstance:TModelConnection;
    var
    FConnection:TFDConnection;
    FDPhysPGDriverLink: TFDPhysPgDriverLink;
    public
    class function GetInstance:TModelConnection;
    constructor Create();
    destructor Destroy();override;
    function Connection:TFDConnection;
  end;
implementation

uses
  Web.WebBroker;

{ TModelConnection }

function TModelConnection.Connection: TFDConnection;
begin
  Result := FConnection;
end;

constructor TModelConnection.Create;
var
  LPath:string;
  LIniFile:TIniFile;
begin
  LPath := GetCurrentDir()+'\Config.Ini';
  LIniFile := TIniFile.Create(LPath);
  try
    FDPhysPGDriverLink := TFDPhysPgDriverLink.Create(Application);
    FConnection := TFDConnection.Create(Application);
    FConnection.Connected := False;
    FConnection.Params.Clear;
    FConnection.Params.Values['DriverID'] := 'PG';
    FConnection.Params.Values['Server'] := '127.0.0.1';
    FConnection.Params.Values['Database'] := LIniFile.ReadString('Config', 'Database', '');
    FConnection.Params.Values['User_name'] := 'postgres';
    FConnection.Params.Values['Password'] := LIniFile.ReadString('Config', 'Password', '');;
    FConnection.Connected := True;
  finally
    LIniFile.Free;
  end;
end;

destructor TModelConnection.Destroy;
begin
  FDPhysPGDriverLink.Free;
  FConnection.Free;
  inherited;
end;

class function TModelConnection.GetInstance: TModelConnection;
begin
  Result := FInstance;
end;
initialization
  TModelConnection.FInstance := TModelConnection.Create;
finalization
  if Assigned(TModelConnection.FInstance) then
    TModelConnection.FInstance.Free;
end.
