unit final_project_main;

{$mode objfpc}{$H+}

{
los strings siempre van entre comillas
-root(f,a,b,bool,n): o root(f,a,b,bool) o root(f,a,b,bool,n). n es el metodo.
bool = true, todas las raíces, false, solo una raíz
-intersection(f,g,a,b,color_f,color_g): todos los puntos de interseccion entre
f y g en [a,b]
-plot2d(f,a,b,color_f): grafica.
-plot2d(g,a',b',color_g): grafica la otra funcion por encima.
Si hace click en f y g, halla todas las intersecciones del intervalo.
si a != a' y b != b' entonces para las intersecciones toma [a',b']
Pueden haber n funciones.		
-polyroot([3,2,5]). Pasas las raíces del polinomio, halla el polinomio. No grafica.
Devuelve un string. Se puede asignar a una variable. Podemos graficar despues.
-polynomial([valores en x], [valores en y]): si mandas diferente cantidad de valores,
deberia mandar un error. Devuelve un polinomio que se debería poder pasar a 
una variable, ejemplo: f = polynomial([1,2],[3,5]). Maximo 6 elementos.
-senl(['x','y'],[f1,f2],[x_0,y_0]): [nombres_variables],[funciones],[valores_iniciales]
Si no encuentra raices: mensaje diciendo que no se encontro una raiz.
-integral(f,a,b,method=1): grafica la region sombreada, NO necesariamente el area.
Devuelve un numero.
0: trapecio
1: simpson1/3
2: simpson3/8
-area(f,g,a,b,method=1): grafica f y g, ubica la region entre ambas funciones.
para hallar el area: h = f-(g)
f = clblue, g = clred
cada f_i en la sumatoria debe estar en valor absoluto. NO es el valor absoluto de la respuesta.
Ambos (area, integral) grafican.
-edo(df,x_0,y_0,x_n,method=0):
si x_n > x_0: el h resta, no aumenta.
tip:
var signo
signo = sign(x_n-x_0)
signo = signo * h
metodos: 0->euler, 1->heun, 2->rk4, 3->dormand-prince
Respuesta numérica (y_n), grafica la funcion 'original'

clearplot: limpia las funciones
eval(f): el parser evalua la funcion f con los valores ya guardados antes.
variables por defecto:
decimal = 2
error = 0.01

-opcional: ecuaciones diferenciales parciales, SEDO con runge kutta. No se grafica. Metodo adaptativo.
}

interface

uses
  Classes, SysUtils, FileUtil, uCmdBox, TAGraph, TAFuncSeries, TASeries, Forms, math,
  Controls, Graphics, Dialogs, Grids, StdCtrls, ExtCtrls, nle_methods, lagrange_pol, Integrals,
  edo, MyMatrix, NonLinearSystem, ParseMath;

type

  { TForm1 }

  TForm1 = class(TForm)
    Chart1: TChart;
    Chart1LineSeries1: TLineSeries;
    CmdBox1: TCmdBox;
    memHistorial: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    StringGrid1: TStringGrid;
    procedure Chart1FuncSeries1Calculate(const AX: Double; out AY: Double);
    procedure Chart1FuncSeries2Calculate(const AX: Double; out AY: Double);
    procedure CmdBox1Input(ACmdBox: TCmdBox; Input: string);
    procedure FormCreate(Sender: TObject);
    function CreatingStrings(Input: string): String;
    function CreatingNumbers(Input: String): Real;
    function find_string(Input: string): String;
    function f(x:Real): Real;
    function f2(x:Real): Real;
    function finding_roots(my_list: TStringList): Real;
    function finding_polyroot(my_list: TStringList): String;
    function finding_lagrange(my_list: TStringList): String;
    function finding_integral(my_list: TStringList): Real;
    function finding_area(my_list: TStringList): Real;
    function finding_edo(my_list: TStringList): Real;
  private
    h: Real;
    values: array of Real; //integer/real variables
    names: array of String; //integer/real variables names
    s_values: array of String; //string variables
    s_names: array of String; //string variables names
    le_parser: TParseMath;
    current_var: Integer;
    current_real, current_string: Integer;

    { private declarations }
  public
    { public declarations }
    LineSeries: TLineSeries;
    le_area: TAreaSeries;
    le_area_inter: TAreaSeries;
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
  StringGrid1.Cells[1,0] := 'Type';
  StringGrid1.Cells[2,0] := 'Value';
  SetLength(values, 100);
  SetLength(names, 100);
  SetLength(s_values, 100);
  SetLength(s_names, 100);
  h := 0.01;
  values[0] := h;
  names[0] := 'error';
  names[1] := 'decimal';
  values[1] := decimal;

  le_parser := TParseMath.create();
  le_parser.AddVariable('x',0);
  le_parser.AddVariable('y', 0);
  le_parser.AddVariable('z', 0);
  le_parser.AddVariable('w', 0);
  le_parser.AddVariable('error',0.01);
  le_parser.AddVariable('decimal',2);

  StringGrid1.Cells[0,1] := names[0];
  StringGrid1.Cells[1,1] := 'Real';
  StringGrid1.Cells[2,1] := FloatToStr(h);

  StringGrid1.Cells[0,2] := names[1];
  StringGrid1.Cells[1,2] := 'Integer';
  StringGrid1.Cells[2,2] := FloatToStr(decimal);

  s_names[0] := '';
  s_names[1] := '';
  s_values[0] := '';
  s_values[1] := '';

  for i := 2 to 99 do begin
      names[i] := '';
      s_names[i] := '';
      s_values[i] := '';
  end;

  current_var:= 2;
  current_string:=0;
  current_real:=2;

  memHistorial.Text:= '';

