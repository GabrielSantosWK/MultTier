unit ServerMethods.Lote;

interface

uses System.SysUtils, System.Classes, System.Json,
    DataSnap.DSProviderDataModuleAdapter,Datasnap.DSHTTPWebBroker,Data.DBXPlatform,
    Datasnap.DSServer, Datasnap.DSAuth, Model.DAO.Pessoa, System.Types,
  Model.Format.Result,Model.Socket;

type
  TServerMethodsLote = class(TDSServerModule)
  private
    function LineTxtToJson(const ALine:string):TJSONObject;
    procedure SendResult(const AValue:string);
  public
    function UpdatePessoaLote:TJSONObject;
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}


uses System.StrUtils, Model.Connection;


{ TServerMethodsLote }

function TServerMethodsLote.LineTxtToJson(const ALine: string): TJSONObject;
var
  LValue:string;
  LListOfStringsLine:TStringDynArray;
  I: Integer;
  LListOfStringsItem:TStringDynArray;
  LCep:string;
  LJsonArrayEndereco:TJSONArray;
  LJsonObjectEndereco:TJSONObject;
  LPessoa:string;
  LEndereco:string;
  LDaoPessoa:TModelDAOPessoa;
begin
  Result := TJSONObject.Create;
  LPessoa := Copy(ALine,1,Pos('dscep:',ALine)-2);
  LListOfStringsLine := SplitString(LPessoa,';');
  for I := Low(LListOfStringsLine) to High(LListOfStringsLine) do
  begin
    LValue := LListOfStringsLine[i];
    LListOfStringsItem := SplitString(LValue,':');
    Result.AddPair(LListOfStringsItem[0],LListOfStringsItem[1])
  end;
  LEndereco := Copy(ALine,Length(LPessoa)+2);
  LListOfStringsLine := SplitString(LEndereco,';');

  LJsonArrayEndereco := TJSONArray.Create;
  LJsonObjectEndereco := TJSONObject.Create;

  for I := Low(LListOfStringsLine) to High(LListOfStringsLine) do
  begin
    LValue := LListOfStringsLine[i];
    LListOfStringsItem := SplitString(LValue,':');
    LJsonObjectEndereco.AddPair(LListOfStringsItem[0],LListOfStringsItem[1])
  end;
  LJsonArrayEndereco.Add(LJsonObjectEndereco);
  Result.AddPair('endereco',LJsonArrayEndereco);
end;

procedure TServerMethodsLote.SendResult(const AValue: string);
begin
  if TModelSocket.GetInstance.Bird <> nil then
    TModelSocket.GetInstance.Bird.Send(AValue);
end;

function TServerMethodsLote.UpdatePessoaLote: TJSONObject;
var
  LBody:TJSONObject;
  LFileBody:TextFile;
  I:Integer;
  LStrringStream:TStringStream;
  LPath:string;
  LLinha:string;
  LCountStringList:TStringList;
  LCountLine:Integer;
begin
  LPath := GetCurrentDir() + '\FileTemp.txt';
  LStrringStream := TStringStream.Create(GetDataSnapWebModule.Request.Content);
  LStrringStream.SaveToFile(LPath);
  if FileExists(LPath) then
  begin
    AssignFile(LFileBody, LPath);
    Reset(LFileBody);
    if not TModelSocket.GetInstance.Socket.Active then
      TModelSocket.GetInstance.Socket.Start;
    TThread.CreateAnonymousThread(
    procedure
    var
      LDAOPessoa:TModelDAOPessoa;
    begin
      LDaoPessoa := TModelDAOPessoa.Create;
      LCountStringList := TStringList.Create;
      try
        TModelConnection.GetInstance.Connection.StartTransaction;
        try
          LCountStringList.LoadFromFile(LPath);
          if LCountStringList.Count > 50000 then
            raise Exception.Create('O arquivo contem mais de 50.000 linhas');
          LCountLine := 0;
          while not Eof(LFileBody) do
          begin
            Inc(LCountLine);
            Readln(LFileBody, LLinha);
            if LLinha.Contains('flnatureza') then
            begin
              LDaoPessoa.Post(LineTxtToJson(LLinha));
            end
            else
              if (LCountLine >= 5) and(LCountLine < (LCountStringList.Count-3)) then
                raise Exception.Create('Arquivo inválido erro na linha '+LCountLine.ToString);
          end;
          TModelConnection.GetInstance.Connection.Commit;
        except
          on E: Exception do
          begin
            TModelConnection.GetInstance.Connection.Rollback;
            SendResult(TModelFormatResult.ResultError(E.Message, 400).ToJSON());
            Exit;
          end;
        end;
        SendResult('Sucess');
        //Result := TJSONObject.Create;
      finally
        LDaoPessoa.Free;
        LCountStringList.Free;
        CloseFile(LFileBody);
      end;
      TThread.Synchronize(nil,
      procedure
      begin

      end);
    end).Start;
  end;
  Result := TJSONObject.Create;
end;

end.
