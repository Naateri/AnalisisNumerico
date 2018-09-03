unit nle_methods;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, math, Dialogs, ParseMath;

type
    TNLEMethods = class
      ErrorAllowed: Real;
      //x: Real;
      a, b: Real; //bounds
      error: Real;
      globalBolzano: Boolean;
      nSequence: TStringList;
      Method: Integer;
      MethodList: TStringList;
      ErrorSequence: TStringList;
      SolutionSequence: TStringList;
      func: String;
      Parse: TParseMath;
      function f(x: Real): Real;
      function fd(x: Real): Real; //differential

      private
        function Bolzano(): Boolean;
        function Bisection(): Real;
        function FakePosition(): Real;
        function Newton(): Real;
        function Secante(): Real;

      public
        constructor create;
        destructor Destroy; override;
        function Execute(): Real;

      end;
    const
         IsBisection = 0;
         IsFakePos = 1;
         IsNewton = 2;
         IsSecant = 3;

implementation

const
     Top = 10000;

constructor TNLEMethods.create;
begin
     ErrorSequence := TStringList.Create;
     SolutionSequence := TStringList.Create;
     nSequence := TStringList.Create;
     MethodList := TStringList.Create;
//     ErrorSequence.Add(' ');
//     SolutionSequence.Add(' ');
     error:= 0.0001;
     MethodList.AddObject('Biseccion', TObject (IsBisection) );
     MethodList.AddObject('Falsa Posicion', TObject (IsFakePos) );
     MethodList.AddObject('Newton', TObject (IsNewton) );
     MethodList.AddObject('Secante', TObject (IsSecant) );
{     Parse := TParseMath.create();
     Parse.AddVariable( 'x', 0);
     Parse.Expression:= 'x';}
end;

destructor TNLEMethods.Destroy;
begin
     ErrorSequence.Destroy;
     SolutionSequence.Destroy;
     nSequence.Destroy;
     MethodList.Destroy;
     Parse.destroy;
end;

function TNLEMethods.f(x: Real): Real;
begin
     Result := 2.3 * exp(0.5*x) + 3 * power(x,4) -  power(x, 3) + power (x,2) + 3*x - 4;
     //Result := power(x, 2) - ln(x) - sin(x) - x;
{     Parse.Expression := func;
     Parse.NewValue('x', x);
     Result := Parse.Evaluate();}
end;

function TNLEMethods.fd(x: Real): Real;
var
   h: Real;
begin
     h := error/10;
     Result := ( f(x+h) - f(x-h) ) / (2*h) ;
end;

function TNLEMethods.Bolzano(): Boolean;
begin
     if ( ( f(a) * f(b) ) < 0) then
     begin
        Result := True;
        globalBolzano := True;
     end
     else
     begin
        Result := False;
        globalBolzano:= False;
     end;
end;

function TNLEMethods.Bisection(): Real;
var n: Integer = 0;
   xn, xnn, newError: Real; //xnn: newest result, xn: stores previous result
   newA, newB: Real;
   sign: Real;
   evalBolzano: Boolean;
begin
//     Parse.Expression := func;
     evalBolzano:= Bolzano();
     if (not evalBolzano) then
     begin
          ShowMessage('No se cumple el Teorema de Bolzano. Escoja otro intervalo.');
          Exit;
     end;
     newA := a;
     newB := b;
     xnn := (a + b) / 2; //first xn
     newError := 10;
     repeat
       nSequence.Add(IntToStr(n));
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
            newA := xnn
       else //xn is solution
            begin
                if (newA = 0) then
                   Result := xnn
                else //xn is 0
                   Result := newA;
                Exit;
            end;

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
//     Parse.Expression:= func;
     evalBolzano:= Bolzano();
     if (not evalBolzano) then
     begin
          ShowMessage('No se cumple el Teorema de Bolzano. Escoja otro intervalo.');
          Exit;
     end;
     newA := a;
     newB := b;
     xnn := a - ( f(a) ) * ( (b - a)/(f(b) - f(a)) ); //first xn
     newError := 10;
     repeat
       nSequence.Add(IntToStr(n));
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

       sign := f(newA) * f(xnn);
       if ( sign < 0) then
          newB := xnn
       else if (sign > 0) then
            newA := xnn
       else //xn is solution
            begin
                if (newA = 0) then
                   Result := xnn
                else //xn is 0
                   Result := newA;
                Exit;
            end;

       n := n + 1;
     until ( (newError <= error) or (n > Top) );
     Result := xnn;
end;

function TNLEMethods.Newton(): Real;
var n: Integer = 0;
   xn, xnn, newError: Real; //xnn: newest result, xn: stores previous result
   fxn, fdxn: Real;
begin
//     Parse.Expression:= func;
     xnn := a; //first xn
     newError := 10;
     //SolutionSequence.Add(FloatToStr(xnn));
     repeat
       nSequence.Add(IntToStr(n));
       xn := xnn; //storing previous value
       fdxn := fd(xn);
       if (fdxn = 0) then
       begin
           xn := xn + 0.1;
           fdxn := fd(xn);
       end;
       fxn:= f(xn);
       xnn := xn - (fxn/fdxn);
       SolutionSequence.Add(FloatToStr(xnn));
       if (n > 0) then
       begin
              newError := abs(xn - xnn);
              ErrorSequence.Add(FloatToStr(newError));
       end
       else
           ErrorSequence.Add('-');

       n := n + 1;
     until ( (newError <= error) or (n > Top) );
     Result := xnn;
end;

function TNLEMethods.Secante(): Real;
var n: Integer = 0;
   xn, xnn, newError: Real; //xnn: newest result, xn: stores previous result
   h, fxn, fxnh: Real;
begin
//     Parse.Expression:= func;
     h := error/10;
     xnn := a; //first xn
     newError := 10;
     //SolutionSequence.Add(FloatToStr(xnn));
     repeat
       nSequence.Add(IntToStr(n));
       xn := xnn; //storing previous value
       fxn := f(xn);
       fxnh := f(xn+h) - f(xn-h);
       if (fxnh = 0) then
       begin
           xn := xn + 0.1;
           fxnh := f(xn+h) - f(xn-h);
       end;
       xnn := xn - ( ( 2*h*(fxn) ) / fxnh);
       SolutionSequence.Add(FloatToStr(xnn));
       if (n > 0) then
       begin
              newError := abs(xn - xnn);
              ErrorSequence.Add(FloatToStr(newError));
       end
       else
           ErrorSequence.Add('-');

       n := n + 1;
     until ( (newError <= error) or (n > Top) );
     Result := xnn;
end;


function TNLEMethods.Execute(): Real;
begin
     case Method of
          IsBisection: Result := Bisection();
          IsFakePos: Result := FakePosition();
          IsNewton: Result := Newton();
          IsSecant: Result := Secante();
     end;
end;

end.

