use Test;
use lib 'lib';
use Racoco::Annotation;
use Racoco::Constants;

plan 5;

my $root = 't'.IO.add('resources').add('root-folder');
my $index-path = $root.add($DOT-RACOCO).add($INDEX);
my $lib = $root.add('lib1');

my $index-content = $index-path.slurp;
END { $index-path.spurt: $index-content }

my $index = Index.new(:$lib);

{
  my $timestamp = Instant.from-posix('1485726595');
  my $timestamp2 = Instant.from-posix('1485726595.3');
  my $module = Annotation.new(:file<Module.rakumod>, :hashcode<hashcode>,
    :$timestamp, :lines(47, 49, 50));
  my $empty-lines = Annotation.new(:file<empty-lines>, :hashcode<hashcode>,
    :timestamp($timestamp2), :lines(()));

  is $index.get('Module.rakumod'), $module, 'index get ok';
  is $index.get('empty-lines'), $empty-lines, 'empty-lines ok';
  nok $index.get('bad-timestamp'), 'bad-timestamp ok';
  nok $index.get('no-hashcode'), 'no-hashcode ok';
}

{
  my $timestamp = Instant.from-posix('1485726596');
  my $first = Annotation.new(
    :file<AFirst.rakumod>, :$timestamp, :hashcode<hash>, :lines(1, 2));
  my $last = Annotation.new( # the new at the tail ot the list
    :file<xLast.rakumod>, :$timestamp, :hashcode<hash>, :lines(3, 2, 1));
  my $rewrite-hash = Annotation.new(:file<Module.rakumod>, :hashcode<rewrite>,
    :timestamp(Instant.from-posix('1485726595')),
    :lines(47, 49, 50));
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

done-testing