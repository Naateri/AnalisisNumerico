unit main_NLE;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Grids, nle_methods;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    TempResult: TEdit;
    StringGrid1: TStringGrid;
    procedure Button1Click(Sender: TObject);

  private
      Methods: TNLEMethods;

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var SL: TStringList;
  Res: Real;
begin
     {SL := TStringList.Create;
     SL.Add('3.14');
     SL.Add('1.23');
     SL.Add('1.2334');

     StringGrid1.Cols[ 1 ].Assign(SL); //how to fill a StringGrid with a TStringList}
     Methods := TNLEMethods.create;
     Methods.a := 1.5;
     Methods.b := 2.5;
     Res := Methods.Execute();
     TempResult.Text := FloatToStr(Res);
     StringGrid1.Cols[ 1 ].Assign(Methods.SolutionSequence);
     StringGrid1.Cols[ 2 ].Assign(Methods.ErrorSequence);

     Methods.Destroy;

end;

end.

