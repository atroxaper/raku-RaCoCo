unit module Racoco::UtilExtProc;

role ExtProc is export {
  method run(|) { ... }
}

class RunProc does ExtProc is export {
  method run(|c --> Proc) {
    run(|c);
  }
}
