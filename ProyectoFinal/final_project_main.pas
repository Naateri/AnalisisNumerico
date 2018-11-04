unit final_project_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, uCmdBox, TAGraph, Forms, Controls, Graphics,
  Dialogs, Grids, nle_methods;

type

  { TForm1 }

  TForm1 = class(TForm)
    Chart1: TChart;
    CmdBox1: TCmdBox;
    StringGrid1: TStringGrid;
    procedure CmdBox1Input(ACmdBox: TCmdBox; Input: string);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  error: Real;
  decimal: Integer;


implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  error := 0.01;
  decimal := 2;
  CmdBox1.StartRead(clWhite, clBlack, 'Numerico>', clWhite, clBlack);
end;

procedure TForm1.CmdBox1Input(ACmdBox: TCmdBox; Input: string);
var
  my_list: TStringList;
  func: String;
  iPos: Integer;
  root_finder: TNLEMethods;
  h: Real;
begin
  my_list := TStringList.Create;
  Input := Trim(Input);
  iPos := Pos( '(', Input);
  func := Trim( Copy(Input, 1, iPos-1));
  my_list.Delimiter:= ';';
  my_list.StrictDelimiter:= true;
  my_list.DelimitedText:= Copy( Input, iPos+1, Length(Input) - iPos - 1);
  h := 0.01;
  {ShowMessage('funcion: ' + func);

  for iPos := 0 To my_list.Count - 1 do
      ShowMessage('Parametro: ' + IntToStr( iPos+1 ) + ': ' + my_list[iPos]); }

  case func of
          'help': ShowMessage('(visu)Algo.');
          'exit': begin
            ShowMessage('Me voy,');
            Application.Terminate;
          end;
          'root': begin
            Chart1.Visible:= True;
            root_finder := TNLEMethods.create;
            root_finder.func:= my_list[0];
            root_finder.a := StrToFloat(my_list[1]);
            root_finder.b:= StrToFloat(my_list[2]);
            root_finder.ErrorAllowed:= h;
            root_finder.Method:= StrToInt(my_list[3]);
            //ShowMessage('root(f,a,b,method,true/false). Biseccion, Falsa Posicion, Secante.'); SYNTAX
            ShowMessage('Root: ' + FloatToStr(root_finder.Execute() ) );
            root_finder.Destroy;
          end;
          'plot2d': begin
            ShowMessage('Grafica. (f,a,b,color)');
          end;
          'polyroot': begin
            ShowMessage('polyroot([1,3,5,8]). Raices de un polinomio.');
          end;
          'polynomial': begin
            ShowMessage('polynomial([1,3,5],[4,2,3]). LaGrange.');
          end;
          'SENL': begin
            ShowMessage('SENL([f1,f2,f3], [x0, x1, x2]). Newton Raphson generalizado.');
          end;
          'intersection': begin
            ShowMessage('intersection(f,g,a,b,colorf,colorg). Interseccion de dos funciones en un intervalo.' +
            ' Todos los puntos.');
          end;
          'integral': begin
            ShowMessage('integral(f,a,b,method)');
          end;
          'area': begin
            ShowMessage('area(f,a,b,method): halla y grafica el área.');
          end;
          'area2': begin
            ShowMessage('area2(f,g,a,b, method): halla y grafica el área entre 2 funciones');
          end;
          'edo': begin
            ShowMessage('edo(df,x0,y0,method): plottea la funcion primitiva');
          end;

     end;

  CmdBox1.StartRead(clWhite, clBlack, 'Numerico>', clWhite, clBlack);

end;



end.

