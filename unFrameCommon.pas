unit unFrameCommon;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, unCommon;

type
  TFrameCommon = class(TFrame)
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadData(aRecItem: TRecordItem); virtual; abstract;
  end;

implementation

{$R *.dfm}

end.
