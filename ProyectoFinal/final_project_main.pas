unit final_project_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, uCmdBox, TAGraph, TAFuncSeries, TASeries, Forms,
  Controls, Graphics, Dialogs, Grids, StdCtrls, ExtCtrls, nle_methods, lagrange_pol, Integrals,
  edo, MyMatrix, NonLinearSystem, ParseMath;

type

  { TForm1 }

  TForm1 = class(TForm)
    Chart1: TChart;
    Chart1FuncSeries1: TFuncSeries;
    Chart1FuncSeries2: TFuncSeries;
    Chart1LineSeries1: TLineSeries;
    edoPlotter: TLineSeries;
    CmdBox1: TCmdBox;
    memHistorial: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    StringGrid1: TStringGrid;
    procedure Chart1FuncSeries1Calculate(const AX: Double; out AY: Double);
    procedure Chart1FuncSeries2Calculate(const AX: Double; out AY: Double);
    procedure CmdBox1Input(ACmdBox: TCmdBox; Input: string);
    procedure FormCreate(Sender: TObject);
  private
    h: Real;
    values: array of Real;
    names: array of String;
    le_parser: TParseMath;

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
var
  i: Integer;
begin
  error := 0.01;
  decimal := 2;
  CmdBox1.StartRead(clWhite, clBlack, 'Numerico>', clWhite, clBlack);
  StringGrid1.Cells[0,0] := 'Name';
  StringGrid1.Cells[1,0] := 'Value';
  StringGrid1.Cells[2,0] := 'Type';
  SetLength(values, 100);
  SetLength(names, 100);
  h := 0.01;
  values[0] := h;
  names[0] := 'h';

  le_parser := TParseMath.create();
  le_parser.AddVariable('x',0);
  le_parser.AddVariable('y', 0);
  le_parser.AddVariable('z', 0);
  le_parser.AddVariable('w', 0);
  le_parser.AddVariable('h',0.01);

  StringGrid1.Cells[0,1] := names[0];
  StringGrid1.Cells[1,1] := 'Real';
  StringGrid1.Cells[2,1] := FloatToStr(h);

  for i := 1 to 99 do
      names[i] := '';

end;

procedure TForm1.CmdBox1Input(ACmdBox: TCmdBox; Input: string);
var
  my_list: TStringList;
  array_list: TStringList;
  func, temp: String;
  iPos, i: Integer;
  root_finder: TNLEMethods;
  parser: TParseMath;
  res: Real;
  //values: array of Real;
  m_function: my_function;
  my_point: TPoint;
  lagrange_solver: TLagrange;
  integral_solver: TIntegralMethods;
  pts: array of array of Real;
  edo_solver: TEdo;
  senl_final_result: MyMatrix.mat;
  senl_solver: NLSystems;

begin
  my_list := TStringList.Create;
  Input := Trim(Input);
  iPos := Pos( '(', Input);
  func := Trim( Copy(Input, 1, iPos-1));
  my_list.Delimiter:= ';';
  my_list.StrictDelimiter:= true;
  my_list.DelimitedText:= Copy( Input, iPos+1, Length(Input) - iPos - 1);

  h := values[0];
  current_func:= '0';
  current_func2:= '0';

  //ShowMessage('funcion: ' + func);

{  for iPos := 0 To my_list.Count - 1 do
      ShowMessage('Parametro: ' + IntToStr( iPos+1 ) + ': ' + my_list[iPos]); }

      Chart1.Extent.UseYMax := False;
      Chart1.Extent.UseYMin := False;

      //edoPlotter.Clear;
      edoPlotter.Active:= False;

  case func of
          'help': begin ShowMessage('Las siguientes funciones pueden ser ingresadas: ' + LineEnding +
          'update(var_name, var_value): actualiza el valor de una variable' + LineEnding
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
            + 'integral(f,a,b,method): halla el valor de la integral de f en los intervalos a y b.'
            + ' Method: 0 es trapecio, 1 es Simpson 1/3' + LineEnding
            + 'area: WIP' + LineEnding
            + 'area2: WIP' + LineEnding
            + 'edo: WIP' + LineEnding
            );
            memHistorial.Text:= memHistorial.Text + func;
          end;
          'exit': begin
            ShowMessage('Me voy.');
            Application.Terminate;
          end;

          'update': begin
            for i := 1 to StringGrid1.ColCount - 1 do begin
              if ( StringGrid1.Cells[0,i] = my_list[0] ) then begin
                iPos := i;
                Break;
              end;
            end;
            values[iPos-1] := StrToFloat(my_list[1]);

            StringGrid1.Cells[2,i] := my_list[1];

            le_parser.NewValue(my_list[0], values[iPos-1]);

            memHistorial.Text:= memHistorial.Text + func + LineEnding;
            memHistorial.Text:= memHistorial.Text + 'variable ' + my_list[0] + ' actualizada con valor ' + my_list[1]
            + LineEnding;

          end;

          'create': begin //create(name, value)
            Chart1.Visible:= False;
            iPos := 1;
            while (names[iPos] <> '') do begin
              iPos := iPos + 1;
            end;

            names[iPos] := my_list[0];
            values[iPos] := StrToFloat(my_list[1]);
            StringGrid1.Cells[0,iPos+1] := my_list[0];
            StringGrid1.Cells[1,iPos+1] := 'Real';
            StringGrid1.Cells[2,iPos+1] := my_list[1];

            le_parser.AddVariable(names[iPos], values[iPos]);
            memHistorial.Text:= memHistorial.Text + func + LineEnding;
            memHistorial.Text:= memHistorial.Text + 'Variable ' + my_list[0] + 'creada con valor ' + my_list[1] + '.'
            + LineEnding;

          end;

          'root': begin
            current_func:= my_list[0];
            current_func2:= my_list[0];

            root_finder := TNLEMethods.create;
            root_finder.Parse := le_parser;
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
            //root_finder.Destroy;
            memHistorial.Text:= memHistorial.Text + func + LineEnding;
            memHistorial.Text:= memHistorial.Text + 'Root: ' + FloatToStr( res ) + LineEnding;

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
            memHistorial.Text:= memHistorial.Text + func + LineEnding;
            memHistorial.Text:= memHistorial.Text + 'funcion ' + current_func + ' graficada.' + LineEnding;

