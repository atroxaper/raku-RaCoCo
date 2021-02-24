unit module Racoco::Annotation;

use Racoco::PrecompFile;
use Racoco::Constants;

class Annotation is export {
  has $.file;
  has $.timestamp = now;
  has $.hashcode;
  has @.lines;

  method Str() {
    "Annotation($!file)[{$!timestamp.to-posix[0]}]{$!hashcode}: @!lines[]"
  }
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
      .eager
      .List
  }
}

class Index is export {
  has $.path;
  has %!annotations;

  submethod TWEAK(:$lib) {
    $!path = $lib.parent.add($DOT-RACOCO).add($INDEX);
    %!annotations = self!read-index();
  }

  method !read-index() {
    return unless $!path.e;
    $!path.lines.map(-> $l {
      my ($file, $timestamp, $hashcode, $lines) =
        $l.split('|').map(*.trim).List;

      my $annotation = Annotation.new(:$file, :$hashcode,
        :timestamp(self!parse-timestamp($timestamp)),
        :lines(self!parse-lines($lines))
      );

      $annotation.timestamp && $annotation.hashcode
        ?? $annotation !! Annotation
    })
    .grep(*.so).map(-> $a { $a.file => $a }).eager.Map;
  }

  method !parse-lines($lines is copy) {
    $lines //= '';
    $lines .= trim;
    $lines.split(' ').grep(*.so).map(*.Int).eager.sort.List
  }

  method !parse-timestamp($timestamp is copy) {
    $timestamp .= trim;
    my $result;
    try $result = Instant.from-posix($timestamp);
    return $result;
  }

  method get($path) {
    %!annotations{$path.Str}
  }

  method add($annotation) {
    %!annotations{$annotation.file} = $annotation
  }

  method flush() {
    my $h = $!path.open(:w);
    LEAVE { .close with $h }
    %!annotations.sort.map(*.value)
      .map(-> $a { self!serialize-annotation($a)})
      .map(-> $s { $h.say($s.trim)});
    Nil
  }

  method !serialize-annotation($annotation) {
    with $annotation -> $a {
      ($a.file, $a.timestamp.to-posix[0], $a.hashcode, $a.lines.Str)
        .join(' | ');
    }
  }
}

class Calculator is export {
  has $.provider;

  method calc($path) {
    Annotation.new(:file($path))
  }
}