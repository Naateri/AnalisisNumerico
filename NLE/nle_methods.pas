unit nle_methods;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, math, Dialogs;

type
    TNLEMethods = class
      ErrorAllowed: Real;
      //x: Real;
      a, b: Real; //bounds
      error: Real;
      ErrorSequence: TStringList;
      SolutionSequence: TStringList;
      function f(x: Real): Real;

      private
        function Bolzano(): Boolean;
        function Bisection(): Real;
        function FakePosition(): Real;


      public
        constructor create;
        destructor Destroy; override;
        function Execute(): Real;

      end;

implementation

const
     Top = 10000;

constructor TNLEMethods.create;
begin
     ErrorSequence := TStringList.Create;
     SolutionSequence := TStringList.Create;
//     ErrorSequence.Add(' ');
//     SolutionSequence.Add(' ');
     error:= 0.001;
end;

destructor TNLEMethods.Destroy;
begin
     ErrorSequence.Destroy;
     SolutionSequence.Destroy;
end;

function TNLEMethods.f(x: Real): Real;
begin
     //Result := power(x, 3);
     Result := power(x, 2) - ln(x) - sin(x) - x;
end;

function TNLEMethods.Bolzano(): Boolean;
begin
     if ( ( f(a) * f(b) ) < 0) then
        Result := True
     else
        Result := False;
end;

function TNLEMethods.Bisection(): Real;
var n: Integer = 0;
   xn, xnn, newError: Real; //xnn: newest result, xn: stores previous result
   newA, newB: Real;
   sign: Real;
   evalBolzano: Boolean;
begin
     evalBolzano:= Bolzano();
     if (not evalBolzano) then
     begin
          ShowMessage('No se cumple el Teorema de Bolzano. Escoja otro intervalo.');
          Exit;
     end;
     newA := a;
     newB := b;
     xnn := (a + b) / 2; //first xn
     repeat
       xn := xnn; //storing previous value
       xnn := (newA + newB) / 2;
       SolutionSequence.Add(FloatToStr(xnn));
       if (n > 0) then
       begin
              newError := abs(xn - xnn);
              ErrorSequence.Add(FloatToStr(newError));
       end
       else
           ErrorSequence.Add('-');

       sign := f(newA) * f(xnn);
       if ( sign < 0) then
       begin
          newB := xnn;
       end
       else if (sign > 0) then
            newA := xnn;
       {else //xn is solution
            begin
                if (newA = 0) then
                   Result := xnn
                else //xn is 0
                   Result := newA;
                Exit;
            end; }

       n := n + 1;
     until ( (newError <= error) or (n > Top) );
     Result := xnn;
end;

function TNLEMethods.FakePosition(): Real;
var n: Integer = 0;
   xn, xnn, newError: Real; //xnn: newest result, xn: stores previous result
   newA, newB: Real;
   sign: Real;
   evalBolzano: Boolean;
begin
     evalBolzano:= Bolzano();
     if (not evalBolzano) then
     begin
          ShowMessage('No se cumple el Teorema de Bolzano. Escoja otro intervalo.');
          Exit;
     end;
     newA := a;
     newB := b;
     xnn := a - ( f(a) ) * ( (b - a)/(f(b) - f(a)) ); //first xn
     repeat
       xn := xnn;
       xnn := newA - ( f(newA) ) * ( (newB - newA)/(f(newB) - f(newA)) );
       SolutionSequence.Add(FloatToStr(xnn));
       if (n >= 1) then
       begin
              newError := abs(xn - xnn);
              ErrorSequence.Add(FloatToStr(newError));
       end
       else
           ErrorSequence.Add('-');

       sign := f(a) * f(xnn);
       if ( sign < 0) then
          newA := xnn
       else if (sign > 0) then
            newB := xnn
       else //xn is solution
            begin
                if (a = 0) then
                   Result := xnn
                else //xn is 0
                   Result := a;
                Exit;
            end;

       n := n + 1;
     until ( (newError <= error) or (n > Top) );
     Result := xnn;
end;

function TNLEMethods.Execute(): Real;
begin
     Result := Bisection();
end;

end.

