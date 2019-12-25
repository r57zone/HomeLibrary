program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Main},
  Unit2 in 'Unit2.pas' {DescriptionForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMain, Main);
  Application.CreateForm(TDescriptionForm, DescriptionForm);
  Application.ShowMainForm:=false;
  Application.Run;
end.
