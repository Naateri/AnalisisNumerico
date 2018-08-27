unit main; //la unidad debe llamarse igual que el archivo

//Pascal datatypes:
{
 Real
 Double
 Integer
 LongInt
 String (todo lo que puedas)
 ShortString (string 255 caracteres max)
 Char
 Boolean

 Importando:
 TStringList
}

//Bloques de código: con begin y end (en vez de { y })

(*
  comentario
*)

{$mode objfpc}{$H+}

interface

uses //includes
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  taylor_series;

type //dentro defino una clase

  { TForm1 }

  TForm1 = class(TForm) //TForm1, hereda de TForm
    ResultMemo: TMemo;
    TaylorFunc: TComboBox;
    btnExecute: TButton;
    EdiAngle: TEdit;
    EdiError: TEdit;
    EdiResult: TEdit;
    LabAngle: TLabel;
    LabError: TLabel;
    procedure btnExecuteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private //costumbre: nombre de clase empieza con T mayuscula
  //variables privadas
    Taylor : TTaylor;
  public
  //variables publicas
  end; //acabo la definicion de clase

//function: funciones
//procedure: equivalente a funcion void de C(?)

var
  Form1: TForm1;

implementation

{$R *.lfm}



{ TForm1 }



procedure TForm1.btnExecuteClick(Sender: TObject);
var x: Real;
begin

  Taylor := TTaylor.create();
  Taylor.FunctionType := IntPtr(TaylorFunc.Items.Objects[ TaylorFunc.ItemIndex ]);
  Taylor.x := StrToFloat(EdiAngle.Text);
  Taylor.Error := StrToFloat(EdiError.Text);
  x := Taylor.Execute();
  if (Taylor.valid = True) then
  begin
      EdiResult.Text := FloatToStr(x);
  end else begin
      EdiResult.Text := 'ERROR';
  end;
  Taylor.Destroy; //siempre destruir

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
     Taylor := TTaylor.create();
     TaylorFunc.Items.Assign( Taylor.FunctionList );
     TaylorFunc.ItemIndex := 0;
end;

end.