//            ShowMessage('Grafica. (f,a,b,color)'); SYNTAX
          end;
          'polyroot': begin
            lagrange_solver := TLagrange.create;
            array_list := TStringList.Create;
            temp := Trim(my_list[0]);
            iPos := Pos( ']', temp);
            array_list.Delimiter:= ',';
            array_list.StrictDelimiter:= True;
            array_list.DelimitedText:= Copy(temp, 2, Length(temp) - 2);
            lagrange_solver.num_points:= array_list.Count;
            SetLength(pts, lagrange_solver.num_points, 2);

            for iPos := 0 to array_list.Count - 1 do
                pts[iPos][0] := StrToFloat(array_list[iPos]);
                ShowMessage('Valor: ' + array_list[iPos]);
            //copy values to create the polynomial

            array_list.Destroy;
            lagrange_solver.points := pts;

            current_func := lagrange_solver.polyroot_text();
            current_func2:= current_func;
            Chart1.Extent.UseYMax := True;
            Chart1.Extent.UseYMax := True;
            Chart1.Extent.XMax := 10;
            Chart1.Extent.XMin := -10;

            Chart1FuncSeries1.Active:= False;
            Chart1FuncSeries2.Active:= False;
            Chart1FuncSeries1.Pen.Color:= clBlue;
            Chart1FuncSeries1.Active:= True;

            Chart1.Visible:= True;
            Chart1.Proportional:= True;

            memHistorial.Text:= memHistorial.Text + func + LineEnding;
            memHistorial.Text:= memHistorial.Text + 'funcion: ' + current_func + LineEnding;

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

            for iPos := 0 to array_list.Count - 1 do begin
                ShowMessage('Valor: ' + array_list[iPos]);
                pts[iPos][1] := StrToFloat(array_list[iPos]);
            end;
            array_list.Sort; //to get min and max
            //copy y values to Lagrange

            array_list.Destroy;
            lagrange_solver.points := pts;

            current_func := lagrange_solver.find_text();
            current_func2:= current_func;
            Chart1.Extent.UseYMax := True;
            Chart1.Extent.UseYMax := True;
            Chart1.Extent.XMax := 10;
            Chart1.Extent.XMin := -10;
{            Chart1.Extent.XMin := pts[0][0];
            Chart1.Extent.XMax := pts[lagrange_solver.num_points-1][0];
            Chart1.Extent.YMin := pts[0][1];
            Chart1.Extent.YMax := pts[lagrange_solver.num_points-1][1]; }
            Chart1FuncSeries1.Active:= False;
            Chart1FuncSeries2.Active:= False;
            Chart1FuncSeries1.Pen.Color:= clBlue;
            Chart1FuncSeries1.Active:= True;

            Chart1.Visible:= True;
            Chart1.Proportional:= True;

            memHistorial.Text:= memHistorial.Text + func + LineEnding;
            memHistorial.Text:= memHistorial.Text + 'funcion: ' + current_func + LineEnding;

          end;
          'SENL': begin
            senl_solver := NLSystems.create;
            Chart1.Visible:= False;
            senl_solver.Parse := le_parser;
            array_list := TStringList.Create;
            temp := Trim(my_list[0]);
            iPos := Pos( ']', temp);
            array_list.Delimiter:= ',';
            array_list.StrictDelimiter:= True;
            array_list.DelimitedText:= Copy(temp, 2, Length(temp) - 2);
            senl_solver.num_equations:= array_list.Count;
            SetLength(senl_solver.equations, 4);

            for iPos := 0 to array_list.Count - 1 do begin
              senl_solver.equations[iPos] := array_list[iPos];
