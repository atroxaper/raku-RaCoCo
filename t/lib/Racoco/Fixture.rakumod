unit module Racoco::Fixture;

my @tmp-files;
my @tmp-dirs;

our sub create-tmp-file(IO() $path) {
  register-tmp-file($path);
  $path.spurt: '';
}

our sub create-tmp-dir(IO() $path) {
  register-tmp-dir($path);
  $path.mkdir;
}

our sub register-tmp-file(IO() $path) {
  @tmp-files.push: $path;
}

our sub register-tmp-dir(IO() $path) {
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
    $path.rmdir;
    CATCH {
      default {
        $*ERR.say("Error while rmdir dir $path ", .^name, ': ',.Str)
      }
    }
  }
  @tmp-files = [];
  @tmp-dirs = [];
}