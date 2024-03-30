unit unMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls, System.Generics.Collections,
  System.IOUtils, System.Types, System.ImageList, Vcl.ImgList, System.Math, unCommon, unFrameCommon,
  unFrameText, unFrameBmp, unFrameJpg;

type
  TFormMain = class(TForm)
    pnlTree: TPanel;
    pnlContent: TPanel;
    splTree: TSplitter;
    tvDisks: TTreeView;
    ilMain: TImageList;
    statMain: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tvDisksExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure tvDisksClick(Sender: TObject);
    procedure tvDisksExpanded(Sender: TObject; Node: TTreeNode);
    procedure tvDisksChanging(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean);
  private
    { Private declarations }
    /// <summary>
    /// Модель данных
    /// </summary>
    FModel: TDictionary<TTreeNode, TRecordItem>;

    /// <summary>
    /// Активный фрейм
    /// </summary>
     FActiveFrame: TFrameCommon;

    /// <summary>
    /// Пул фреймов по расширению файлов
    /// </summary>
    FPoolFrames: TDictionary<string,TFrameCommon>;

    /// <summary>
    /// Загрузка дисков
    /// </summary>
    procedure LoadDisks;

    /// <summary>
    ///  Загрузка дочерних узлов
    /// </summary>
    procedure loadNode(aParentNode: TTreeNode);
    /// <summary>
    /// Проверка элементов внутри папки
    /// </summary>
    function containsChildren(aNode: TTreeNode): Boolean;
    /// <summary>
    /// Получить фрейм по типу расширения фалйа
    /// </summary>
    function getFrame(aExt: string): TFrameCommon;
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}
{$R FileCtrl}

{ TFormMain }

function TFormMain.containsChildren(aNode: TTreeNode): Boolean;
var
  recItem: TRecordItem;
begin
  try
    recItem := FModel[aNode];
    Result := Length(TDirectory.GetFileSystemEntries(recItem.path)) > 0;
  except
    on e: Exception do begin
      { TODO -oAndrey -c : низкоуровневые API 29.03.2024 17:39:31 }
      Result := False;
    end;
  end;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  FModel := TDictionary<TTreeNode, TRecordItem>.Create;
  FPoolFrames := TDictionary<string, TFrameCommon>.Create;
  LoadDisks;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  FModel.Free;
  FPoolFrames.Free;
end;

function TFormMain.getFrame(aExt: string): TFrameCommon;
var
  frame: TFrameCommon;
begin
  frame := nil;
  if not FPoolFrames.ContainsKey(aExt) then begin
    if aExt = EXT_TXT then begin
      frame := TFrameText.Create(Self);
    end;
    if (aExt = EXT_BMP) then begin
      frame := TFrameBmp.Create(Self);
    end;
    if aExt = EXT_JPG then begin
      frame := TFrameJpg.Create(Self);
    end;

    if Assigned(frame) then
      FPoolFrames.Add(aExt, frame);
  end
    else
      frame := FPoolFrames[aExt];
  Result := frame;
end;

procedure TFormMain.LoadDisks;
const
  IconNames: array [0..6] of string = ( 'CLOSEDFOLDER',
                                        'OPENFOLDER',
                                        'FLOPPY',
                                        'HARD',
                                        'NETWORK',
                                        'CDROM',
                                        'RAM' );
var
  node: TTreeNode;
  DriveType: integer;
  i: integer;
  recItem: TRecordItem;
