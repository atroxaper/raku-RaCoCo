unit module Racoco::UtilTmpFile;

my @tmp-files;
my @tmp-dirs;

our sub create-file(IO() $path --> IO::Path:D) {
  register-file($path);
  $path.spurt: '';
  $path
}

our sub create-dir(IO() $path --> IO::Path:D) {
  register-dir($path);
  $path.mkdir;
  $path
}

our sub register-file(IO() $path --> IO::Path:D) {
  @tmp-files.push: $path;
  $path
}

our sub register-dir(IO() $path --> IO::Path:D) {
  @tmp-dirs.push: $path;
  $path
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
  return unless $path ~~ :d & :e;
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
