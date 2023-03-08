unit Model.DAO.Pessoa;

interface
  uses
  System.JSON, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Model.Connection, System.SysUtils,
  Model.DAO.Endereco,  DataSetConverter4D, DataSetConverter4D.Impl,
  System.Classes, Model.Format.Result;
type
  TModelDAOPessoa = class
    private
    FQuery:TFDQuery;
    FDAOEndereco:TmodelDAOEndereco;
    FQueryFields:TStrings;
    public
    constructor Create();
    destructor Destroy();override;
    procedure SetQueryFields(AQueryFields:TStrings);
    function Post(AJsonObject:TJSONObject):TJSONObject;
    function Get(const AId:Integer):TJSONValue;
    function Put(const AId:Integer;AJsonObject:TJSONObject): TJSONObject;
    function Delete(const AId:Integer):TJSONObject;

  end;

implementation

{ TModelDAOPessoa }

constructor TModelDAOPessoa.Create;
begin
  FDAOEndereco := TmodelDAOEndereco.Create;
  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := TModelConnection.GetInstance.Connection;
end;

function TModelDAOPessoa.Delete(const AId: Integer): TJSONObject;
begin
  FQuery.Close;
  FQuery.SQL.Clear;
  FQuery.SQL.Add('SELECT * FROM PESSOA');
  FQuery.SQL.Add('WHERE idpessoa = :idpessoa');
  FQuery.ParamByName('idpessoa').AsInteger := AId;
  FQuery.Open();
  if FQuery.RecordCount <= 0 then
  begin
    Result := TModelFormatResult.ResultError(Format('Pessoa %s não encontrada',[AId.ToString]),404);
  end
  else
  begin
    FQuery.Delete;
    Result := TJSONObject.Create;
  end;
end;

destructor TModelDAOPessoa.Destroy;
begin
  FDAOEndereco.Free;
  FQuery.Free;
  inherited;
end;

function TModelDAOPessoa.Get(const AId: Integer): TJSONValue;
var
  LJsonResponse:TJSONValue;
  LJsonObjectPessoa:TJSONObject;
  LIdPessoa:Integer;
  LQuery:TFDQuery;
  LLimit:string;
  LOffset:string;
  i: Integer;
  LQueryCount:TFDQuery;
begin
  LLimit := '50';
  LOffset := '0';
  for i := 0 to Pred(FQueryFields.Count) do
  begin
    if FQueryFields.Names[i].Equals('limit') then
      LLimit := StrToIntDef(FQueryFields.Values['limit'],0).ToString
    else if FQueryFields.Names[i].Equals('offset') then
      LOffset := StrToIntDef(FQueryFields.Values['offset'],50).ToString;

  end;
  LQuery := TFDQuery.Create(nil);
  LQuery.Connection := TModelConnection.GetInstance.Connection;
  LQueryCount := TFDQuery.Create(nil);
  LQueryCount.Connection := TModelConnection.GetInstance.Connection;

  try
    LQuery.Close;
    LQuery.SQL.Clear;
    LQuery.SQL.Add('SELECT * FROM PESSOA');

    LQueryCount.Close;
    LQueryCount.SQL.Clear;
    LQueryCount.SQL.Add('SELECT COUNT(idpessoa) FROM PESSOA');

    if AId > 0 then
    begin
      LQuery.SQL.Add('WHERE idpessoa = :idpessoa');
      LQuery.ParamByName('idpessoa').AsInteger := AId;

      LQueryCount.SQL.Add('WHERE idpessoa = :idpessoa');
      LQueryCount.ParamByName('idpessoa').AsInteger := AId;

      LQuery.SQL.Add('ORDER BY IDPESSOA');
      LQuery.SQL.Add(Format('limit %s offset %s',[LLimit,LOffset]));
      LQuery.Open();
      LQueryCount.Open();

      if LQuery.RecordCount <= 0 then
      begin
        Result := TModelFormatResult.ResultError('Pessoa não encontrada !',404);
        Exit;
      end;

      LJsonResponse := TConverter.New.DataSet(LQuery).AsJSONObject;
      TJSONObject(LJsonResponse).AddPair('endereco',FDAOEndereco.GetEnderecoByPessoa(LQuery.FieldByName('IDPESSOA').AsInteger));
      Result := TModelFormatResult.ResultItem(TJSONObject(LJsonResponse));
    end
    else
    begin
      LJsonResponse := TJSONArray.Create;
      LQuery.SQL.Add('ORDER BY IDPESSOA');
      LQuery.SQL.Add(Format('limit %s offset %s',[LLimit,LOffset]));
      LQueryCount.Open();
      LQuery.Open();
      LQuery.First;
      while not LQuery.Eof do
      begin
        LJsonObjectPessoa := TConverter.New.DataSet(LQuery).AsJSONObject;
        LJsonObjectPessoa.AddPair('endereco',FDAOEndereco.GetEnderecoByPessoa(LQuery.FieldByName('IDPESSOA').AsInteger));
        TJSONArray(LJsonResponse).Add(LJsonObjectPessoa);
        LQuery.Next;
      end;

      Result := TModelFormatResult.ResultList(TJSONArray(LJsonResponse),LQueryCount.FieldByName('count').AsInteger,LLimit.ToInteger(),LOffset.ToInteger());
    end;
  finally
    LQueryCount.Free;
    LQuery.Free;
  end;
