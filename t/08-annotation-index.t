use Test;
use lib 'lib';
use lib 't/lib';
use Racoco::Annotation;
use Racoco::Constants;
use Racoco::Fixture;

plan 6;

my $root = 't-resources'.IO.add('root-folder');
my $index-path = $root.add(DOT-RACOCO).add(INDEX);
my $lib = $root.add('lib');

my $index-content = $index-path.slurp;
END { $index-path.spurt: $index-content }

my $index = IndexFile.new(:$lib);

{
  my ($mod, $empty-lines) = (
    Fixture::anno('Module.rakumod', 1485726595, 'hashcode', 47, 49, 50),
    Fixture::anno('empty-lines', 1485726595.3, 'hashcode')
  );

  is $index.get($mod.file), $mod, 'index get ok';
  is $index.get($empty-lines.file), $empty-lines, 'empty-lines ok';

  nok $index.get('bad-timestamp'), 'bad-timestamp ok';
  nok $index.get('no-hashcode'), 'no-hashcode ok';
}

{
  my ($first, $last, $rewrite-hash) = (
    Fixture::anno('AFirst.rakumod', 1485726596, 'hash', 1, 2),
    Fixture::anno('xLast.rakumod', 1485726596, 'hash', 3, 2, 1),
    Fixture::anno('Module.rakumod', 1485726595, 'rewrite', 47, 49, 50),
  );
  $index.add($last);
  $index.add($first);
  $index.add($rewrite-hash);
  $index.flush;

  is $index-path.slurp, q:to/END/, 'flush ok';
    AFirst.rakumod | 1485726596 | hash | 1 2
    Module.rakumod | 1485726595 | rewrite | 47 49 50
    empty-lines | 1485726595.3 | hashcode |
    xLast.rakumod | 1485726596 | hash | 3 2 1
    END
}

{
  lives-ok { IndexFile.new(:lib($*TMPDIR)) }, 'index without index file'
}

done-testing