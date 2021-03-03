unit module Racoco::Coverable::CoverableOutliner;

use Racoco::RunProc;

role CoverableOutliner is export {
	method outline(IO::Path :$path --> Positional) { ... }
}

class CoverableOutlinerReal does CoverableOutliner is export {
	has RunProc $.proc;
  has Str $.moar;

  method outline(IO::Path :$path --> Positional) {
    my $proc = $!proc.run("$!moar --dump $path", :out);
    LEAVE { $proc.out.close if $proc && $proc.out }
    return () if $proc.exitcode;
    self!parse-dump($proc.out)
  }

  method !parse-dump($h) {
  	$h.lines
      .grep(*.starts-with: '     annotation:')
      .map(*.split(':')[*-1].Int)
      .unique
      .sort
      .List
  }
}