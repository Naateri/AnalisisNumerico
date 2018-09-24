unit MyMatrix;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, Grids, math;

type
  mat = array of array of real;
  MMatrix = class
    Esc: Real;
    Sequence: TStringList;
    ErrorSeq: TStringList;
    FunctionList: TStringList;
    FunctionList2: TStringList;
    FunctionType: Integer;
    FunctionType2: Integer;
    mistaken: Integer;
    mat1, mat2, ret: mat;
    gmat1, gmat2, resultMat, temp_mat: TStringGrid;
    rm1, rm2, cm1, cm2, rm3, cm3: Integer; //rows of mat 1/2, cols of mat 1/2
    function Sum(A,B: mat): mat;
    function Resta(A,B: mat): mat;
    function Multiplicacion(A,B: mat): mat;
    function Escalar(n: Real; A: mat): mat;
    function Transpuesta(A: mat): mat;
    function Adjunta(X: mat): mat;
    function Inversa(A: mat): mat;
    function m_Power(X: mat; n: Integer): mat;
    function Division(A, B: mat): mat;
    //function Triang(): mat;
    function Execute(A,B: mat; n: Real): mat;
    function Traza(): Real;
    function Determinante(A: mat; row, col: Integer): Real;
    function Execute2(A: mat; row, col: Integer): Real;
    private
      public

      constructor create;
      destructor Destroy; override;

  end;

const
  IsSum = 0;
  IsResta = 1;
  IsMult = 2;
  IsEsc = 3; //escalar
  IsTrans = 4;
  IsAdj = 5;
  IsInv = 6;
  IsPow = 7;
  IsDiv = 8;
  IsTriang = 9;

  IsDet = 0; //determinante
  IsTr = 1;  //traza

implementation

constructor MMatrix.create;
begin
  Sequence := TStringList.Create;
  FunctionList := TStringList.Create;
  FunctionList2 := TStringList.Create;
  FunctionList.AddObject('Suma', TObject( IsSum ));
  FunctionList.AddObject('Resta', TObject( IsResta ));
  FunctionList.AddObject('Multiplicacion', TObject( IsMult ));
  FunctionList.AddObject('Escalares', TObject( IsEsc ));
  FunctionList.AddObject('Transpuesta', TObject( IsTrans ));
  FunctionList.AddObject('Adjunta', TObject( IsAdj ));
  FunctionList.AddObject('Inversa', TObject( IsInv ));
  FunctionList.AddObject('Potencia', TObject( IsPow ));
  FunctionList.AddObject('Division', TObject( IsDiv ));
  FunctionList2.AddObject('Determinante', TObject( IsDet ));
  FunctionList2.AddObject('Traza', TObject( IsTr ));
  Sequence.Add('');
end;

destructor MMatrix.Destroy;
begin
  Sequence.Destroy;
  FunctionList.Destroy;
  resultMat.Destroy;
end;

function MMatrix.Execute(A,B: mat; n:Real): mat;
var i,j:Integer;
begin

  case FunctionType of
         IsSum: Result := Sum(A,B);
         IsResta: Result := Resta(A,B);
         IsMult: Result := Multiplicacion(A,B);
         IsEsc: Result := Escalar(n, A); //escalar
         IsTrans: Result := Transpuesta(A);
         IsAdj: Result := Adjunta(A);
         IsInv: Result := Inversa(A);
         IsPow: Result := m_Power(A, Intptr(n));
         IsDiv: Result := Division(A,B);
  end;

{ resultMat.ColCount := cm3;
  resultMat.RowCount := rm3;
  for i := 0 to rm3 -1 do
  begin
      for j := 0 to cm3 -1 do
            resultMat.Cells[j,i] := FloatToStr(Result[i,j]);
  end;}
end;

function MMatrix.Sum(A,B: mat): mat;
var
  i, j: Integer;
