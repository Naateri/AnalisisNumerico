unit main_edo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, Forms, Controls, Graphics, Dialogs,
  StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Chart1: TChart;
    ediY0: TEdit;
    ediX0: TEdit;
    labResult: TLabel;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

end.

