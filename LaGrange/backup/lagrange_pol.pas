unit lagrange_pol;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs;

type
  TLagrange = class
    points: array of array of Real;
    num_points: Integer;

    public
      constructor create;
      destructor Destroy; override;
      function find_pol(x: Real): Real;
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
begin
//     SetLength(points, 2, num_points);
     temp := 1;
     answer := 0;
     for i := 0 to num_points-1 do
     begin
       temp := 1;
       for j := 0 to num_points - 1 do
       begin
//         ShowMessage('idek' );
         if (i = j) then
            continue;
         temp := temp * ( ( x - points[j][0] ) / ( points[i][0] - points[j][0]) );
       end;
       temp := temp * points[i][1];
       answer := answer + temp;
     end;
     ShowMessage('answer: ' + FloatToStr(answer));
     Result := answer;
end;

end.

