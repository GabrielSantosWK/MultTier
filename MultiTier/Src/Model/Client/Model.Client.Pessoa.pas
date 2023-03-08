unit Model.Client.Pessoa;

interface

uses
  Model.Client,
  System.JSON,
  System.SysUtils,
  System.Generics.Collections,
  Entity.Pessoa;
  type
  TPagination = record
    Count:Integer;
    Limit:Integer;
    Offset:Integer;
  end;
  type
  TModelClientPessoa = class(TModelClient)
  private
    FList:TObjectList<TEntityPessoa>;
    FPagination:TPagination;
  public
    constructor Create();override;
    destructor Destroy(); override;
    function Get:TModelClientPessoa;
    function Post(AEntity:TEntityPessoa):TModelClientPessoa;
    function Put(AEntity:TEntityPessoa):TModelClientPessoa;
    function Delete(AEntity:TEntityPessoa):TModelClientPessoa;
    function List:TObjectList<TEntityPessoa>;
    function Pagination:TPagination;
  end;

implementation

{ TModelClientPessoa }

constructor TModelClientPessoa.Create;
begin
  Resource('TServerMethodsPessoa/pessoa');
  FList := TObjectList<TEntityPessoa>.Create;
  inherited;
end;

function TModelClientPessoa.Delete(AEntity: TEntityPessoa): TModelClientPessoa;
var
  LJsonObject:TJSONObject;
begin
  Result := Self;
  LJsonObject := Self.DeleteApi(AEntity.ID.ToString);
  LJsonObject.Free;
end;

destructor TModelClientPessoa.Destroy;
begin
  FList.Free;
  inherited;
end;

function TModelClientPessoa.Get:TModelClientPessoa;
var
  LJsonResponse:TJSONObject;
  LJSONArrayList:TJSONArray;
  I: Integer;
begin
  Result := Self;
  FList.Clear;
  LJsonResponse := Self.GetApi;
  try
    if not (LJsonResponse.TryGetValue<TJSONArray>('Data',LJSONArrayList)) then Exit;
    for I := Pred(LJSONArrayList.Count) downto 0 do
      FList.Add(TEntityPessoa.New.BindJsonToClass(LJSONArrayList.Items[i] as TJSONObject));
    LJsonResponse.TryGetValue<Integer>('Count',FPagination.Count);
    LJsonResponse.TryGetValue<Integer>('Limit',FPagination.Limit);
    LJsonResponse.TryGetValue<Integer>('Offset',FPagination.Offset);
  finally
    LJsonResponse.Free;
  end;
end;

function TModelClientPessoa.List: TObjectList<TEntityPessoa>;
begin
  Result := FList;
end;

function TModelClientPessoa.Pagination: TPagination;
begin
  Result := FPagination;
end;

function TModelClientPessoa.Post(AEntity: TEntityPessoa): TModelClientPessoa;
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

function TModelClientPessoa.Put(AEntity: TEntityPessoa): TModelClientPessoa;
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
