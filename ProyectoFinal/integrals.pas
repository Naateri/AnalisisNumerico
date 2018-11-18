unit Integrals;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, math, ParseMath, Dialogs;

type
    TIntegralMethods = class
      h: Real;
      //x: Real;
      a, b: Real; //bounds
      h_1: Real;
      Method: Integer;
      MethodList: TStringList;
      area: Boolean;
      //ErrorSequence: TStringList;
      //SolutionSequence: TStringList;
      func: String;
      Parse: TParseMath;
      function f(x: Real): Real;

      private
        function Trapecio(): Real;
        function Simpson_1_3(): Real;
        function Simpson_3_8(): Real;

      public
        constructor create;
        destructor Destroy; override;
        function Execute(): Real;

      end;
    const
         IsTrap = 0;
         IsSimpson_1_3 = 1;
         IsSimpson_3_8 = 2;

implementation

constructor TIntegralMethods.create;
begin
     MethodList := TStringList.Create;
     MethodList.AddObject('Trapecio', TObject (IsTrap) );
     MethodList.AddObject('Simpson 1/3', TObject (IsSimpson_1_3) );
     h := 0.5;
     a := 2;
     b := 3;
     area:= False;
end;

destructor TIntegralMethods.Destroy;
begin
     MethodList.Destroy;
end;

function TIntegralMethods.f(x: Real): Real;
begin
     Parse.NewValue('x', x);
     Parse.Expression:= func;
     Result := Parse.Evaluate();

//     Result := power(x, 3); //for now
end;

function TIntegralMethods.Trapecio(): Real;
var n: Integer = 0;
   i: Integer;
   xn: Real;
begin
     Result := (f(a) + f(b))/2;
     if (area = True) then
        Result := abs(Result);
     xn := a + h;
     while (xn < b) do begin
//       ShowMessage('xn: ' + FloatToStr(xn));
       if (area = True) then
          Result := Result + abs(f(xn))
       else
           Result := Result + f(xn);
       xn := xn + h;
     end;
     Result := Result * h;
end;

function TIntegralMethods.Simpson_1_3(): Real;
var n: Integer = 1;
   i: Integer;
   xn, temp_2, temp_4: Real;
begin
     i := round((b-a)/(h)); //intervals
     h_1 := (b-a)/(2*i);
     //ShowMessage('h_1: ' + FloatToStr(h_1));
     Result := (f(a) + f(b));
     if (area = True) then begin
        Result := abs(Result);
     end;
     xn := a + h_1;
     temp_2 := 0;
     temp_4 := 0;
     while (xn < b) do begin
       if (n mod 2 = 1) then begin
//          temp_4 += f(xn); //those multiplied by 2
          if (area = True) then
             temp_4 := temp_4 + abs(f(xn))
          else
              temp_4 += f(xn);
       end
       else begin
//           temp_2 += f(xn); //those multiplied by 4
           if (area = True) then
              temp_2 := temp_2 + abs(f(xn))
           else
               temp_2 += f(xn);
       end;
       xn := xn + h_1;
       n := n + 1;
     end;
     Result := Result + 2*temp_2 + 4*temp_4;
     Result := Result * h_1/3;
end;

function TIntegralMethods.Simpson_3_8(): Real;
var n: Integer = 1;
   i: Integer;
   xn, temp_2, temp_3: Real;
begin
     i := round((b-a)/(h)); //intervals
{     if (i mod 3 <> 0) then begin
        ShowMessage('Escoja otro valor en h.');
        Exit;
     end; }
     h_1 := (b-a)/(2*i);
     //ShowMessage('h_1: ' + FloatToStr(h_1));
     Result := (f(a) + f(b));
     if (area = True) then begin
        Result := abs(Result);
     end;
     xn := a + h;
     temp_2 := 0; //multiplied by 2
     temp_3 := 0; //multiplied by 3
     while (xn < b) do begin
       if (n mod 3 = 0) then begin
          if (area = True) then
             temp_2 := temp_2 + abs(f(xn))
          else
              temp_2 += f(xn);
       end
       else begin
           if (area = True) then
              temp_3 := temp_3 + abs(f(xn))
           else
               temp_3 += f(xn);
       end;
       xn := xn + h;
       n := n + 1;
     end;
     Result := Result + 2*temp_2 + 3*temp_3;
     Result := Result * 3*h/8;
end;

function TIntegralMethods.Execute(): Real;
begin
     if (Method = IsTrap) then
        Result := Trapecio()
     else if (Method = IsSimpson_1_3) then
        Result := Simpson_1_3()
     else if (Method = IsSimpson_3_8) then
        Result := Simpson_3_8();
//     Result := Trapecio();
//     Result := Simpson_1_3();
end;

end.

