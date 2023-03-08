unit Entity.Endereco;

interface

uses
  Entity.Endereco.Integracao,
  System.JSON;

type
  TEntityEndereco = class
  private
    FCep: string;
    FID: Integer;
    FIdPessoa: Integer;
    FIntegracao: TEntityEnderecoIntegracao;
    procedure SetCep(const Value: string);
    procedure SetID(const Value: Integer);
    procedure SetIdPessoa(const Value: Integer);
    procedure SetIntegracao(const Value: TEntityEnderecoIntegracao);
  public
    constructor Create();
    destructor Destroy();override;
    class function New:TEntityEndereco;
    property ID: Integer read FID write SetID;
    property IdPessoa: Integer read FIdPessoa write SetIdPessoa;
    property Cep: string read FCep write SetCep;
    property Integracao:TEntityEnderecoIntegracao read FIntegracao write SetIntegracao;
    function BindClassToJson:TJSONObject;
    function BindJsonToClass(AJSONObject: TJSONObject):TEntityEndereco;
    function CopyEntity(AEntity:TEntityEndereco):TEntityEndereco;
  end;

implementation

uses
  System.SysUtils;

{ TEntityEndereco }

function TEntityEndereco.BindClassToJson: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('idendereco',FID);
  Result.AddPair('idpessoa',FIdPessoa);
  Result.AddPair('dscep',FCep);
  Result.AddPair('dsuf',FIntegracao.UF);
  Result.AddPair('nmcidade',FIntegracao.Cidade);
  Result.AddPair('nmbairro',FIntegracao.Bairro);
  Result.AddPair('nmlogradouro',FIntegracao.Logradouro);
  Result.AddPair('dscomplemento',FIntegracao.Complemento);
end;

function TEntityEndereco.BindJsonToClass(AJSONObject: TJSONObject):TEntityEndereco;
var
  LDate:string;
begin
  Result := Self;
  if not Assigned(FIntegracao) then
    FIntegracao := TEntityEnderecoIntegracao.Create;
  AJSONObject.TryGetValue<Integer>('idendereco',FID);
  FIntegracao.UF := AJSONObject.GetValue('dsuf').Value;
  FIntegracao.Cidade := AJSONObject.GetValue('nmcidade').Value;
  FIntegracao.Bairro := AJSONObject.GetValue('nmbairro').Value;
  FIntegracao.Logradouro := AJSONObject.GetValue('nmlogradouro').Value;
  FIntegracao.Complemento := AJSONObject.GetValue('dscomplemento').Value;
  FIdPessoa := AJSONObject.GetValue('idpessoa').Value.ToInteger();
  FCep := AJSONObject.GetValue('dscep').Value;
end;

function TEntityEndereco.CopyEntity(AEntity: TEntityEndereco): TEntityEndereco;
begin
  Result := Self;

  ID := AEntity.ID;
  Integracao.UF := AEntity.Integracao.UF;
  Integracao.Cidade := AEntity.Integracao.Cidade;
  Integracao.Bairro := AEntity.Integracao.Bairro;
  Integracao.Logradouro := AEntity.Integracao.Logradouro;
  Integracao.Complemento := AEntity.Integracao.Complemento;
  IdPessoa := AEntity.IdPessoa;
  Cep := AEntity.Cep;
end;

constructor TEntityEndereco.Create;
begin
  FIntegracao := TEntityEnderecoIntegracao.Create;
end;

destructor TEntityEndereco.Destroy;
begin
  FIntegracao.Free;
  inherited;
end;

class function TEntityEndereco.New: TEntityEndereco;
begin
  Result := Self.Create;
end;

procedure TEntityEndereco.SetCep(const Value: string);
begin
  FCep := Value;
end;

procedure TEntityEndereco.SetID(const Value: Integer);
begin
  FID := Value;
end;

procedure TEntityEndereco.SetIdPessoa(const Value: Integer);
begin
  FIdPessoa := Value;
end;

procedure TEntityEndereco.SetIntegracao(const Value: TEntityEnderecoIntegracao);
begin
  FIntegracao := Value;
end;

end.
