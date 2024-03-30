unit unFrameJpg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, unFrameCommon, unCommon, Vcl.Imaging.jpeg,
  Vcl.ExtCtrls;

type
  TFrameJpg = class(TFrameCommon)
    imgMain: TImage;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadData(aRecItem: TRecordItem); override;
  end;

var
  FrameJpg: TFrameJpg;

implementation

{$R *.dfm}

{ TFrameJpg }

procedure TFrameJpg.LoadData(aRecItem: TRecordItem);
var
  image: TJPEGImage;
begin
  image := TJPEGImage.Create;
  image.LoadFromFile(aRecItem.path);
  imgMain.Picture.Assign(image);
  image.Free;
end;

end.
