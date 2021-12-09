use Test;
use lib 'lib';
use lib 't/lib';
use App::Racoco::Coverable::Coverable;
use App::Racoco::Coverable::CoverableIndex;
use App::Racoco::Paths;
use App::Racoco::Fixture;
use App::Racoco::TmpDir;
use TestResources;

plan 2;

sub cover(Str $file-name, Str() $time, Str $hashcode, *@lines) {
  Coverable.new(
  	:$file-name, :timestamp(Instant.from-posix($time)), :$hashcode, :@lines)
}

my ($lib, $index, $subtest);
sub setup($lib-name, :$subtest, :$plan!) {
	plan $plan;
	TestResources::prepare($subtest);
	$lib = TestResources::exam-directory.add($lib-name);
	$index = CoverableIndexFile.new(:$lib);
}

$subtest = '01-retrieve-from-index';
subtest $subtest, {
	setup('lib', :$subtest, :4plan);
  my $module-c = cover('Module.rakumod', 1485726595, 'hashcode', 47, 49, 50);
  my $empty-c = cover('Empty.rakumod', 1485726595.3, 'hashcode');
  is $index.retrieve(file-name => $module-c.file-name), $module-c, 'index get ok';
  is $index.retrieve(file-name => $empty-c.file-name), $empty-c, 'empty get ok';
  nok $index.retrieve(file-name => 'BadTimestamp.rakumod'), 'bad-timestamp ok';
  nok $index.retrieve(file-name => 'NoHashcode.rakumod'), 'no-hashcode ok';
}

$subtest = '02-put-new-and-repair';
subtest $subtest, {
	setup('lib', :$subtest, :1plan);

	my $first-c = cover('Average.rakumod', 1485726596, 'hash', 1, 2);
	my $last-c = cover('Zorro.rakumod', 1485726596, 'hash', 3, 2, 1),
	my $update-c = cover('Module.rakumod', 1485726595, 'updated', 7, 9, 15),
  $index.put(coverable => $last-c);
  $index.put(coverable => $first-c);
  $index.put(coverable => $update-c);

  is index-path(:$lib).slurp, q:to/END/.trim, 'flush ok';
    Average.rakumod | 1485726596 | hash | 1 2
    Empty.rakumod | 1485726595.3 | hashcode |
    Module.rakumod | 1485726595 | updated | 7 9 15
    Zorro.rakumod | 1485726596 | hash | 3 2 1
    END
}




#Fixture::restore-root-folder();
#
#my $sources = Fixture::root-folder();
#my $lib = $sources.add('lib');
#my $index-path = index-path(:$lib);
#
#my $index-content = $index-path.slurp;
#END { $index-path.spurt: $index-content }
#
#sub cover(Str $file-name, Str() $time, Str $hashcode, *@lines) {
#  Coverable.new(
#  	:$file-name, :timestamp(Instant.from-posix($time)), :$hashcode, :@lines)
#}
#
#my $index = CoverableIndexFile.new(:$lib);
#
#{
#  my ($first, $last, $rewrite-hash) = (
#    cover('AFirst.rakumod', 1485726596, 'hash', 1, 2),
#    cover('xLast.rakumod', 1485726596, 'hash', 3, 2, 1),
#    cover('Module.rakumod', 1485726595, 'rewrite', 47, 49, 50),
#  );
#  $index.put(coverable => $last);
#  $index.put(coverable => $first);
#  $index.put(coverable => $rewrite-hash);
#
#  is $index-path.slurp, q:to/END/.trim, 'flush ok';
#    AFirst.rakumod | 1485726596 | hash | 1 2
#    Module.rakumod | 1485726595 | rewrite | 47 49 50
#    empty-lines | 1485726595.3 | hashcode |
#    xLast.rakumod | 1485726596 | hash | 3 2 1
#    END
#}
#
#{
#  my $lib = TmpDir::create-tmp-dir('lib');
#  lives-ok { CoverableIndexFile.new(:$lib) }, 'without index file'
#}

done-testing