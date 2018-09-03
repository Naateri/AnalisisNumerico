unit main_NLE;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TAFuncSeries, TASeries, Forms, Controls,
  Graphics, Dialogs, StdCtrls, Grids, nle_methods;

type

  { TGraph }

  TGraph = class(TForm)
    btnGraph: TButton;
    btnCalculate: TButton;
    Chart1: TChart;
    Chart1ConstantLine1: TConstantLine;
    Chart1ConstantLine2: TConstantLine;
    Chart1LineSeries1: TLineSeries;
    cboMethods: TComboBox;
    EdiA: TEdit;
    EdiB: TEdit;
    EdiError: TEdit;
    Func1: TFuncSeries;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    LabResult: TLabel;
    LabIter: TLabel;
    ediFunc: TEdit;
    StringGrid1: TStringGrid;
    procedure btnCalculateClick(Sender: TObject);
    procedure btnGraphClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Func1Calculate(const AX: Double; out AY: Double);

  private
      Methods: TNLEMethods;

  public

  end;

var
  Graph: TGraph;

implementation

{$R *.lfm}

{ TGraph }

procedure TGraph.btnGraphClick(Sender: TObject);
begin

     Func1.Active:= False;
     Func1.Pen.Color:= clBlue;
     Func1.Active:= True;

end;

procedure TGraph.FormCreate(Sender: TObject);
begin
  Methods := TNLEMethods.create;
  cboMethods.Items.Assign(Methods.MethodList);
  cboMethods.ItemIndex:= 0;
end;

procedure TGraph.btnCalculateClick(Sender: TObject);
var //SL: TStringList;
  Res: Real;
begin
     {SL := TStringList.Create;
     SL.Add('3.14');
     SL.Add('1.23');
     SL.Add('1.2334');
     StringGrid1.Cols[ 1 ].Assign(SL); //how to fill a StringGrid with a TStringList}
     Methods := TNLEMethods.create;
     Methods.a := StrToFloat(EdiA.Text);
     Methods.b := StrToFloat(EdiB.Text);
     Methods.error:= StrToFloat(EdiError.Text);
     Methods.func := ediFunc.Text;
     Methods.Method:= IntPtr( cboMethods.Items.Objects[cboMethods.ItemIndex]);
     Res := Methods.Execute();
     if (Methods.globalBolzano = True) then
     begin
         //TempResult.Text := FloatToStr(Res);
         StringGrid1.Cols[ 0 ].Assign(Methods.nSequence);
         StringGrid1.Cols[ 1 ].Assign(Methods.SolutionSequence);
         StringGrid1.Cols[ 2 ].Assign(Methods.ErrorSequence);
         LabResult.Caption := FloatToStr(Res);
         LabIter.Caption:= IntToStr(Methods.nSequence.Count);
         Chart1LineSeries1.ShowPoints:= True;
         Chart1LineSeries1.AddXY(Res, 0);
     end else
     begin
       StringGrid1.Cells[0,0] := 'No se';
       StringGrid1.Cells[1,0] := 'encontro';
       StringGrid1.Cells[2,0] := 'respuesta';
       LabResult.Caption := '-';
       LabIter.Caption:= '-';
     end;
     Methods.Destroy;
end;

procedure TGraph.Func1Calculate(const AX: Double; out AY: Double);
begin
  Methods := TNLEMethods.create;
  AY := Methods.f( AX );
  Methods.Destroy;
end;

end.
