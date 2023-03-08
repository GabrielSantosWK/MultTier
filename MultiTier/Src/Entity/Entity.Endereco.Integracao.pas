unit Entity.Endereco.Integracao;

interface

type
  TEntityEnderecoIntegracao = class
  private
    FLogradouro: string;
    FUF: string;
    FId: string;
    FComplemento: string;
    FCidade: string;
    FBairro: string;
    procedure SetCidade(const Value: string);
    procedure SetComplemento(const Value: string);
    procedure SetId(const Value: string);
    procedure SetLogradouro(const Value: string);
    procedure SetUF(const Value: string);
    procedure SetBairro(const Value: string);
  public
    constructor Create();
    destructor Destroy();override;
    property Id: string read FId write SetId;
    property UF: string read FUF write SetUF;
    property Cidade: string read FCidade write SetCidade;
    property Bairro:string read FBairro write SetBairro;
    property Logradouro: string read FLogradouro write SetLogradouro;
    property Complemento: string read FComplemento write SetComplemento;
  end;

implementation

{ TEntityEndereco }

constructor TEntityEnderecoIntegracao.Create;
begin
  UF := 'PR';
  Cidade := 'Cianorte';
  Logradouro := 'Rua Parecis 662';
  Complemento := 'Casa dos fundos';

end;

destructor TEntityEnderecoIntegracao.Destroy;
begin

  inherited;
end;

procedure TEntityEnderecoIntegracao.SetBairro(const Value: string);
begin
  FBairro := Value;
end;

procedure TEntityEnderecoIntegracao.SetCidade(const Value: string);
begin
  FCidade := Value;
end;

procedure TEntityEnderecoIntegracao.SetComplemento(const Value: string);
begin
  FComplemento := Value;
end;

procedure TEntityEnderecoIntegracao.SetId(const Value: string);
begin
  FId := Value;
end;

procedure TEntityEnderecoIntegracao.SetLogradouro(const Value: string);
begin
  FLogradouro := Value;
end;

procedure TEntityEnderecoIntegracao.SetUF(const Value: string);
begin
  FUF := Value;
end;

end.
