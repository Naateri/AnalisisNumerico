unit final_project_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, uCmdBox, TAGraph, TAFuncSeries, TASeries, Forms,
  Controls, Graphics, Dialogs, Grids, StdCtrls, ExtCtrls, nle_methods, lagrange_pol,
  ParseMath;

type

  { TForm1 }

  TForm1 = class(TForm)
    Chart1: TChart;
    Chart1FuncSeries1: TFuncSeries;
    Chart1FuncSeries2: TFuncSeries;
    Chart1LineSeries1: TLineSeries;
    CmdBox1: TCmdBox;
    Panel1: TPanel;
    StringGrid1: TStringGrid;
    procedure Chart1FuncSeries1Calculate(const AX: Double; out AY: Double);
    procedure Chart1FuncSeries2Calculate(const AX: Double; out AY: Double);
    procedure CmdBox1Input(ACmdBox: TCmdBox; Input: string);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

  my_function = class
    func: String;
    parser: TParseMath;
    public
      constructor Create;
      function f(x: Real): Real;

  end;

var
  Form1: TForm1;
  error: Real;
  decimal: Integer;
  current_func, current_func2: String;


implementation

{$R *.lfm}

{ TForm1 }

constructor my_function.Create;
begin
  parser := TParseMath.create();
  parser.AddVariable('x', 0);
  parser.Expression:= 'x';
end;

function my_function.f(x: Real): Real;
begin
     parser.Expression:= func;
     parser.NewValue('x', x);
     Result := parser.Evaluate();
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  error := 0.01;
  decimal := 2;
  CmdBox1.StartRead(clWhite, clBlack, 'Numerico>', clWhite, clBlack);
end;

procedure TForm1.CmdBox1Input(ACmdBox: TCmdBox; Input: string);
var
  my_list: TStringList;
  array_list: TStringList;
  func, temp: String;
  iPos: Integer;
  root_finder: TNLEMethods;
  parser: TParseMath;
  h, res: Real;
  m_function: my_function;
  my_point: TPoint;
  lagrange_solver: TLagrange;
  pts: array of array of Real;

begin
  StringGrid1.Cells[0,0] := 'Name';
  StringGrid1.Cells[1,0] := 'Value';
  StringGrid1.Cells[2,0] := 'Type';

  my_list := TStringList.Create;
  Input := Trim(Input);
  iPos := Pos( '(', Input);
  func := Trim( Copy(Input, 1, iPos-1));
  my_list.Delimiter:= ';';
  my_list.StrictDelimiter:= true;
  my_list.DelimitedText:= Copy( Input, iPos+1, Length(Input) - iPos - 1);
  h := 0.01;

  StringGrid1.Cells[0,1] := 'h';
  StringGrid1.Cells[1,1] := 'Real';
  StringGrid1.Cells[2,1] := FloatToStr(h);

  //ShowMessage('funcion: ' + func);

