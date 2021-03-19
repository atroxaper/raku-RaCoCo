use Test;
use lib 'lib';
use lib 't/lib';
use App::Racoco::Coverable::Coverable;
use App::Racoco::Coverable::CoverableIndex;
use App::Racoco::Paths;
use App::Racoco::Fixture;
use App::Racoco::TmpDir;

plan 6;

my $sources = Fixture::root-folder();
my $lib = $sources.add('lib');
my $index-path = index-path(:$lib);

my $index-content = $index-path.slurp;
END { $index-path.spurt: $index-content }

sub cover(Str $file-name, Str() $time, Str $hashcode, *@lines) {
  Coverable.new(
  	:$file-name, :timestamp(Instant.from-posix($time)), :$hashcode, :@lines)
}

my $index = CoverableIndexFile.new(:$lib);

{
  my ($module, $empty-lines) = (
    cover('Module.rakumod', 1485726595, 'hashcode', 47, 49, 50),
    cover('empty-lines', 1485726595.3, 'hashcode')
  );

  is $index.retrieve(file-name => $module.file-name), $module, 'index get ok';
  is $index.retrieve(file-name => $empty-lines.file-name), $empty-lines,
  	'empty-lines ok';

  nok $index.retrieve(file-name => 'bad-timestamp'), 'bad-timestamp ok';
  nok $index.retrieve(file-name => 'no-hashcode'), 'no-hashcode ok';
}

{
  my ($first, $last, $rewrite-hash) = (
    cover('AFirst.rakumod', 1485726596, 'hash', 1, 2),
    cover('xLast.rakumod', 1485726596, 'hash', 3, 2, 1),
    cover('Module.rakumod', 1485726595, 'rewrite', 47, 49, 50),
  );
  $index.put(coverable => $last);
  $index.put(coverable => $first);
  $index.put(coverable => $rewrite-hash);

  is $index-path.slurp, q:to/END/.trim, 'flush ok';
    AFirst.rakumod | 1485726596 | hash | 1 2
    Module.rakumod | 1485726595 | rewrite | 47 49 50
    empty-lines | 1485726595.3 | hashcode |
    xLast.rakumod | 1485726596 | hash | 3 2 1
    END
}

{
  my $lib = TmpDir::create-tmp-dir('lib');
  lives-ok { CoverableIndexFile.new(:$lib) }, 'without index file'
}

done-testing