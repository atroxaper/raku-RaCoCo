unit class DataPart;

#| Bag like: line-number => covered-times.
#| The bag contains $!purple-lines.
has Bag $!data;
#| Same bag like $!data, but only for lines,
#| which is not coverable, but covered.
has Bag $!purple-lines;

method read(Str $str --> DataPart) {
	$str.split('|');
	DataPart.new;
}