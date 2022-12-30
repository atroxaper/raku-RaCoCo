unit module App::Racoco::X;

class WrongPath is Exception {
  has $.path;

  method message() { "$.path-name path ｢$!path｣ does not exists." }

  method backtrace() { '' }
  method path-name() { ... }
}

class WrongRootPath is WrongPath {
  method path-name() { 'Project root' }
}

class WrongLibPath is WrongPath {
  method path-name() { 'Library' }
}

class WrongRacocoPath is WrongPath {
  method path-name() { '.racoco parent' }
}

class WrongRakuBinDirPath is WrongPath {
  method path-name() { 'Raku bin dir' }
}

class CannotReadReport is Exception is export {
  has $.path;

  method message() { "Cannot find report file for library path ｢$!path｣." }
  method backtrace() { '' }
}

class NonZeroExitCode is Exception {
  has $.exitcode
}
