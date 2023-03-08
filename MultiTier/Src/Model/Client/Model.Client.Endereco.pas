unit Model.Client.Endereco;

interface

uses
  Entity.Endereco,
  Model.Client,
  System.SysUtils,
  System.JSON,
  System.Generics.Collections;

type
  TModelEndereco = class(TModelClient)
  private
    FList:TObjectList<TEntityEndereco>;
  public
    constructor Create();override;
    destructor Destroy(); override;
    function Get:TModelEndereco;
    function GetByPessoa(const APessoa:string):TModelEndereco;
    function Post(AEntity:TEntityEndereco):TModelEndereco;
    function Put(AEntity:TEntityEndereco):TModelEndereco;
    function Delete(AEntity:TEntityEndereco):TModelEndereco;
    function List:TObjectList<TEntityEndereco>;
  end;

implementation

{ TModelEndereco }

constructor TModelEndereco.Create;
begin
  inherited;
  FList := TObjectList<TEntityEndereco>.Create;
  Resource('TServerMethodsPessoa/endereco');
end;

function TModelEndereco.Delete(AEntity: TEntityEndereco): TModelEndereco;
begin

end;

destructor TModelEndereco.Destroy;
begin
  FList.Free;
  inherited;
end;

function TModelEndereco.Get: TModelEndereco;
var
  LJsonResponse:TJSONObject;
  LJSONArrayList:TJSONArray;
  I: Integer;
begin
  Result := Self;
  Resource('TServerMethodsPessoa/endereco');
  FList.Clear;
  LJsonResponse := Self.GetApi;
  try
    if not (LJsonResponse.TryGetValue<TJSONArray>('Data',LJSONArrayList)) then Exit;
    for I := Pred(LJSONArrayList.Count) downto 0 do
      FList.Add(TEntityEndereco.New.BindJsonToClass(LJSONArrayList.Items[i] as TJSONObject));
  finally
    LJsonResponse.Free;
  end;
end;

function TModelEndereco.GetByPessoa(const APessoa: string): TModelEndereco;
var
  LJsonResponse:TJSONObject;
  LJSONArrayList:TJSONArray;
  I: Integer;
begin
  Result := Self;
  Resource('TServerMethodsPessoa/enderecopessoa/'+APessoa);
  FList.Clear;
  LJsonResponse := Self.GetApi;
  try
    if not (LJsonResponse.TryGetValue<TJSONArray>('Data',LJSONArrayList)) then Exit;
    for I := Pred(LJSONArrayList.Count) downto 0 do
      FList.Add(TEntityEndereco.New.BindJsonToClass(LJSONArrayList.Items[i] as TJSONObject));
  finally
    LJsonResponse.Free;
  end;
end;

function TModelEndereco.List: TObjectList<TEntityEndereco>;
begin
  Result := FList;
end;

function TModelEndereco.Post(AEntity: TEntityEndereco): TModelEndereco;
var
  LResult:TJSONObject;
begin
  Result := Self;
  try
    LResult := Self.PostApi(AEntity.BindClassToJson.ToJSON);
  finally
    LResult.Free;
  end;
end;

function TModelEndereco.Put(AEntity: TEntityEndereco): TModelEndereco;
var
  LResult:TJSONObject;
begin
  Result := Self;
  try
    LResult := Self.PutApi(AEntity.ID.ToString,AEntity.BindClassToJson.ToJSON);
  finally
    LResult.Free;
  end;
end;

end.
