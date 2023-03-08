unit Model.Socket;

interface

uses
  Bird.Socket;

type
  TModelSocket = class
  private
    class var FInstance: TModelSocket;
  var
    FSocket: TBirdSocket;
    FBird:TBirdSocketConnection;
  public
    class function GetInstance: TModelSocket;
    constructor Create();
    destructor Destroy(); override;
    function Socket:TBirdSocket;
    function Bird:TBirdSocketConnection;
  end;

implementation

{ TModelSocket }

function TModelSocket.Bird: TBirdSocketConnection;
begin
  Result := FBird;
end;

constructor TModelSocket.Create;
begin
  FBird := nil;
  FSocket := TBirdSocket.Create(8082);
  FSocket.AddEventListener(
      TEventType.CONNECT,
      procedure(const ABird:TBirdSocketConnection)
      var
        LMessege:string;
      begin
        FBird := ABird;
      end);
  FSocket.AddEventListener(
      TEventType.DISCONNECT,
      procedure(const ABird:TBirdSocketConnection)
      var
        LMessege:string;
      begin
        FBird := nil;
      end);
  FSocket.AddEventListener(
      TEventType.EXECUTE,
      procedure(const ABird:TBirdSocketConnection)
      var
        LMessege:string;
      begin

      end);
  //FSocket.Start;
end;

destructor TModelSocket.Destroy;
begin
  FSocket.Free;
  inherited;
end;

class function TModelSocket.GetInstance: TModelSocket;
begin
  Result := FInstance;
end;

function TModelSocket.Socket: TBirdSocket;
begin
  Result := FSocket;
end;

initialization
  TModelSocket.FInstance := TModelSocket.Create;
finalization
  TModelSocket.FInstance.Free;
end.
