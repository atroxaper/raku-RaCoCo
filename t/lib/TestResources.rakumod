unit module TestResources;

use App::Racoco::ModuleNames;
use TmpDir;
use Fixture;

our sub test-directory() {
  't-resources/'.IO.add((callframe(4).file.IO.extension: '').basename).absolute.IO
}

our sub subtest-directory($subtest) {
  test-directory().add($subtest)
}

our sub exam-directory() {
  't-resources/'.IO.add('exam').absolute.IO;
}

our sub prepare($subtest --> IO::Path) {
  my $exam-directory = exam-directory();
  TmpDir::rmdir($exam-directory);
  TmpDir::create-dir($exam-directory);
  copy-content(from => subtest-directory($subtest), to => $exam-directory);
}

sub copy-content(:$from, :$to is copy) {
  $to = make-dir($to);
  for $from.dir() -> $ls-from {
    my $ls-to = $to.add($ls-from.basename);
    if $ls-from.d {
      copy-content(from => $ls-from, to => $ls-to);
    } else {
      copy-file(from => $ls-from, to => $ls-to);
    }
  }
}

sub make-dir($create is copy) {
  return $create if $create ~~ :d & :e;
  $create = fix-name($create);
  $create.mkdir;
  $create
}

sub copy-file(:$from, :$to is copy) {
  $to = fix-name($to);
  $from.copy($to);
}

sub fix-name(IO::Path $path --> IO::Path) {
  my $basename = $path.basename;
  if $basename.starts-with('_') {
    return $path.parent.add('.' ~ $basename.substr(1));
  } elsif $basename eq 'current_compiler_id' {
    return $path.parent.add(Fixture::compiler-id());
  } elsif $basename.starts-with('precomp_') {
    my ($lib, $module-name) = $basename.split('_')[1, 2];
    $module-name .= subst('::', '/', :g);
    $lib = exam-directory().add($lib);
    my $precomp-path = file-precomp-path(:$lib, path => $module-name);
    try $path.parent.add($precomp-path.parent).mkdir;
    return $path.parent.add($precomp-path);
  }
  return $path;
}