unit View.Endereco;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  View.Components.Edit, FMX.Objects, View.Components.Button,FMX.Ani,
  Model.Client.Cep, Model.Client.Endereco, Entity.Endereco,System.Generics.Collections,
  View.Components.Load, FMX.Controls.Presentation;

type
  TViewEndereco = class(TFrame)
    ComponentsEditUF: TViewComponentsEdit;
    ViewComponentsEditCep: TViewComponentsEdit;
    ViewComponentsEditCidade: TViewComponentsEdit;
    ViewComponentsEditLogradouro: TViewComponentsEdit;
    ViewComponentsEditBairro: TViewComponentsEdit;
    ViewComponentsEditComplemento: TViewComponentsEdit;
    recBase: TRectangle;
    Rectangle1: TRectangle;
    ViewComponentsButton1: TViewComponentsButton;
    ViewComponentsButton2: TViewComponentsButton;
    imgCep: TImage;
    ViewComponentsLoad: TViewComponentsLoad;
    lblError: TLabel;
    procedure ViewComponentsButton2Click(Sender: TObject);
    procedure imgCepClick(Sender: TObject);
    procedure ViewComponentsButton1Click(Sender: TObject);
  private
    FCLientCep: TModelClientCep;
    FPessoa: Integer;
    FEndereco: Integer;
    FList: TObjectList<TEntityEndereco>;
    FClientEndereco: TModelEndereco;
    procedure GetCep(const ACep: string);
    procedure SaveEndereco();
  protected
    procedure Loaded; override;
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  public
    procedure SetPessoa(const APessoa: Integer);
    procedure SetEndereco(const AEndereco: Integer);
    procedure Toggle();
    procedure OpenEndereco();
    procedure OpenRegisterByPessoa(const APessoa: String);
    function IsOpen: Boolean;
    function List: TObjectList<TEntityEndereco>;
    procedure ClearFields();
    procedure IsValidate;

  end;

implementation

{$R *.fmx}

{ TViewEndereco }

procedure TViewEndereco.AfterConstruction;
begin
  inherited;
  FCLientCep := TModelClientCep.Create;
  FList := TObjectList<TEntityEndereco>.Create;
  FClientEndereco := TModelEndereco.Create;
end;

procedure TViewEndereco.BeforeDestruction;
begin
  inherited;
  FCLientCep.Free;
  FClientEndereco.Free;
  FList.Free;
end;

procedure TViewEndereco.ClearFields;
var
  I: Integer;
begin
  for I := 0 to Pred(ComponentCount) do
  begin
    if Components[i] is TViewComponentsEdit then
    begin
      TViewComponentsEdit(Components[i]).Field.Text := EmptyStr;
    end;
  end;
  FPessoa := 0;
  FEndereco := 0;
  FList.Clear;
end;

function TViewEndereco.List: TObjectList<TEntityEndereco>;
begin
  Result := FList;
end;

procedure TViewEndereco.Loaded;
begin
  inherited;
  ClearFields;
end;

procedure TViewEndereco.GetCep(const ACep: string);
begin
  lblError.Text := EmptyStr;
  ViewComponentsLoad.OpenLoad();
  TThread.CreateAnonymousThread(
    procedure
    begin
      try
        FCLientCep.Get(ACep);
      except on E: Exception do
        begin
          TThread.Synchronize(nil,
            procedure
            begin
              ViewComponentsLoad.CloseLoad;
              lblError.Text := e.Message;
            end);
        end;
      end;
      TThread.Synchronize(nil,
        procedure
        begin
          ComponentsEditUF.Field.Text := FCLientCep.Entity.UF;
          ViewComponentsEditCidade.Field.Text := FCLientCep.Entity.Localidade;
          ViewComponentsEditLogradouro.Field.Text := FCLientCep.Entity.Logradouro;
          ViewComponentsEditBairro.Field.Text := FCLientCep.Entity.Bairro;
          ViewComponentsEditComplemento.Field.Text := FCLientCep.Entity.Complemento;
          ViewComponentsLoad.CloseLoad;
        end);
    end).Start;
end;

procedure TViewEndereco.imgCepClick(Sender: TObject);
begin
  GetCep(ViewComponentsEditCep.Field.Text);
end;

function TViewEndereco.IsOpen: Boolean;
begin
  Result := Self.Position.Y = 0;
end;

procedure TViewEndereco.IsValidate;
begin
  if String(ViewComponentsEditCep.Field.Text).IsEmpty then
    raise Exception.Create('CEP não pode ser vazio !');
  if String(ViewComponentsEditLogradouro.Field.Text).IsEmpty then
    raise Exception.Create('Logradouro não pode ser vazia !');
  if String(ViewComponentsEditBairro.Field.Text).IsEmpty then
    raise Exception.Create('Bairro não pode ser vazia !');
  if String(ViewComponentsEditCidade.Field.Text).IsEmpty then
    raise Exception.Create('Cidade não pode ser vazia !');
  if String(ComponentsEditUF.Field.Text).IsEmpty then
    raise Exception.Create('UF não pode ser vazia !');
