unit module App::Racoco::X;

class WrongLibPath is Exception {
  has $.path;

  method message() { "Library path ｢$!path｣ does not exists." }
  method backtrace() { '' }
}

class WrongRakuBinDirPath is Exception {
  has $.path;

  method message() { "Raku bin dir ｢$!path｣ is wrong." }
  method backtrace() { '' }
}

class AmbiguousPrecompContent is Exception {
  has $.path;

  method message() {
    "Library path ｢$!path｣ has ambiguous .precomp directory with more than one " ~
    'CompUnit Repository. Please, make sure you have only the one directory ' ~
    'in the <library>/.precomp path or use --fix-compunit flag for the next ' ~
    'RaCoCo launch to erase .precomp directory automatically.' }
  method backtrace() { '' }
}

class CannotReadReport is Exception {
  has $.path;

  method message() { "Cannot find report file for library path ｢$!path｣." }
  method backtrace() { '' }
}

class NonZeroExitCode is Exception {
  has $.exitcode
}