{  for iPos := 0 To my_list.Count - 1 do
      ShowMessage('Parametro: ' + IntToStr( iPos+1 ) + ': ' + my_list[iPos]); }

      Chart1.Extent.UseYMax := False;
      Chart1.Extent.UseYMin := False;

  case func of
          'help': ShowMessage('Las siguientes funciones pueden ser ingresadas: ' + LineEnding
          + 'root(f;a;b;method;true/false): f es la función, a y b el intervalo, los métodos pueden ser: ' +
           'Biseccion (0), Falsa Posicion (1), Secante (2). True (1) o False (0)' +
            ' te dice si puedes hallar todas las raíces.'+ LineEnding
            + 'plot2d(f;a;b;color): f es la funcion, [a,b] el intervalo donde será graficado,' +
            ' color el color de la gráfica. (Ej: clBlue).' + LineEnding
            + 'polyroot([1,3,4,2]): WIP.' + LineEnding
            + 'polynomial([1,2,3];[3,-3,4]): devuelve una función dados unos puntos. ' +
            'Primer array: valores en x. Segundo array: valores en y.' + LineEnding
            + 'SENL: WIP' + LineEnding
            + 'intersection(f,g,a,b,color1,color2): halla la intersección entre dos funciones. '
            + 'f y g son funciones, a y b el intervalo donde va a hallar la o las intersecciones, '
            + 'color1 y color2 son los colores de f y g respectivamente.' + LineEnding
            + 'integral: WIP' + LineEnding
            + 'area: WIP' + LineEnding
            + 'area2: WIP' + LineEnding
            + 'edo: WIP' + LineEnding
            );
          'exit': begin
            ShowMessage('Me voy.');
            Application.Terminate;
          end;
          'root': begin
            current_func:= my_list[0];
            current_func2:= my_list[0];

            root_finder := TNLEMethods.create;
            root_finder.func:= my_list[0];

            root_finder.a := StrToFloat(my_list[1]);
            root_finder.b:= StrToFloat(my_list[2]);
            root_finder.ErrorAllowed:= h;
            root_finder.Method:= StrToInt(my_list[3]);
            Chart1.Extent.UseXMin := False;
            Chart1.Extent.UseXMax := False;
            Chart1FuncSeries1.Active:= False;
            Chart1FuncSeries1.Pen.Color := clBlack;
            Chart1FuncSeries1.Active:= True;
            Chart1.Proportional:= True;
            Chart1FuncSeries2.Active:= False;

            res := root_finder.Execute();
            //ShowMessage('root(f,a,b,method,true/false). Biseccion, Falsa Posicion, Secante.'); SYNTAX
            ShowMessage('Root: ' + FloatToStr( res ) );
            {my_point.X:= res;
            my_point.Y:= 0;}

            Chart1LineSeries1.AddXY(res, 0);
            Chart1LineSeries1.ShowPoints:= True;
            Chart1.Visible:= True;
            root_finder.Destroy;
          end;
          'plot2d': begin
//            Chart1.ClearSeries;
            parser := TParseMath.create();
            parser.AddVariable( 'x', 0);
            parser.Expression:= my_list[0];
            current_func:= my_list[0];
            current_func2:= my_list[0];

            Chart1.Extent.UseXMin := True;
            Chart1.Extent.UseXMax := True;
            Chart1.Extent.XMin := StrToFloat(my_list[1]);
            Chart1.Extent.XMax := StrToFloat(my_list[2]);
            Chart1FuncSeries2.Active:= False;
            Chart1FuncSeries1.Active:= False;
            Chart1FuncSeries1.Pen.Color := StringToColor(my_list[3]);
            Chart1FuncSeries1.Active:= True;
            Chart1.Proportional:= True;

            Chart1.Visible:= True;
//            ShowMessage('Grafica. (f,a,b,color)'); SYNTAX
          end;
          'polyroot': begin
            array_list := TStringList.Create;
            temp := Trim(my_list[0]);
            iPos := Pos( ']', temp);
            array_list.Delimiter:= ',';
            array_list.StrictDelimiter:= True;
            array_list.DelimitedText:= Copy(temp, 2, Length(temp) - 2);
            for iPos := 0 to array_list.Count - 1 do
                ShowMessage('Valor: ' + array_list[iPos]);
            //copy values to create the polynomial
            ShowMessage('polyroot([1,3,5,8]). Raices de un polinomio.');
          end;
          'polynomial': begin
            lagrange_solver := TLagrange.create;
            array_list := TStringList.Create;
            temp := Trim(my_list[0]);
            iPos := Pos( ']', temp);
            array_list.Delimiter:= ',';
            array_list.StrictDelimiter:= True;
            array_list.DelimitedText:= Copy(temp, 2, Length(temp) - 2);
            lagrange_solver.num_points:= array_list.Count;
            SetLength(pts, lagrange_solver.num_points, 2);
            array_list.Sort; //to get min and max

            for iPos := 0 to array_list.Count - 1 do begin
              pts[iPos][0] := StrToFloat(array_list[iPos]);
              ShowMessage('Valor: ' + array_list[iPos]);
            end;
            //copy x values to Lagrange

