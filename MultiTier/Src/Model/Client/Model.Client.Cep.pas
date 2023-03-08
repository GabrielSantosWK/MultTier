unit Model.Client.Cep;

interface

uses
  Entity.Cep,
  Model.Client,
  System.JSON;

type
  TModelClientCep = class(TModelClient)
  private
    FEntity:TEntityCep;
  public
    constructor Create(); override;
    destructor Destroy(); override;
    function Get(const ACep: string):TModelClientCep;
    function Entity: TEntityCep;
  end;

implementation

{ TModelClientCep }

constructor TModelClientCep.Create;
begin
  inherited;
  FEntity := TEntityCep.Create;
  UrlBase('https://viacep.com.br/ws/');
end;

destructor TModelClientCep.Destroy;
begin
  FEntity.Free;
  inherited;
end;

function TModelClientCep.Entity: TEntityCep;
begin
  Result := FEntity;
end;

function TModelClientCep.Get(const ACep: string): TModelClientCep;
var
  LJsonObject: TJSONObject;
begin
  Result := Self;
  Resource(ACep + '/json/');
  LJsonObject := Self.GetApi;
  try
    FEntity.BindJsonToClass(LJsonObject);
  finally
    LJsonObject.Free;
  end;
end;

end.
