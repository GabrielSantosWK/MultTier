unit View.Pessoa.Iten.List;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, Entity.Pessoa, FMX.Effects,
  FMX.Filter.Effects;

type
  TViewPessoaItenList = class(TFrame)
    recBase: TRectangle;
    lblNome: TLabel;
    lblDocumento: TLabel;
    imgEdit: TImage;
    imgDelete: TImage;
    FillRGBEffect1: TFillRGBEffect;
    FillRGBEffect2: TFillRGBEffect;
    ShadowEffect1: TShadowEffect;
    procedure imgEditClick(Sender: TObject);
    procedure imgDeleteClick(Sender: TObject);
  private
    FEntityPessoa:TEntityPessoa;
    FOnClickDelete: TProc<TObject>;
    FOnClickEdit: TProc<TObject>;
    procedure SetOnClickDelete(const Value: TProc<TObject>);
    procedure SetOnClickEdit(const Value: TProc<TObject>);
  public
    class function New(AParent:TControl):TViewPessoaItenList;
    function NomeCompleto(AValue:string):TViewPessoaItenList;
    function Documento(AValue:string):TViewPessoaItenList;
    function Entity(AValue:TEntityPessoa):TViewPessoaItenList;overload;
    function Entity:TEntityPessoa;overload;
    function OnClickEdit(AProc:TProc<TObject>):TViewPessoaItenList;
    function OnClickDelete(AProc:TProc<TObject>):TViewPessoaItenList;
  end;

implementation

{$R *.fmx}

{ TViewPessoaItenList }

function TViewPessoaItenList.Documento(AValue: string): TViewPessoaItenList;
begin
  Result := Self;
  lblDocumento.Text := AValue;
end;

function TViewPessoaItenList.Entity(AValue: TEntityPessoa): TViewPessoaItenList;
begin
  Result := Self;
  FEntityPessoa := AValue;
end;

function TViewPessoaItenList.Entity: TEntityPessoa;
begin
  Result := FEntityPessoa;
end;

procedure TViewPessoaItenList.imgDeleteClick(Sender: TObject);
begin
  if Assigned(FOnClickDelete) then
    FOnClickDelete(Self);
end;

procedure TViewPessoaItenList.imgEditClick(Sender: TObject);
begin
  if Assigned(FOnClickEdit) then
    FOnClickEdit(Self);
end;

class function TViewPessoaItenList.New(AParent: TControl): TViewPessoaItenList;
begin
  Result := Self.Create(AParent);
  Result.Parent := AParent;
  Result.Align := TAlignLayout.MostTop;
  Result.Name := 'A'+TGUID.NewGuid.ToString
                      .Replace('{','',[rfReplaceAll])
                      .Replace('}','',[rfReplaceAll])
                      .Replace('-','',[rfReplaceAll]);
end;

function TViewPessoaItenList.NomeCompleto(AValue: string): TViewPessoaItenList;
begin
  Result := Self;
  lblNome.Text := AValue;
end;

function TViewPessoaItenList.OnClickDelete(AProc: TProc<TObject>): TViewPessoaItenList;
begin
  Result := Self;
  SetOnClickDelete(AProc);
end;

function TViewPessoaItenList.OnClickEdit(AProc: TProc<TObject>): TViewPessoaItenList;
begin
  Result := Self;
  SetOnClickEdit(AProc);
end;

procedure TViewPessoaItenList.SetOnClickDelete(const Value: TProc<TObject>);
begin
  FOnClickDelete := Value;
end;

procedure TViewPessoaItenList.SetOnClickEdit(const Value: TProc<TObject>);
begin
  FOnClickEdit := Value;
end;

end.