begin
     if ( (rm1 = rm2) and (cm1 = cm2) ) then
     begin
       SetLength(ret, rm1, cm1);
       cm3 := cm1;
       rm3 := rm1;
       for i := 0 to rm1 - 1 do
       begin
            for j := 0 to cm1 - 1 do
            begin
                ret[i,j] := A[i,j] + B[i,j];
                //ret[j,i] := A[j,i] + B[j,i];
            end;
       end;
         Result := ret;
     end
     else
     begin
         ShowMessage('No se puede realizar la suma.');
         Exit;
     end;

end;

function MMatrix.Resta(A,B: mat): mat;
var
  i, j: Integer;
begin
     if ( (rm1 = rm2) and (cm1 = cm2) ) then
     begin
       SetLength(ret, rm1, cm1);
       cm3 := cm1;
       rm3 := rm1;
       for i := 0 to rm1-1 do
       begin
            for j := 0 to cm1-1 do
//                ret[i,j] := strToFloat(gmat1.Cells[i,j]) - strToFloat(gmat2.Cells[i,j]);
                  ret[i,j] := A[i,j] - B[i,j];
       end;
       Result := ret;
     end
     else
     begin
         ShowMessage('No se puede realizar la resta.');
         Exit;
     end;

end;

function MMatrix.Multiplicacion(A,B: mat): mat;
var
  i, j, k: Integer;
  reslt, suma: Real;
begin
     if ( (cm1 <> rm2) ) then
     begin
       ShowMessage('No se puede realizar la multiplicacion.');
       Exit;
     end
     else
       rm3 := rm1;
       cm3 := cm2;
       SetLength(ret, rm3, cm3);
       for i:= 0 to rm1-1 do
       begin
           for j := 0 to cm2 - 1 do
               ret[i,j] := 0;
       end;
       for i := 0 to rm1-1 do
       begin
            for j := 0 to cm2-1 do
            begin
                suma := 0;
                for k := 0 to cm1-1 do
                begin
                    //reslt := A[i,k] * B[k,j];
                    //suma := suma + reslt;
                    ret[i,j] := ret[i,j] + (A[i,k] * B[k,j]);
                end;
                //ret[i,j] := suma;
            end;
       end;
       Result := ret;
end;


function MMatrix.Escalar(n: Real; A: mat): mat;
var
  i, j: Integer;
begin
       SetLength(ret, rm1, cm1);
       rm3 := rm1;
       cm3 := cm1;
       for i := 0 to rm1-1 do
       begin
            for j := 0 to cm1-1 do
//                ret[i,j] := Esc * StrToFloat(gmat1.Cells[i,j]);
                  ret[i,j] := n * A[i,j];
       end;
       Result := ret;
end;

function MMatrix.Transpuesta(A: mat): mat;
var
  i, j: Integer;
begin
       SetLength(ret, rm1, cm1);
       cm3 := cm1;
       rm3 := rm1;
       for i := 0 to rm1-1 do
       begin
            for j := 0 to cm1-1 do
//                ret[i,j] := StrToFloat(gmat1.Cells[j,i]);
                  ret[i,j] := A[j,i];
       end;
       Result := ret;
end;

function MMatrix.Adjunta(X: mat): mat;
var
  i, j, a, b, a_factor, b_factor: Integer;
   temp_res: Real;
  le_mat, mat_temp: mat; //determinants
begin
     setLength(mat_temp, rm1, cm1);
     setLength(ret, rm1, cm1);
     for i := 0 to rm1-1 do
     begin
         for j:= 0 to cm1-1 do
             mat_temp[i,j] := X[i,j];
             ret[i,j] := 0;
     end;
     setLength(le_mat, rm1-1, cm1-1);
     cm3 := cm1;
     rm3 := rm1;
     for i := 0 to rm1-1 do
     begin
          for j := 0 to cm1-1 do
              begin
                  a_factor := 0;
                   for a := 0 to cm1-1 do //filling le_mat: matrix to find determinant of
                       begin
                       b_factor:=0;
                         if (a = i) then
                              begin
                                a_factor := 1;
                                 Continue;
                              end;
                           for b := 0 to rm1-1 do
                               begin
                                    if (b = j) then
                                         begin
                                           b_factor := 1;
                                            Continue;
                                         end;
                                    le_mat[a-a_factor,b-b_factor] := mat_temp[a,b];
                               end;
                       end;
                    temp_res := power(-1, i+j+2) * Determinante(le_mat, rm1-1, cm1-1);
                    ret[i,j] := temp_res;
              end;
     end;
     Result := ret;