end;

function TForm1.finding_roots(my_list: TStringList): Real;
var
  root_finder: TNLEMethods;
  res: Real;
  xmin, xmax, x: Real;
  func, temp: String;
  i: Integer;
begin
  current_func:= my_list[0];
//            current_func2:= my_list[0];
root_finder := TNLEMethods.create;
root_finder.Parse := le_parser;
root_finder.func:= find_string( Copy(my_list[0], 2, Length(my_list[0]) - 2) );

//root_finder.a := StrToFloat(my_list[1]);
            le_parser.Expression:= my_list[1];
            root_finder.a := le_parser.Evaluate();
            le_parser.Expression:= my_list[2];
            root_finder.b := le_parser.Evaluate();
//            root_finder.b:= StrToFloat(my_list[2]);
            root_finder.ErrorAllowed:= h;
            if (my_list.Count = 5) then
               root_finder.Method:= StrToInt(my_list[4])
            else
                root_finder.Method:= 0;
            if (my_list[3] = 'True') or (my_list[3] = 'true') then begin
                root_finder.Method:= 3;
            end;

            xmin:= root_finder.a;
            xmax := root_finder.b;
            Chart1.Extent.XMin := root_finder.a;
            Chart1.Extent.XMax := root_finder.b;

            res := root_finder.Execute();
            ShowMessage('Root: ' + FloatToStr( res ) );

            LineSeries := TLineseries.Create( Chart1 );
            x := xmin;

            le_parser.Expression:= root_finder.func;

            with LineSeries do begin
                 repeat
                       le_parser.NewValue('x', x);
                       if (le_parser.Evaluate() = NaN) then begin
                          x := x + 0.01;
                          Continue;
                       end;
                       AddXY(x, le_parser.Evaluate());
                       x := x + 0.01;
                 until (x >= xmax);
            end;

            LineSeries.ShowLines:= True;
            LineSeries.LinePen.Color:= clBlue;
            LineSeries.Active:= True;

            Chart1.AddSeries( LineSeries );

            LineSeries := TLineSeries.Create(Chart1);

            memHistorial.Text:= memHistorial.Text + func + LineEnding;
            if (my_list[3] = 'True') or (my_list[3] = 'true') then begin
               for i := 0 to root_finder.results_size - 1 do begin
                 LineSeries.AddXY(root_finder.results[i], 0);
                 memHistorial.Text:= memHistorial.Text + 'Roots: ' + FloatToStr( root_finder.results[i] ) + ', ';
               end;
               memHistorial.Text:= memHistorial.Text + LineEnding;
            end else begin
                LineSeries.AddXY(res, 0);
                memHistorial.Text:= memHistorial.Text + 'Root: ' + FloatToStr( res ) + LineEnding;
            end;
            LineSeries.ShowPoints:= True;
            LineSeries.ShowLines:= False;
            Chart1.AddSeries(LineSeries);
            Chart1.Visible:= True;
            Result := res;
            //root_finder.Destroy;

end;

function TForm1.finding_polyroot(my_list: TStringList): String;
var
  array_list: TStringList;
  func, temp: String;
  iPos, i: Integer;
  lagrange_solver: TLagrange;
  pts: array of array of Real;
begin
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
                //ShowMessage('Valor: ' + array_list[iPos]);
            //copy values to create the polynomial

            array_list.Destroy;
            lagrange_solver.points := pts;

            current_func := lagrange_solver.polyroot_text();
            Chart1.Proportional:= False;
            Chart1.Visible:= False;

            memHistorial.Text:= memHistorial.Text + func + LineEnding;
            memHistorial.Text:= memHistorial.Text + 'funcion: ' + current_func + LineEnding;
            Result := current_func;

            ShowMessage('polyroot([raices]). Raices de un polinomio.');
end;

