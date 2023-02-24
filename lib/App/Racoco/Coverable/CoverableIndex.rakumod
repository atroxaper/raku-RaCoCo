unit module App::Racoco::Coverable::CoverableIndex;

use App::Racoco::Paths;
use App::Racoco::Coverable::Coverable;

role CoverableIndex is export {
  method put(Coverable :$coverable) { ... }
	method retrieve(Str :$file-name --> Coverable) { ... }
}

class CoverableIndexFile does CoverableIndex is export {
	has IO::Path $!index-path;
  has Coverable %!coverables;

  submethod BUILD(Paths :$paths!) {
    $!index-path = $paths.index-path;
    %!coverables = self!read-index();
  }

  method !read-index(--> Associative) {
    return %{} unless $!index-path.e;
    $!index-path.lines.map(-> $l {
      my ($file-name, $timestamp, $hashcode, $lines) =
        $l.split('|').map(*.trim).List;

      my $coverable = Coverable.new(
      	:$file-name,
        :timestamp(self!parse-timestamp($timestamp)),
      	:hashcode($hashcode // ''),
        :lines(self!parse-lines($lines))
      );

      $coverable.timestamp && $coverable.hashcode
        ?? $coverable !! Nil
    })
    .grep(*.so).map({ $_.file-name => $_ }).Hash;
  }

  method !parse-lines($lines --> Positional) {
    ($lines // '').trim.split(' ').grep(*.so).map(*.Int).sort.List
  }

  method !parse-timestamp($timestamp --> Instant) {
    try Instant.from-posix($timestamp);
  }

  method retrieve(Str :$file-name --> Coverable) {
    %!coverables{$file-name} // Nil
  }

  method put(Coverable :$coverable) {
    %!coverables{$coverable.file-name} = $coverable;
    self!flush()
  }

  method !flush() {
  	my $content = %!coverables
			.sort
			.map(*.value)
			.map({ self!serialize-coverage($_) })
			.map(*.trim)
			.join("\n");
		$!index-path.spurt: $content;
  }

  method !serialize-coverage($coverable --> Str) {
    with $coverable -> $c {
      ($c.file-name, $c.timestamp.to-posix[0], $c.hashcode, $c.lines.Str)
        .join(' | ');
    }
  }
}