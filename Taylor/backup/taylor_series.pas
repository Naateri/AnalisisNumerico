unit taylor_series;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, math, Dialogs;

type //definicion de la clase
    TTaylor = class
      x : Real;
      valid : Boolean;
      FunctionList: TStringList;
      FunctionType: Integer;
      function Execute(): Real;
      function sen(): Real;
      function cos(): Real;
      function tan(): Real;
      function arcsin(): Real;
      function arccos(): Real;
      function arctan(): Real;
      function exp(): Real;
      function ln(): Real;
      function senh(): Real;
      function cosh(): Real;
      private

      public //constructor y destructor deben ser publicos
        Error: Real;
        constructor create();
        destructor Destroy; override;

        end;

const
  Top = 1000;

implementation

const
  IsSin = 0;
  IsCos = 1;
  IsTan = 2;
  IsArcSin = 3;
  IsArcCos = 4;
  IsArcTan = 5;
  IsExp = 6;
  IsLn = 7;
  IsSinH = 8;
  IsCosH = 9;

function potencia(b: Real; n: Integer): Real;
var i: Integer;
    temp: Real;
begin
  //implementar
  //Result (o nombre de funcion) es
  //donde se guarda el resultado que devuelve
  //y ahi no termina la funcion
  //Para que termine: Se usa exit;
  {if (n = 0) then
  begin
       Result := 1;
       Exit;
  end;}
  temp := b;
  for i := 1 to n do
  begin
    temp := temp * b;
  end;
  Result := temp;
end;

function factorial(n: Integer): LongInt;
var temp, i: Integer;
begin
  {case n of //switch case
       0, 1: Result := 1;
       else Result := n * factorial(n-1); //recursividad
       //else: en lugar de default de C
  end;}
  if (n < 0) then
  begin
      ShowMessage('Factorial no legal. Revisar.');
      Exit;
  end;
  if (n <= 1) then
     Result := 1
  else
     begin
          temp := 1;
         for i := 2 to n do
         begin
              temp := temp * i;
         end;
         Result := temp;
     end;
end;

function Combinatorics(n:Integer; p: Integer): Real;
var temp: Integer;
begin
   {if (n > p) then
      begin
         temp := n;
         Result := 1;
         repeat
           Result := Result * temp;
           temp := temp - 1;
         until (temp = p+1);
         Result := Result / Factorial(p);
      end
   else}
      Result := (factorial(n) / ( factorial(p) * factorial(n-p) ));
end;

function Bernoulli(n:Integer): Real;
var k: Integer;
var Bk: Real;
begin
     Result := 0;
   if n = 0 then
      Result := 1
   else if (n mod 2 = 1) and (n > 1) then
      Result := 0
   else
       for k := 0 to n-1 do
          begin
               Bk := Bernoulli(k);
               Result := Result - (Combinatorics(n+1,k) * Bk);
          end;
        Result := Result / (n+1);
end;

constructor TTaylor.create(); //constructor
begin
  Error := 0.1;
  x := 1;
  FunctionList := TStringList.Create;
  FunctionList.AddObject('sin', TObject(IsSin));
  FunctionList.AddObject('cos', TObject(IsCos));
  FunctionList.AddObject('tan', TObject(IsTan));
  FunctionList.AddObject('arcsin', TObject(IsArcSin));
  FunctionList.AddObject('arccos', TObject(IsArcCos));
  FunctionList.AddObject('arctan', TObject(IsArcTan));
  FunctionList.AddObject('exp', TObject(IsExp));
  FunctionList.AddObject('ln', TObject(IsLn));
  FunctionList.AddObject('sinh', TObject(IsSinH));
  FunctionList.AddObject('cosh', TObject(IsCosH));
end;

destructor TTaylor.Destroy;
begin
  //destructor
  FunctionList.Destroy;
end;

function TTaylor.Execute(): Real;
begin
  valid:= True;
  case FunctionType of
       0: Result := sen(); //done
       1: Result := cos(); //done
       2: Result := tan();
       3: Result := arcsin();
       4: Result := arccos();
       5: Result := arctan(); //done
       6: Result := exp(); //done
       7: Result := ln();
       8: Result := senh();
       9: Result := cosh();
  end;
end;

function TTaylor.sen(): Real; //TTaylor.func porque es parte de la clase
var //n: Integer = 0;
    n: Integer;
    newError, xn, xnn: Real;
    //se puede usar el = si definimos UNA sola variable
    //i, n: Integer = 0; no es valido
begin
     Result := 0;
     n := 0;
     xn := 100000;
     repeat //equivalente a do{}while();
            xnn := xn;
            //Result := (potencia(-1, n) / (factorial( (2*n + 1) )) ) * potencia(x, 2*n + 1);
            Result := Result + (power(-1, n) / (factorial( (2*n) + 1 )) ) * power(x, (2*n) + 1);
            xn := Result;
            newError := abs(xn - xnn); //error absoluto aproximado
            n := n + 1;
     until ( (newError < Error) or (n > Top) );
     //Result := xn;
