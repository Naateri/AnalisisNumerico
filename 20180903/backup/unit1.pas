unit mainTest;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Menus, ParseMath;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    EdiF: TEdit;
    EdiX: TEdit;
    Memo1: TMemo;
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    Parse: TParseMath;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
     Parse := TParseMath.create();
     Parse.AddVariable('x', 0);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
     Parse.Expression:= EdiF.Text;
     Parse.NewValue('x', EdiX.Text);


end;

end.

