with AUnit.Options;
with AUnit.Reporter.Text;
with AUnit.Test_Results;

package Ada_Lib.Unit_Test.Reporter is

   type Reporter_Type is new AUnit.Reporter.Text.Text_Reporter with private;

   overriding
   procedure Report (
      Engine                     : in     Reporter_Type;
      Results                    : in out AUnit.Test_Results.Result'Class;
      Options                    : in     AUnit.Options.AUnit_Options :=
                                             AUnit.Options.Default_Options);

private

   type Reporter_Type is new AUnit.Reporter.Text.Text_Reporter with null record;

end Ada_Lib.Unit_Test.Reporter;


