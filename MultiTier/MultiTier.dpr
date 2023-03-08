program MultiTier;

uses
  System.StartUpCopy,
  FMX.Forms,
  View.Principal in 'Src\View\View.Principal.pas' {ViewPrincipal},
  View.Components.Edit in 'Src\View\Components\View.Components.Edit.pas' {ViewComponentsEdit: TFrame},
  View.Components.Button in 'Src\View\Components\View.Components.Button.pas' {ViewComponentsButton: TFrame},
  View.Pessoa.Iten.List in 'Src\View\Pessoa\View.Pessoa.Iten.List.pas' {ViewPessoaItenList: TFrame},
  Entity.Pessoa in 'Src\Entity\Entity.Pessoa.pas',
  Entity.Endereco.Integracao in 'Src\Entity\Entity.Endereco.Integracao.pas',
  Entity.Endereco in 'Src\Entity\Entity.Endereco.pas',
  Model.Client in 'Src\Model\Client\Model.Client.pas',
  Model.Client.Pessoa in 'Src\Model\Client\Model.Client.Pessoa.pas',
  View.Endereco in 'Src\View\Endereco\View.Endereco.pas' {ViewEndereco: TFrame},
  Model.Client.Cep in 'Src\Model\Client\Model.Client.Cep.pas',
  Entity.Cep in 'Src\Entity\Entity.Cep.pas',
  Model.Client.Endereco in 'Src\Model\Client\Model.Client.Endereco.pas',
  Model.Client.Pessoa.Lote in 'Src\Model\Client\Model.Client.Pessoa.Lote.pas',
  View.Components.Load in 'Src\View\Components\View.Components.Load.pas' {ViewComponentsLoad: TFrame},
  View.Components.Progress in 'Src\View\Components\View.Components.Progress.pas' {ViewComponentsProgress: TFrame},
  Bird.Socket.Client.Consts in '..\MultiTierServer\Model\Lib\Bird.Socket.Client.Consts.pas',
  Bird.Socket.Client in '..\MultiTierServer\Model\Lib\Bird.Socket.Client.pas',
  Bird.Socket.Client.Types in '..\MultiTierServer\Model\Lib\Bird.Socket.Client.Types.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TViewPrincipal, ViewPrincipal);
  Application.Run;
end.
