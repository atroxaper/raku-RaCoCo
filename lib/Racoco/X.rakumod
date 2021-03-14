unit module Racoco::X;

class WrongLibPath is Exception {
  has $.path;

  method message() { "Library path ｢$!path｣ doest not exists." }
}

class WrongRakuBinDirPath is Exception {
  has $.path;

  method message() { "Raku bin dir ｢$!path｣ is wrong." }
}

class AmbiguousPrecompContent is Exception {
  has $.path;

  method message() { "Library path ｢$!path｣ has ambiguous .precomp folder with "
    ~ 'more than one CompUnit Repository' }
}