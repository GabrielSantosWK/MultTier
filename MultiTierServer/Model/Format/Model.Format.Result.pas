unit Model.Format.Result;

interface

uses
  System.JSON;
  type
  TModelFormatResult = class
    private
    public
    class function ResultList(AJsonArrayList:TJSONArray;ACountRegister,Limit,Offset:Integer):TJSONObject;static;
    class function ResultItem(AJsonObjectItem: TJSONObject): TJSONObject; static;
    class function ResultError(AMessege:string;ACode:Integer):TJSONObject;
  end;
implementation

{ TModelFormatResult }

class function TModelFormatResult.ResultList(AJsonArrayList: TJSONArray;ACountRegister,Limit,Offset:Integer): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('Data',AJsonArrayList);
  Result.AddPair('Count',ACountRegister);
  Result.AddPair('Limit',Limit);
  Result.AddPair('Offset',Offset);
end;
class function TModelFormatResult.ResultError(AMessege: string;
  ACode: Integer): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('Messege',AMessege);
  Result.AddPair('Code',ACode);
end;

class function TModelFormatResult.ResultItem(AJsonObjectItem:TJSONObject): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('Data',AJsonObjectItem);
end;

end.