end;

function TModelDAOPessoa.Post(AJsonObject: TJSONObject): TJSONObject;
var
  I: Integer;
  LJsonArrayEndereco:TJSONArray;
  LQuery:TFDQuery;
  LJsonObjectEndereco:TJSONObject;
begin
  LQuery := TFDQuery.Create(nil);
  LQuery.Connection := TModelConnection.GetInstance.Connection;
  try
    FQuery.Close;
    FQuery.SQL.Clear;
    FQuery.SQL.Add('SELECT * FROM PESSOA');
    FQuery.SQL.Add('WHERE 1<>1');
    FQuery.Open();
    AJsonObject.RemovePair('dtregistro');
    AJsonObject.RemovePair('idpessoa');
    AJsonObject.AddPair('dtregistro',FormatDateTime('dd/mm/yyyy',Now));
    FQuery.Append;
    for I := 0 to Pred(AJsonObject.Count) do
    begin
      if AJsonObject.Get(i).JsonString.Value.Equals('endereco') then
        continue;
      FQuery.FieldByName(AJsonObject.Get(i).JsonString.Value).AsString := AJsonObject.GetValue(AJsonObject.Get(i).JsonString.Value).Value;
    end;
    FQuery.Post();
    LQuery.Close;
    LQuery.SQL.Clear;
    LQuery.SQL.Add('select max(idpessoa) from pessoa');
    LQuery.Open();
    AJsonObject.TryGetValue<TJSONArray>('endereco',LJsonArrayEndereco);
    for I := 0 to Pred(LJsonArrayEndereco.Count) do
    begin
      LJsonObjectEndereco :=  LJsonArrayEndereco.Items[i] as TJSONObject;
      LJsonObjectEndereco.RemovePair('idpessoa');
      LJsonObjectEndereco.AddPair('idpessoa',LQuery.FieldByName('max').AsInteger);
      FDAOEndereco.Post(LJsonObjectEndereco);
    end;
    Result := TConverter.New.DataSet(FQuery).AsJSONObject;
  finally
    LQuery.Free;
  end;


end;

function TModelDAOPessoa.Put(const AId: Integer;AJsonObject: TJSONObject): TJSONObject;
var
  LJsonArrayEndereco:TJSONArray;
  LJsonArrayNewEndereco:TJSONArray;
  LJsonResponse:TJSONObject;
  I: Integer;
begin
  FQuery.Close;
  FQuery.SQL.Clear;
  FQuery.SQL.Add('SELECT * FROM PESSOA');
  FQuery.SQL.Add('WHERE idpessoa = :idpessoa');
  FQuery.ParamByName('idpessoa').AsInteger := AId;
  FQuery.Open();
  if FQuery.RecordCount > 0 then
  begin
    FQuery.Edit;
    AJsonObject.RemovePair('dtregistro');
    AJsonObject.RemovePair('idpessoa');
    for I := 0 to Pred(AJsonObject.Count) do
    begin
      if AJsonObject.Get(i).JsonString.Value.Equals('endereco') then
        continue;
      FQuery.FieldByName(AJsonObject.Get(i).JsonString.Value).AsString := AJsonObject.GetValue(AJsonObject.Get(i).JsonString.Value).Value;
    end;
    FQuery.Post;
    LJsonResponse := TConverter.New.DataSet(FQuery).AsJSONObject;
    AJsonObject.TryGetValue<TJSONArray>('endereco',LJsonArrayEndereco);
    LJsonArrayNewEndereco := TJSONArray.Create;
    for I := 0 to Pred(LJsonArrayEndereco.Count) do
    begin
      LJsonArrayNewEndereco.Add(FDAOEndereco.Put((LJsonArrayEndereco.Items[i] as TJSONObject).GetValue('idendereco').Value.ToInteger
       ,LJsonArrayEndereco.Items[i] as TJSONObject));
    end;
    LJsonResponse.AddPair('endereco',LJsonArrayNewEndereco);

    Result := LJsonResponse;
  end
  else
  begin
    Result := TModelFormatResult.ResultError('Pessoa não encontrada!',404);
  end;
end;

procedure TModelDAOPessoa.SetQueryFields(AQueryFields: TStrings);
begin
  FQueryFields := AQueryFields;
end;

end.
