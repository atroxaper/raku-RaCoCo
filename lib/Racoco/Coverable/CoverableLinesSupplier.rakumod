unit module Racoco::Coverable::CoverableLinesSupplier;

use Racoco::Precomp::PrecompSupplier;
use Racoco::Precomp::PrecompHashcodeReader;
use Racoco::Coverable::CoverableIndex;
use Racoco::Coverable::Coverable;
use Racoco::Coverable::CoverableOutliner;

class CoverableLinesSupplier is export {
	has PrecompSupplier $.supplier;
  has CoverableIndex $.index;
  has CoverableOutliner $.outliner;
  has PrecompHashcodeReader $.hashcode-reader;

  method supply(Str :$file-name) {
    my $precomp-path = $!supplier.supply(:$file-name);
		return () unless $precomp-path;
    my $coverable = $!index.retrieve(:$file-name);
    unless self!is-coverable-actual($coverable, $precomp-path) {
			$coverable = self!calc-coverable($file-name, $precomp-path);
    	$!index.put(:$coverable);
    }
    $coverable.lines
  }

  method !is-coverable-actual($coverable, $precomp-path) {
    $coverable && $precomp-path &&
    $coverable.timestamp >= $precomp-path.modified &&
    $coverable.hashcode eq $!hashcode-reader.read(path => $precomp-path)
  }

  method !calc-coverable($file-name, $precomp-path) {
  	Coverable.new(
    	:$file-name,
    	timestamp => $precomp-path.modified,
    	hashcode => $!hashcode-reader.read(path => $precomp-path),
    	lines => $!outliner.outline(path => $precomp-path)
    )
  }
}