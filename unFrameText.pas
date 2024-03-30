unit unFrameText;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, unFrameCommon, unCommon, Vcl.StdCtrls;

type
  TFrameText = class(TFrameCommon)
    mmoText: TMemo;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadData(aRecItem: TRecordItem); override;
  end;

var
  FrameText: TFrameText;

implementation

{$R *.dfm}

{ TFrameCommon1 }

procedure TFrameText.LoadData(aRecItem: TRecordItem);
begin
  mmoText.Lines.Clear;
  mmoText.Lines.LoadFromFile(aRecItem.path);
end;

end.
