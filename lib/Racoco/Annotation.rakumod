unit module Racoco::Annotation;

use Racoco::PrecompFile;

class Annotation is export {
  has $.file;
  has $.timestamp = now;
  has $.hashcode;
  has @.lines;
}

class Dumper is export {
  has $.proc;
  has $.moar;

  method dump($file) {
    my @args = "$!moar", "--dump", $file.Str;
    my $proc = $!proc.run(|@args, :out);
    if $proc.exitcode != 0 {
      $*ERR.say: "Fail dump. Executed: ", @args;
      return Nil;
    }
    $proc.out.lines
      .grep(*.starts-with: '     annotation:')
      .map(*.split(':')[*-1].Int)
      .unique
      .sort
      .List
  }
}

class Index {
}

class Calculator is export {
  has $.provider;

  method calc($path) {
    Annotation.new(:file($path))
  }
}