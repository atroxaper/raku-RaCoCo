unit module TmpDir;

my @tmp-dirs;

our sub create-tmp-dir($name --> IO::Path:D) {
  mkdir register-dir($*TMPDIR.add($name))
}

our sub create-tmp-lib($name) {
	my $dir = create-tmp-dir($name);
	my $lib = create-dir($dir.add('lib'));
	$dir, $lib
}

our sub create-dir(IO() $path --> IO::Path:D) {
  mkdir register-dir($path)
}

our sub register-dir(IO() $path --> IO::Path:D) {
  @tmp-dirs.push: $path;
  $path
}

our sub clean-up() {
  for @tmp-dirs.reverse -> $path {
    rmdir($path)
  }
  @tmp-dirs = [];
}

our sub rmdir($path) {
  return unless $path ~~ :d & :e;
  for $path.dir() -> $sub-path {
    rmdir($sub-path) if $sub-path.d;
    $sub-path.unlink;
  }
  $path.rmdir;
  CATCH {
    default {
      $*ERR.say("Error while rmdir dir $path ", .^name, ': ',.Str);
      iter-and($path, -> $p { note "d: ", $p.d, ' ', $p });
    }
  }
}

sub iter-and($path, &do) {
  for $path.dir -> $p {
    do($p);
    if $p.d {
      iter-and($p, &do);
    }
  }
}

END { clean-up }