begin
   tvDisks.Items.BeginUpdate;

   // Находим диски и выводим их в TreeView
   for i := 0 to 25 do
   begin
      DriveType := GetDriveType( PChar( Chr( i + 65 ) + ':\' ) );
      if DriveType = 1 then continue;
      node := tvDisks.Items.AddChild( nil, Chr( i+65 ) + ':' );
      case DriveType of
         DRIVE_REMOVABLE: node.ImageIndex := 2;
         DRIVE_FIXED: node.ImageIndex := 3;
         DRIVE_REMOTE: node.ImageIndex := 4;
         DRIVE_CDROM: node.ImageIndex := 5;
         else
            node.ImageIndex := 6;
      end;
      node.SelectedIndex := node.ImageIndex;
      recItem.isDirectory := True;
      recItem.isLoaded := False;
      recItem.path := Chr(i + 65) + ':\';
      recItem.name := recItem.path;
      recItem.ext := '';
      FModel.Add(node, recItem);

      node.HasChildren := containsChildren(node);
   end;
   tvDisks.Items.EndUpdate;
end;

procedure TFormMain.loadNode(aParentNode: TTreeNode);
var
  node: TTreeNode;
  path, nodeName, ext: string;
  recItem, recItemNew: TRecordItem;

  entries: TStringDynArray;

  //Альтернатива получения аттрибутов
//  fileAttr: TFileAttributes;

  i: Integer;
  fileAttrInt: Cardinal;
begin     
  recItem := FModel[aParentNode];
  entries := TDirectory.GetFileSystemEntries(recItem.path);

  for path in entries do begin
    nodeName := TPath.GetFileName(path);
    fileAttrInt := GetFileAttributes(PChar(path));
//    fileAttr := TPath.GetAttributes(path);
    node := tvDisks.Items.AddChild(aParentNode, nodeName);

    recItemNew.name := nodeName;
    recItemNew.path := recItem.path + nodeName;
    recItemNew.isLoaded := False;

    //Приходится прибегать к низкоуровнему API из-за неумения TPath.GetAttributes(path) работать
    //с папками типа C:\Document and Setting - нет прав и версия Sydney генерирует ошибку
    if fileAttrInt and faDirectory <> 0 {TFileAttribute.faDirectory in fileAttr} then begin
      node.ImageIndex := IMG_CLOSEDFOLDER;
      node.SelectedIndex := IMG_CLOSEDFOLDER;
      node.ExpandedImageIndex := IMG_OPENFOLDER;
      recItemNew.isDirectory := True;
      recItemNew.path := recItemNew.path + '\';
      recItemNew.ext := '';
    end
      else begin
        node.HasChildren := False;
        ext := TPath.GetExtension(nodeName);
        recItemNew.ext := ext;
        node.ImageIndex := IfThen(TArray.BinarySearch(KNOWNS_EXTENSION, ext, i), IMG_KNOWN, IMG_UNKNOWN);
        node.SelectedIndex := node.ImageIndex;
        recItemNew.isDirectory := False;
      end;

    FModel.Add(node, recItemNew);

    if fileAttrInt and faDirectory <> 0 {TFileAttribute.faDirectory in fileAttr} then
      node.HasChildren := containsChildren(node);
  end;

  recItem.isLoaded := True;
  FModel[aParentNode] := recItem;
end;

procedure TFormMain.tvDisksChanging(Sender: TObject; Node: TTreeNode;
  var AllowChange: Boolean);
var
  frame: TFrameCommon;
  recItem: TRecordItem;
  ext: string;
begin
  if Assigned(FActiveFrame) then
    FActiveFrame.Hide;
  recItem := FModel[Node];

  statMain.Panels[0].Text := '';
  statMain.Panels[1].Text := '';

  if recItem.isDirectory then
    Exit;

  statMain.Panels[0].Text := recItem.name;
  statMain.Panels[1].Text := recItem.path;

  frame := getFrame(recItem.ext);
  if Assigned(frame) then begin
    frame.LoadData(recItem);
    frame.Parent := pnlContent;
    frame.Visible := True;
    frame.Align := alClient;
  end;

  FActiveFrame := frame;
end;

procedure TFormMain.tvDisksClick(Sender: TObject);
var
  node: TTreeNode;
  recItem: TRecordItem;
begin
  node := tvDisks.Selected;
  if Assigned(node) then begin
    recItem := FModel[node];
  end;
end;

procedure TFormMain.tvDisksExpanded(Sender: TObject; Node: TTreeNode);
begin
  Node.ExpandedImageIndex := IMG_OPENFOLDER;
end;

procedure TFormMain.tvDisksExpanding(Sender: TObject; Node: TTreeNode;
  var AllowExpansion: Boolean);
var
  recItem: TRecordItem;
begin
  recItem := FModel[Node];

  if recItem.isLoaded then
    Exit;

  loadNode(Node);
end;

end.