//            ShowMessage('polynomial([1,3,5],[4,2,3]). LaGrange.'); SYNTAX
              array_list.Clear;
            temp := Trim(my_list[1]);
            iPos := Pos( ']', temp);
            array_list.Delimiter:= ',';
            array_list.StrictDelimiter:= True;
            array_list.DelimitedText:= Copy(temp, 2, Length(temp) - 2);
            array_list.Sort; //to get min and max

            for iPos := 0 to array_list.Count - 1 do begin
                ShowMessage('Valor: ' + array_list[iPos]);
                pts[iPos][1] := StrToFloat(array_list[iPos]);
            end;
            //copy y values to Lagrange

            array_list.Destroy;
            lagrange_solver.points := pts;

            current_func := lagrange_solver.find_text();
            current_func2:= current_func;
            Chart1.Extent.UseYMax := True;
            Chart1.Extent.UseYMax := True;
            Chart1.Extent.XMin := pts[0][0];
            Chart1.Extent.XMax := pts[lagrange_solver.num_points-1][0];
            Chart1.Extent.YMin := pts[0][1];
            Chart1.Extent.YMax := pts[lagrange_solver.num_points-1][1];
            Chart1FuncSeries1.Active:= False;
            Chart1FuncSeries2.Active:= False;
            Chart1FuncSeries1.Pen.Color:= clBlue;
            Chart1FuncSeries1.Active:= True;

            Chart1.Visible:= True;
            Chart1.Proportional:= True;

          end;
          'SENL': begin
            ShowMessage('SENL([f1,f2,f3], [x0, x1, x2]). Newton Raphson generalizado.');
          end;
          'intersection': begin
//            Chart1.ClearSeries;
            Chart1.Visible:= True;
            root_finder := TNLEMethods.create;
            root_finder.func:= my_list[0];
            root_finder.func2:= my_list[1];

            current_func:= my_list[0];
            current_func2:= my_list[1];

            root_finder.a := StrToFloat(my_list[2]);
            root_finder.b:= StrToFloat(my_list[3]);
            root_finder.ErrorAllowed:= h;
            Chart1.Extent.UseXMin := True;
            Chart1.Extent.UseXMax := True;
            Chart1.Extent.XMin := root_finder.a;
            Chart1.Extent.XMax := root_finder.b;
            Chart1FuncSeries1.Active:= False;
            Chart1FuncSeries1.Pen.Color := StringToColor(my_list[4]);
            Chart1FuncSeries1.Active:= True;
            Chart1FuncSeries2.Active:= False;
            Chart1FuncSeries2.Pen.Color:= StringToColor(my_list[5]);
            Chart1FuncSeries2.Active := True;
            Chart1.Proportional:= True;

            res := root_finder.Intersection();
            ShowMessage('Intersection: (' + FloatToStr(res) + ', ' + FloatToStr( root_finder.f2(res)) + ')' );
            {my_point.X:= res;
            my_point.Y:= root_finder.f(res);}

            Chart1LineSeries1.AddXY(res, root_finder.f2(res));
            Chart1LineSeries1.ShowPoints:= True;
            root_finder.Destroy;
//            ShowMessage('intersection(f,g,a,b,colorf,colorg). Interseccion de dos funciones en un intervalo.' +
//            ' Todos los puntos.'); SYNTAX
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
//  Chart1FuncSeries1.Extent.UseXMin := False;
//  Chart1FuncSeries1.Extent.UseXMax := False;

  CmdBox1.StartRead(clWhite, clBlack, 'Numerico>', clWhite, clBlack);

end;

procedure TForm1.Chart1FuncSeries1Calculate(const AX: Double; out AY: Double);
var
  m_function: my_function;
  m_parser: TParseMath;
begin
  //ShowMessage('current func: ' + current_func);
  m_function := my_function.Create;
  m_parser := TParseMath.create();
  m_parser.Expression:= current_func;
  m_parser.AddVariable('x', AX);
  m_function.func := current_func;
  //AY := m_function.f(AX);
  AY := m_parser.Evaluate();
  //AY := AX;

end;

procedure TForm1.Chart1FuncSeries2Calculate(const AX: Double; out AY: Double);
var
  m_function: my_function;
begin
  m_function := my_function.Create;
  m_function.func := current_func2;
  AY := m_function.f(AX);

end;



end.

