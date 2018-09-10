unit mainTest; //DEBERIA FUNCIONAR SI LAZARUS FUERA CHEVERE

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Menus, ParseMath, TAGraph, TAFuncSeries;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Chart1: TChart;
    Chart1FuncSeries1: TFuncSeries;
    Graph: TButton;
    EdiF: TEdit;
    EdiY: TEdit;
    EdiX: TEdit;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Chart1FuncSeries1Calculate(const AX: Double; out AY: Double);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    function f(x: Real): Real;
    procedure GraphClick(Sender: TObject);
  private
    Parse: TParseMath;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
     Parse := TParseMath.create();
     Parse.AddVariable('x', 0);
     Parse.AddVariable('y', 0);
     Memo1.Clear;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Parse.destroy;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
     Parse.Expression:= EdiF.Text;
     Parse.NewValue('x', StrToFloat(EdiX.Text) );
     Parse.NewValue('y', StrToFloat(EdiY.Text) );
     Memo1.Lines.Add( {StringReplace( ediF.Text, 'x', EdiX.Text, [rfReplaceAll, rfIgnoreCase ] )
                      + StringReplace( ediF.Text, 'y', EdiY.Text, [rfReplaceAll, rfIgnoreCase ])}
                      EdiF.Text + ' = '
                      + FloatToStr(Parse.Evaluate()) );
end;

procedure TForm1.Chart1FuncSeries1Calculate(const AX: Double; out AY: Double);
begin
  AY := f(AX);
end;

function TForm1.f(x: Real): Real;
begin
     Parse.Expression := EdiF.Text;
     Parse.NewValue('x', x);
     Result := Parse.Evaluate();
end;

procedure TForm1.GraphClick(Sender: TObject);
begin
  Chart1FuncSeries1.Active:= False;
  Chart1FuncSeries1.Active:= True;
end;

end.

