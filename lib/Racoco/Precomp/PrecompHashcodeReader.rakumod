unit module Racoco::Precomp::PrecompHashcodeReader;

use Racoco::UtilExtProc;

role PrecompHashcodeReader is export {
  method read(IO() :$path --> Str) { ... }
}

class PrecompHashcodeReaderReal does PrecompHashcodeReader is export {
  method read(IO() :$path --> Str) {
    my $h = $path.open :r;
    LEAVE { .close with $h }
    $h.get
  }
}