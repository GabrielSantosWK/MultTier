unit Model.Client;

interface
uses
  System.JSON,
  REST.Types,
  REST.Client,
  System.Generics.Collections,
  System.SysUtils,
  REST.HttpClient;
type
  TModelClient = class
  private
    FClient: TRestClient;
    FRequest: TRestRequest;
    FResponse: TRestResponse;
    FBaseURL:string;
    FResource:string;
    FID:string;
    FListParams:TDictionary<string,string>;

    function Execute(AJson:TJSONObject = nil):TJSONObject;
    function AddParams: string;overload;
  public
    constructor Create();virtual;
    destructor Destroy();override;
    function AddParams(AField,AValue:string):TModelClient;overload;
    function ClearParams:TModelClient;
  protected
    procedure ID(const AValue:string);
    procedure Resource(AValue:string);
    procedure UrlBase(const AValue:string);
    function PostApi(const ABory:String):TJSONObject;virtual;
    function PutApi(AId,ABory: String): TJSONObject;virtual;
    function DeleteApi(const AId: String): TJSONObject;virtual;
    function GetApi():TJSONObject;overload;virtual;
    function GetApi(const AId:string):TJSONObject;overload;virtual;
  end;

implementation

{ TModelClient }

function TModelClient.AddParams(AField, AValue: string):TModelClient;
begin
  Result := Self;
  FListParams.Add(AField,AValue);
end;

function TModelClient.ClearParams:TModelClient;
begin
  Result := Self;
  FListParams.Clear;
end;

constructor TModelClient.Create;
begin
  FListParams := TDictionary<string,string>.Create;
  FClient := TRestClient.Create(nil);
  FRequest := TRestRequest.Create(nil);
  FResponse := TRestResponse.Create(nil);
  FRequest.Client := FClient;
  FRequest.Response := FResponse;
  FBaseURL := 'http://127.0.0.1:8080/datasnap/rest/';
  FID := EmptyStr;
end;

function TModelClient.DeleteApi(const AId: String): TJSONObject;
begin
  FRequest.Method := rmDELETE;
  ID(AId);
  Result := Execute();
end;

destructor TModelClient.Destroy;
begin
  FClient.Free;
  FRequest.Free;
  FResponse.Free;
  FListParams.Free;
  inherited;
end;

function TModelClient.Execute(AJson:TJSONObject): TJSONObject;
var
  LKeys:string;
begin
  try
    if FResource.IsEmpty then
      raise Exception.Create('Resource não informado!');

    FClient.BaseURL := FBaseURL+FResource+FID+addParams;
    if Assigned(AJson) then
    begin
      FRequest.Body.ClearBody;
      FRequest.Body.Add(AJson);
    end;
    FRequest.Execute;
    Result := TJSONValue.ParseJSONValue(FResponse.Content) as TJSONObject;
  finally
    FID := EmptyStr;
  end;
end;

function TModelClient.GetApi: TJSONObject;
var
  LBoryJSON:TJSONObject;
begin
  FRequest.Method := rmGET;
  Result := Execute;
end;

function TModelClient.GetApi(const AId: string): TJSONObject;
begin

end;

procedure TModelClient.ID(const AValue: string);
begin
  FID := '/'+AValue;
end;

function TModelClient.PostApi(const ABory: String): TJSONObject;
var
  LJsonObject:TJSONObject;
begin
  LJsonObject := TJSONObject.ParseJSONValue(ABory) as TJSONObject;
  try
    FRequest.Method := rmPOST;
    Result := Execute(LJsonObject);
  finally
    LJsonObject.Free;
  end;
end;

function TModelClient.PutApi(AId, ABory: String): TJSONObject;
var
  LJsonObject:TJSONObject;
begin
  LJsonObject := TJSONObject.ParseJSONValue(ABory) as TJSONObject;
  try
    ID(AId);
    FRequest.Method := rmPUT;
    Result := Execute(LJsonObject);
  finally
    LJsonObject.Free;
  end;
end;

procedure TModelClient.Resource(AValue: string);
begin
  FResource := AValue;
end;

procedure TModelClient.UrlBase(const AValue: string);
begin
  FBaseURL := AValue;
end;
function TModelClient.AddParams: string;
var
  LKey:string;
  LCount:Integer;
  LSeparador:string;
begin
  LCount := 0;
  Result := '';
  for Lkey in FListParams.Keys do
  begin
    LSeparador := '?';
    if LCount > 0 then
      LSeparador := '&';
    Result := Result + LSeparador + LKey +'='+ FListParams.Items[LKey];
    Inc(LCount);
  end;
end;
end.
