unit View.Principal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, FMX.Objects, FMX.Layouts,FMX.Ani,
  View.Components.Edit, View.Components.Button, View.Pessoa.Iten.List,
  Model.Client.Pessoa,Entity.Pessoa,System.Generics.Collections, View.Endereco,
  Entity.Endereco,Model.Client.Pessoa.Lote, FMX.ListBox, View.Components.Load,
  View.Components.Progress,Bird.Socket.Client;

type
  TViewPrincipal = class(TForm)
    ScrollBox: TVertScrollBox;
    Layout1: TLayout;
    ComponentsEditDocumento: TViewComponentsEdit;
    ComponentsEditNatureza: TViewComponentsEdit;
    ComponentsEditPrimeiroNome: TViewComponentsEdit;
    ComponentsEditSegundoNome: TViewComponentsEdit;
    ViewComponentsButton1: TViewComponentsButton;
    recEndereco: TRectangle;
    lblEndereco: TLabel;
    ViewEndereco: TViewEndereco;
    ComponentsEditCodigo: TViewComponentsEdit;
    ViewComponentsButton2: TViewComponentsButton;
    RecLote: TRectangle;
    Label1: TLabel;
    OpenDialog: TOpenDialog;
    lblPath: TLabel;
    Rectangle2: TRectangle;
    lblTotalRegister: TLabel;
    ComboBoxItemPage: TComboBox;
    Label3: TLabel;
    Image1: TImage;
    Layout2: TLayout;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    ViewComponentsLoad: TViewComponentsLoad;
    Layout3: TLayout;
    ViewComponentsProgress: TViewComponentsProgress;
    RecAtualizar: TRectangle;
    Label2: TLabel;
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ViewComponentsButton1Click(Sender: TObject);
    procedure recEnderecoClick(Sender: TObject);
    procedure ViewComponentsButton2Click(Sender: TObject);
    procedure RecLoteClick(Sender: TObject);
    procedure ComboBoxItemPageChange(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    procedure Image4Click(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure RecAtualizarClick(Sender: TObject);
    private
    FClient:TModelClientPessoa;
    FClientLote:TModelClientPessoaLote;
    FIdPessoa:Integer;
    FMaxValuePage:Integer;
    FCurrentPage:Integer;
    FSocket:TBirdSocketClient;
    procedure GetPessoa();
    procedure ClearFields();
    procedure ClearScroll();
    procedure CreateList(AList:TObjectList<TEntityPessoa>);
    procedure OnClickEdit(Sender:TObject);
    procedure OnClickDelete(Sender:TObject);
    procedure SetPessoa(const APessoa:Integer);
  public
  end;

var
  ViewPrincipal: TViewPrincipal;

implementation

{$R *.fmx}

procedure TViewPrincipal.ClearFields;
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
  FIdPessoa := 0;
end;

procedure TViewPrincipal.ClearScroll;
var
  I: Integer;
begin
  for I := Pred(ScrollBox.Content.ControlsCount) downto 0 do
    if ScrollBox.Content.Controls[i] is TViewPessoaItenList then
      ScrollBox.Content.Controls[i].Free;
end;

procedure TViewPrincipal.ComboBoxItemPageChange(Sender: TObject);
begin
  FCurrentPage := 1;
  GetPessoa();
end;

procedure TViewPrincipal.CreateList(AList:TObjectList<TEntityPessoa>);
var
  I: Integer;
begin
  ClearScroll;
  for I := 0 to Pred(AList.Count) do
  begin
    TViewPessoaItenList.New(ScrollBox)
                       .NomeCompleto(Format('%s - %s %s',[AList[i].ID.ToString,AList[i].PrimeiroNome,AList[i].SegundoNome]))
                       .Documento(AList[i].Documento)
                       .Entity(AList[i])
                       .OnClickEdit(OnClickEdit)
                       .OnClickDelete(OnClickDelete);
  end;
  lblTotalRegister.Text := Format('Total de registros %s',[FClient.Pagination.Count.ToString]);
end;

procedure TViewPrincipal.FormCreate(Sender: TObject);
begin
  FClientLote := TModelClientPessoaLote.Create;
  FClient := TModelClientPessoa.Create;
  FSocket := TBirdSocketClient.New('ws://localhost:8082');
  FSocket.AddEventListener(TEventType.MESSAGE,
          procedure(const AText:string)
          begin
            FClientLote.SetContent(AText);

            TThread.Synchronize(nil,
            procedure
            begin
              ViewComponentsProgress.StopProgress;
              if FClientLote.StatusCode >= 400 then
              begin
                FSocket.Disconnect;
                lblPath.text := EmptyStr;
                ShowMessage('Não foi possivél gravar o lote de arquivos: '+FClientLote.MessegeError);
                Abort
              end;
              lblPath.text := 'Lote salvo com sucesso!';
            end);

            TThread.CreateAnonymousThread(
            procedure
            begin
              TThread.Sleep(2500);
              TThread.Synchronize(nil,
              procedure
              begin
                lblPath.text := EmptyStr;
                RecAtualizar.Visible := True;
                RecAtualizar.Position.X := lblPath.Position.X;
                RecAtualizar.Position.Y := RecLote.Position.Y;
                FSocket.Disconnect;
              end);
            end).Start;
          end);
end;

procedure TViewPrincipal.FormDestroy(Sender: TObject);
begin
  FClientLote.Free;
  FClient.Free;
  FSocket.Free;
end;

procedure TViewPrincipal.FormResize(Sender: TObject);
begin
  ViewComponentsButton1.Position.X := (Self.Width - ViewComponentsButton1.Width) - 30;
  ViewComponentsButton2.Position.X := (ViewComponentsButton1.Position.X - ViewComponentsButton2.Width)- 10;
  recEndereco.Position.X := (ViewComponentsButton2.Position.X - recEndereco.Width)- 10;
  lblPath.Position.X :=  (RecLote.Position.X + RecLote.Width + 10);
end;

procedure TViewPrincipal.FormShow(Sender: TObject);
begin
  FCurrentPage := 1;
  GetPessoa;
end;

procedure TViewPrincipal.GetPessoa;
var
  LOffset:string;
begin
  RecAtualizar.Visible := False;
  LOffset := '0';
  if FCurrentPage > 1 then
  begin
    LOffset := (FCurrentPage*ComboBoxItemPage.Items[ComboBoxItemPage.ItemIndex].ToInteger()).ToString;
  end;
  ViewComponentsLoad.OpenLoad;
  ClearFields();
  ScrollBox.Visible := False;
  TThread.CreateAnonymousThread(
    procedure
    begin
      TThread.Sleep(0);
      FClient.ClearParams
             .AddParams('offset',LOffset)
             .AddParams('limit',ComboBoxItemPage.Items[ComboBoxItemPage.ItemIndex]);
      try
        FClient.Get;
      except on E: Exception do
        begin
          TThread.Synchronize(nil,
            procedure
            begin
              ViewComponentsLoad.CloseLoad;
              ShowMessage(e.Message);
              Abort;
            end);
        end;
      end;


      CreateList(FClient.List);
      TThread.Synchronize(nil,
        procedure
        begin
          ScrollBox.Visible := True;
          ViewComponentsLoad.CloseLoad;
          FMaxValuePage := Trunc(FClient.Pagination.Count/FClient.Pagination.Limit);
          if FMaxValuePage <= 0 then
            FMaxValuePage := 1;
          lblTotalRegister.Text := Format('%s  -  %s  de  %s',[FCurrentPage.ToString,FMaxValuePage.ToString,FClient.Pagination.Count.ToString]);
        end);
    end).Start;
end;

procedure TViewPrincipal.Image1Click(Sender: TObject);
begin
  if FCurrentPage = 1 then Exit;
  FCurrentPage := 1;
  GetPessoa;
end;

procedure TViewPrincipal.Image2Click(Sender: TObject);
begin
  if FCurrentPage >= FMaxValuePage then Exit;
  FCurrentPage := FMaxValuePage;
  GetPessoa;
end;

procedure TViewPrincipal.Image3Click(Sender: TObject);
begin
  if FCurrentPage >= FMaxValuePage then Exit;

  Inc(FCurrentPage);
  GetPessoa;
end;

procedure TViewPrincipal.Image4Click(Sender: TObject);
begin
  if FCurrentPage <= 1 then Exit; 
  
  FCurrentPage := FCurrentPage -1;
  GetPessoa;
end;

procedure TViewPrincipal.OnClickDelete(Sender: TObject);
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      FClient.Delete(TEntityPessoa(TViewPessoaItenList(Sender).Entity)).Get;
      TThread.Synchronize(nil,
        procedure
        begin
          GetPessoa();
        end);
    end).Start;
end;

procedure TViewPrincipal.OnClickEdit(Sender: TObject);
begin
  SetPessoa(TViewPessoaItenList(Sender).Entity.ID);
  ViewEndereco.SetEndereco(TViewPessoaItenList(Sender).Entity.ListEndereco[0].Id);
  ComponentsEditCodigo.Field.Text := TViewPessoaItenList(Sender).Entity.ID.ToString;
  ComponentsEditDocumento.Field.Text := TViewPessoaItenList(Sender).Entity.Documento;
  ComponentsEditNatureza.Field.Text := TViewPessoaItenList(Sender).Entity.Natureza.ToString;
  ComponentsEditPrimeiroNome.Field.Text := TViewPessoaItenList(Sender).Entity.PrimeiroNome;
  ComponentsEditSegundoNome.Field.Text := TViewPessoaItenList(Sender).Entity.SegundoNome;
  ViewEndereco.OpenRegisterByPessoa(TViewPessoaItenList(Sender).Entity.ID.ToString)
end;

procedure TViewPrincipal.RecAtualizarClick(Sender: TObject);
begin
  RecAtualizar.Visible := False;
  FCurrentPage := 1;
  GetPessoa;
end;

procedure TViewPrincipal.recEnderecoClick(Sender: TObject);
begin
  ViewEndereco.Toggle;
end;

procedure TViewPrincipal.RecLoteClick(Sender: TObject);
var
  LTypeArquivo:string;
begin
  if OpenDialog.Execute then
  begin
    LTypeArquivo := Copy(OpenDialog.FileName,Length(OpenDialog.FileName)-3);
    if (LTypeArquivo <> '.txt') then
      raise Exception.Create('arquivo invalido!');
    if not FileExists(OpenDialog.FileName) then
      raise Exception.Create('Caminho do arquivo invalido!');
    lblPath.Text := OpenDialog.FileName;
    TThread.Synchronize(nil,
    procedure
    begin
      ViewComponentsProgress.StartProgress;
    end);
    FSocket.Connect;
    TThread.CreateAnonymousThread(
    procedure
    begin
      FClientLote.Post(lblPath.Text);
    end).Start;
  end;
end;

procedure TViewPrincipal.SetPessoa(const APessoa: Integer);
begin
  FIdPessoa := APessoa;
end;

procedure TViewPrincipal.ViewComponentsButton1Click(Sender: TObject);
var
  LEntity:TEntityPessoa;
  I: Integer;
begin
  try
    ViewEndereco.IsValidate;
  except on E: Exception do
    begin
      ViewEndereco.OpenEndereco;
      raise Exception.Create(e.Message);
    end;
  end;
  LEntity := TEntityPessoa.Create;
  try
    LEntity.Natureza := StrToIntDef(ComponentsEditNatureza.Field.Text,0);
    LEntity.Documento := ComponentsEditDocumento.Field.Text;
    LEntity.PrimeiroNome := ComponentsEditPrimeiroNome.Field.Text;
    LEntity.SegundoNome := ComponentsEditSegundoNome.Field.Text;
    for I := 0  to Pred(ViewEndereco.List.Count) do
      LEntity.ListEndereco.Add(TEntityEndereco.New.CopyEntity(ViewEndereco.List[i]));
    if FIdPessoa > 0 then
    begin
      LEntity.ID := FIdPessoa;
      FClient.Put(LEntity);
    end
    else
      FClient.Post(LEntity);
    TThread.CreateAnonymousThread(
      procedure
      begin
        FClient.Get;
        TThread.Synchronize(nil,
          procedure
          begin
            CreateList(FClient.List);
            ClearFields();
            ViewEndereco.ClearFields;
          end);
      end).Start;
  finally
    LEntity.Free;
  end;
end;

procedure TViewPrincipal.ViewComponentsButton2Click(Sender: TObject);
begin
  ClearFields;
  ViewEndereco.ClearFields;
end;

end.
