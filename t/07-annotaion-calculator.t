use Test;
use lib 'lib';
use lib 't/lib';
use Racoco::Annotation;
use Racoco::Constants;

plan 3;

my $source = 't'.IO.absolute.IO.add('resources').add('root-folder');
my $racoco = $source.add($DOT-RACOCO);
my $lib = $source.add('lib1');
my $now = now;

my $calc = AnnotationCalculator.new(:$lib);

my $annotation = $calc.calc('Module.rakumod');
isa-ok $annotation, Annotation, 'calc annotation';
is $annotation.file, 'Module.rakumod', 'annotation file ok';
ok $annotation.timestamp >= $now, 'annotation timestamp ok';
#is $annotation.lines, (47, 49, 50), 'annotation lines ok';

done-testing