function TForm1.finding_lagrange(my_list: TStringList): String;
var
  array_list: TStringList;
  func, temp: String;
  iPos, i: Integer;
  lagrange_solver: TLagrange;
  pts: array of array of Real;
begin
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
  //                ShowMessage('Valor: ' + array_list[iPos]);
                  pts[iPos][1] := StrToFloat(array_list[iPos]);
              end;
              //array_list.Sort; //to get min and max
              //copy y values to Lagrange

              array_list.Destroy;
              lagrange_solver.points := pts;

              current_func := lagrange_solver.find_text();
              current_func2:= current_func;
              Chart1.Visible:= False;

              memHistorial.Text:= memHistorial.Text + func + LineEnding;
              memHistorial.Text:= memHistorial.Text + 'funcion: ' + current_func + LineEnding;
              Result := current_func;
end;

function TForm1.finding_integral(my_list: TStringList): Real;
var
  func, temp: String;
  res: Real;
  xmin, xmax, x: Real;
  integral_solver: TIntegralMethods;
begin
     integral_solver := TIntegralMethods.create;
              integral_solver.func:= find_string( Copy(my_list[0], 2, Length(my_list[0]) - 2) );
              le_parser.Expression:= my_list[1];
//integral_solver.a := StrToFloat(my_list[1]);
             integral_solver.a := le_parser.Evaluate();
             le_parser.Expression:= my_list[2];
             integral_solver.b:= le_parser.Evaluate();
             integral_solver.h := h;
//              integral_solver.b := StrToFloat(my_list[2]);
              if (my_list.Count = 4) then
                 integral_solver.Method:= StrToInt(my_list[3])
              else
                  integral_solver.Method:= 2;

              current_func:= integral_solver.func;
//              current_func2:= my_list[1];

              integral_solver.Parse := le_parser;

              res := integral_solver.Execute();

              xmin:= integral_solver.a;
              xmax:= integral_solver.b;

              LineSeries := TLineseries.Create( Chart1 );
              le_area := TAreaSeries.Create(Chart1);
              x := xmin;

              Chart1.Extent.XMin := xmin;
              Chart1.Extent.XMax := xmax;

              le_area.UseZeroLevel:= True;
              le_area.AreaBrush.Color:= clGreen;
              le_area.AreaContourPen.Color:= clRed;
              le_area.AreaContourPen.Style:= psDot;
              le_area.AreaContourPen.Width:= 3;
              le_area.AreaLinesPen.Style:= psClear;

              le_parser.Expression:= integral_solver.func;

              with LineSeries do begin
                   repeat
                         le_parser.NewValue('x', x);
                         if (le_parser.Evaluate() = NaN) then begin
                            x := x + 0.01;
                            Continue;
                         end;
                         AddXY(x, le_parser.Evaluate());
                         le_area.AddXY(x, le_parser.Evaluate());
                         x := x + 0.01;
                   until (x >= xmax);
              end;

              le_area.Active:= True;

              LineSeries.ShowLines:= True;
              LineSeries.LinePen.Color:= clRed;
              LineSeries.Active:= True;

              Chart1.AddSeries( LineSeries );
              Chart1.AddSeries( le_area );

              Chart1.Proportional:= False;

              Chart1.Visible:= True;

  //            functions.Add(LineSeries);

              ShowMessage('Resultado Integral: ' + FloatToStr(res) + ' unidades.');
              memHistorial.Text:= memHistorial.Text + func + LineEnding;
              memHistorial.Text:= memHistorial.Text + 'Resultado Integral: ' + FloatToStr(res) + ' unidades.' + LineEnding;

              Result := res;
end;

function Tform1.finding_area(my_list: TStringList): Real;
var
  func, temp: String;
  res: Real;
  xmin, xmax, x: Real;
  integral_solver: TIntegralMethods;
begin
//     ShowMessage('area(f,g,a,b,method=1): halla y grafica el área. f = blue, g = red');
            integral_solver := TIntegralMethods.create;
            integral_solver.func:= find_string( Copy(my_list[0], 2, Length(my_list[0]) - 2) ) + ' - (' +
                                   find_string( Copy(my_list[1], 2, Length(my_list[1]) - 2) ) + ')';
            le_parser.Expression:= my_list[2];
            integral_solver.a:= le_parser.Evaluate();
            le_parser.Expression:= my_list[3];
            integral_solver.b:= le_parser.Evaluate();
