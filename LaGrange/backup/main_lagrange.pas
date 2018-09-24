unit main_lagrange;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TAFuncSeries, Forms, Controls, Graphics,
  Dialogs, Grids, StdCtrls, lagrange_pol;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnGraph: TButton;
    Chart1: TChart;
    Chart1FuncSeries1: TFuncSeries;
    EdiPuntos: TEdit;
    Label1: TLabel;
    StringGrid1: TStringGrid;
    procedure btnGraphClick(Sender: TObject);
    procedure Chart1FuncSeries1Calculate(const AX: Double; out AY: Double);
    procedure FormCreate(Sender: TObject);
  private
    LaGrange: TLagrange;
    pts: array of array of Real;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Chart1FuncSeries1Calculate(const AX: Double; out AY: Double);
var
  i,j: Integer;
begin
     LaGrange := TLagrange.create;
     LaGrange.num_points := StrToInt(EdiPuntos.Text);
     //SetLength(pts, 2, LaGrange.num_points);
     SetLength(pts, LaGrange.num_points, 2);
     for i := 0 to LaGrange.num_points - 1 do
     begin
       for j := 0 to 1 do
       begin
         pts[i][j] := StrToFloat(StringGrid1.Cells[j,i]);
       end;
     end;
     LaGrange.points := pts;

     AY := LaGrange.find_pol(AX);
end;

procedure TForm1.btnGraphClick(Sender: TObject);
var i, j: Integer;
begin
{     LaGrange.num_points := StrToInt(EdiPuntos.Text);
     //SetLength(pts, 2, LaGrange.num_points);
     SetLength(pts, LaGrange.num_points, 2);
     for i := 0 to LaGrange.num_points - 1 do
     begin
       for j := 0 to 1 do
       begin
         pts[i][j] := StrToFloat(StringGrid1.Cells[j,i]);
       end;
     end;
     LaGrange.points := pts;
}
     Chart1FuncSeries1.Active:= False;
     Chart1FuncSeries1.Pen.Color := clBlue;
     Chart1FuncSeries1.Active:= True;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
//  LaGrange := TLagrange.create;
end;

end.

