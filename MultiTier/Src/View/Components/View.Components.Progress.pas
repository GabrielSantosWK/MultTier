unit View.Components.Progress;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects,FMX.Ani, FMX.Controls.Presentation;

type
  TViewComponentsProgress = class(TFrame)
    recProgress: TRectangle;
    recEffectProgress: TRectangle;
    FloatAnimation1: TFloatAnimation;
    Label1: TLabel;
    procedure FloatAnimation1Finish(Sender: TObject);
  private
    { Private declarations }
  public
    procedure StartProgress();
    procedure StopProgress();
  end;

implementation

{$R *.fmx}

{ TFrame1 }

procedure TViewComponentsProgress.FloatAnimation1Finish(Sender: TObject);
begin
  recEffectProgress.Visible := False;
  recEffectProgress.Margins.Left := recEffectProgress.Width + 5;
  recEffectProgress.Visible := True;
end;

procedure TViewComponentsProgress.StartProgress;
begin
  Self.Visible := True;
  FloatAnimation1.StopValue := Self.Width;
  FloatAnimation1.Start;
end;

procedure TViewComponentsProgress.StopProgress;
begin
  FloatAnimation1.Stop;
  Visible := False;
end;

end.