//            integral_solver.a := StrToFloat(my_list[2]);
//            integral_solver.b := StrToFloat(my_list[3]);
              integral_solver.h := h;
            if (my_list.Count = 5) then
               integral_solver.Method:= StrToInt(my_list[4])
            else
                integral_solver.Method:= 2;
            integral_solver.area:= True;

            current_func:= find_string (Copy(my_list[0], 2, Length(my_list[0]) - 2) );
            current_func2:= find_string (Copy(my_list[1], 2, Length(my_list[1]) - 2) );

            integral_solver.Parse := le_parser;

            res := integral_solver.Execute();

            xmin:= integral_solver.a;
            xmax:= integral_solver.b;

            {le_area := TAreaSeries.Create(Chart1);
            le_area_inter := TAreaSeries.Create(Chart1);

            le_area.UseZeroLevel:= True;
            le_area.AreaBrush.Color:= clGreen;
            le_area.AreaContourPen.Color:= clRed;
            le_area.AreaContourPen.Style:= psDot;
            le_area.AreaContourPen.Width:= 3;
            le_area.AreaLinesPen.Style:= psClear;

            le_area_inter.UseZeroLevel:= True;
            le_area_inter.AreaBrush.Color:= clYellow;
            le_area_inter.AreaContourPen.Color:= clBlue;
            le_area_inter.AreaContourPen.Style:= psDot;
            le_area_inter.AreaContourPen.Width:= 3;
            le_area_inter.AreaLinesPen.Style:= psClear; }
            //function f
            x := xmin;
            LineSeries := TLineseries.Create( Chart1 );

            le_parser.Expression:= current_func;

            with LineSeries do begin
                 repeat
                       le_parser.NewValue('x', x);
                       if (le_parser.Evaluate() = NaN) then begin
                          x := x + 0.01;
                          Continue;
                       end;
                       AddXY(x, le_parser.Evaluate());

                       {if (f(x) >= f2(x)) then begin
                          le_area.AddXY(x, f(x));
                          le_area_inter.AddXY(x, f2(x));
                       end
                       else begin
                           le_area.AddXY(x, f2(x));
                           le_area_inter.AddXY(x, f(x));
                       end; }
                       x := x + 0.01;
                 until (x >= xmax);
            end;
{            le_area.Active:= True;
            le_area_inter.Active:= True; }

            LineSeries.ShowLines:= True;
            LineSeries.LinePen.Color:= clBlue;
            LineSeries.Active:= True;

            Chart1.AddSeries( LineSeries );

            //function g

            x := xmin;
            LineSeries := TLineseries.Create( Chart1 );

            le_parser.Expression:= current_func2;

            with LineSeries do begin
                 ShowLines:= True;
                 LinePen.Color:= clRed;
                 Active:= True;
                 repeat
                       le_parser.NewValue('x', x);
                       if (le_parser.Evaluate() = NaN) then begin
                          x := x + 0.01;
                          Continue;
                       end;
                       AddXY(x, le_parser.Evaluate());
                       //le_area.AddXY(x, le_parser.Evaluate());
                       {if (f(x) > f2(x)) then
                          le_area.AddXY(x, f(x))
                       else
                          le_area.AddXY(x, f2(x)); }
                       x := x + 0.01;
                 until (x >= xmax);
            end;

            Chart1.AddSeries(LineSeries);

{            Chart1.AddSeries( le_area );
            Chart1.AddSeries(le_area_inter); }

            Chart1.Proportional:= False;
            Chart1.Extent.XMin := xmin;
            Chart1.Extent.XMax := xmax;

            Chart1.Visible:= True;

            ShowMessage('Resultado Integral: ' + FloatToStr(res) + ' unidades.');
            memHistorial.Text:= memHistorial.Text + func + LineEnding;
            memHistorial.Text:= memHistorial.Text + 'Resultado Integral: ' + FloatToStr(res) + ' unidades.' + LineEnding;
            Result := res;
end;

function Tform1.finding_edo(my_list: TStringList): Real;
var
  func, temp: String;
  res: Real;
  xmin, xmax, x: Real;
  i: Integer;
  edo_solver: TEdo;
