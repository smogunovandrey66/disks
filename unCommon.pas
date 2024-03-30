unit unCommon;

interface

const
  EXT_BMP = '.bmp';
  EXT_JPG = '.jpg';
  EXT_TXT = '.txt';
  KNOWNS_EXTENSION: TArray<String> = [EXT_BMP, EXT_JPG, EXT_TXT];

  IMG_CLOSEDFOLDER = 1;
  IMG_OPENFOLDER = 0;
  IMG_FLOPPY = 2;
  IMG_HARD = 3;
  IMG_NETWORK = 4;
  IMG_CDROM = 5;
  IMG_RAM = 6;
  IMG_KNOWN = 7;
  IMG_UNKNOWN = 8;

type
  TRecordItem = record
    isDirectory: Boolean;
    isLoaded: Boolean;
    path: string;
    name: string;
    ext: string;
  end;

implementation

end.