end;

function MMatrix.Inversa(A: mat): mat;
var
  i,j: Integer;
  mat_temp: mat;
  det, temp: Real;
begin
    setLength(mat_temp, rm1, cm1);
    setLength(ret, rm1, cm1);
    for i := 0 to rm1-1 do
     begin
         for j:= 0 to cm1-1 do
               mat_temp[i,j] := A[i,j];
     end;
    if (Determinante(mat_temp, rm1, cm1) = 0) then
       begin
       ShowMessage('No se puede hallar la inversa de esta matriz.');
       Exit;
       end
    else
        begin
            Esc := 1 / (Determinante(mat_temp, rm1, cm1));
            mat_temp := Adjunta(mat_temp);
            //TRANSPUESTA
            ret := Transpuesta(mat_temp);
            //ESCALAR POR 1/DETERMINANTE
            ret := Escalar(Esc, ret);
        end;
        Result := ret;

end;

function MMatrix.m_Power(X: mat; n: Integer): mat;
var
  i, j: Integer;
begin
     setLength(ret, rm1, cm1);
     rm3 := rm1;
     cm3 := cm1;
     //ret := X;
     //Result := X;
     for i := 0 to rm1-1 do
      begin
          for j:= 0 to cm1-1 do
              ret[i,j] := X[i,j];
      end;
     for i := 0 to n-1 do
      begin
           ret := Multiplicacion(ret, ret);
           setLength(ret, rm1, cm1);
      end;
     //Result := X;
     Result := ret;
end;

function MMatrix.Division(A,B: mat): mat;
var
  i: Integer;
begin
     if (rm1 <> cm2) then
     begin
          ShowMessage('No se puede hallar la division entre estas matrices.');
          Exit;
     end;
     B := Inversa(B);
     setLength(ret, rm2, cm1);
     cm3 := cm1;
     rm3 := rm2;
     Result := Multiplicacion(A, B); //A * B^(-1)
     //Result := ret;
end;


function MMatrix.Traza(): Real;
var
  i: Integer;
begin
     if (rm1 <> cm1) then
     begin
       ShowMessage('La cantidad de filas es diferente a la cantidad de columnas.');
       Exit;
     end
     else
     begin
         Result := 0;
         for i := 0 to rm1 - 1 do
             Result := Result + StrToFloat(gmat1.Cells[i, i]);
     end;
end;

function MMatrix.Determinante(A: mat; row, col: Integer): Real;
var
  b: mat;
  i,j,n: Integer;
begin
  if (row = 1) then
  begin
         Result := A[0,0];
         Exit;
  end;
  if (row <> col) then
       begin
         ShowMessage('La cantidad de filas es diferente a la cantidad de columnas.');
         Exit;
         end
  else
       begin
           SetLength(b, row, col);
           if (row = 2) then
                Result := A[0,0] * A[1,1] - A[0,1] * A[1,0]
           else
           begin
              Result := 0;
              for n := 0 to row-1 do
              begin
                for i := 1 to row-1 do
                begin
                    for j:= 0 to n-1 do
                        b[i-1, j] := A[i,j];
                    for j:= n+1 to row-1 do
                        b[i-1, j-1] := A[i,j];
                end;
                if (n+2) mod 2 = 0 then
                     i := 1
                else i := -1;
                Result := Result + i * A[0,n] * Determinante(b, row-1, col-1);
              end;
           end;

        end;
  end;

function MMatrix.Execute2(A: mat; row, col: Integer): Real;
begin

  case FunctionType2 of
         IsDet: Result := Determinante(A, row, col);
         IsTr: Result := Traza();
  end;

end;


end.

