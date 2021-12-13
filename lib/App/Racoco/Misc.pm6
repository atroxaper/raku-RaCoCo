unit module App::Racoco::Misc;

our sub percent(Int $numerator, Int $denominator --> Rat) is export {
	return 100.Rat if $denominator == 0;
	min 100.Rat, (($numerator / $denominator) * 100 * 10).Int / 10;
}