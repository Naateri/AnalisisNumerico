unit lagrange_pol;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs;

type
  TLagrange = class
    points: array of array of Real;
    num_points: Integer;
    polinomy, real_polinomy: String;
    polyroot, real_polyroot: String;

    public
      constructor create;
      destructor Destroy; override;
      function find_pol(x: Real): Real;
      function find_text(): String;
      function polyroot_text(): String;
//      function f(x: Real): Real;
  end;

implementation

constructor TLagrange.create;
begin
     num_points := 0;
end;

destructor TLagrange.Destroy;
begin

end;

function TLagrange.find_pol(x: Real): Real;
var
  i,j: Integer;
  temp, answer: Real;
  temp_polinomy: String;
begin
//     SetLength(points, 2, num_points);
     temp := 1;
     answer := 0;
     polinomy:= '';
     for i := 0 to num_points-1 do
     begin
       temp := 1;
       temp_polinomy := '';
       for j := 0 to num_points - 1 do
       begin
         if (i = j) then
            continue;
         temp_polinomy := temp_polinomy + '( ( x - ' + FloatToStr(points[j][0]) + ')/' + FloatToStr( points[i][0] - points[j][0]) + ') )*';
         temp := temp * ( ( x - points[j][0] ) / ( points[i][0] - points[j][0]) );
       end;
       temp := temp * points[i][1];
       temp_polinomy := FloatToStr(points[i][1]) + '*' + temp_polinomy;
       polinomy := temp_polinomy + '+' + polinomy;;
       answer := answer + temp;
     end;
//     ShowMessage('answer: ' + FloatToStr(answer));
       real_polinomy:= polinomy;
     Result := answer;
end;

function TLagrange.find_text(): String;
var
  i,j: Integer;
  temp, answer: Real;
  temp_polinomy: String;
begin
//     SetLength(points, 2, num_points);
     temp := 1;
     answer := 0;
     polinomy:= '';
     for i := 0 to num_points-1 do
     begin
       temp := 1;
       temp_polinomy := '';
       for j := 0 to num_points - 1 do
       begin
         if (i = j) then
            continue;
         temp_polinomy := temp_polinomy + '( ( x - ' + FloatToStr(points[j][0]) + ')/' + FloatToStr( points[i][0] - points[j][0]) + ' )*';
       end;
       temp_polinomy := Copy(temp_polinomy, 0, Length(temp_polinomy) - 1);
       temp_polinomy := FloatToStr(points[i][1]) + '*' + temp_polinomy;
       polinomy := temp_polinomy + '+' + polinomy;;
     end;
//     ShowMessage('answer: ' + FloatToStr(answer));
       real_polinomy:= Copy(polinomy, 0, Length(polinomy) - 1);
     Result := real_polinomy;
end;

function TLagrange.polyroot_text(): String;
var
  i,j: Integer;
  temp, answer: Real;
  temp_polyroot: String;
begin
     temp := 1;
     answer := 0;
     polyroot:= '';
     for i := 0 to num_points-1 do
     begin
       temp := 1;
       temp_polyroot := '(x - ' + FloatToStr(points[i][0]) + ')';
       temp_polyroot := temp_polyroot + '*';
       polyroot := polyroot + temp_polyroot;
     end;
//     ShowMessage('answer: ' + FloatToStr(answer));
       real_polyroot:= Copy(polyroot, 0, Length(polyroot) - 1);
     Result := real_polyroot;

end;

end.

