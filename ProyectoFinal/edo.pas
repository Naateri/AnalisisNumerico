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
    zn_s: array of Real;
    a, b: Real;
    parser: TParseMath;
    func_d: String;
    sedo_funcs: array of String;
    sedo_ans: array of Real;
    sedo_initial_values: array of Real;
    method: Integer;
    function euler(): Real;
    function heun(): Real;
    function rk4(): Real;
    function dormand_prince(): Real;
    function rk_fehlberg(): Real;
    function sedo_rk4(): Real;
    function Execute(): Real;
    private
      function fd(x: Real; y: Real): Real;
      function fd_sedo(x: Real; y: Real; z: Real; expr: String): Real;
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
  isFehlberg = 4;

constructor TEdo.create();
begin
     h := 0.2;
{     parser := TParseMath.create();
     parser.AddVariable('x', 0);
     parser.AddVariable('y', 0);
     parser.Expression:= 'x+y'; }
     SetLength(sedo_funcs, 2);
     SetLength(sedo_ans,2);
     SetLength(sedo_initial_values, 2);
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

function TEdo.fd_sedo(x: Real; y: Real; z: Real; expr: String): Real;
begin
     parser.NewValue('x', x);
     parser.NewValue('y', y);
     parser.NewValue('z', z);
     parser.Expression:= expr;
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

function TEdo.dormand_prince(): Real;
var
  iters, i: Integer;
  k1, k2, k3, k4, k5, k6, k7: Real;
  a21, a31, a32, a41, a42, a43, a51, a52, a53, a54, a61, a62, a63, a64, a65,
    a71, a72, a73, a74, a75, a76, c2, c3, c4, c5,
    b1, b2, b3, b4, b5, b6: Real;
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

     a21 :=  (1/5);
     a31 := (3/40);
     a32 := (9/40);
     a41 := (44/45);
     a42 := (-56/15);
     a43 := (32/9);
     a51 :=  (19372/6561);
     a52 :=(-25360/2187);
     a53 := (64448/6561);
     a54 := (-212/729);
     a61 := (9017/3168);
     a62 := (-355/33);
     a63 := (46732/5247);
     a64 := (49/176);
     a65 := (-5103/18656);
     a71 := (35/384);
     a72 := (0);
     a73 := (500/1113);
     a74 := (125/192);
     a75 := (-2187/6784);
     a76 := (11/84);

     c2 := (1/5);
     c3 := (3/10);
     c4 := (4/5);
     c5 := (8/9);

     b1 := (35/384);
     b2 := 0;
     b3 := (500/1113);
     b4 := (125/192);
     b5 := (-2187/6784);
     b6 := (11/84);

     for i := 1 to iters do
     begin
       xn_s[i] := xn_s[i-1] + h;
       k1 := fd(xn_s[i-1],yn_s[i-1]);
       k2 := fd(xn_s[i-1] + c2*h, yn_s[i-1]+h*(a21*k1)  );
       k3 := fd(xn_s[i-1] + c3*h, yn_s[i-1]+h*(a31*k1 + a32*k2));
       k4 := fd(xn_s[i-1] + c4*h, yn_s[i-1] + h*(a41*k1 + a42*k2 + a43*k3));
       k5 := fd(xn_s[i-1] + c5*h, yn_s[i-1] + h*(a51*k1 + a52*k2 + a53*k3 + a54*k4));
       k6 := fd(xn_s[i-1] + h, yn_s[i-1] + h*(a61*k1 + a62*k2 + a63*k3 + a64*k4 + a65*k5) );
       yn_s[i] := yn_s[i-1] + h * (b1*k1 + b3*k3 + b4*k4 + b5*k5 + b6*k6);
     end;

     //Result := xn_s[iters];
     Result := yn_s[iters]

end;