end;

procedure TViewEndereco.OpenEndereco;
begin
  TAnimator.AnimateFloat(Self,'Position.Y',0,0.2);
  lblError.Text := EmptyStr;
  Self.BringToFront;
end;

procedure TViewEndereco.OpenRegisterByPessoa(const APessoa: String);
begin
  FList.Clear;
  FClientEndereco.GetByPessoa(APessoa);
  if FClientEndereco.List.Count < 0 then Exit;

  SetPessoa(APessoa.ToInteger);
  ViewComponentsEditCep.Field.Text := FClientEndereco.List[0].Cep;
  ComponentsEditUF.Field.Text := FClientEndereco.List[0].Integracao.UF;
  ViewComponentsEditCidade.Field.Text := FClientEndereco.List[0].Integracao.Cidade;
  ViewComponentsEditBairro.Field.Text := FClientEndereco.List[0].Integracao.Bairro;
  ViewComponentsEditLogradouro.Field.Text := FClientEndereco.List[0].Integracao.Logradouro;
  ViewComponentsEditComplemento.Field.Text := FClientEndereco.List[0].Integracao.Complemento;
  FList.Add(TEntityEndereco.New.CopyEntity( FClientEndereco.List[0]));
end;

procedure TViewEndereco.SaveEndereco;
var
  LClientEndereco:TModelEndereco;
  LEntityEndereco:TEntityEndereco;
begin
  FList.Clear;
  if (FEndereco > 0) then
  begin
    if FPessoa <= 0 then
      raise Exception.Create('Pessoa não informada');
    LClientEndereco := TModelEndereco.Create;
    LEntityEndereco := TEntityEndereco.Create;
    try
      LEntityEndereco.ID := FEndereco;
      LEntityEndereco.IdPessoa := FPessoa;
      LEntityEndereco.Cep := ViewComponentsEditCep.Field.Text;
      LEntityEndereco.Integracao.UF := ComponentsEditUF.Field.Text;
      LEntityEndereco.Integracao.Cidade := ViewComponentsEditCidade.Field.Text;
      LEntityEndereco.Integracao.Bairro := ViewComponentsEditBairro.Field.Text;
      LEntityEndereco.Integracao.Logradouro := ViewComponentsEditLogradouro.Field.Text;
      LEntityEndereco.Integracao.Complemento := ViewComponentsEditComplemento.Field.Text;
      FList.Add(TEntityEndereco.New.CopyEntity(LEntityEndereco));
      LClientEndereco.Put(LEntityEndereco);
    finally
      LEntityEndereco.Free;
      LClientEndereco.Free;
    end;
  end
  else
  begin
    LEntityEndereco := TEntityEndereco.Create;
    LEntityEndereco.IdPessoa := FPessoa;
    LEntityEndereco.Cep := ViewComponentsEditCep.Field.Text;
    LEntityEndereco.Integracao.UF := ComponentsEditUF.Field.Text;
    LEntityEndereco.Integracao.Cidade := ViewComponentsEditCidade.Field.Text;
    LEntityEndereco.Integracao.Bairro := ViewComponentsEditBairro.Field.Text;
    LEntityEndereco.Integracao.Logradouro := ViewComponentsEditLogradouro.Field.Text;
    LEntityEndereco.Integracao.Complemento := ViewComponentsEditComplemento.Field.Text;
    FList.Add(LEntityEndereco);
  end;
  Toggle;
end;

procedure TViewEndereco.SetEndereco(const AEndereco: Integer);
begin
  FEndereco := AEndereco;
end;

procedure TViewEndereco.SetPessoa(const APessoa: Integer);
begin
  FPessoa := APessoa;
end;

procedure TViewEndereco.Toggle;
var
  LPosition:Single;
begin
  if Position.Y = 0 then
    LPosition := 1500
  else
    LPosition := 0;
  TAnimator.AnimateFloat(Self,'Position.Y',LPosition,0.2);
  lblError.Text := EmptyStr;
  Self.BringToFront;
end;

procedure TViewEndereco.ViewComponentsButton1Click(Sender: TObject);
begin
  try
    IsValidate;
  except on E: Exception do
    begin
      raise Exception.Create(e.Message);
    end;
  end;
  SaveEndereco;
end;

procedure TViewEndereco.ViewComponentsButton2Click(Sender: TObject);
begin
  Toggle;
end;

end.
