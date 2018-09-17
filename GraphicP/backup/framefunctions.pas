unit framefunctions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, Buttons, LCLType,
  ColorBox, Dialogs, TAGraph, TAFuncSeries, math, ParseMath, Graphics, ExtCtrls;

type

  { TGraphicsFrameTemplate }

  TGraphicsFrameTemplate = class(TFrame)
    cbtnFunSeriesColor: TColorButton;
    ediF: TEdit;
    Panel1: TPanel;

    procedure cbtnFunSeriesColorClick(Sender: TObject);
    procedure cbtnFunSeriesColorColorChanged(Sender: TObject);
    procedure ediFKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FrameClick(Sender: TObject);
    procedure FuncSeriesCalculate(const AX: Double; out AY: Double);
  private
    IsLastOne: Boolean;
    Parse: TParseMath;

    function f(x: Real): Real;
  public
     FuncColor: TColor;
     FuncSeries: TFuncSeries;
  end;



implementation

uses main;

{$R *.lfm}

{ TGraphicsFrameTemplate }

function TGraphicsFrameTemplate.f(x: Real): Real;
begin
    Parse.NewValue('x', x);
    Result:= Parse.Evaluate();
end;

procedure TGraphicsFrameTemplate.FuncSeriesCalculate(const AX: Double; out
  AY: Double);
begin
    AY:= f( AX )

end;

procedure TGraphicsFrameTemplate.ediFKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if not (Key = VK_RETURN) then
     exit;

  with frmGraphics do begin
     if not Assigned( FuncSeries ) then begin
        FuncSeries:= TFuncSeries.Create( charFunction );
        charFunction.AddSeries( FuncSeries );
     end;

     FuncSeries.Pen.Color:= FuncColor;
     FuncSeries.Active:= False;
     Parse:= TparseMath.create;
     Parse.Expression:= ediF.Text;
     Parse.AddVariable( 'x', 0);
     FuncSeries.OnCalculate:= @FuncSeriesCalculate;

     FuncSeries.Active:= True;

     if Self.Tag = frmGraphics.GFMaxPosition then
        frmGraphics.AddGraphics;


  end;

end;

procedure TGraphicsFrameTemplate.FrameClick(Sender: TObject);
begin
  frmGraphics.GFActualPosition:= Self.Tag;
  Panel1.Color:= clGray;
end;

procedure TGraphicsFrameTemplate.cbtnFunSeriesColorClick(Sender: TObject);
begin

end;

procedure TGraphicsFrameTemplate.cbtnFunSeriesColorColorChanged(Sender: TObject
  );
begin
   FuncColor:= cbtnFunSeriesColor.ButtonColor;
   if Assigned( FuncSeries ) then
      FuncSeries.Pen.Color:= FuncColor;
end;

end.