function TEdo.rk_fehlberg(): Real;
var
  iters, i: Integer;
  k1, k2, k3, k4, k5, k6, m: Real;
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
       k1 := h*fd(xn_s[i-1], yn_s[i-1]);
       k2 := h*fd(xn_s[i-1] + h/4, yn_s[i-1] + ( (1/4) * k1) );
       k3 := h*fd(xn_s[i-1] + (3/8)*h, yn_s[i-1] + ( (3/32) * k1 + (9/32) * k2) );
       k4 := h*fd(xn_s[i-1] + (12/13) * h, yn_s[i-1] + ( (1932/2197) * k1 - (7200/2197)*k2 + (7296/2197) * k3) );
       k5 := h*fd(xn_s[i-1] + h, yn_s[i-1] + ( (439/216) * k1 - 8*k2 + (3680/513) * k3 - (845/4104) * k4) );
       k6 := h*fd(xn_s[i-1] + (1/2) * h, yn_s[i-1] + ( (-8/27) * k1 + 2*k2 - (3544/2565) * k3 + (1859/4104) * k4 - (11/40) * k5) );

       //m := (25/216) * k1 + (1408/2565)*k3 + (2197/4101) * k4 - (1/5) * k5;
       m := (16/135) * k1 + (6656/12825)*k3 + (28561/56430) * k4 - (9/50) * k5 + (2/55) * k6;
       yn_s[i] := yn_s[i-1] + m;
       xn_s[i] := xn_s[i-1] + h;
{       ShowMessage('yn_s[i]: ' + FloatToStr(yn_s[i]));
       ShowMessage('xn_s[i]: ' + FloatToStr(xn_s[i])); }
//       ShowMessage('yn: ' + FloatToStr(yn_s[i]));
     end;

     Result := yn_s[iters];
end;

function TEdo.sedo_rk4(): Real;
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
     SetLength(zn_s, iters+1);
     answers[0] := x_0;
     xn_s[0] := x_0;
     yn_s[0] := sedo_initial_values[0];
     zn_s[0] := sedo_initial_values[1];

     for i := 1 to iters do begin
       k1 := fd_sedo(xn_s[i-1], yn_s[i-1], zn_s[i-1], sedo_funcs[0]);
       k2 := fd_sedo(xn_s[i-1] + h/2, yn_s[i-1] + ( h/2 * k1), zn_s[i-1] + ( h/2 * k1), sedo_funcs[0] );
       k3 := fd_sedo(xn_s[i-1] + h/2, yn_s[i-1] + ( h/2 * k2), zn_s[i-1] + ( h/2 * k2), sedo_funcs[0] );
       k4 := fd_sedo(xn_s[i-1] + h, yn_s[i-1] + ( h * k3), zn_s[i-1] + ( h * k3), sedo_funcs[0] );
       {k1 := h * fd(xn_s[i-1], yn_s[i-1]);
       k2 := h * fd(xn_s[i-1] + h/2, yn_s[i-1] + ( k1/2 ) );
       k3 := h * fd(xn_s[i-1] + h/2, yn_s[i-1] + ( k2/2 ) );
       k4 := h * fd(xn_s[i-1] + h, yn_s[i-1] + (k3) ); }
       m := (k1 + 2*k2 + 2*k3 + k4) / 6;
       yn_s[i] := yn_s[i-1] + h * m;

       k1 := fd_sedo(xn_s[i-1], yn_s[i-1], zn_s[i-1], sedo_funcs[1]);
       k2 := fd_sedo(xn_s[i-1] + h/2, yn_s[i-1] + ( h/2 * k1), zn_s[i-1] + ( h/2 * k1), sedo_funcs[1] );
       k3 := fd_sedo(xn_s[i-1] + h/2, yn_s[i-1] + ( h/2 * k2), zn_s[i-1] + ( h/2 * k2), sedo_funcs[1] );
       k4 := fd_sedo(xn_s[i-1] + h, yn_s[i-1] + ( h * k3), zn_s[i-1] + ( h * k3), sedo_funcs[1] );
       m := (k1 + 2*k2 + 2*k3 + k4) / 6;
       zn_s[i] := zn_s[i-1] + h * m;

       xn_s[i] := xn_s[i-1] + h;
//       ShowMessage('yn: ' + FloatToStr(yn_s[i]));
     end;
     Result := yn_s[iters];
     sedo_ans[0] := yn_s[iters];
     sedo_ans[1] := zn_s[iters];
end;



function TEdo.Execute(): Real;
begin
     if (method = isEuler) then
        Result := euler()
     else if (method = isHeun) then
        Result := heun()
     else if (method = isDormandPrince) then
        Result := dormand_prince()
     else if (method = isRk4) then
        Result := rk4()
     else if (method = isFehlberg) then begin
        Result := rk_fehlberg();
     end
     else
       Result := 0;
end;

end.

