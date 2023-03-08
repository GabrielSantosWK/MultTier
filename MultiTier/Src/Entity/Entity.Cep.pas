unit Entity.Cep;

interface

uses
  System.JSON;

type
  TEntityCep = class
  private
    FLogradouro: string;
    FIbge: string;
    FBairro: string;
    FDDD: string;
    FUf: string;
    FCep: string;
    FSiafi: string;
    FLocalidade: string;
    FComplemento: string;
    FGia: string;
    procedure SetBairro(const Value: string);
    procedure SetCep(const Value: string);
    procedure SetComplemento(const Value: string);
    procedure SetDDD(const Value: string);
    procedure SetGia(const Value: string);
    procedure SetIbge(const Value: string);
    procedure SetLocalidade(const Value: string);
    procedure SetLogradouro(const Value: string);
    procedure SetSiafi(const Value: string);
    procedure SetUf(const Value: string);
  public
    constructor Create();
    destructor Destroy(); override;
    class function New:TEntityCep;
    property Cep: string read FCep write SetCep;
    property Logradouro: string read FLogradouro write SetLogradouro;
    property Complemento: string read FComplemento write SetComplemento;
    property Bairro: string read FBairro write SetBairro;
    property Localidade: string read FLocalidade write SetLocalidade;
    property Uf: string read FUf write SetUf;
    property Ibge: string read FIbge write SetIbge;
    property Gia: string read FGia write SetGia;
    property DDD: string read FDDD write SetDDD;
    property Siafi: string read FSiafi write SetSiafi;
    function BindJsonToClass(AJSONObject: TJSONObject):TEntityCep;
  end;

implementation

{ TEntityCep }

function TEntityCep.BindJsonToClass(AJSONObject: TJSONObject): TEntityCep;
begin
  Result := Self;
  AJSONObject.TryGetValue<string>('cep',FCep);
  AJSONObject.TryGetValue<string>('logradouro',FLogradouro);
  AJSONObject.TryGetValue<String>('complemento',FComplemento);
  AJSONObject.TryGetValue<String>('bairro',FBairro);
  AJSONObject.TryGetValue<String>('localidade',FLocalidade);
  AJSONObject.TryGetValue<String>('uf',FUf);
  AJSONObject.TryGetValue<String>('ibge',FIbge);
  AJSONObject.TryGetValue<String>('gia',FGia);
  AJSONObject.TryGetValue<String>('ddd',FDDD);
  AJSONObject.TryGetValue<String>('siafi',FSiafi);
end;

constructor TEntityCep.Create;
begin

end;

destructor TEntityCep.Destroy;
begin

  inherited;
end;

class function TEntityCep.New: TEntityCep;
begin
  Result := Self.Create;
end;

procedure TEntityCep.SetBairro(const Value: string);
begin
  FBairro := Value;
end;

procedure TEntityCep.SetCep(const Value: string);
begin
  FCep := Value;
end;

procedure TEntityCep.SetComplemento(const Value: string);
begin
  FComplemento := Value;
end;

procedure TEntityCep.SetDDD(const Value: string);
begin
  FDDD := Value;
end;

procedure TEntityCep.SetGia(const Value: string);
begin
  FGia := Value;
end;

procedure TEntityCep.SetIbge(const Value: string);
begin
  FIbge := Value;
end;

procedure TEntityCep.SetLocalidade(const Value: string);
begin
  FLocalidade := Value;
end;

procedure TEntityCep.SetLogradouro(const Value: string);
begin
  FLogradouro := Value;
end;

procedure TEntityCep.SetSiafi(const Value: string);
begin
  FSiafi := Value;
end;

procedure TEntityCep.SetUf(const Value: string);
begin
  FUf := Value;
end;

end.
