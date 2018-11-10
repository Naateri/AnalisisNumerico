unit NonLinearSystem;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, MyMatrix, ParseMath, math, strings;

type
  mat = array of array of real;
  NLSystems = class
    ErrorAllowed: Real;
    SequenceX: TStringList;
    SequenceY: TStringList;
    ErrorSeq: TStringList;
    mistaken: Integer;
    num_equations: Integer;
    ecu1, ecu2, ecu3, ecu4: String;
    equations: array of String;
    variables: array of String;
    prev_solutions: array of Real;
    solutions: array of Real;
    start_x, start_y, start_z, start_w: Real;
    starts: array of Real;
    tempParse: TParseMath;
    function NewtonRaphson(): mat;
    private
      Error: Real;
      Parse: TParseMath;
      Matrices: MMatrix;
  public
  constructor create;
  destructor Destroy; override;

  end;


implementation

const Top = 10000;

constructor NLSystems.create;
begin
  SequenceX := TStringList.Create;
  SequenceY := TStringList.Create;
  ErrorSeq := TStringList.Create;
  Parse := TParseMath.create();
  Matrices := MMatrix.create;
  Parse.AddVariable('x', 0);
  Parse.AddVariable('y', 0);
  Parse.AddVariable('z', 0);
  Parse.AddVariable('w', 0);
  Parse.AddVariable('e', 2.71828183);
  Parse.AddVariable('t', 4.71828183);
  Matrices.rm1 := 4;
  Matrices.cm1 := 4;

  Matrices.rm2 := 4;
  Matrices.cm2 := 1;

  SequenceX.Add('');
  SequenceY.Add('');
  ErrorSeq.Add('');
  Error := Top;

end;

destructor NLSystems.Destroy;
begin
  SequenceX.Destroy;
  SequenceY.Destroy;
  ErrorSeq.Destroy;
  Parse.destroy;
  Matrices.Destroy;
end;

function NLSystems.NewtonRaphson(): mat;
var resA, resB, resC, resd, a, b, c, d, h, temp: Real;
    i, j, n: Integer;
    xn, Jacobian, i_Jac, points, temp2: mat;
    expr: String;
begin
     Matrices.rm1 := num_equations;
     Matrices.cm1 := num_equations;

     Matrices.rm2 := num_equations;
     Matrices.cm2 := 1;

     mistaken := 0;
     n := 0;
     Error := Top;
     h := ErrorAllowed / 10;
     SetLength(xn, num_equations, 1);
     SetLength(Jacobian, num_equations, num_equations);
     SetLength(points, num_equations, 1);
     SetLength(i_Jac, num_equations, num_equations);
     SetLength(temp2, num_equations, 1);

{     SetLength(xn, 2, 1);
     SetLength(Jacobian, 2, 2);
     SetLength(points, 2, 1);  }
//     setLength(equations, 4);
     setLength(variables, 4);
     setLength(prev_solutions, 4);
     setLength(solutions, 4);

{     equations[0] := ecu1;
     equations[1] := ecu2;
     equations[2] := ecu3;
     equations[3] := ecu4; }

     variables[0] := 'x';
     variables[1] := 'y';
     variables[2] := 'z';
     variables[3] := 'w';

{     solutions[0] := start_x;
     solutions[1] := start_y;
     solutions[2] := start_z;
     solutions[3] := start_w;}

     solutions[0] := starts[0];
     solutions[1] := starts[1];
     solutions[2] := starts[2];
     solutions[3] := starts[3];

     for i := 0 to num_equations - 1 do
         xn[i][0] := solutions[i];
     repeat
       for i := 0 to 3 do
           begin
                prev_solutions[i] := solutions[i];
                Parse.NewValue(variables[i], solutions[i]);
           end;
       for i := 0 to num_equations - 1 do
         begin
              Parse.Expression := equations[i];
              for j := 0 to num_equations - 1 do
                begin
                     temp := Parse.Evaluate();
                     Parse.NewValue(variables[j], solutions[j] + h);
                     Jacobian[i][j] := (Parse.Evaluate() - temp)/h;
                     //ShowMessage('Jacobian[i][j]: ' + FloatToStr(Jacobian[i][j]));
                     Parse.NewValue(variables[j], solutions[j]); //restoring default value
                end;
         end;


       for i := 0 to num_equations - 1 do
         begin
              Parse.Expression := equations[i];
              points[i][0] := Parse.Evaluate();
         end;

       Matrices.rm1 := num_equations;
       Matrices.cm1 := num_equations;

       Matrices.rm2 := num_equations;
       Matrices.cm2 := 1;

       i_Jac := Matrices.Inversa(Jacobian);

       //temp2 := Matrices.Multiplicacion(Jacobian, points);
       temp2 := Matrices.Multiplicacion(i_Jac, points);

       Matrices.rm1 := num_equations;
       Matrices.cm1 := 1;

       xn := Matrices.Resta(xn, temp2);
       Result := xn;
       for i := 0 to num_equations - 1 do
         begin
                 solutions[i] := xn[i][0];
//                 ShowMessage('xn : ' + FloatToStr(xn[i][0]));
         end;

       resA := prev_solutions[0];
       a := solutions[0];
       resB := prev_solutions[1];
       b := solutions[1];

       if (n > 0) then
          begin
            temp := 0;
               for i := 0 to num_equations - 1 do
                 begin
                      temp := temp +  power(prev_solutions[i] - solutions[i], 2);
                 end;
//            Error := sqrt( power((resA - a), 2) + power((resB - b), 2) );
              Error := sqrt(temp);
          end;
       ErrorSeq.Add( FloatToStr(Error) );
       {SequenceX.Add( FloatToStr(resA) );
       SequenceY.Add( FloatToStr(resB) );}
       n := n + 1;
     until (Error <= ErrorAllowed) or (n >= Top);
end;

end.

