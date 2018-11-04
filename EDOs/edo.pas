unit edo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TEdo = class
    f: String;
    x_0, y_0, y_n, h: Real;
    answers: array of Real;
    xn_s: array of Real;
    yn_s: array of Real;
    function euler(): Real;
    function heun(): Real;
    private

    public
      constructor create();
      destructor Destroy; override;
  end;

implementation

constructor TEdo.create();
begin
     h := 0.01;
end;

destructor TEdo.Destroy;
begin
     h := 0;
end;

function TEdo.euler(): Real;
begin
     ;
end;

function TEdo.heun(): Real;
begin
     ;
end;

end.

