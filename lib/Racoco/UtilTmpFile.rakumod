unit module Racoco::UtilTmpFile;

my @tmp-files;
my @tmp-dirs;

our sub create-file(IO() $path) {
  register-file($path);
  $path.spurt: '';
}

our sub create-dir(IO() $path) {
  register-dir($path);
  $path.mkdir;
}

our sub register-file(IO() $path) {
  @tmp-files.push: $path;
}

our sub register-dir(IO() $path) {
  @tmp-dirs.push: $path;
}

our sub clean-up() {
  for @tmp-files.reverse -> $path {
    $path.unlink;
    CATCH {
      default {
        $*ERR.say("Error while unlink file $path ", .^name, ': ',.Str)
      }
    }
  }
  for @tmp-dirs.reverse -> $path {
    rmdir($path)
  }
  @tmp-files = [];
  @tmp-dirs = [];
}

sub rmdir($path) {
  for $path.dir() -> $sub-path {
    rmdir($sub-path) if $sub-path.d;
    $sub-path.unlink;
  }
  $path.rmdir;
  CATCH {
    default {
      $*ERR.say("Error while rmdir dir $path ", .^name, ': ',.Str)
    }
  }
}
