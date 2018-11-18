unit edo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ParseMath, Dialogs, math;

type
  TEdo = class
    f: String;
    x_0, y_0, y_n, h: Real;
    answers: array of Real;
    xn_s: array of Real;
    yn_s: array of Real;
    a, b: Real;
    parser: TParseMath;
    func_d: String;
    method: Integer;
    function euler(): Real;
    function heun(): Real;
    function rk4(): Real;
    function Execute(): Real;
    private
      function fd(x: Real; y: Real): Real;
      function f_euler(i: Integer): Real;
    public
      constructor create();
      destructor Destroy; override;
  end;

implementation

const
  isEuler = 0;
  isHeun = 1;
  isDormandPrince = 3;
  isRk4 = 2;

constructor TEdo.create();
begin
     h := 0.2;
{     parser := TParseMath.create();
     parser.AddVariable('x', 0);
     parser.AddVariable('y', 0);
     parser.Expression:= 'x+y'; }
end;

destructor TEdo.Destroy;
begin
     h := 0;
//     parser.destroy;
end;

function TEdo.fd(x:Real; y:Real):Real;
begin
     parser.NewValue('x', x);
     parser.NewValue('y', y);
     parser.Expression:= func_d;
     Result := parser.Evaluate();
end;

function TEdo.f_euler(i: Integer): Real;
begin
     Result := yn_s[i] + h * fd(xn_s[i], yn_s[i]);
end;

function TEdo.euler(): Real;
var
  iters, i: Integer;
begin
     iters := round ((b-a) / h);
     h := Sign(b-a) * h;
     iters := abs(iters);
     SetLength(answers, iters+1);
     SetLength(xn_s, iters+1);
     SetLength(yn_s, iters+1);
     answers[0] := x_0;
     xn_s[0] := x_0;
     yn_s[0] := y_0;
     for i := 1 to iters do
     begin
       //temp := start +
       yn_s[i] := yn_s[i-1] + h*fd(xn_s[i-1],yn_s[i-1]);
//       ShowMessage('f(x_' + IntToStr(i) + ') = ' + FloatToStr(yn_s[i]));
       xn_s[i] := xn_s[i-1] + h;
     end;

     //Result := xn_s[iters];
     Result := yn_s[iters]
end;

function TEdo.heun(): Real;
var
  iters, i: Integer;
  temp_yn: Real;
begin
     iters := round ((b-a) / h);
     h := Sign(b-a) * h;
     iters := abs(iters);

     SetLength(answers, iters+1);
     SetLength(xn_s, iters+1);
     SetLength(yn_s, iters+1);
     answers[0] := x_0;
     xn_s[0] := x_0;
     yn_s[0] := y_0;
     for i := 1 to iters do
     begin
       //temp := start +
       temp_yn := f_euler(i-1);
       xn_s[i] := xn_s[i-1] + h;
       yn_s[i] := yn_s[i-1] + h/2 * (fd(xn_s[i-1], yn_s[i-1]) +
               fd(xn_s[i], temp_yn) );
     end;

     //Result := xn_s[iters];
     Result := yn_s[iters]
end;

function TEdo.rk4(): Real;
var
  iters, i: Integer;
  k1, k2, k3, k4, m: Real;
begin
     iters := round ((b-a) / h);
     h := Sign(b-a) * h;
     iters := abs(iters);

     SetLength(answers, iters+1);
     SetLength(xn_s, iters+1);
     SetLength(yn_s, iters+1);
     answers[0] := x_0;
     xn_s[0] := x_0;
     yn_s[0] := y_0;

     for i := 1 to iters do begin
       k1 := fd(xn_s[i-1], yn_s[i-1]);
       k2 := fd(xn_s[i-1] + h/2, yn_s[i-1] + ( h/2 * k1) );
       k3 := fd(xn_s[i-1] + h/2, yn_s[i-1] + ( h/2 * k2) );
       k4 := fd(xn_s[i-1] + h, yn_s[i-1] + ( h * k3) );
       {k1 := h * fd(xn_s[i-1], yn_s[i-1]);
       k2 := h * fd(xn_s[i-1] + h/2, yn_s[i-1] + ( k1/2 ) );
       k3 := h * fd(xn_s[i-1] + h/2, yn_s[i-1] + ( k2/2 ) );
       k4 := h * fd(xn_s[i-1] + h, yn_s[i-1] + (k3) ); }
       m := (k1 + 2*k2 + 2*k3 + k4) / 6;
       yn_s[i] := yn_s[i-1] + h * m;
       xn_s[i] := xn_s[i-1] + h;
//       ShowMessage('yn: ' + FloatToStr(yn_s[i]));
     end;

     Result := yn_s[iters];
end;

function TEdo.Execute(): Real;
begin
     if (method = isEuler) then
        Result := euler()
     else if (method = isHeun) then
        Result := heun()
     else if (method = isDormandPrince) then
        Result := 0
     else if (method = isRk4) then
        Result := rk4();
end;

end.
