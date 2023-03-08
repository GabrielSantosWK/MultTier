unit ServerMethods.Pessoa;

interface

uses System.SysUtils, System.Classes, System.JSON,
  DataSnap.DSProviderDataModuleAdapter, DataSetConverter4D,
  DataSetConverter4D.Impl,Datasnap.DSHTTPWebBroker,Data.DBXPlatform,
  DataSnap.DSServer, DataSnap.DSAuth, System.Types,
  Model.DAO.Pessoa, Model.DAO.Endereco;

type
  TServerMethodsPessoa = class(TDSServerModule)
  private

  public
    function Pessoa(const AId:Integer):TJSONValue;
    function AcceptPessoa(const AId:Integer):TJSONObject;
    function UpdatePessoa:TJSONObject;
    function CancelPessoa(const AId:Integer):TJSONObject;

    function EnderecoPessoa(const AId:Integer):TJSONValue;

    function Endereco(const AId:Integer):TJSONValue;
    function AcceptEndereco(const AId:Integer):TJSONObject;
    function UpdateEndereco:TJSONObject;
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}


uses System.StrUtils;

{ TServerMethodsPessoa }

function TServerMethodsPessoa.AcceptEndereco(const AId: Integer): TJSONObject;
var
  LBody:TJSONObject;
  LDaoEndereco:TmodelDAOEndereco;
begin
  LBody := TJSONObject.ParseJSONValue(GetDataSnapWebModule.Request.Content) as TJSONObject;
  LDaoEndereco := TmodelDAOEndereco.Create;
  try
    Result := LDaoEndereco.Put(AId,LBody);
  finally
    LBody.Free;
    LDaoEndereco.Free;
  end;
end;

function TServerMethodsPessoa.AcceptPessoa(const AId:Integer): TJSONObject;
var
  LBody:TJSONObject;
  LDaoPessoa:TModelDAOPessoa;
begin
  LBody := TJSONObject.ParseJSONValue(GetDataSnapWebModule.Request.Content) as TJSONObject;
  LDaoPessoa := TModelDAOPessoa.Create;
  try
    Result := LDaoPessoa.Put(AId,LBody);
  finally
    LBody.Free;
    LDaoPessoa.Free;
  end;
end;

function TServerMethodsPessoa.CancelPessoa(const AId:Integer): TJSONObject;
var
  LDaoPessoa:TModelDAOPessoa;
begin
  LDaoPessoa := TModelDAOPessoa.Create;
  try
    Result := LDaoPessoa.Delete(AId);
  finally
    LDaoPessoa.Free;
  end;
end;

function TServerMethodsPessoa.Endereco(const AId: Integer): TJSONValue;
var
  LDaoEndereco:TmodelDAOEndereco;
begin
  LDaoEndereco := TmodelDAOEndereco.Create;
  try
    Result := LDaoEndereco.Get(AId);
  finally
    LDaoEndereco.Free;
  end;
end;

function TServerMethodsPessoa.EnderecoPessoa(const AId: Integer): TJSONValue;
var
  LDaoEndereco:TmodelDAOEndereco;
begin
  LDaoEndereco := TmodelDAOEndereco.Create;
  try
    Result := LDaoEndereco.GetEnderecoByPessoa(AId);
  finally
    LDaoEndereco.Free;
  end;
end;

function TServerMethodsPessoa.Pessoa(const AId: Integer): TJSONValue;
var
  LQueryFields:TStrings;
  LDaoPessoa:TModelDAOPessoa;
begin
  //Modelo a seguir
  LQueryFields := GetDataSnapWebModule.Request.QueryFields;
  LDaoPessoa := TModelDAOPessoa.Create;
  try
    LDaoPessoa.SetQueryFields(LQueryFields);
    Result := LDaoPessoa.Get(AId);
  finally
    LDaoPessoa.Free;
  end;
end;

function TServerMethodsPessoa.UpdateEndereco: TJSONObject;
var
  LBody:TJSONObject;
  LDaoEndereco:TmodelDAOEndereco;
begin
  LDaoEndereco := TmodelDAOEndereco.Create;
  LBody := TJSONObject.ParseJSONValue(GetDataSnapWebModule.Request.Content) as TJSONObject;
  try
    Result := LDaoEndereco.Post(LBody);
  finally
    LDaoEndereco.Free;
    LBody.Free;
  end;
end;

function TServerMethodsPessoa.UpdatePessoa: TJSONObject;
var
  LBody:TJSONObject;
  LDaoPessoa:TModelDAOPessoa;
begin
  LBody := TJSONObject.ParseJSONValue(GetDataSnapWebModule.Request.Content) as TJSONObject;
  LDaoPessoa := TModelDAOPessoa.Create;
  try
    Result := LDaoPessoa.Post(LBody);
  finally
    LDaoPessoa.Free;
  end;
end;

end.
