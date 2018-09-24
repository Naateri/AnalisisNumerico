unit mainNLSystems;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, ExtCtrls, Grids, MyMatrix, ParseMath, NonLinearSystem, Types;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnFindSol: TButton;
    Ecu1: TLabel;
    Ecu2: TLabel;
    EdiEcu1: TEdit;
    EdiError: TEdit;
    EdiEcu3: TEdit;
    EdiEcu4: TEdit;
    EdiEcus: TEdit;
    EdiWStart: TEdit;
    EdiWVal: TEdit;
    EdiZStart: TEdit;
    EdiZVal: TEdit;
    EdiYStart: TEdit;
    EdiXStart: TEdit;
    EdiXVal: TEdit;
    EdiYVal: TEdit;
    EdiEcu2: TEdit;
    EAllowed: TLabel;
    GridErrors: TStringGrid;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Y_start: TLabel;
    X_start: TLabel;
    YVal: TLabel;
    XVal: TLabel;
    procedure btnFindSolClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    //Parse: TParseMath;
    //XValue, YValue: Real;
    Solver: NLSystems;
    //final_result: mat;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
     //Solver.create;
     //Parse.create();
     //Parse := TParseMath.create();
     Solver := NLSystems.create;
end;

procedure TForm1.btnFindSolClick(Sender: TObject);
var
  final_result: MyMatrix.mat;
begin
//     Solver := NLSystems.create;
     Solver.ecu1 := EdiEcu1.Text;
     Solver.ecu2 := EdiEcu2.Text;
     Solver.ecu3 := EdiEcu3.Text;
     Solver.ecu4 := EdiEcu4.Text;
     //SetLength(final_result, 4, 1);
     Solver.ErrorAllowed := StrToFloat(EdiError.Text);
     Solver.start_x := StrToFloat(EdiXStart.Text);
     Solver.start_y := StrToFloat(EdiYStart.Text);
     Solver.start_z := StrToFloat(EdiZStart.Text);
     Solver.start_w := StrToFloat(EdiWStart.Text);
     Solver.num_equations := StrToInt(EdiEcus.Text);
     final_result := Solver.NewtonRaphson();
     EdiXVal.Text := FloatToStr(final_result[0,0]);
     EdiYVal.Text := FloatToStr(final_result[1,0]);
//     EdiZVal.Text := FloatToStr(final_result[2,0]);
//     EdiWVal.Text := FloatToStr(final_result[3,0]);
//     Solver.Destroy;
end;

end.

