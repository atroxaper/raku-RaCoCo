unit module Racoco::UtilExtProc;

class RunProc is export {
  method run(|c --> Proc) {
    shell(|c);
  }
}
