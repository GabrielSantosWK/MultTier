unit View.Components.Load;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.ani;

type
  TViewComponentsLoad = class(TFrame)
    AniIndicator: TAniIndicator;
    Rectangle1: TRectangle;
  private
    { Private declarations }
  public
    procedure OpenLoad();
    procedure CloseLoad();
  end;

implementation

{$R *.fmx}

{ TFrame1 }

procedure TViewComponentsLoad.CloseLoad;
begin
  TAnimator.AnimateFloat(Self,'Opacity',0,0.2);
  TThread.CreateAnonymousThread(
    procedure
    begin
      TThread.Sleep(150);
      TThread.Synchronize(nil,
        procedure
        begin
          AniIndicator.Enabled := False;
          Self.Visible := False;
        end)
    end).Start
end;

procedure TViewComponentsLoad.OpenLoad;
begin
  AniIndicator.BringToFront;
  Self.BringToFront;
  Self.Visible := True;
  AniIndicator.Enabled := True;
  TAnimator.AnimateFloat(Self,'Opacity',1,0.2);
end;

end.
