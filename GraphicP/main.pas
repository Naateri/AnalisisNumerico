unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TATools, TAFuncSeries, TASeries, Forms,
  Controls, Graphics, Dialogs, ExtCtrls, framefunctions, Types, TAChartUtils, nle_methods,
  ParseMath;

type

  { TfrmGraphics }

  TfrmGraphics = class(TForm)
    charFunction: TChart;
    charFunctionConstantLine1: TConstantLine;
    charFunctionConstantLine2: TConstantLine;
    charFunctionFuncSeries1: TFuncSeries;
    charFunctionLineSeries1: TLineSeries;
    ChartToolset1: TChartToolset;
    ChartToolset1DataPointClickTool1: TDataPointClickTool;
    GraphicScroll: TPanel;
    procedure charFunctionFuncSeries1Calculate(const AX: Double; out AY: Double);
    procedure ChartToolset1DataPointClickTool1PointClick(ATool: TChartTool;
      APoint: TPoint);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    GraphicFrame: Array of TGraphicsFrameTemplate;
    Methods: TNLEMethods;
    clickFunc1: Boolean;
    tempX: Real;
    func1: String;
    Parse: TParseMath;

  public
    GFMaxPosition,
    GFActualPosition: Integer;
    procedure AddGraphics;
  end;

var
  frmGraphics: TfrmGraphics;

implementation

{$R *.lfm}

{ TfrmGraphics }

procedure TfrmGraphics.AddGraphics;
begin
   GFMaxPosition:= GFMaxPosition + 1;
   SetLength( GraphicFrame, GFMaxPosition + 1 );
   GraphicFrame[ GFMaxPosition ]:= TGraphicsFrameTemplate.Create( GraphicScroll );
   GraphicFrame[ GFMaxPosition ].Name:= 'GF'+ IntToStr( GFMaxPosition );
   GraphicFrame[ GFMaxPosition ].Parent:= GraphicScroll;
   GraphicFrame[ GFMaxPosition ].Align:= alTop;
   GraphicFrame[ GFMaxPosition ].Tag:= GFMaxPosition;

 (*  with GraphicFrame[ GFMaxPosition -1 ] do
   if GFMaxPosition > 1 then begin
      AnchorSide[akBottom].Side:= asrBottom;
      AnchorSide[akBottom].Control:= GraphicFrame[ GFMaxPosition  ];
      //Anchors:= GraphicFrame[ GFMaxPosition -1 ].Anchors + [akTop];
   end;

   *)
end;

procedure TfrmGraphics.charFunctionFuncSeries1Calculate(const AX: Double; out
  AY: Double);
begin

end;

procedure TfrmGraphics.ChartToolset1DataPointClickTool1PointClick(
  ATool: TChartTool; APoint: TPoint);
var
  x, y: Real;
  newA, Res, temp: Real;
  pg: TDoublePoint;
  i: Integer;
begin
  pg := charFunction.ImageToGraph(APoint);
  with ATool as TDataPointClickTool do
    if (Series is TFuncSeries) then
    begin
//          with TFuncSeries(Series) do begin
        x := pg.X;
        y := pg.Y;
        ShowMessage('x: ' + FloatToStr(x) + ', y: ' + FloatToStr(y));
        if (clickFunc1 = False) then
        begin
            Parse := TParseMath.create();
            Parse.AddVariable('x', 0);
           for i := 0 to GFMaxPosition - 1 do begin //checks which function
               Parse.Expression := GraphicFrame[i].ediF.Text; //we've just clicked
               Parse.NewValue('x', x);
               temp := Parse.Evaluate();
               if ( abs(temp - y) <= 0.1) then
               begin
                  func1 := GraphicFrame[i].ediF.Text;
                  ShowMessage('final func: ' + func1 );
                  Parse.destroy;
                  break;
               end;
           end;
        end;
//        func1 := GraphicFrame[i].ediF.Text;
        if (clickFunc1 = True) then
        begin
            Parse := TParseMath.create();
            Parse.AddVariable('x', 0);
            Methods := TNLEMethods.create;
            newA := (pg.X + tempX) / 2;
            Methods.a := newA;
            Methods.func := func1;
            for i := 0 to GFMaxPosition - 1 do begin //checks which function
               Parse.Expression := GraphicFrame[i].ediF.Text; //we've just clicked
               ShowMessage('func: ' + Parse.Expression );
               Parse.NewValue('x', x);
               temp := Parse.Evaluate();
               if ( abs(temp - y) <= 0.1 ) then //temp = y is broken
               begin
                  Methods.func2 := GraphicFrame[i].ediF.Text;
                  Parse.destroy;
                  break;
               end;
           end;
            Methods.func := func1;
            Res := Methods.Intersection();
            charFunctionLineSeries1.ShowPoints:= True;
            charFunctionLineSeries1.AddXY(Res, Methods.f(Res));
            //LabResult.Caption := FloatToStr(Res);
            ShowMessage('Interseccion: ' + FloatToStr(Res) + ', ' +
                                       FloatToStr(Methods.f(Res)) );
            Methods.Destroy;
            clickFunc1 := False;
            Exit;
        end;
        clickFunc1:= True;
        tempX := x;
    end;

end;

procedure TfrmGraphics.FormCreate(Sender: TObject);
begin
  GFMaxPosition:= -1;
  AddGraphics;
  clickFunc1:= False;
end;

procedure TfrmGraphics.FormDestroy(Sender: TObject);
var i: Integer;
begin
  for i:= 0 to Length( GraphicFrame ) - 1 do
      if Assigned( GraphicFrame[ i ] ) then
         GraphicFrame[ i ].Destroy;

end;

end.

