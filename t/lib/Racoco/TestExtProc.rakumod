use Racoco::UtilExtProc;
unit module Racoco::TestExtProc;

class FakeProc does ExtProc is export {
  has $.c;
  method run(|c) {
    $!c = c;
    return class :: { method exitcode { 0 } }
  }
}

class FailProc does ExtProc is export {
  method run(|c) {
    return class :: { method exitcode { 1 } }
  }
}