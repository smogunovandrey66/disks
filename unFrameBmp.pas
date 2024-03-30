unit unFrameBmp;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, unFrameCommon, unCommon, Vcl.ExtCtrls,
  Vcl.Imaging.jpeg;

type
  TFrameBmp = class(TFrameCommon)
    imgMain: TImage;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadData(aRecItem: TRecordItem); override;
  end;

var
  FrameBmp: TFrameBmp;

implementation

{$R *.dfm}

{ TFrameBmp }

procedure TFrameBmp.LoadData(aRecItem: TRecordItem);
begin
  imgMain.Picture.LoadFromFile(aRecItem.path);
end;

end.
