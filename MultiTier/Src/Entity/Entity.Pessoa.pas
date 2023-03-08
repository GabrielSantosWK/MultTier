unit Entity.Pessoa;

interface

uses
  System.Generics.Collections,
  Entity.Endereco.Integracao,
  System.SysUtils,
  System.JSON, Entity.Endereco;

type
  TEntityPessoa = class
  private
    FNatureza: SmallInt;
    FID: Integer;
    FDataRegistro: TDateTime;
    FDocumento: string;
    FPrimeiroNome: string;
    FSegundoNome: string;
    FListEndereco: TObjectList<TEntityEndereco>;
    procedure SetID(const Value: Integer);
    procedure SetNatureza(const Value: SmallInt);
    procedure SetDataRegistro(const Value: TDateTime);
    procedure SetDocumento(const Value: string);
    procedure SetPrimeiroNome(const Value: string);
    procedure SetSegundoNome(const Value: string);
    procedure SetListEndereco(const Value: TObjectList<TEntityEndereco>);
  public
    constructor Create();
    destructor Destroy();override;
    class function New:TEntityPessoa;
    property ID: Integer read FID write SetID;
    property Natureza: SmallInt read FNatureza write SetNatureza;
    property Documento: string read FDocumento write SetDocumento;
    property PrimeiroNome: string read FPrimeiroNome write SetPrimeiroNome;
    property SegundoNome: string read FSegundoNome write SetSegundoNome;
    property DataRegistro: TDateTime read FDataRegistro write SetDataRegistro;
    property ListEndereco: TObjectList<TEntityEndereco> read FListEndereco write SetListEndereco;
    function BindJsonToClass(AJSONObject:TJSONObject):TEntityPessoa;
    function BindClassToJson:TJSONObject;
    function BindClassToJsonString:String;
  end;

implementation

{ TEntityPessoa }

function TEntityPessoa.BindClassToJson: TJSONObject;
var
  LJsonArrayEndereco:TJSONArray;
  I: Integer;
begin
  Result := TJSONObject.Create;
  Result.AddPair('idpessoa',FID);
  Result.AddPair('flnatureza',FNatureza);
  Result.AddPair('dsdocumento',FDocumento);
  Result.AddPair('nmprimeiro',FPrimeiroNome);
  Result.AddPair('nmsegundo',FSegundoNome);
  Result.AddPair('dtregistro',FDataRegistro);
  LJsonArrayEndereco := TJSONArray.Create;
  for I := 0 to Pred(FListEndereco.Count) do
  begin
    LJsonArrayEndereco.Add(FListEndereco[i].BindClassToJson);
  end;
  Result.AddPair('endereco',LJsonArrayEndereco);
end;

function TEntityPessoa.BindClassToJsonString:String;
var
  LJson:TJSONObject;
begin
  LJson := BindClassToJson;
  try
    Result := LJson.ToString;
  finally
    LJson.Free;
  end;
end;

function  TEntityPessoa.BindJsonToClass(AJSONObject: TJSONObject):TEntityPessoa;
var
  LDate:string;
  LJsonArrayEndereco:TJSONArray;
  I: Integer;
begin
  Result := Self;
  FListEndereco.Clear;
  AJSONObject.TryGetValue<Integer>('idpessoa',FID);
  AJSONObject.TryGetValue<SmallInt>('flnatureza',FNatureza);
  AJSONObject.TryGetValue<String>('dsdocumento',FDocumento);
  AJSONObject.TryGetValue<String>('nmprimeiro',FPrimeiroNome);
  AJSONObject.TryGetValue<String>('nmsegundo',FSegundoNome);
  if AJSONObject.TryGetValue<String>('dtregistro',LDate) then
  begin
    if LDate.IsEmpty then Exit;
    TryStrToDate(LDate,FDataRegistro);
  end;
  if AJSONObject.TryGetValue<TJSONArray>('endereco',LJsonArrayEndereco) then
  begin
    for I := 0 to Pred(LJsonArrayEndereco.Count) do
    begin
      ListEndereco.Add(TEntityEndereco.New.BindJsonToClass(LJsonArrayEndereco.Items[i] as TJSONObject));
    end;
  end;
end;

constructor TEntityPessoa.Create;
begin
  FListEndereco := TObjectList<TEntityEndereco>.Create;
end;

destructor TEntityPessoa.Destroy;
begin
  FListEndereco.Clear;
  FListEndereco.Free;
  inherited;
end;

class function TEntityPessoa.New: TEntityPessoa;
begin
  Result := TEntityPessoa.Create;
end;

procedure TEntityPessoa.SetDataRegistro(const Value: TDateTime);
begin
  FDataRegistro := Value;
end;

procedure TEntityPessoa.SetDocumento(const Value: string);
begin
  FDocumento := Value;
end;


procedure TEntityPessoa.SetID(const Value: Integer);
begin
  FID := Value;
end;

procedure TEntityPessoa.SetListEndereco(const Value:TObjectList<TEntityEndereco>);
begin
  FListEndereco := Value;
end;

procedure TEntityPessoa.SetNatureza(const Value: SmallInt);
begin
  FNatureza := Value;
end;

procedure TEntityPessoa.SetPrimeiroNome(const Value: string);
begin
  FPrimeiroNome := Value;
end;

procedure TEntityPessoa.SetSegundoNome(const Value: string);
begin
  FSegundoNome := Value;
end;

end.