end;

function TTaylor.cos(): Real;
var n: Integer = 0;
    newError, xn, xnn: Real;
begin
     Result := 0;
     xn := 100000;
     repeat
            xnn := xn;
            Result := Result + (power(-1, n) / (factorial( (2*n) )) ) * power(x, 2*n);
            xn := Result;
            newError := abs(xn - xnn);
            n := n + 1;
     until ( (newError <= Error) or (n > Top) );

end;

function TTaylor.tan(): Real;
var n: Integer = 1;
    newError, xn, xnn: Real;
begin
     if ( abs(x) > pi/2) then
     begin
         ShowMessage('Valor no valido. Intente de nuevo.');
         valid := False;
         Exit;
     end;
     Result := 0;
     xn := 100000;
     repeat
            xnn := xn;
            Result := Result + ( Bernoulli(2*n) * power(-4, n) * (1 - power(4, n) )) / (factorial( (2*n) )) * power(x, 2*n - 1);
            xn := Result;
            newError := abs(xn - xnn);
            n := n + 1;
     until ( (newError <= Error) or (n > Top) );

end;


function TTaylor.arcsin(): Real;
var n: Integer = 0;
    newError, xn, xnn: Real;
begin
     if ( (abs(x) > 1) ) then
     begin
         ShowMessage('Valores no validos. Intente de nuevo.');
         valid:= False;
         Exit;
     end;
     Result := 0;
     xn := 100000;
     repeat
            xnn := xn;
            Result := Result + ( factorial(2*n) / ( power(4, n) * power( factorial(n), 2) * (2*n + 1) ) * power(x, 2*n + 1) );
            xn := Result;
            newError := abs(xn - xnn);
            n := n + 1;
     until ( (newError <= Error) or (n > Top) );

end;

function TTaylor.arccos(): Real;
var n: Integer = 0;
    newError, xn, xnn, temp: Real;
begin
     if ( (abs(x) > 1) ) then
     begin
         ShowMessage('Valores no validos. Intente de nuevo.');
         valid:= False;
         Exit;
     end;
     Result := pi/2;
     xn := 100000;
     repeat
            xnn := xn;
            Result := ( Result - ( factorial(2*n) / ( power(4, n) * power( factorial(n), 2) * (2*n + 1) ) * power(x, 2*n + 1) ) );
            xn := Result;
            newError := abs(xn - xnn);
            n := n + 1;
     until ( (newError <= Error) or (n > Top) );

//     Result := pi/2 - Result;
end;


function TTaylor.arctan(): Real;
var n: Integer = 0;
    newError, xn, xnn: Real;
begin
     if ( (abs(x) > 1) ) then
     begin
         ShowMessage('Valores no validos. Intente de nuevo.');
         valid := False;
         Exit;
     end;
     Result := 0;
     xn := 100000;
     repeat
            xnn := xn;
            Result := Result + (power(-1, n) / ( (2*n + 1) ) ) * power(x, 2*n + 1);
            xn := Result;
            newError := abs(xn - xnn);
            n := n + 1;
     until ( (newError <= Error) or (n > Top) );

end;

function TTaylor.exp(): Real;
var n: Integer = 0;
    newError, xn, xnn: Real;
begin
     Result := 0;
     xn := 100000;
     repeat
            xnn := xn;
            Result := Result + (power(x, n) / ( factorial(n) ) );
            xn := Result;
            newError := abs(xn - xnn);
            n := n + 1;
     until ( (newError <= Error) or (n > Top) );

end;

function TTaylor.ln(): Real;
var n: Integer = 1;
    newError, xn, xnn: Real;
begin

     Result := 0;
     xn := 100000;
     repeat
            xnn := xn;
            Result := Result + (power(-1, n+1)) * ( power(x-1, n) / ( n ) );
            xn := Result;
            newError := abs(xn - xnn);
            n := n + 1;
     until ( (newError <= Error) or (n > Top) );

end;


function TTaylor.senh(): Real;
var n: Integer = 0;
    newError, xn, xnn: Real;
begin
     Result := 0;
     xn := 100000;
     repeat
            xnn := xn;
            Result := Result + (power(x, 2*n + 1) / ( factorial(2*n + 1) ) );
            xn := Result;
            newError := abs(xn - xnn);
            n := n + 1;
     until ( (newError <= Error) or (n > Top) );

end;

function TTaylor.cosh(): Real;
var n: Integer = 0;
    newError, xn, xnn: Real;
begin
     Result := 0;
     xn := 100000;
     repeat
            xnn := xn;
            Result := Result + (power(x, 2*n) / ( factorial(2*n) ) );
            xn := Result;
            newError := abs(xn - xnn);
            n := n + 1;
     until ( (newError <= Error) or (n > Top) );

end;

end.