//              ShowMessage('Valor: ' + array_list[iPos]);
            end;

            for i := iPos + 1 to 3 do
                senl_solver.equations[i] := 'x';

              array_list.Clear;
            temp := Trim(my_list[1]);
            iPos := Pos( ']', temp);
            array_list.Delimiter:= ',';
            array_list.StrictDelimiter:= True;
            array_list.DelimitedText:= Copy(temp, 2, Length(temp) - 2);
            SetLength( senl_solver.starts, 4 );

            for iPos := 0 to array_list.Count - 1 do begin
                senl_solver.starts[iPos] := StrToFloat(array_list[iPos]);
//                ShowMessage('Valor: ' + array_list[iPos]);
            end;

            senl_solver.ErrorAllowed:= h;

            senl_final_result := senl_solver.NewtonRaphson();

            memHistorial.Text:= memHistorial.Text + func + LineEnding;

            for i := 0 to senl_solver.num_equations - 1 do begin
              memHistorial.Text:= memHistorial.Text + senl_solver.variables[i] + ': ' +
              FloatToStr(senl_final_result[i,0]) + LineEnding;
            end;


            ShowMessage('SENL([f1,f2,f3], [x0, x1, x2]). Newton Raphson generalizado.');
          end;
          'intersection': begin
//            Chart1.ClearSeries;
            Chart1.Visible:= True;
            root_finder := TNLEMethods.create;
            root_finder.Parse := le_parser;
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
            memHistorial.Text:= memHistorial.Text + func + LineEnding;
            memHistorial.Text:= memHistorial.Text + 'Interseccion: ' + FloatToStr(res) + LineEnding;
//            ShowMessage('intersection(f,g,a,b,colorf,colorg). Interseccion de dos funciones en un intervalo.' +
//            ' Todos los puntos.'); SYNTAX
          end;
          'integral': begin
            integral_solver := TIntegralMethods.create;
            integral_solver.func:= my_list[0];
            integral_solver.a := StrToFloat(my_list[1]);
            integral_solver.b := StrToFloat(my_list[2]);
            integral_solver.Method:= StrToInt(my_list[3]);

            current_func:= my_list[0];
            current_func2:= my_list[1];

            integral_solver.Parse := le_parser;

            res := integral_solver.Execute();

            ShowMessage('Resultado Integral: ' + FloatToStr(res) + ' unidades.');
            memHistorial.Text:= memHistorial.Text + func + LineEnding;
            memHistorial.Text:= memHistorial.Text + 'Resultado Integral: ' + FloatToStr(res) + ' unidades.' + LineEnding;

            //ShowMessage('integral(f,a,b,method)'); SYNTAX
          end;
          'area': begin
            ShowMessage('area(f,a,b,method): halla y grafica el área.');
          end;
          'area2': begin
            ShowMessage('area2(f,g,a,b, method): halla y grafica el área entre 2 funciones');
          end;
          'edo': begin
            Chart1.Visible:= True;

            edo_solver :=  TEdo.create();
            edo_solver.parser := le_parser;
            edoPlotter.Clear;
            edo_solver.func_d:= my_list[0];
            edo_solver.a := StrToFloat(my_list[1]);
            edo_solver.x_0 := StrToFloat(my_list[1]);
            edo_solver.y_0:= StrToFloat(my_list[2]);
            edo_solver.b := StrToFloat(my_list[3]);
            edo_solver.method := StrToInt(my_list[4]);
            res := edo_solver.Execute();

            for i:= 0 to Length(edo_solver.xn_s) - 1 do begin
              edoPlotter.AddXY(edo_solver.xn_s[i], edo_solver.yn_s[i]);
            end;

            edoPlotter.Active:= True;

            Chart1.Extent.XMin := edo_solver.a;
            Chart1.Extent.XMax := edo_solver.b;

            memHistorial.Text:= memHistorial.Text + func + LineEnding;
            memHistorial.Text:= memHistorial.Text + 'Resultado EDO: ' + FloatToStr(res) + '.' + LineEnding;

            ShowMessage('edo(df,x0,y0,obj,method): plottea la funcion primitiva');

            edo_solver.Destroy;
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
//  m_function := my_function.Create;
//  m_parser := TParseMath.create();
  le_parser.Expression:= current_func;
  le_parser.NewValue('x', AX);
  //m_function.func := current_func;
  //AY := m_function.f(AX);
  AY := le_parser.Evaluate();
  //AY := AX;

end;

procedure TForm1.Chart1FuncSeries2Calculate(const AX: Double; out AY: Double);
var
  m_function: my_function;
begin
  {m_function := my_function.Create;
  m_function.func := current_func2;
  AY := m_function.f(AX);}

  le_parser.NewValue('x', AX);
  le_parser.Expression:= current_func2;

  //AY := m_function.f(AX);
  AY := le_parser.Evaluate();

end;

end.

