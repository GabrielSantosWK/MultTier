unit Model.DAO.Endereco;

interface
  uses
  DataSetConverter4D,
  DataSetConverter4D.Impl,
  System.JSON,FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  System.SysUtils,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Model.Connection,
  Model.Format.Result;
 type
 TModelDAOEndereco = class
   private
   public
   function Post(AJsonObject:TJSONObject):TJSONObject;
   function Put(const AId:Integer;AJsonObject:TJSONObject):TJSONObject;
   function GetEnderecoByPessoa(const AId: Integer): TJSONArray;
   function Get(const AId: Integer): TJSONValue;
 end;
implementation

uses
  System.Classes;

{ TmodelDAOEndereco }

function TmodelDAOEndereco.Get(const AId: Integer): TJSONValue;
var
  LQuery:TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  LQuery.Connection := TModelConnection.GetInstance.Connection;
  try
    LQuery.Close;
    LQuery.SQL.Clear;
    LQuery.SQL.Add('SELECT * FROM endereco_integracao');
    LQuery.SQL.Add('left join endereco on endereco.idendereco = endereco_integracao.idendereco');
    if AId > 0 then
    begin
      LQuery.SQL.Add('WHERE idpessoa = :idpessoa');
      LQuery.ParamByName('idpessoa').AsInteger := AId;
      LQuery.SQL.Add('ORDER BY endereco_integracao.IDENDERECO');
      LQuery.Open();
      Result := TModelFormatResult.ResultItem(TConverter.New.DataSet(LQuery).AsJSONObject);
    end
    else
    begin
      LQuery.SQL.Add('ORDER BY endereco_integracao.IDENDERECO');
      LQuery.Open();
      Result := TModelFormatResult.ResultList(TConverter.New.DataSet(LQuery).AsJSONArray,0,0,0);
    end;
  finally
    LQuery.Free;
  end;
end;

function TmodelDAOEndereco.GetEnderecoByPessoa(const AId: Integer): TJSONArray;
var
  LQuery:TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  LQuery.Connection := TModelConnection.GetInstance.Connection;
  try
    LQuery.Close;
    LQuery.SQL.Clear;
    LQuery.SQL.Add('SELECT * FROM endereco_integracao');
    LQuery.SQL.Add('left join endereco on endereco.idendereco = endereco_integracao.idendereco');
    if AId > 0 then
    begin
      LQuery.SQL.Add('where endereco.idpessoa = :idpessoa');
      LQuery.ParamByName('idpessoa').AsInteger := AId;
      LQuery.SQL.Add('ORDER BY endereco_integracao.IDENDERECO');
      LQuery.Open();
      Result := TConverter.New.DataSet(LQuery).AsJSONArray;
    end
    else
    begin
      LQuery.SQL.Add('ORDER BY endereco_integracao.IDENDERECO');
      LQuery.Open();
      Result := TConverter.New.DataSet(LQuery).AsJSONArray;
    end;
  finally
    LQuery.Free;
  end;
end;

function TModelDAOEndereco.Post(AJsonObject: TJSONObject): TJSONObject;
var
  LBody:TJSONObject;
  I: Integer;
  LCodigoEndereco:Integer;
  LQuery:TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  LQuery.Connection := TModelConnection.GetInstance.Connection;
  try
    LQuery.Close;
    LQuery.SQL.Clear;
    LQuery.SQL.Add('INSERT INTO ENDERECO (IDPESSOA,DSCEP)');
    LQuery.SQL.Add('VALUES(:IDPESSOA,:DSCEP)');
    LQuery.ParamByName('IDPESSOA').AsInteger := AJsonObject.GetValue('idpessoa').Value.ToInteger();
    LQuery.ParamByName('DSCEP').AsString := AJsonObject.GetValue('dscep').Value;
    LQuery.ExecSQL();

    LQuery.Close;
    LQuery.SQL.Clear;
    LQuery.SQL.Add('select max(idendereco) from endereco e');
    LQuery.Open();

    LCodigoEndereco := LQuery.FieldByName('max').AsInteger;

    LQuery.Close;
    LQuery.SQL.Clear;
    LQuery.SQL.Add('SELECT * FROM endereco_integracao');
    LQuery.SQL.Add('WHERE 1<>1');
    LQuery.Open();

    AJsonObject.RemovePair('idpessoa');
    AJsonObject.RemovePair('dscep');
    AJsonObject.RemovePair('idendereco');
    AJsonObject.AddPair('idendereco',LCodigoEndereco);
    LQuery.Append;
    for I := 0 to Pred(AJsonObject.Count) do
    begin
      LQuery.FieldByName(AJsonObject.Get(i).JsonString.Value).AsString := AJsonObject.GetValue(AJsonObject.Get(i).JsonString.Value).Value;
    end;
    LQuery.Post();
    Result := TConverter.New.DataSet(LQuery).AsJSONObject;
  finally
    LQuery.Free;
  end;
end;

function TmodelDAOEndereco.Put(const AId: Integer; AJsonObject:TJSONObject): TJSONObject;
var
  I: Integer;
  LCodigoEndereco:Integer;
  LQuery:TFDQuery;
  LQueryEndereco:TFDQuery;
begin
  LQueryEndereco := TFDQuery.Create(nil);
  LQueryEndereco.Connection := TModelConnection.GetInstance.Connection;

  LQuery := TFDQuery.Create(nil);
  LQuery.Connection := TModelConnection.GetInstance.Connection;
  try
    LQueryEndereco.Close;
    LQueryEndereco.SQL.Clear;
    LQueryEndereco.SQL.Add('SELECT * FROM endereco_integracao');
    LQueryEndereco.SQL.Add('left join endereco on endereco.idendereco = endereco_integracao.idendereco');
    LQueryEndereco.SQL.Add('where endereco.idendereco = :idendereco');
    LQueryEndereco.ParamByName('idendereco').AsInteger := AId;
    LQueryEndereco.Open();
    if LQueryEndereco.RecordCount > 0 then
    begin
      AJsonObject.RemovePair('idendereco');
      LQueryEndereco.Edit;
      for I := 0 to Pred(AJsonObject.Count) do
      begin
        LQueryEndereco.FieldByName(AJsonObject.Get(i).JsonString.Value).AsString := AJsonObject.GetValue(AJsonObject.Get(i).JsonString.Value).Value;
      end;
      LQueryEndereco.Post;

      LQuery.Close;
      LQuery.SQL.Clear;
      LQuery.SQL.Add('update endereco set dscep = :dscep');
      LQuery.SQL.Add('where idendereco = :idendereco');
      LQuery.ParamByName('dscep').AsString := LQueryEndereco.FieldByName('dscep').AsString;
      LQuery.ParamByName('idendereco').AsInteger := AId;
      LQuery.ExecSQL;

      Result := TConverter.New.DataSet(LQueryEndereco).AsJSONObject;
    end
    else
    begin
      Result := TModelFormatResult.ResultError('Endereço não encontrado',404);
    end;
  finally
    LQuery.Free;
    LQueryEndereco.Free;
  end;
end;

end.
