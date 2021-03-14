unit module App::Racoco::X;

class WrongLibPath is Exception {
  has $.path;

  method message() { "Library path ｢$!path｣ doest not exists." }
  method backtrace() { '' }
}

class WrongRakuBinDirPath is Exception {
  has $.path;

  method message() { "Raku bin dir ｢$!path｣ is wrong." }
  method backtrace() { '' }
}

class AmbiguousPrecompContent is Exception {
  has $.path;

  method message() { "Library path ｢$!path｣ has ambiguous .precomp folder with "
    ~ 'more than one CompUnit Repository' }
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