begin
  Chart1.Visible:= True;

              edo_solver :=  TEdo.create();
              edo_solver.parser := le_parser;
              //edoPlotter.Clear;
              edo_solver.func_d:= find_string(Copy( my_list[0], 2, Length(my_list[0]) - 2) );
              le_parser.Expression:= my_list[1];
              edo_solver.a := le_parser.Evaluate();
              edo_solver.x_0 := le_parser.Evaluate();

              le_parser.Expression:= my_list[2];
              edo_solver.y_0 := le_parser.Evaluate();

              le_parser.Expression:= my_list[3];
              edo_solver.b:= le_parser.Evaluate();
{              edo_solver.a := StrToFloat(my_list[1]);
              edo_solver.x_0 := StrToFloat(my_list[1]);
              edo_solver.y_0:= StrToFloat(my_list[2]);
              edo_solver.b := StrToFloat(my_list[3]); }
              edo_solver.h:= h;
              if (my_list.Count = 5) then
                 edo_solver.method := StrToInt(my_list[4])
              else
                  edo_solver.method:= 3;
              res := edo_solver.Execute();
              //le_parser.Expression:= my_list[1];

              LineSeries := TLineseries.Create( Chart1 );

              for i:= 0 to Length(edo_solver.xn_s) - 1 do begin
                LineSeries.AddXY(edo_solver.xn_s[i], edo_solver.yn_s[i]);
              end;

              LineSeries.ShowLines:= True;
              LineSeries.LinePen.Color:= clBlue;
              LineSeries.Active:= True;

              Chart1.AddSeries( LineSeries );


              {for i:= 0 to Length(edo_solver.xn_s) - 1 do begin
                edoPlotter.AddXY(edo_solver.xn_s[i], edo_solver.yn_s[i]);
              end; }

              //edoPlotter.Active:= True;

              if (edo_solver.a > edo_solver.b) then begin
                  Chart1.Extent.XMin := edo_solver.b;
                  Chart1.Extent.XMax := edo_solver.a;
              end else begin
                Chart1.Extent.XMin := edo_solver.a;
                Chart1.Extent.XMax := edo_solver.b;
              end;

              memHistorial.Text:= memHistorial.Text + func + LineEnding;
              memHistorial.Text:= memHistorial.Text + 'Resultado EDO: ' + FloatToStr(res) + '.' + LineEnding;

              ShowMessage('edo(df,x0,y0,obj,method): plottea la funcion primitiva');

              Result := res;

              edo_solver.Destroy;

end;

function Tform1.CreatingStrings(Input: string): String;
var
  my_list: TStringList;
  array_list: TStringList;
  func, temp: String;
  iPos, i: Integer;
  lagrange_solver: TLagrange;
  pts: array of array of Real;
begin
  my_list := TStringList.Create;
  Input := Trim(Input);
  iPos := Pos( '(', Input);
  func := Trim( Copy(Input, 1, iPos-1));
  my_list.Delimiter:= ';';
  my_list.StrictDelimiter:= true;
  my_list.DelimitedText:= Copy( Input, iPos+1, Length(Input) - iPos - 1);

  case func of
       'polyroot': begin
            Result := finding_polyroot(my_list);
            Exit;
          end;
          'polynomial': begin
            Result := finding_lagrange(my_list);
            Exit;
          end;
  end;

  Result := Input;

end;

function TForm1.CreatingNumbers(Input: String): Real;
var
  my_list: TStringList;
  func, temp: String;
  iPos, i: Integer;
  root_finder: TNLEMethods;
  res: Real;
  xmin, xmax, x: Real;
  integral_solver: TIntegralMethods;
  edo_solver: TEdo;
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

  case func of
          'root': begin
            Result := finding_roots(my_list);
            Exit;
          end;
          'integral': begin
            Result := finding_integral(my_list);
            Exit;
          end;
          'area': begin
            Result := finding_area(my_list);
            Exit;
          end;
          'edo': begin
            Result := finding_edo(my_list);
            Exit;
          end;
     end;
     le_parser.Expression:= Input;
     Result := le_parser.Evaluate();

end;

function TForm1.find_string(Input: String): String;
var
  index: Integer;
begin
     index := 0;
     while index < current_string do begin
       if s_names[index] = Input then begin
          Result := s_values[index];
          Exit;
          Break;
       end;
       index := index + 1;
     end;
     Result := Input; //string was not created
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
  xmin, xmax, x: Real;
  //values: array of Real;
  m_function: my_function;
