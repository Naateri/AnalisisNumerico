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
    btnFindY: TButton;
    Chart1: TChart;
    Chart1FuncSeries1: TFuncSeries;
    EdiPuntos: TEdit;
    ediX: TEdit;
    ediYVal: TEdit;
    Label1: TLabel;
    MemFunction: TMemo;
    StringGrid1: TStringGrid;
    procedure btnFindYClick(Sender: TObject);
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
{     LaGrange := TLagrange.create;
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
     MemFunction.Clear;
     MemFunction.Append(LaGrange.polinomy);
     ShowMessage(LaGrange.polinomy);
 }
     AY := LaGrange.find_pol(AX);
end;

procedure TForm1.btnGraphClick(Sender: TObject);
var i, j: Integer;
  func: String;
begin
//     LaGrange := TLagrange.create;
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
          MemFunction.Clear;
          func := LaGrange.find_text();
          MemFunction.Append(func);
//          ShowMessage(func);

     Chart1FuncSeries1.Active:= False;
     Chart1FuncSeries1.Pen.Color := clBlue;
     Chart1FuncSeries1.Active:= True;
end;

procedure TForm1.btnFindYClick(Sender: TObject);
var x: Real;
begin
      x := StrToFloat(ediX.Text);
      ediYVal.Text := FloatToStr(LaGrange.find_pol(x));
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  LaGrange := TLagrange.create;
end;

end.

