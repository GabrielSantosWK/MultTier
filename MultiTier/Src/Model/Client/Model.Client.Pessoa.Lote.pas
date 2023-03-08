unit Model.Client.Pessoa.Lote;

interface
uses
  System.Classes,
  System.JSON,
  System.Net.HttpClient,
  System.Net.Mime;

  type
  TModelClientPessoaLote = class
    private
      FStatusCode:Integer;
      FContent:string;
    public
    function Post(AFileName:string):TModelClientPessoaLote;
    function StatusCode:Integer;
    procedure SetContent(const AContent:string);
    function Content:string;
    function MessegeError:string;
  end;
implementation

{ TModelClientPessoaLote }

function TModelClientPessoaLote.Content: string;
begin
  Result := FContent;
end;

function TModelClientPessoaLote.MessegeError: string;
var
  LMessegeError:TJSONObject;
begin
  Result := '';
  LMessegeError := TJSONObject.ParseJSONValue(FContent) as TJSONObject;
  try
    LMessegeError.TryGetValue<string>('Messege',Result)
  finally
    LMessegeError.Free;
  end;
end;

function TModelClientPessoaLote.Post(AFileName: string): TModelClientPessoaLote;
var
  LRequest: THTTPClient;
  LFormData: TMultipartFormData;
  LResponse: TStringStream;
begin
  LRequest := THTTPClient.Create;
  LFormData := TMultipartFormData.Create();
  LResponse := TStringStream.Create;
  try
    LRequest.CustHeaders.Add('Content-Type', 'multipart/form-data');
    LFormData.AddFile('',AFileName);
    LRequest.Post('http://127.0.0.1:8081/datasnap/rest/TServerMethodsLote/pessoalote', LFormData, LResponse);
    FContent :=  LResponse.DataString;
  finally
    LRequest.Free;
    LFormData.Free;
    LResponse.Free;
  end;
end;

procedure TModelClientPessoaLote.SetContent(const AContent: string);
begin
  FContent := AContent;
end;

function TModelClientPessoaLote.StatusCode: Integer;
var
  LError:TJSONObject;
begin
  Result := 0;
  LError := TJSONObject.ParseJSONValue(FContent) as TJSONObject;
  try
    LError.TryGetValue<integer>('Code',Result)
  finally
    LError.Free;
  end;
end;

end.
