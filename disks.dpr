program disks;

uses
  Vcl.Forms,
  unMain in 'unMain.pas' {FormMain},
  unFrameCommon in 'unFrameCommon.pas' {FrameCommon: TFrame},
  unCommon in 'unCommon.pas',
  unFrameText in 'unFrameText.pas' {FrameText: TFrame},
  unFrameBmp in 'unFrameBmp.pas' {FrameBmp: TFrame},
  unFrameJpg in 'unFrameJpg.pas' {FrameJpg: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