//  my_point: TPoint;
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

      //edoPlotter.Active:= False;

      Chart1.Extent.UseXMin := True;
      Chart1.Extent.UseXMax := True;
      Chart1.Extent.XMax := 10;
      Chart1.Extent.XMin := -10;

  case func of
          'exit': begin
            ShowMessage('Me voy.');
            Application.Terminate;
          end;

          'update': begin
            iPos := 0;
            while (names[iPos] <> my_list[0]) do begin
              iPos := iPos + 1;
            end;

            le_parser.Expression:= my_list[1];
            values[iPos] := le_parser.Evaluate();
            le_parser.NewValue(my_list[0], values[iPos]);

            for i := 1 to current_var do begin
              if ( StringGrid1.Cells[0,i] = my_list[0] ) then begin
                iPos := i;
                Break;
              end;
            end;
            //values[iPos-1] := StrToFloat(my_list[1]);

            StringGrid1.Cells[2,iPos] := FloatToStr(le_parser.Evaluate());

            memHistorial.Text:= memHistorial.Text + func + LineEnding;
            memHistorial.Text:= memHistorial.Text + 'variable ' + my_list[0] + ' actualizada con valor ' + my_list[1]
            + LineEnding;

          end;

          'create': begin //create(name, value)
            Chart1.Visible:= False;
            iPos := 2;
            while (names[iPos] <> '') do begin
              iPos := iPos + 1;
            end;

            names[iPos] := my_list[0];
            for i := 2 to my_list.Count - 1 do
                my_list[1] := my_list[1] + ';' + my_list[i];
            values[iPos] := CreatingNumbers(my_list[1]);
            StringGrid1.Cells[0,current_var+1] := my_list[0];
            StringGrid1.Cells[1,current_var+1] := 'Real';
            StringGrid1.Cells[2,current_var+1] := FloatToStr(values[iPos]);

            le_parser.AddVariable(names[iPos], values[iPos]);
            memHistorial.Text:= memHistorial.Text + func + LineEnding;
            memHistorial.Text:= memHistorial.Text + 'Variable ' + my_list[0] + ' creada con valor ' +
            FloatToStr(values[iPos]) + '.' + LineEnding;

            current_var := current_var + 1;
            current_real:= current_real + 1;

          end;

          'create_s': begin //create_s(name, value)
            Chart1.Visible:= False;
            iPos := 0;
            {while (s_names[iPos] <> '') do begin
              iPos := iPos + 1;
            end;}

            //ShowMessage('Current String: ' + IntToStr(current_string));
            s_names[current_string] := my_list[0];
            for i := 2 to my_list.Count - 1 do
                my_list[1] := my_list[1] + ';' + my_list[i];

            s_values[current_string] := CreatingStrings(my_list[1]);

            StringGrid1.Cells[0,current_var+1] := my_list[0];
            StringGrid1.Cells[1,current_var+1] := 'String';
            StringGrid1.Cells[2,current_var+1] := s_values[iPos];

            memHistorial.Text:= memHistorial.Text + func + LineEnding;
            memHistorial.Text:= memHistorial.Text + 'Variable ' + my_list[0] + ' creada con valor ' + s_values[current_string] + '.'
            + LineEnding;

            current_var := current_var + 1;
            current_string := current_string + 1;

          end;

          'root': begin
            finding_roots(my_list);
          end;
          'plot2d': begin
//            Chart1.ClearSeries;
            current_func:= find_string( Copy(my_list[0], 2, Length(my_list[0]) - 2) );
            //current_func2:= my_list[0];
            LineSeries := TLineseries.Create( Chart1 );
            le_parser.Expression:= my_list[1];
            xmin:= le_parser.Evaluate();
            le_parser.Expression:= my_list[2];
            xmax := le_parser.Evaluate();
            x := xmin;

            Chart1.Extent.XMin := xmin;
            Chart1.Extent.XMax := xmax;

            le_parser.Expression:= current_func;

            with LineSeries do begin
                 repeat
                       le_parser.NewValue('x', x);
                       if (le_parser.Evaluate() = NaN) then begin
                          x := x + 0.01;
                          Continue;
                       end;
                       AddXY(x, le_parser.Evaluate());
                       x := x + 0.01;
                 until (x >= xmax);
            end;

            LineSeries.ShowLines:= True;
            LineSeries.LinePen.Color:= StringToColor(my_list[3]);
            LineSeries.Active:= True;

            Chart1.AddSeries( LineSeries );

            Chart1.Proportional:= False;

            Chart1.Visible:= True;
            memHistorial.Text:= memHistorial.Text + func + LineEnding;
            memHistorial.Text:= memHistorial.Text + 'funcion ' + current_func + ' graficada ' +
            'de ' + my_list[1] + ' a ' + my_list[2] + LineEnding;

//            functions.Add( LineSeries );

//            ShowMessage('Grafica. (f,a,b,color)'); SYNTAX
          end;
          'polyroot': begin
            finding_polyroot(my_list);
          end;
          'polynomial': begin
            finding_lagrange(my_list);
          end;
          'senl': begin
            senl_solver := NLSystems.create;
            Chart1.Visible:= False;
            senl_solver.Parse := le_parser;
            senl_solver.ErrorAllowed:= h;
            array_list := TStringList.Create;
            temp := Trim(my_list[1]);
            iPos := Pos( ']', temp);
            array_list.Delimiter:= ',';
            array_list.StrictDelimiter:= True;
            array_list.DelimitedText:= Copy(temp, 2, Length(temp) - 2);
            senl_solver.num_equations:= array_list.Count;
            SetLength(senl_solver.equations, 4);

            for iPos := 0 to array_list.Count - 1 do begin
              senl_solver.equations[iPos] := find_string(Copy(array_list[iPos],2,Length(array_list[iPos])-2));
            end;

            for i := iPos + 1 to 3 do //if less than 4 equations
                senl_solver.equations[i] := 'x';

              array_list.Clear;
            temp := Trim(my_list[2]);
            iPos := Pos( ']', temp);
            array_list.Delimiter:= ',';
            array_list.StrictDelimiter:= True;
            array_list.DelimitedText:= Copy(temp, 2, Length(temp) - 2);
            SetLength( senl_solver.starts, 4 );

            for iPos := 0 to array_list.Count - 1 do begin
                le_parser.Expression:= array_list[iPos];
