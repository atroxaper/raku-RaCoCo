unit module App::Racoco::Coverable::Coverable;

class Coverable is export {
	has Str $.file-name;
  has Instant $.timestamp;
  has Str $.hashcode;
  has @.lines;

  method Str() {
    "Coverable($!file-name)[{$!timestamp.to-posix[0]}]{$!hashcode}: @!lines[]"
  }
}