//                senl_solver.starts[iPos] := StrToFloat(array_list[iPos]);
                  senl_solver.starts[iPos] := le_parser.Evaluate();
//                ShowMessage('Valor: ' + array_list[iPos]);
            end;

            senl_solver.ErrorAllowed:= h;

            senl_final_result := senl_solver.NewtonRaphson();

            memHistorial.Text:= memHistorial.Text + func + LineEnding;

            for i := 0 to senl_solver.num_equations - 1 do begin
              memHistorial.Text:= memHistorial.Text + senl_solver.variables[i] + ': ' +
              FloatToStr(senl_final_result[i,0]) + LineEnding;
            end;
            ShowMessage('SENL([variables],[functions], [initial_values]). Newton Raphson generalizado.');
          end;
          'intersection': begin
//            Chart1.ClearSeries;
            Chart1.Visible:= True;
            root_finder := TNLEMethods.create;
            root_finder.Parse := le_parser;
            root_finder.func:= find_string( Copy(my_list[0], 2, Length(my_list[0]) - 2) );
//            ShowMessage('Function: ' + root_finder.func);
            root_finder.func2:= find_string( Copy(my_list[1], 2, Length(my_list[1]) - 2) );
//            ShowMessage('Function2: ' + root_finder.func2);

            current_func:= root_finder.func;
            current_func2:= root_finder.func2;

            root_finder.ErrorAllowed:= h;

            le_parser.Expression:= my_list[2];
//            root_finder.a := StrToFloat(my_list[2]);
              root_finder.a:= le_parser.Evaluate();
            le_parser.Expression:= my_list[3];
//            root_finder.b:= StrToFloat(my_list[3]);
              root_finder.b:= le_parser.Evaluate();
            root_finder.ErrorAllowed:= h;
            xmin:= root_finder.a;
            xmax := root_finder.b;
            x := xmin;
            Chart1.Extent.XMin := xmin;
            Chart1.Extent.XMax := xmax;

            res := root_finder.Intersection();
            ShowMessage('Intersection: (' + FloatToStr(res) + ', ' + FloatToStr( root_finder.f2(res)) + ')' );
            Chart1.Proportional:= False;

            LineSeries := TLineseries.Create( Chart1 );

            le_parser.Expression:= current_func;

            with LineSeries do begin
                 repeat
                       le_parser.NewValue('x', x);
                       if (le_parser.Evaluate() = NaN) then begin
                          x := x + 0.01;
                          Continue;
                       end;
                       AddXY(x, le_parser.Evaluate());
                       x := x + 0.01;
                 until (x >= xmax);
            end;

            LineSeries.ShowLines:= True;
            LineSeries.LinePen.Color:= StringToColor(my_list[4]);
            LineSeries.Active:= True;

            Chart1.AddSeries( LineSeries );
//            ShowMessage('func1 graphed');

            ///////////////////// SECOND FUNCTION /////////////

            le_parser.Expression:= current_func2;

            LineSeries := TLineseries.Create( Chart1 );
            xmin:= Chart1.Extent.XMin;
            xmax := Chart1.Extent.XMax;
            x := xmin;

            with LineSeries do begin
                 repeat
                       le_parser.NewValue('x', x);
                       if (le_parser.Evaluate() = NaN) then begin
                          x := x + 0.01;
                          Continue;
                       end;
                       AddXY(x, le_parser.Evaluate());
                       x := x + 0.01;
                 until (x >= xmax);
            end;

            LineSeries.ShowLines:= True;
            LineSeries.LinePen.Color:= StringToColor(my_list[5]);
            LineSeries.Active:= True;

            Chart1.AddSeries( LineSeries );

//            ShowMessage('func2 graphed');

              LineSeries := TLineSeries.Create(Chart1);

            for i := 0 to root_finder.results_size - 1 do begin
              LineSeries.AddXY(root_finder.results[i], root_finder.f2(root_finder.results[i]));
            end;
            LineSeries.ShowPoints:= True;
            LineSeries.ShowLines:= False;

            Chart1.AddSeries( LineSeries );
//            root_finder.Destroy;
            memHistorial.Text:= memHistorial.Text + func + LineEnding;
            memHistorial.Text:= memHistorial.Text + 'Raices: ';
            for i := 0 to root_finder.results_size - 1 do begin
              memHistorial.Text := memHistorial.Text + '(' + FloatToStr(root_finder.results[i]) + ', ' +
              FloatToStr( root_finder.f2(res)) + ')' + ', ';
            end;
            memHistorial.Text := memHistorial.Text + LineEnding;
//            ShowMessage('intersection(f,g,a,b,colorf,colorg). Interseccion de dos funciones en un intervalo.' +
//            ' Todos los puntos.'); SYNTAX
          end;
          'integral': begin
            finding_integral(my_list);
            //ShowMessage('integral(f,a,b,method)'); SYNTAX
          end;
          'area': begin
            finding_area(my_list);
          end;
          'edo': begin
            finding_edo(my_list);
          end;
     end;
//  Chart1FuncSeries1.Extent.UseXMin := False;
//  Chart1FuncSeries1.Extent.UseXMax := False;

    case Input of
            'clearplot': begin

//              SetLength(TSeries, 4);
//              Chart1.Series.Clear;
              Chart1.ClearSeries;
//              Chart1.Refresh;
            end;
            'help': begin ShowMessage('Las siguientes funciones pueden ser ingresadas: ' + LineEnding
            + 'create(var_name, var_value): crea una variable de tipo Real/Float. Puede guardar funciones de tipo:'
            + 'root (si se hallan todas las raices guarda la ultima), integral, area y edo.'+ LineEnding
         + 'update(var_name, var_value): actualiza el valor de una variable' + LineEnding
           +'create_s(var_name, var_value): crea una variable de tipo string. Puede guardar funciones de polynomial y polyroot' + LineEnding
          + 'root(f;a;b;true/false;method): f es la función, a y b el intervalo, los métodos pueden ser: ' +
           'Biseccion (0), Falsa Posicion (1), Secante (2). True (1) o False (0)' +
            ' te dice si puedes hallar todas las raíces.'+ LineEnding
            + 'plot2d(f;a;b;color): f es la funcion, [a,b] el intervalo donde será graficado,' +
            ' color el color de la gráfica. (Ej: clBlue).' + LineEnding
            + 'polyroot([1,3,4,2]): Halla un polinomio con las raíces dadas.' + LineEnding
            + 'polynomial([1,2,3];[3,-3,4]): devuelve una función dados unos puntos. ' +
            'Primer array: valores en x. Segundo array: valores en y.' + LineEnding
            + 'senl([variables];[ecuaciones];[valores_iniciales]): resuelve el sistema de ecuaciones propuesto.' + LineEnding
            + 'intersection(f,g,a,b,color1,color2): halla la intersección entre dos funciones. '
            + 'f y g son funciones, a y b el intervalo donde va a hallar la o las intersecciones, '
            + 'color1 y color2 son los colores de f y g respectivamente.' + LineEnding
            + 'integral(f,a,b,method): halla el valor de la integral de f en los intervalos a y b. Grafica el area.'
            + ' Method: 0 es trapecio, 1 es Simpson 1/3, 2 es Simpson 3/8' + LineEnding
            + 'area(f,g,a,b,method): halla la integral entre f y g en el intervalo [a,b].' + LineEnding
            + 'edo(df, x0, y0, xn, method): plottea la funcion primitiva de df, desde x0 hasta yn.' +
            'method: 0->Euler, 1->Heun, 2->Runge Kutta cuarto orden, 3->Dormand-Prince. ' + LineEnding
            );
            memHistorial.Text:= memHistorial.Text + func;
          end;
            'noplot': begin
               Chart1.Visible:= False;
            end;
    end;

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
{  le_parser.Expression:= current_func;
  le_parser.NewValue('x', AX);
  //m_function.func := current_func;
  //AY := m_function.f(AX);
  AY := le_parser.Evaluate();
  //AY := AX; }
  AY := 0;

end;

procedure TForm1.Chart1FuncSeries2Calculate(const AX: Double; out AY: Double);
var
  m_function: my_function;
begin
  {m_function := my_function.Create;
  m_function.func := current_func2;
  AY := m_function.f(AX);}

{  le_parser.NewValue('x', AX);
  le_parser.Expression:= current_func2;

  //AY := m_function.f(AX);
  AY := le_parser.Evaluate();}
  AY := 0;

end;

Function TForm1.f(x: Real): Real;
var
  parse: TParseMath;
begin
  parse := TParseMath.create();
  parse.AddVariable('x', x);
  parse.Expression:= current_func;
//  ShowMessage('func: ' + current_func);
  Result := Parse.Evaluate();
  parse.destroy;
end;

function TForm1.f2(x: Real): Real;
var
  parse: TParseMath;
begin
  parse := TParseMath.create();
  parse.AddVariable('x', x);
  parse.Expression:= current_func2;
  Result := Parse.Evaluate();
  parse.destroy;
end;


end.

